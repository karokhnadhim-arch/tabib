import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/auth_service.dart';
import '../../../services/staff_data_service.dart';
import '../../../utils/localization_utils.dart';

enum OwnerStaffFilter { doctors, secretaries, all }

class OwnerStaffListScreen extends StatelessWidget {
  const OwnerStaffListScreen({super.key, required this.filter});

  final OwnerStaffFilter filter;

  String _title(AppLocalizations l10n) {
    switch (filter) {
      case OwnerStaffFilter.doctors:
        return l10n.viewAllDoctors;
      case OwnerStaffFilter.secretaries:
        return l10n.viewAllSecretaries;
      case OwnerStaffFilter.all:
        return l10n.manageStaff;
    }
  }

  String _roleLabel(AppLocalizations l10n, UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return l10n.roleDoctor;
      case UserRole.secretary:
        return l10n.roleSecretary;
      case UserRole.patient:
        return l10n.patientApp;
      case UserRole.admin:
        return l10n.roleAdmin;
    }
  }

  List<UserAccount> _filterStaff(List<UserAccount> staff) {
    switch (filter) {
      case OwnerStaffFilter.doctors:
        return staff
            .where((s) => s.role == UserRole.doctor || s.role == UserRole.admin)
            .toList();
      case OwnerStaffFilter.secretaries:
        return staff.where((s) => s.role == UserRole.secretary).toList();
      case OwnerStaffFilter.all:
        return staff;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canViewAllStaff(auth)) {
      return const SizedBox.shrink();
    }

    final staffData = context.watch<StaffDataService>();
    final staff = _filterStaff(staffData.staff);

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title(l10n)),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: staff.isEmpty
            ? Center(child: Text(l10n.noStaffAccounts))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: staff.length,
                itemBuilder: (context, i) {
                  final user = staff[i];
                  return Card(
                    child: ListTile(
                    leading: Icon(
                      user.role == UserRole.secretary
                          ? Icons.badge_outlined
                          : Icons.medical_services_outlined,
                      color: user.isActive
                          ? AppTheme.primaryDark
                          : Colors.grey,
                    ),
                      title: Text(user.name.localized(context)),
                      subtitle: Text(
                        [
                          _roleLabel(l10n, user.role),
                          if (user.email != null) user.email!,
                          user.isActive
                              ? l10n.accountActive
                              : l10n.accountInactive,
                        ].join(' · '),
                      ),
                      isThreeLine: true,
                      trailing: user.isSystemOwner
                          ? Chip(
                              label: Text(l10n.systemOwner),
                              backgroundColor:
                                  AppTheme.medicalGreen.withOpacity(0.15),
                            )
                          : Switch(
                              value: user.isActive,
                              onChanged: (active) async {
                                final err = await auth.setStaffActive(
                                  user.id,
                                  active,
                                );
                                if (err != null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.errorGeneric),
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
