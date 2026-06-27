import '../../services/auth_service.dart';

/// Role-based permissions for the hidden system owner admin panel.
class AdminPermissions {
  AdminPermissions._();

  static bool canAccessAdminPanel(AuthService auth) => auth.isSystemOwner;

  static bool canCreateDoctors(AuthService auth) => auth.isSystemOwner;

  static bool canCreateSecretaries(AuthService auth) => auth.isSystemOwner;

  static bool canManageClinics(AuthService auth) => auth.isSystemOwner;

  static bool canViewAllStaff(AuthService auth) => auth.isSystemOwner;

  static bool canActivateAccounts(AuthService auth) => auth.isSystemOwner;

  static bool canManageSubscriptions(AuthService auth) => auth.isSystemOwner;

  static bool canViewStatistics(AuthService auth) => auth.isSystemOwner;
}
