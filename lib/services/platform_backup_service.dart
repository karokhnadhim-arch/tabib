import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/audit_module.dart';
import '../models/clinic.dart';
import '../models/doctor.dart';
import '../models/localized_text.dart';
import '../models/platform_backup.dart';
import '../models/specialty.dart';
import '../models/user_account.dart';
import 'audit_logger.dart';
import 'auth_service.dart';
import 'backend/clinic_backend.dart';
import 'owner_audit_service.dart';
import 'smart_owner_notification_service.dart';

/// Owner backup, restore, and disaster recovery — non-blocking background jobs.
class PlatformBackupService extends ChangeNotifier {
  PlatformBackupService({
    required ClinicBackend backend,
    FirebaseFirestore? firestore,
    bool? useFirestore,
  })  : _backend = backend,
        _db = firestore ?? FirebaseFirestore.instance,
        _useFirestore = useFirestore ?? false;

  final ClinicBackend _backend;
  final FirebaseFirestore _db;
  final bool _useFirestore;
  static const _uuid = Uuid();

  final List<PlatformBackupRecord> _history = [];
  final Map<String, String> _payloads = {};
  BackupScheduleConfig _schedule = BackupScheduleConfig.defaults;
  DateTime? _lastDailyRun;
  DateTime? _lastWeeklyRun;
  DateTime? _lastRestoreDate;
  Timer? _scheduleTimer;

  bool _backupInProgress = false;
  bool _restoreInProgress = false;
  double _progress = 0;
  String _progressLabel = '';

  AuditLogger? _audit;
  AuthService? _auth;
  SmartOwnerNotificationService? _notifications;
  bool _loaded = false;

  bool get backupInProgress => _backupInProgress;
  bool get restoreInProgress => _restoreInProgress;
  double get progress => _progress;
  String get progressLabel => _progressLabel;
  BackupScheduleConfig get schedule => _schedule;
  List<PlatformBackupRecord> get history =>
      List.unmodifiable(_history..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  PlatformBackupRecord? get latestHealthyBackup {
    for (final record in history) {
      if (record.isRestorable) return record;
    }
    return null;
  }

  BackupDashboardMetrics get dashboard {
    final healthy = history.where((r) => r.isRestorable).length;
    PlatformBackupRecord? last;
    for (final r in history) {
      if (r.status.isHealthy) {
        last = r;
        break;
      }
    }
    final totalBytes = history.fold<int>(0, (acc, r) => acc + r.sizeBytes);
    return BackupDashboardMetrics(
      lastBackup: last?.createdAt,
      nextScheduledBackup: _computeNextScheduled(),
      statusLabel: _backupInProgress
          ? 'Running'
          : _restoreInProgress
              ? 'Restoring'
              : (last != null ? 'Healthy' : 'No backups yet'),
      totalBackups: history.length,
      storageUsageBytes: totalBytes,
      latestRestoreDate: _lastRestoreDate,
      healthyBackupCount: healthy,
    );
  }

  void attachAudit({
    required OwnerAuditService audit,
    required AuthService auth,
  }) {
    _audit = AuditLogger(audit);
    _auth = auth;
  }

  void attachNotifications(SmartOwnerNotificationService notifications) {
    _notifications = notifications;
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final scheduleRaw = prefs.getString(_scheduleKey);
    if (scheduleRaw != null) {
      _schedule = BackupScheduleConfig.fromMap(
        jsonDecode(scheduleRaw) as Map<String, dynamic>,
      );
    }
    _lastRestoreDate = _readDate(prefs.getString(_lastRestoreKey));
    _lastDailyRun = _readDate(prefs.getString(_lastDailyKey));
    _lastWeeklyRun = _readDate(prefs.getString(_lastWeeklyKey));

    if (_useFirestore) {
      final snap = await _db
          .collection('platform_backups')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      _history
        ..clear()
        ..addAll(
          snap.docs.map((d) => PlatformBackupRecord.fromMap(d.id, d.data())),
        );
      for (final doc in snap.docs) {
        final payload = doc.data()['payload'] as String?;
        if (payload != null) _payloads[doc.id] = payload;
      }
    } else {
      final raw = prefs.getString(_historyKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _history
          ..clear()
          ..addAll(
            list.map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              final id = map.remove('id') as String;
              return PlatformBackupRecord.fromMap(id, map);
            }),
          );
      }
      final payloadIndex = prefs.getStringList(_payloadIndexKey) ?? [];
      for (final key in payloadIndex) {
        final payload = prefs.getString('$_payloadPrefix$key');
        if (payload != null) _payloads[key] = payload;
      }
    }

    _loaded = true;
    _startScheduleTimer();
    notifyListeners();
    unawaited(_checkScheduledBackups());
  }

  Future<void> updateSchedule(BackupScheduleConfig config) async {
    _schedule = config;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scheduleKey, jsonEncode(config.toMap()));
  }

  Future<PlatformBackupRecord?> runManualBackup() =>
      _runBackup(BackupType.manual);

  Future<void> _checkScheduledBackups() async {
    if (_backupInProgress || _restoreInProgress) return;
    final now = DateTime.now();

    if (_schedule.dailyEnabled) {
      final due = _lastDailyRun == null ||
          now.difference(_lastDailyRun!).inHours >= 24;
      if (due && now.hour >= _schedule.dailyHour) {
        await _runBackup(BackupType.daily);
        _lastDailyRun = now;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastDailyKey, now.toIso8601String());
        return;
      }
    }

    if (_schedule.weeklyEnabled) {
      final weekDue = _lastWeeklyRun == null ||
          now.difference(_lastWeeklyRun!).inDays >= 7;
      if (weekDue &&
          now.weekday == _schedule.weeklyWeekday &&
          now.hour >= _schedule.weeklyHour) {
        await _runBackup(BackupType.weekly);
        _lastWeeklyRun = now;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastWeeklyKey, now.toIso8601String());
      }
    }
  }

  Future<PlatformBackupRecord?> _runBackup(BackupType type) async {
    if (_backupInProgress) return null;
    _backupInProgress = true;
    _progress = 0;
    _progressLabel = 'Preparing backup…';
    notifyListeners();

    final actor = _auth?.currentUser;
    final recordId = 'bkp_${_uuid.v4()}';
    var record = PlatformBackupRecord(
      id: recordId,
      createdAt: DateTime.now(),
      sizeBytes: 0,
      type: type,
      status: BackupJobStatus.running,
      createdById: actor?.id ?? 'system',
      createdByName: AuditLogger.displayName(actor),
      checksum: '',
    );
    _history.insert(0, record);
    notifyListeners();

    try {
      _progress = 0.1;
      _progressLabel = 'Exporting clinics…';
      notifyListeners();
      final payload = await _exportPayload(onProgress: (p, label) {
        _progress = p;
        _progressLabel = label;
        notifyListeners();
      });

      final checksum = _checksum(payload);
      final bytes = utf8.encode(payload).length;
      if (!_validatePayloadStructure(payload)) {
        throw const FormatException('Invalid backup payload');
      }

      record = record.copyWith(
        status: BackupJobStatus.completed,
        sizeBytes: bytes,
        checksum: checksum,
      );
      _payloads[recordId] = payload;
      _history[0] = record;
      await _persistRecord(record, payload);

      _audit?.log(
        actor: actor,
        module: AuditModule.owner,
        actionType: AuditActionType.other,
        action: 'Backup created',
        description: '${type.storageKey} · ${record.sizeLabel}',
        details: recordId,
      );
      _notifications?.clearBackupFailed();
      notifyListeners();
      return record;
    } catch (e) {
      record = record.copyWith(
        status: BackupJobStatus.failed,
        failureReason: e.toString(),
      );
      _history[0] = record;
      await _persistRecord(record, null);
      _notifications?.notifyBackupFailed(message: e.toString());
      _audit?.log(
        actor: actor,
        module: AuditModule.owner,
        actionType: AuditActionType.other,
        action: 'Backup failed',
        description: e.toString(),
      );
      notifyListeners();
      return null;
    } finally {
      _backupInProgress = false;
      _progress = 1;
      _progressLabel = '';
      notifyListeners();
    }
  }

  Future<bool> validateBackup(String backupId) async {
    final record = _findRecord(backupId);
    if (record == null) return false;
    if (record.formatVersion != PlatformBackupRecord.currentFormatVersion) {
      return false;
    }
    final payload = await _loadPayload(backupId);
    if (payload == null || payload.isEmpty) {
      await _markCorrupted(backupId, 'Missing payload');
      return false;
    }
    if (_checksum(payload) != record.checksum) {
      await _markCorrupted(backupId, 'Checksum mismatch');
      return false;
    }
    if (!_validatePayloadStructure(payload)) {
      await _markCorrupted(backupId, 'Incompatible format');
      return false;
    }
    return true;
  }

  Future<void> restoreBackup(String backupId) async {
    if (_restoreInProgress || _backupInProgress) return;
    final record = _findRecord(backupId);
    if (record == null) throw StateError('backup_not_found');

    _restoreInProgress = true;
    _progress = 0;
    _progressLabel = 'Validating backup…';
    notifyListeners();

    final actor = _auth?.currentUser;
    try {
      final valid = await validateBackup(backupId);
      if (!valid) {
        throw const FormatException('Backup validation failed');
      }

      _progress = 0.2;
      _progressLabel = 'Reading backup data…';
      notifyListeners();
      final payload = await _loadPayload(backupId);
      final map = jsonDecode(payload!) as Map<String, dynamic>;
      if ((map['formatVersion'] as num?)?.toInt() !=
          PlatformBackupRecord.currentFormatVersion) {
        throw const FormatException('Incompatible backup version');
      }

      _progress = 0.45;
      _progressLabel = 'Restoring clinics…';
      notifyListeners();
      await _applyPayload(
        map,
        onProgress: (p, label) {
          _progress = p;
          _progressLabel = label;
          notifyListeners();
        },
      );

      _progress = 0.95;
      _progressLabel = 'Finalizing restore…';
      notifyListeners();

      _lastRestoreDate = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastRestoreKey, _lastRestoreDate!.toIso8601String());

      _audit?.log(
        actor: actor,
        module: AuditModule.owner,
        actionType: AuditActionType.other,
        action: 'Backup restored',
        description: backupId,
      );
      _progress = 1;
      notifyListeners();
    } catch (e) {
      _audit?.log(
        actor: actor,
        module: AuditModule.owner,
        actionType: AuditActionType.other,
        action: 'Restore failed',
        description: e.toString(),
      );
      rethrow;
    } finally {
      _restoreInProgress = false;
      _progressLabel = '';
      notifyListeners();
    }
  }

  Future<String?> downloadBackupPayload(String backupId) async {
    if (!await validateBackup(backupId)) return null;
    return _loadPayload(backupId);
  }

  Future<void> recoverFromLatestHealthy() async {
    final latest = latestHealthyBackup;
    if (latest == null) {
      throw StateError('no_healthy_backup');
    }
    await restoreBackup(latest.id);
  }

  Future<String> exportBackupReport() {
    final buffer = StringBuffer('Tabib Backup Report\n');
    final metrics = dashboard;
    buffer.writeln('Status: ${metrics.statusLabel}');
    buffer.writeln('Total backups: ${metrics.totalBackups}');
    buffer.writeln('Storage: ${metrics.storageUsageLabel}');
    buffer.writeln('Last backup: ${metrics.lastBackup}');
    buffer.writeln('Next scheduled: ${metrics.nextScheduledBackup}');
    buffer.writeln('Last restore: ${metrics.latestRestoreDate}');
    buffer.writeln('');
    for (final h in history) {
      buffer.writeln(
        '${h.createdAt.toIso8601String()} | ${h.type.storageKey} | '
        '${h.status.storageKey} | ${h.sizeLabel} | ${h.createdByName}',
      );
    }
    return Future.value(buffer.toString());
  }

  Future<String> _exportPayload({
    required void Function(double progress, String label) onProgress,
  }) async {
    onProgress(0.15, 'Loading specialties…');
    final specialties = await _backend.fetchSpecialties();
    onProgress(0.25, 'Loading clinics…');
    final clinics = await _backend.fetchClinics();
    onProgress(0.4, 'Loading doctors…');
    final doctors = <Map<String, dynamic>>[];
    Object? cursor;
    while (true) {
      final page = await _backend.fetchDoctorsPage(limit: 50, startAfterCursor: cursor);
      for (final d in page.doctors) {
        doctors.add(d.toMap()..['id'] = d.id);
      }
      if (!page.hasMore) break;
      cursor = page.nextCursor;
      onProgress(0.4 + (doctors.length / 500).clamp(0, 0.25), 'Loading doctors…');
    }
    onProgress(0.7, 'Loading accounts…');
    final accounts = await _backend.fetchAllAccounts();
    onProgress(0.85, 'Serializing…');
    final payload = jsonEncode({
      'formatVersion': PlatformBackupRecord.currentFormatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'specialties': specialties.map((s) => s.toMap()..['id'] = s.id).toList(),
      'clinics': clinics.map((c) => c.toMap()..['id'] = c.id).toList(),
      'doctors': doctors,
      'accounts': accounts.map((a) => a.toMap()..['id'] = a.id).toList(),
    });
    onProgress(0.95, 'Finalizing…');
    return payload;
  }

  Future<void> _applyPayload(
    Map<String, dynamic> map, {
    required void Function(double progress, String label) onProgress,
  }) async {
    final specialties = <String, Specialty>{};
    final clinics = <String, Clinic>{};

    final specList = (map['specialties'] as List<dynamic>?) ?? [];
    for (var i = 0; i < specList.length; i++) {
      final raw = Map<String, dynamic>.from(specList[i] as Map);
      final id = raw.remove('id') as String? ?? '';
      if (id.isEmpty) continue;
      final specialty = Specialty.fromFirestore(id, raw);
      await _backend.upsertSpecialty(specialty);
      specialties[id] = specialty;
      onProgress(
        0.45 + ((i + 1) / specList.length) * 0.1,
        'Restoring specialties…',
      );
    }

    final clinicList = (map['clinics'] as List<dynamic>?) ?? [];
    for (var i = 0; i < clinicList.length; i++) {
      final raw = Map<String, dynamic>.from(clinicList[i] as Map);
      final id = raw.remove('id') as String? ?? '';
      if (id.isEmpty) continue;
      final clinic = Clinic.fromFirestore(id, raw);
      await _backend.upsertClinic(clinic);
      clinics[id] = clinic;
      onProgress(
        0.55 + ((i + 1) / clinicList.length) * 0.15,
        'Restoring clinics…',
      );
    }

    final doctorList = (map['doctors'] as List<dynamic>?) ?? [];
    for (var i = 0; i < doctorList.length; i++) {
      final raw = Map<String, dynamic>.from(doctorList[i] as Map);
      final id = raw.remove('id') as String? ?? '';
      if (id.isEmpty) continue;
      final specId = raw['specialtyId'] as String? ?? '';
      final clinId = raw['clinicId'] as String? ?? '';
      final specialty = specialties[specId] ??
          Specialty(
            id: specId.isEmpty ? 'unknown_spec' : specId,
            name: const LocalizedText(ku: '', ar: '', en: ''),
            iconName: 'medical',
          );
      final clinic = clinics[clinId] ??
          Clinic(
            id: clinId.isEmpty ? 'unknown_clinic' : clinId,
            name: const LocalizedText(ku: '', ar: '', en: ''),
            address: const LocalizedText(ku: '', ar: '', en: ''),
            latitude: 0,
            longitude: 0,
            phone: '',
          );
      final doctor = Doctor.fromMap(
        id: id,
        data: raw,
        specialty: specialty,
        clinic: clinic,
      );
      await _backend.upsertDoctor(doctor);
      onProgress(
        0.7 + ((i + 1) / doctorList.length) * 0.15,
        'Restoring doctors…',
      );
    }

    final accountList = (map['accounts'] as List<dynamic>?) ?? [];
    for (var i = 0; i < accountList.length; i++) {
      final raw = Map<String, dynamic>.from(accountList[i] as Map);
      final id = raw.remove('id') as String? ?? '';
      if (id.isEmpty) continue;
      final account = UserAccount.fromFirestore(id, raw);
      await _backend.upsertStaff(account);
      onProgress(
        0.85 + ((i + 1) / accountList.length) * 0.1,
        'Restoring accounts…',
      );
    }
  }

  bool _validatePayloadStructure(String payload) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      return map.containsKey('formatVersion') &&
          map.containsKey('clinics') &&
          map.containsKey('doctors');
    } catch (_) {
      return false;
    }
  }

  Future<void> _markCorrupted(String backupId, String reason) async {
    final index = _history.indexWhere((r) => r.id == backupId);
    if (index < 0) return;
    _history[index] = _history[index].copyWith(
      status: BackupJobStatus.corrupted,
      failureReason: reason,
    );
    await _persistRecord(_history[index], _payloads[backupId]);
    _audit?.log(
      actor: _auth?.currentUser,
      module: AuditModule.owner,
      actionType: AuditActionType.other,
      action: 'Backup corruption detected',
      description: reason,
      details: backupId,
    );
    notifyListeners();
  }

  PlatformBackupRecord? _findRecord(String id) {
    for (final r in _history) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<String?> _loadPayload(String backupId) async {
    if (_payloads.containsKey(backupId)) return _payloads[backupId];
    if (_useFirestore) {
      final doc = await _db.collection('platform_backups').doc(backupId).get();
      final payload = doc.data()?['payload'] as String?;
      if (payload != null) _payloads[backupId] = payload;
      return payload;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_payloadPrefix$backupId');
  }

  Future<void> _persistRecord(
    PlatformBackupRecord record,
    String? payload,
  ) async {
    if (_useFirestore) {
      await _db.collection('platform_backups').doc(record.id).set({
        ...record.toMap(),
        if (payload != null) 'payload': payload,
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _history
          .map((r) => {'id': r.id, ...r.toMap()})
          .toList();
      await prefs.setString(_historyKey, jsonEncode(encoded));
      if (payload != null) {
        await prefs.setString('$_payloadPrefix${record.id}', payload);
        final index = prefs.getStringList(_payloadIndexKey) ?? [];
        if (!index.contains(record.id)) {
          index.add(record.id);
          await prefs.setStringList(_payloadIndexKey, index);
        }
        _payloads[record.id] = payload;
      }
    }
  }

  DateTime? _computeNextScheduled() {
    final now = DateTime.now();
    if (_schedule.dailyEnabled) {
      var next = DateTime(now.year, now.month, now.day, _schedule.dailyHour);
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    }
    if (_schedule.weeklyEnabled) {
      var next = DateTime(now.year, now.month, now.day, _schedule.weeklyHour);
      while (next.weekday != _schedule.weeklyWeekday || !next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    }
    return null;
  }

  void _startScheduleTimer() {
    _scheduleTimer?.cancel();
    _scheduleTimer = Timer.periodic(const Duration(hours: 1), (_) {
      unawaited(_checkScheduledBackups());
    });
  }

  static String _checksum(String data) {
    var hash = BigInt.parse('cbf29ce484222325', radix: 16);
    final prime = BigInt.parse('100000001b3', radix: 16);
    final mask = BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16);
    for (final unit in data.codeUnits) {
      hash = (hash ^ BigInt.from(unit)) & mask;
      hash = (hash * prime) & mask;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  static DateTime? _readDate(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

  static const _scheduleKey = 'platform_backup_schedule_v1';
  static const _historyKey = 'platform_backup_history_v1';
  static const _payloadPrefix = 'platform_backup_payload_';
  static const _payloadIndexKey = 'platform_backup_payload_index';
  static const _lastRestoreKey = 'platform_backup_last_restore';
  static const _lastDailyKey = 'platform_backup_last_daily';
  static const _lastWeeklyKey = 'platform_backup_last_weekly';
}
