import '../../../core/constants/app_constants.dart';

/// Layout tokens for the doctor clinical workspace.
abstract final class DoctorWorkspaceConstants {
  static const double queuePanelWidth = 300;
  static const double summaryPanelWidth = 340;
  static const double panelGap = 12;
  static const double panelRadius = 16;
  static const double sectionSpacing = 16;
  static const double queueTileHeight = 72;

  static bool isThreePane(double width) =>
      width >= AppConstants.threePaneBreakpoint;

  static bool isWideTwoPane(double width) =>
      width >= 880 && width < AppConstants.threePaneBreakpoint;
}
