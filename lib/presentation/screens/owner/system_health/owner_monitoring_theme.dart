import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/owner_dashboard_appearance_service.dart';

/// Applies owner dashboard accent and density without changing global app theme.
class OwnerMonitoringTheme extends StatelessWidget {
  const OwnerMonitoringTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<OwnerDashboardAppearanceService>();
    final base = Theme.of(context);
    final isDark = switch (appearance.dashboardThemeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => base.brightness == Brightness.dark,
    };

    final seed = appearance.accentColor;
    final themed = (isDark ? AppTheme.dark() : AppTheme.light()).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    return Theme(
      data: themed,
      child: child,
    );
  }
}
