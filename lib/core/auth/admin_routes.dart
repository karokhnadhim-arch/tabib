/// Admin route helpers for go_router guards.
class AdminRoutes {
  AdminRoutes._();

  static const platformPrefix = '/doctor/platform';

  static bool isAdminRoute(String path) => path.startsWith(platformPrefix);
}
