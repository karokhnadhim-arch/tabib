import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/owner_monitoring_phase4.dart';

/// Owner dashboard appearance preferences — local only, does not affect other modules.
class OwnerDashboardAppearanceService extends ChangeNotifier {
  DashboardAccent _accent = DashboardAccent.blue;
  DashboardDensity _density = DashboardDensity.comfortable;
  DashboardLayout _layout = DashboardLayout.standard;
  ThemeMode _dashboardThemeMode = ThemeMode.system;

  DashboardAccent get accent => _accent;
  DashboardDensity get density => _density;
  DashboardLayout get layout => _layout;
  ThemeMode get dashboardThemeMode => _dashboardThemeMode;

  double get cardPadding => switch (_density) {
        DashboardDensity.compact => 8,
        DashboardDensity.comfortable => 16,
      };

  double get sectionSpacing => switch (_density) {
        DashboardDensity.compact => 8,
        DashboardDensity.comfortable => 16,
      };

  int get gridCrossAxisCountMultiplier => switch (_layout) {
        DashboardLayout.standard => 1,
        DashboardLayout.wide => 2,
        DashboardLayout.focused => 1,
      };

  Color get accentColor => switch (_accent) {
        DashboardAccent.blue => const Color(0xFF1E88E5),
        DashboardAccent.green => const Color(0xFF2E7D32),
        DashboardAccent.teal => const Color(0xFF00897B),
        DashboardAccent.purple => const Color(0xFF7B1FA2),
        DashboardAccent.orange => const Color(0xFFF57C00),
      };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _accent = DashboardAccent.values.byName(
      prefs.getString(_accentKey) ?? DashboardAccent.blue.name,
    );
    _density = DashboardDensity.values.byName(
      prefs.getString(_densityKey) ?? DashboardDensity.comfortable.name,
    );
    _layout = DashboardLayout.values.byName(
      prefs.getString(_layoutKey) ?? DashboardLayout.standard.name,
    );
    _dashboardThemeMode = ThemeMode.values.byName(
      prefs.getString(_themeKey) ?? ThemeMode.system.name,
    );
    notifyListeners();
  }

  Future<void> setAccent(DashboardAccent accent) async {
    _accent = accent;
    await _save(_accentKey, accent.name);
    notifyListeners();
  }

  Future<void> setDensity(DashboardDensity density) async {
    _density = density;
    await _save(_densityKey, density.name);
    notifyListeners();
  }

  Future<void> setLayout(DashboardLayout layout) async {
    _layout = layout;
    await _save(_layoutKey, layout.name);
    notifyListeners();
  }

  Future<void> setDashboardThemeMode(ThemeMode mode) async {
    _dashboardThemeMode = mode;
    await _save(_themeKey, mode.name);
    notifyListeners();
  }

  Future<void> _save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static const _accentKey = 'owner_dashboard_accent_v1';
  static const _densityKey = 'owner_dashboard_density_v1';
  static const _layoutKey = 'owner_dashboard_layout_v1';
  static const _themeKey = 'owner_dashboard_theme_v1';
}
