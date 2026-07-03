import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_permissions.dart';
import '../../l10n/app_localizations.dart';
import '../../models/account_status.dart';
import '../../models/user_account.dart';
import '../../presentation/widgets/account_status_badge.dart';
import '../../services/auth_service.dart';
import '../../utils/account_status_labels.dart';
import 'admin_reset_password_dialog.dart';
import 'admin_secretary_form_dialog.dart';
import 'admin_transfer_secretary_dialog.dart';

/// Shared secretary management actions for the System Owner console.
abstract final class OwnerSecretaryActions {
  OwnerSecretaryActions._();

  static Future<void> confirmDelete(
    BuildContext context,
    UserAccount secretary,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSecretary),
        content: Text(l10n.deleteSecretaryConfirm),
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

    final err = await context
        .read<AuthService>()
        .deleteSecretaryAccount(secretary.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? l10n.deletedSuccessfully : l10n.errorGeneric,
        ),
      ),
    );
  }

  static Future<void> pickStatus(
    BuildContext context,
    UserAccount secretary,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<AccountStatus>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AccountStatus.values.map((status) {
            return ListTile(
              leading: AccountStatusBadge(status: status, compact: true),
              title: Text(AccountStatusLabels.label(l10n, status)),
              selected: secretary.accountStatus == status,
              onTap: () => Navigator.pop(context, status),
            );
          }).toList(),
        ),
      ),
    );
    if (selected == null || selected == secretary.accountStatus) return;

    final err = await context.read<AuthService>().setAccountStatus(
          secretary.id,
          selected,
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  static Future<void> transfer(
    BuildContext context,
    UserAccount secretary,
    String currentDoctorId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await AdminTransferSecretaryDialog.show(
      context,
      secretary: secretary,
      currentDoctorId: currentDoctorId,
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transferredSuccessfully)),
      );
    }
  }

  static Future<void> edit(
    BuildContext context,
    UserAccount secretary,
    String doctorId,
  ) async {
    await AdminSecretaryFormDialog.show(
      context,
      doctorId: doctorId,
      secretary: secretary,
    );
  }

  static Future<void> resetPassword(
    BuildContext context,
    UserAccount secretary,
  ) async {
    await AdminResetPasswordDialog.show(context, secretary);
  }

  static List<PopupMenuEntry<String>> menuItems(
    BuildContext context,
    UserAccount secretary,
    String doctorId,
  ) {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    final canManage = AdminPermissions.canCreateSecretaries(auth);
    final canDelete = AdminPermissions.canDeleteAccounts(auth);
    final canReset = AdminPermissions.canResetPasswords(auth);
    final isActive = secretary.accountStatus == AccountStatus.active;

    return [
      if (canManage)
        PopupMenuItem(value: 'edit', child: Text(l10n.editSecretary)),
      if (canManage && !isActive)
        PopupMenuItem(value: 'enable', child: Text(l10n.enableAccount)),
      if (canManage && isActive)
        PopupMenuItem(value: 'disable', child: Text(l10n.disableAccount)),
      if (canManage)
        PopupMenuItem(
          value: 'status',
          child: Text(l10n.changeAccountStatus),
        ),
      if (canManage)
        PopupMenuItem(
          value: 'transfer',
          child: Text(l10n.transferSecretary),
        ),
      if (canReset)
        PopupMenuItem(value: 'reset', child: Text(l10n.resetPassword)),
      if (canDelete)
        PopupMenuItem(
          value: 'delete',
          child: Text(
            l10n.deleteSecretary,
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
    ];
  }

  static Future<void> handleMenuSelection(
    BuildContext context,
    String value,
    UserAccount secretary,
    String doctorId,
  ) async {
    switch (value) {
      case 'edit':
        await edit(context, secretary, doctorId);
      case 'enable':
        final err = await context.read<AuthService>().setAccountStatus(
              secretary.id,
              AccountStatus.active,
            );
        if (context.mounted && err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
          );
        }
      case 'disable':
        final err = await context.read<AuthService>().setAccountStatus(
              secretary.id,
              AccountStatus.disabled,
            );
        if (context.mounted && err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
          );
        }
      case 'status':
        await pickStatus(context, secretary);
      case 'transfer':
        await transfer(context, secretary, doctorId);
      case 'reset':
        await resetPassword(context, secretary);
      case 'delete':
        await confirmDelete(context, secretary);
    }
  }
}
