import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/system_monitoring.dart';

enum ErrorLogTimeFilter { all, today, thisWeek }

enum ErrorLogSeverityFilter { all, criticalOnly }

class SystemErrorLogService extends ChangeNotifier {
  SystemErrorLogService() {
    _seedDemo();
  }

  static const _uuid = Uuid();
  final List<AppErrorEntry> _entries = [];
  ErrorLogTimeFilter _timeFilter = ErrorLogTimeFilter.all;
  ErrorLogSeverityFilter _severityFilter = ErrorLogSeverityFilter.all;
  String? _moduleFilter;

  List<AppErrorEntry> get entries => List.unmodifiable(
        _entries..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
      );

  List<AppErrorEntry> get openEntries =>
      entries.where((e) => e.status == AppErrorStatus.open).toList();

  ErrorLogTimeFilter get timeFilter => _timeFilter;
  ErrorLogSeverityFilter get severityFilter => _severityFilter;
  String? get moduleFilter => _moduleFilter;

  List<String> get availableModules {
    final modules = _entries.map((e) => e.module).toSet().toList()..sort();
    return modules;
  }

  List<AppErrorEntry> get filteredEntries => entries.where(_matchesFilters).toList();

  void setTimeFilter(ErrorLogTimeFilter filter) {
    if (_timeFilter == filter) return;
    _timeFilter = filter;
    notifyListeners();
  }

  void setSeverityFilter(ErrorLogSeverityFilter filter) {
    if (_severityFilter == filter) return;
    _severityFilter = filter;
    notifyListeners();
  }

  void setModuleFilter(String? module) {
    if (_moduleFilter == module) return;
    _moduleFilter = module;
    notifyListeners();
  }

  bool _matchesFilters(AppErrorEntry entry) {
    if (_moduleFilter != null && entry.module != _moduleFilter) return false;
    if (_severityFilter == ErrorLogSeverityFilter.criticalOnly &&
        entry.severity != AppErrorSeverity.critical) {
      return false;
    }
    final now = DateTime.now();
    final ts = entry.timestamp;
    return switch (_timeFilter) {
      ErrorLogTimeFilter.all => true,
      ErrorLogTimeFilter.today =>
        ts.year == now.year && ts.month == now.month && ts.day == now.day,
      ErrorLogTimeFilter.thisWeek =>
        ts.isAfter(now.subtract(const Duration(days: 7))),
    };
  }

  void record({
    required String module,
    required String errorType,
    required String message,
    AppErrorSeverity severity = AppErrorSeverity.medium,
    String? stackTrace,
  }) {
    _entries.insert(
      0,
      AppErrorEntry(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        module: module,
        errorType: errorType,
        severity: severity,
        device: defaultTargetPlatform.name,
        platform: kIsWeb ? 'web' : 'mobile',
        status: AppErrorStatus.open,
        message: message,
        stackTrace: stackTrace,
      ),
    );
    notifyListeners();
  }

  void markFixed(String id) => _setStatus(id, AppErrorStatus.fixed);

  void ignore(String id) => _setStatus(id, AppErrorStatus.ignored);

  void delete(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void _setStatus(String id, AppErrorStatus status) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _entries[index] = _entries[index].copyWith(status: status);
    notifyListeners();
  }

  String exportCsv() {
    final buffer = StringBuffer(
      'Date,Time,Module,Type,Severity,Device,Platform,Status,Message,StackTrace\n',
    );
    for (final e in entries) {
      buffer.writeln(
        '${e.timestamp.toIso8601String().split('T').first},'
        '${e.timestamp.hour}:${e.timestamp.minute},'
        '${_csv(e.module)},${_csv(e.errorType)},${e.severity.name},'
        '${_csv(e.device)},${e.platform},${e.status.name},'
        '${_csv(e.message)},${_csv(e.stackTrace ?? '')}',
      );
    }
    return buffer.toString();
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';

  void _seedDemo() {
    final now = DateTime.now();
    _entries.addAll([
      AppErrorEntry(
        id: 'err_seed_1',
        timestamp: now.subtract(const Duration(minutes: 18)),
        module: 'QueueService',
        errorType: 'SyncTimeout',
        severity: AppErrorSeverity.medium,
        device: 'web',
        platform: 'web',
        status: AppErrorStatus.open,
        message: 'Queue snapshot refresh exceeded 1200ms',
        stackTrace: 'SyncTimeout at QueueService.refreshSnapshot\n  at firestore_clinic_backend.dart:142',
      ),
      AppErrorEntry(
        id: 'err_seed_2',
        timestamp: now.subtract(const Duration(hours: 3)),
        module: 'Notifications',
        errorType: 'DeliveryFailed',
        severity: AppErrorSeverity.low,
        device: 'android',
        platform: 'mobile',
        status: AppErrorStatus.open,
        message: 'SMS provider returned unavailable in demo mode',
        stackTrace: 'DeliveryFailed: provider timeout after 30s',
      ),
      AppErrorEntry(
        id: 'err_seed_3',
        timestamp: now.subtract(const Duration(hours: 8)),
        module: 'AuthService',
        errorType: 'TokenExpired',
        severity: AppErrorSeverity.high,
        device: 'ios',
        platform: 'mobile',
        status: AppErrorStatus.fixed,
        message: 'Session token expired during background refresh',
        stackTrace: 'TokenExpired at AuthService.validateSession',
      ),
      AppErrorEntry(
        id: 'err_seed_4',
        timestamp: now.subtract(const Duration(days: 2)),
        module: 'FirestoreBackend',
        errorType: 'PermissionDenied',
        severity: AppErrorSeverity.critical,
        device: 'web',
        platform: 'web',
        status: AppErrorStatus.open,
        message: 'Platform metrics read denied — using cached summary',
        stackTrace: 'PermissionDenied at firestore_clinic_backend.fetchPlatformDashboardSummary',
      ),
    ]);
  }
}
