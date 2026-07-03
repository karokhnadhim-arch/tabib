import '../../models/admin_capability.dart';
import '../../models/user_account.dart';
import '../../services/auth_service.dart';
import 'data_access_policy.dart';
import 'permission_policy.dart';

/// Role-based permissions for the platform admin panel.
class AdminPermissions {
  AdminPermissions._();

  static UserAccount? _user(AuthService auth) => auth.currentUser;

  static bool canAccessAdminPanel(AuthService auth) =>
      DataAccessPolicy.canAccessAdminPanel(auth.currentUser);

  static bool _has(AuthService auth, AdminCapability capability) =>
      PermissionPolicy.hasCapability(_user(auth), capability);

  static bool canCreateDoctors(AuthService auth) =>
      _has(auth, AdminCapability.manageDoctors);

  static bool canCreateBusinesses(AuthService auth) =>
      _has(auth, AdminCapability.manageBusinesses);

  static bool canCreateSecretaries(AuthService auth) =>
      _has(auth, AdminCapability.manageSecretaries);

  static bool canManageClinics(AuthService auth) =>
      _has(auth, AdminCapability.manageCategories) ||
      _has(auth, AdminCapability.manageDoctors);

  static bool canCreateClinics(AuthService auth) => canManageClinics(auth);

  static bool canViewAllStaff(AuthService auth) =>
      PermissionPolicy.hasAnyCapability(_user(auth), {
        AdminCapability.manageDoctors,
        AdminCapability.manageBusinesses,
        AdminCapability.manageSecretaries,
        AdminCapability.managePatients,
        AdminCapability.suspendAccounts,
        AdminCapability.deleteAccounts,
      });

  static bool canActivateAccounts(AuthService auth) =>
      _has(auth, AdminCapability.suspendAccounts);

  static bool canManageSubscriptions(AuthService auth) =>
      _has(auth, AdminCapability.manageSubscriptions);

  static bool canViewStatistics(AuthService auth) =>
      _has(auth, AdminCapability.viewReports) ||
      _has(auth, AdminCapability.viewAnalytics);

  static bool canManagePatients(AuthService auth) =>
      _has(auth, AdminCapability.managePatients);

  static bool canDeleteAccounts(AuthService auth) =>
      _has(auth, AdminCapability.deleteAccounts);

  static bool canResetPasswords(AuthService auth) =>
      _has(auth, AdminCapability.resetPasswords);

  static bool canSendNotifications(AuthService auth) =>
      _has(auth, AdminCapability.sendNotifications);

  static bool canManageAdmins(AuthService auth) =>
      PermissionPolicy.canManageAdminAccounts(_user(auth));
}
