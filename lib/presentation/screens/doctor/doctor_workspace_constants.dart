import '../../../core/constants/app_constants.dart';

/// Layout tokens for the doctor clinical workspace.
abstract final class DoctorWorkspaceConstants {
  static const double queueSummaryPanelWidth = 170;
  static const double summaryPanelWidth = 280;
  static const double panelGap = 12;
  static const double panelRadius = 16;
  static const double sectionSpacing = 16;
  static const double queueTileHeight = 72;

  /// Desktop split: consultation center · queue + summary on the right.
  static const int queuePanelFlex = 2;
  static const int consultationPanelFlex = 3;

  static bool isDesktopConsultation(double width) => width >= 880;

  static bool isThreePane(double width) =>
      width >= AppConstants.threePaneBreakpoint;

  static bool isWideTwoPane(double width) =>
      width >= 880 && width < AppConstants.threePaneBreakpoint;
}
