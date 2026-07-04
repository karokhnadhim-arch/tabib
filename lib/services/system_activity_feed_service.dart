import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/platform_dashboard_summary.dart';
import '../models/system_monitoring.dart';
import 'dashboard_summary_repository.dart';
import 'system_monitoring_service.dart';

class SystemActivityFeedService extends ChangeNotifier {
  SystemActivityFeedService({DashboardSummaryRepository? summaryRepo})
      : _summaryRepo = summaryRepo {
    _seedDemo();
  }

  static const _uuid = Uuid();
  static const maxEntries = 100;
  static const _cacheKey = 'platform_activity_feed_v1';

  final DashboardSummaryRepository? _summaryRepo;
  final List<ActivityFeedEntry> _entries = [];

  Timer? _refreshTimer;
  bool _active = false;
  bool _isRefreshing = false;
  bool _hasRemoteFeed = false;
  ActivityFeedFilter _filter = ActivityFeedFilter.today;
  DateTime? _lastSyncedAt;

  List<ActivityFeedEntry> get entries => List.unmodifiable(_entries);

  List<ActivityFeedEntry> get filteredEntries {
    final now = DateTime.now();
    return _entries.where((entry) {
      return switch (_filter) {
        ActivityFeedFilter.today => _isToday(entry.timestamp),
        ActivityFeedFilter.lastHour =>
          now.difference(entry.timestamp) <= const Duration(hours: 1),
        ActivityFeedFilter.all => true,
      };
    }).toList(growable: false);
  }

  ActivityFeedFilter get filter => _filter;
  bool get isRefreshing => _isRefreshing;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  Future<void> activate() async {
    if (_active) return;
    _active = true;

    final cached = await _loadCache();
    if (cached != null && cached.isNotEmpty) {
      _replaceEntries(cached);
      notifyListeners();
    }

    await refresh(force: true);
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(SystemMonitoringService.statisticsInterval, (_) {
      if (_active) refresh();
    });
  }

  void deactivate() {
    if (!_active) return;
    _active = false;
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void setFilter(ActivityFeedFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  Future<void> refresh({bool force = false}) async {
    if (!_active && !force) return;
    if (_isRefreshing && !force) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      if (_summaryRepo != null) {
        final remote = await _summaryRepo!.fetchActivityFeed();
        if (remote != null && remote.isNotEmpty) {
          _hasRemoteFeed = true;
          _replaceEntries(remote);
          await _saveCache(remote);
          _lastSyncedAt = DateTime.now();
          return;
        }
      }
    } catch (_) {
      // Keep cached/demo entries on failure.
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Rebuild demo timeline from aggregated summary — zero collection scans.
  Future<void> syncFromSummary(PlatformDashboardSummary summary) async {
    if (_summaryRepo == null || _hasRemoteFeed) return;
    final derived = _summaryRepo!.deriveActivityFeed(summary);
    if (derived.isEmpty) return;
    _replaceEntries(derived);
    await _saveCache(derived);
    _lastSyncedAt = DateTime.now();
    notifyListeners();
  }

  void record({
    required ActivityEventType type,
    required String title,
    String? actorName,
  }) {
    _entries.insert(
      0,
      ActivityFeedEntry(
        id: _uuid.v4(),
        type: type,
        title: title,
        timestamp: DateTime.now(),
        actorName: actorName,
      ),
    );
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
    notifyListeners();
    _saveCache(_entries);
  }

  void _replaceEntries(List<ActivityFeedEntry> next) {
    _entries
      ..clear()
      ..addAll(next.take(maxEntries));
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  bool _isToday(DateTime timestamp) {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  Future<List<ActivityFeedEntry>?> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ActivityFeedEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCache(List<ActivityFeedEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheKey, payload);
    } catch (_) {
      // Ignore cache write failures.
    }
  }

  void _seedDemo() {
    final now = DateTime.now();
    _entries.addAll([
      ActivityFeedEntry(
        id: 'act_doctor_created',
        type: ActivityEventType.doctorCreated,
        title: 'New doctor profile created',
        timestamp: now.subtract(const Duration(minutes: 3)),
        actorName: 'Platform Admin',
      ),
      ActivityFeedEntry(
        id: 'act_patient',
        type: ActivityEventType.patientRegistered,
        title: 'New patient registered',
        timestamp: now.subtract(const Duration(minutes: 7)),
        actorName: 'Demo Patient',
      ),
      ActivityFeedEntry(
        id: 'act_queue',
        type: ActivityEventType.queueJoined,
        title: 'Patient joined queue',
        timestamp: now.subtract(const Duration(minutes: 12)),
      ),
      ActivityFeedEntry(
        id: 'act_appt',
        type: ActivityEventType.appointmentBooked,
        title: 'Appointment booked',
        timestamp: now.subtract(const Duration(minutes: 22)),
      ),
      ActivityFeedEntry(
        id: 'act_login',
        type: ActivityEventType.login,
        title: 'Staff login',
        timestamp: now.subtract(const Duration(minutes: 48)),
        actorName: 'System Owner',
      ),
      ActivityFeedEntry(
        id: 'act_secretary',
        type: ActivityEventType.secretaryAdded,
        title: 'Secretary account added',
        timestamp: now.subtract(const Duration(minutes: 15)),
        actorName: 'Clinic Admin',
      ),
      ActivityFeedEntry(
        id: 'act_queue_cancel',
        type: ActivityEventType.queueCancelled,
        title: 'Queue entry cancelled',
        timestamp: now.subtract(const Duration(minutes: 18)),
      ),
      ActivityFeedEntry(
        id: 'act_logout',
        type: ActivityEventType.logout,
        title: 'Staff logout',
        timestamp: now.subtract(const Duration(minutes: 55)),
        actorName: 'Secretary',
      ),
    ]);
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
