import '../../services/auth_service.dart';
import 'data_access_policy.dart';

/// Role-based permissions for the hidden system owner admin panel.
class AdminPermissions {
  AdminPermissions._();

  static bool canAccessAdminPanel(AuthService auth) =>
      DataAccessPolicy.canAccessAdminPanel(auth.currentUser);

  static bool canCreateDoctors(AuthService auth) => auth.isSystemOwner;

  static bool canCreateSecretaries(AuthService auth) => auth.isSystemOwner;

  static bool canManageClinics(AuthService auth) => auth.isSystemOwner;

  static bool canCreateClinics(AuthService auth) => auth.isSystemOwner;

  static bool canViewAllStaff(AuthService auth) => auth.isSystemOwner;

  static bool canActivateAccounts(AuthService auth) => auth.isSystemOwner;

  static bool canManageSubscriptions(AuthService auth) => auth.isSystemOwner;

  static bool canViewStatistics(AuthService auth) => auth.isSystemOwner;
}
