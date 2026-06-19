import 'package:flutter/material.dart';

/// Medical theme: blue, green, and white.
class AppTheme {
  AppTheme._();

  static const Color medicalBlue = Color(0xFF1E88E5);
  static const Color medicalBlueDark = Color(0xFF1565C0);
  static const Color medicalGreen = Color(0xFF2E7D32);
  static const Color medicalGreenLight = Color(0xFF43A047);
  static const Color medicalWhite = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Colors.white;

  // Role accents
  static const Color patientColor = medicalBlue;
  static const Color doctorColor = medicalGreen;
  static const Color secretaryColor = Color(0xFF00897B);

  // Legacy aliases used across the codebase
  static const Color primary = medicalGreen;
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = medicalGreenLight;
  static const Color staffColor = secretaryColor;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: medicalBlue,
      primary: medicalBlue,
      secondary: medicalGreen,
      surface: surfaceWhite,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: medicalWhite,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: medicalBlue,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: medicalBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: medicalGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: medicalBlue, width: 2),
        ),
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        indicatorColor: medicalBlue.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: medicalBlue, fontWeight: FontWeight.w600);
          }
          return TextStyle(color: Colors.grey.shade600);
        }),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
