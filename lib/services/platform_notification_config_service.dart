import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/platform_notification_config.dart';

/// Persists platform notification configuration for the System Owner.
class PlatformNotificationConfigService extends ChangeNotifier {
  PlatformNotificationConfig _config = PlatformNotificationConfig.defaults();

  PlatformNotificationConfig get config => _config;

  Future<void> load() async {
    final stored = await SharedPreferences.getInstance();
    final raw = stored.getString(_storageKey);
    if (raw == null) {
      _config = PlatformNotificationConfig.defaults();
    } else {
      _config = PlatformNotificationConfig.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
    notifyListeners();
  }

  Future<void> update(PlatformNotificationConfig config) async {
    _config = config;
    notifyListeners();
    final stored = await SharedPreferences.getInstance();
    await stored.setString(_storageKey, jsonEncode(config.toMap()));
  }

  Future<void> updateField(
    PlatformNotificationConfig Function(PlatformNotificationConfig current)
        transform,
  ) async {
    await update(transform(_config));
  }

  static const _storageKey = 'platform_notification_config_v1';
}
