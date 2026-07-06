import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

enum ScreenSize { mobile, tablet, desktop }

ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= AppConstants.tabletBreakpoint) return ScreenSize.desktop;
  if (width >= AppConstants.mobileBreakpoint) return ScreenSize.tablet;
  return ScreenSize.mobile;
}

/// Wide clinical workstation layout (doctor / secretary desktop).
bool isClinicalDesktop(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= AppConstants.clinicalDesktopBreakpoint;
}

/// Three-pane doctor workspace (queue | consultation | summary).
bool isThreePaneDoctorLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= AppConstants.threePaneBreakpoint;
}

/// True on Windows, macOS, Linux, or web on a wide viewport.
bool isDesktopPlatform(BuildContext context) {
  if (kIsWeb) return isClinicalDesktop(context);
  return switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.macOS ||
    TargetPlatform.linux =>
      true,
    _ => false,
  };
}

/// Prefer instant transitions on desktop clinical apps.
Duration clinicalPageTransitionDuration(BuildContext context) {
  return isDesktopPlatform(context)
      ? Duration.zero
      : const Duration(milliseconds: 300);
}

double responsivePadding(BuildContext context) {
  switch (screenSizeOf(context)) {
    case ScreenSize.desktop:
      return isClinicalDesktop(context) ? 20 : 32;
    case ScreenSize.tablet:
      return 24;
    case ScreenSize.mobile:
      return 16;
  }
}

int gridCrossAxisCount(BuildContext context, {int mobile = 2, int tablet = 3, int desktop = 4}) {
  switch (screenSizeOf(context)) {
    case ScreenSize.desktop:
      return desktop;
    case ScreenSize.tablet:
      return tablet;
    case ScreenSize.mobile:
      return mobile;
  }
}
