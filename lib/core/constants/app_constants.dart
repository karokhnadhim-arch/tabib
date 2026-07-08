/// Global app constants for Tabib.
class AppConstants {
  AppConstants._();

  static const String appName = 'Tabib';
  static const String appTaglineKu = 'پلاتفۆرمی نۆرینگەی پزیشکی';
  static const Duration splashDuration = Duration(seconds: 2);
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  /// Side navigation + multi-pane clinical workspace.
  static const double clinicalDesktopBreakpoint = 880;
  /// Doctor 3-pane: queue | consultation | patient summary.
  static const double threePaneBreakpoint = 1280;
  /// Clinical side navigation rail width.
  static const double clinicalNavWidth = 72;
  static const double clinicalNavExtendedWidth = 240;
}
