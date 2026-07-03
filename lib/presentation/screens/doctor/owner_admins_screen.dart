import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/privacy/system_owner_privacy.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/admin_account_form_dialog.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/auth_service.dart';
import '../../../services/staff_data_service.dart';
import '../../../utils/admin_capability_labels.dart';
import '../../../utils/localization_utils.dart';

/// System Owner — manage delegated Admin accounts and permissions.
class OwnerAdminsScreen extends StatelessWidget {
  const OwnerAdminsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, UserAccount admin) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAdminAccount),
        content: Text(l10n.deleteAdminAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelQueue),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final err =
        await context.read<AuthService>().deleteAdminAccount(admin.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? l10n.deletedSuccessfully : l10n.errorGeneric,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canManageAdmins(auth)) {
      return const SizedBox.shrink();
    }

    final admins = SystemOwnerPrivacy.filterAdminRoster(
      context.watch<StaffDataService>().staffIncludingHidden,
    );

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.manageAdmins),
          backgroundColor: AppTheme.primaryDark,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async => AdminAccountFormDialog.show(context),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text(l10n.createAdminAccount),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: admins.isEmpty
            ? Center(child: Text(l10n.noAdminAccounts))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index];
                  final perms = admin.adminPermissions.capabilities.toList()
                    ..sort((a, b) => a.storageKey.compareTo(b.storageKey));
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      title: Text(admin.name.localized(context)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (admin.email != null) Text(admin.email!),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: perms
                                .map(
                                  (cap) => Chip(
                                    label: Text(
                                      AdminCapabilityLabels.label(l10n, cap),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await AdminAccountFormDialog.show(
                              context,
                              admin: admin,
                            );
                          } else if (value == 'delete') {
                            await _confirmDelete(context, admin);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l10n.edit),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
