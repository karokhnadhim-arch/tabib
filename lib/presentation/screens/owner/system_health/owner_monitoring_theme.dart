import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/owner_dashboard_appearance_service.dart';
import 'owner_dashboard_ui.dart';

/// Applies owner dashboard accent, typography, and enterprise Material 3 chrome.
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
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: isDark ? const Color(0xFF121318) : const Color(0xFFF6F8FB),
      surfaceContainerLowest:
          isDark ? const Color(0xFF0E1014) : const Color(0xFFEEF2F7),
      surfaceContainerLow:
          isDark ? const Color(0xFF1A1D24) : const Color(0xFFF3F6FA),
      surfaceContainer:
          isDark ? const Color(0xFF22262F) : const Color(0xFFE8EDF4),
    );

    final textTheme = (isDark ? AppTheme.dark() : AppTheme.light()).textTheme
        .copyWith(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.45,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: scheme.onSurfaceVariant,
      ),
    );

    final themed = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: scheme.surface,
        shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: OwnerDashboardTokens.cardShape,
          side: BorderSide(
            color: scheme.outlineVariant.withOpacity(isDark ? 0.35 : 0.5),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.45),
        space: 24,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
        labelStyle: textTheme.labelLarge,
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(scheme.surface),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: OwnerDashboardTokens.cardShape,
            side: BorderSide(color: scheme.outlineVariant.withOpacity(0.55)),
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: OwnerDashboardTokens.cardShape,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: OwnerDashboardTokens.cardShape,
          borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.6)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      iconTheme: IconThemeData(color: scheme.primary, size: 22),
    );

    return Theme(data: themed, child: child);
  }
}
