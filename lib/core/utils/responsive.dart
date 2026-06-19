import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

enum ScreenSize { mobile, tablet, desktop }

ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= AppConstants.tabletBreakpoint) return ScreenSize.desktop;
  if (width >= AppConstants.mobileBreakpoint) return ScreenSize.tablet;
  return ScreenSize.mobile;
}

double responsivePadding(BuildContext context) {
  switch (screenSizeOf(context)) {
    case ScreenSize.desktop:
      return 32;
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
