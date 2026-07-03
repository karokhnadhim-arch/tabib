import '../../l10n/app_localizations.dart';
import '../../models/admin_capability.dart';

abstract final class AdminCapabilityLabels {
  static String label(AppLocalizations l10n, AdminCapability capability) =>
      switch (capability) {
        AdminCapability.manageDoctors => l10n.permManageDoctors,
        AdminCapability.manageBusinesses => l10n.permManageBusinesses,
        AdminCapability.manageSecretaries => l10n.permManageSecretaries,
        AdminCapability.managePatients => l10n.permManagePatients,
        AdminCapability.manageSubscriptions => l10n.permManageSubscriptions,
        AdminCapability.viewReports => l10n.permViewReports,
        AdminCapability.sendNotifications => l10n.permSendNotifications,
        AdminCapability.resetPasswords => l10n.permResetPasswords,
        AdminCapability.suspendAccounts => l10n.permSuspendAccounts,
        AdminCapability.deleteAccounts => l10n.permDeleteAccounts,
        AdminCapability.manageCategories => l10n.permManageCategories,
        AdminCapability.viewAnalytics => l10n.permViewAnalytics,
        AdminCapability.createAdmins => l10n.permCreateAdmins,
        AdminCapability.manageAdmins => l10n.permManageAdmins,
      };

  static List<AdminCapability> assignableToAdmin() => AdminCapability.values
      .where((cap) => !cap.isOwnerOnly)
      .toList();
}
