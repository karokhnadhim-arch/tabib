/// Platform admin route helpers for go_router guards and navigation.
class AdminRoutes {
  AdminRoutes._();

  /// Super Owner platform console (multi-tenant control).
  static const superOwnerHome = '/super-owner';
  static const superOwnerPrefix = '/super-owner';

  /// System Owner home dashboard.
  static const ownerHome = '/owner';

  /// Delegated Admin console (permission-filtered modules).
  static const adminConsole = '/owner/console';

  /// Prefix for all platform management routes.
  static const platformPrefix = '/owner';

  static bool isAdminRoute(String path) =>
      path == ownerHome ||
      path.startsWith('$platformPrefix/');

  static bool isSuperOwnerRoute(String path) =>
      path == superOwnerHome || path.startsWith('$superOwnerPrefix/');

  static bool isOwnerHome(String path) =>
      path == ownerHome || path == adminConsole;
}
