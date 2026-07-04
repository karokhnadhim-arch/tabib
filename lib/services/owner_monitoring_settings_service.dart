import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/owner_monitoring_phase4.dart';
import 'system_maintenance_service.dart';

/// Centralized owner monitoring settings — local prefs only, no business logic changes.
class OwnerMonitoringSettingsService extends ChangeNotifier {
  OwnerMonitoringSettingsService({required SystemMaintenanceService maintenance})
      : _maintenance = maintenance;

  final SystemMaintenanceService _maintenance;
  final Map<String, dynamic> _settings = {};

  static const _storageKey = 'owner_monitoring_settings_v1';

  Map<String, dynamic> get settings => Map.unmodifiable(_settings);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      _settings
        ..clear()
        ..addAll(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } else {
      _settings.addAll(_defaults);
    }
    notifyListeners();
  }

  String getSection(MonitoringSettingsSection section, String key, {String fallback = ''}) {
    final map = _settings[section.name];
    if (map is Map && map[key] != null) return map[key].toString();
    return fallback;
  }

  bool getSectionBool(MonitoringSettingsSection section, String key, {bool fallback = false}) {
    final map = _settings[section.name];
    if (map is Map && map[key] is bool) return map[key] as bool;
    return fallback;
  }

  Future<void> setSectionValue(
    MonitoringSettingsSection section,
    String key,
    Object value,
  ) async {
    final current = _settings[section.name];
    final map = current is Map<String, dynamic>
        ? Map<String, dynamic>.from(current)
        : <String, dynamic>{};
    map[key] = value;
    _settings[section.name] = map;
    await _persist();
    await _applySideEffects(section, key, value);
    notifyListeners();
  }

  Future<void> _applySideEffects(
    MonitoringSettingsSection section,
    String key,
    Object value,
  ) async {
    if (section == MonitoringSettingsSection.maintenance && key == 'enabled') {
      await _maintenance.setMaintenance(
        enabled: value == true,
        message: getSection(section, 'message', fallback: _maintenance.message),
      );
    }
    if (section == MonitoringSettingsSection.maintenance && key == 'message' && value is String) {
      await _maintenance.setMaintenance(
        enabled: getSectionBool(section, 'enabled', fallback: _maintenance.enabled),
        message: value,
      );
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_settings));
  }

  static final Map<String, dynamic> _defaults = {
    MonitoringSettingsSection.firebase.name: {
      'useAggregatedMetrics': true,
      'cacheTtlSeconds': 60,
      'warnBeforeBulkExport': true,
    },
    MonitoringSettingsSection.queue.name: {
      'realtimeEnabled': true,
      'autoCleanupListeners': true,
    },
    MonitoringSettingsSection.advertisements.name: {
      'cityTargeting': true,
      'autoExpire': true,
    },
    MonitoringSettingsSection.packages.name: {
      'renewalReminders': true,
      'gracePeriodDays': 3,
    },
    MonitoringSettingsSection.notifications.name: {
      'ownerSmartAlerts': true,
      'storageThresholds': true,
    },
    MonitoringSettingsSection.backup.name: {
      'autoBackup': true,
      'retentionDays': 30,
    },
    MonitoringSettingsSection.maintenance.name: {
      'enabled': false,
      'message': 'Tabib is undergoing scheduled maintenance. Please try again later.',
    },
  };
}
