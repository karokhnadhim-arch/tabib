import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemMaintenanceService extends ChangeNotifier {
  bool _enabled = false;
  String _message =
      'Tabib is undergoing scheduled maintenance. Please try again later.';

  bool get enabled => _enabled;
  String get message => _message;

  Future<void> load() async {
    final stored = await SharedPreferences.getInstance();
    _enabled = stored.getBool(_storageEnabled) ?? false;
    _message = stored.getString(_storageMessage) ?? _message;
    notifyListeners();
  }

  Future<void> setMaintenance({
    required bool enabled,
    String? message,
  }) async {
    _enabled = enabled;
    if (message != null && message.trim().isNotEmpty) {
      _message = message.trim();
    }
    notifyListeners();
    final stored = await SharedPreferences.getInstance();
    await stored.setBool(_storageEnabled, _enabled);
    await stored.setString(_storageMessage, _message);
  }

  static const _storageEnabled = 'system_maintenance_enabled_v1';
  static const _storageMessage = 'system_maintenance_message_v1';
}
