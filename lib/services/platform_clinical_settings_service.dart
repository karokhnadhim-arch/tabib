import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/platform_clinical_settings.dart';
import '../models/audit_module.dart';
import 'audit_logger.dart';
import 'owner_audit_service.dart';

/// Owner queue and prescription platform settings.
class PlatformClinicalSettingsService extends ChangeNotifier {
  PlatformClinicalSettings _settings = PlatformClinicalSettings.defaults;
  AuditLogger? _audit;

  PlatformClinicalSettings get settings => _settings;

  void attachAudit(OwnerAuditService audit) => _audit = AuditLogger(audit);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      _settings = PlatformClinicalSettings.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
    notifyListeners();
  }

  Future<void> update(PlatformClinicalSettings settings) async {
    _settings = settings;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(settings.toMap()));
    _audit?.log(
      module: AuditModule.owner,
      actionType: AuditActionType.settingsChanged,
      action: 'Clinical settings updated',
    );
  }

  Future<void> updateField(
    PlatformClinicalSettings Function(PlatformClinicalSettings current) transform,
  ) async {
    await update(transform(_settings));
  }

  static const _storageKey = 'platform_clinical_settings_v1';
}
