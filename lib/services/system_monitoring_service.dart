import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/privacy/system_owner_privacy.dart';
import '../firebase_options.dart';
import '../models/platform_dashboard_summary.dart';
import '../models/system_monitoring.dart';
import '../models/user_account.dart';
import 'advertisement_service.dart';
import 'backend/clinic_backend.dart';
import 'clinic_data_service.dart';
import 'dashboard_summary_repository.dart';
import 'firebase_bootstrap.dart';
import 'staff_communication_log_service.dart';
import 'staff_data_service.dart';
import 'system_error_log_service.dart';
import 'firebase_cost_optimizer_service.dart';
import 'owner_forecast_service.dart';
import 'owner_insights_service.dart';
import 'owner_dashboard_search_service.dart';
import 'smart_owner_notification_service.dart';
import 'system_activity_feed_service.dart';

/// Owner monitoring with cost-aware polling, lazy sections, and offline cache.
class SystemMonitoringService extends ChangeNotifier {
  SystemMonitoringService({
    required ClinicBackend backend,
    required ClinicDataService clinicData,
    required StaffDataService staffData,
    required StaffCommunicationLogService communicationLog,
    required SystemErrorLogService errorLog,
    AdvertisementService? advertisementService,
  })  : _summaryRepo = DashboardSummaryRepository(backend: backend),
        _clinicData = clinicData,
        _staffData = staffData,
        _communicationLog = communicationLog,
        _errorLog = errorLog,
        _advertisementService = advertisementService {
    _errorLog.addListener(_onCriticalSignalsChanged);
  }

  static const healthRefreshInterval = Duration(seconds: 30);
  static const statisticsInterval = healthRefreshInterval;
  static const criticalInterval = Duration(seconds: 10);
  static const sessionPageSize = 5;
  static const activityPageSize = 10;
  static const errorPageSize = 10;

  final DashboardSummaryRepository _summaryRepo;
  final ClinicDataService _clinicData;
  final StaffDataService _staffData;
  final StaffCommunicationLogService _communicationLog;
  final SystemErrorLogService _errorLog;
  final AdvertisementService? _advertisementService;
  SystemActivityFeedService? _activityFeed;

  void attachActivityFeed(SystemActivityFeedService feed) {
    _activityFeed = feed;
  }

  OwnerInsightsService? _insights;
  OwnerForecastService? _forecast;
  SmartOwnerNotificationService? _smartNotifications;
  FirebaseCostOptimizerService? _costOptimizer;
  OwnerDashboardSearchService? _search;

  void attachPhase4Services({
    OwnerInsightsService? insights,
    OwnerForecastService? forecast,
    SmartOwnerNotificationService? smartNotifications,
    FirebaseCostOptimizerService? costOptimizer,
    OwnerDashboardSearchService? search,
  }) {
    _insights = insights;
    _forecast = forecast;
    _smartNotifications = smartNotifications;
    _costOptimizer = costOptimizer;
    _search = search;
  }

  void _syncPhase4(SystemMonitoringSnapshot snapshot, SystemHealthLevel health) {
    _insights?.generateFromSnapshot(snapshot);
    _forecast?.generate(snapshot: snapshot, charts: _charts);
    _costOptimizer?.analyze(snapshot);
    _search?.setSnapshot(snapshot);
    _smartNotifications?.syncFromMonitoring(
      snapshot: snapshot,
      alerts: _criticalAlerts,
      healthLevel: health,
    );
  }

  Timer? _statisticsTimer;
  Timer? _criticalTimer;
  bool _dashboardActive = false;
  bool _statisticsRefreshInFlight = false;
  bool _chartsRefreshInFlight = false;

  AnalyticsRange _range = AnalyticsRange.today;
  SystemMonitoringSnapshot? _snapshot;
  DashboardChartsBundle? _charts;
  List<OwnerAlert> _criticalAlerts = [];
  List<ActiveSessionEntry> _sessions = [];
  BackupSnapshot _backup = const BackupSnapshot(
    lastBackup: null,
    sizeLabel: '—',
    status: 'Pending',
    nextScheduled: null,
  );

  bool _isRefreshing = false;
  bool _isRefreshingPhase1 = false;
  bool _isRefreshingPhase2 = false;
  bool _isLoadingCharts = false;
  bool _chartsLoaded = false;
  bool _isOffline = false;
  bool _showingCachedData = false;
  DateTime? _lastSuccessfulSync;
  int _sessionPage = 1;
  int _errorPage = 1;
  bool _activityRequested = false;
  bool _reportsExpanded = false;
  bool _chartsRequested = false;
  DateTime? _customRangeStart;
  DateTime? _customRangeEnd;
  final Set<String> _lockedUserIds = {};
  final Set<String> _terminatedSessions = {};
  final List<BackupHistoryEntry> _backupHistory = [];

  SystemMonitoringSnapshot? get snapshot => _snapshot;
  DashboardChartsBundle? get charts => _charts;
  AnalyticsRange get range => _range;
  List<OwnerAlert> get criticalAlerts => List.unmodifiable(_criticalAlerts);
  List<OwnerAlert> get phase1Alerts =>
      _criticalAlerts.where((a) => a.type.isPhase1).toList(growable: false);

  SystemHealthLevel get phase1HealthLevel {
    final configured = DefaultFirebaseOptions.isConfigured;
    final connected = FirebaseBootstrap.initialized;
    final openErrors = _errorLog.openEntries.length;
    final totalErrors = _errorLog.entries.length;
    final errorRate =
        totalErrors == 0 ? 0.0 : (openErrors / totalErrors) * 100;
    return _healthLevel(phase1Alerts, connected, configured, errorRate);
  }

  List<ActiveSessionEntry> get activeSessions => List.unmodifiable(_sessions);
  BackupSnapshot get backup => _backup;

  bool get isDashboardActive => _dashboardActive;
  bool get isRefreshing => _isRefreshing;
  bool get isRefreshingPhase1 => _isRefreshingPhase1;
  bool get isRefreshingPhase2 => _isRefreshingPhase2;
  bool get isLoadingCharts => _isLoadingCharts;
  bool get chartsLoaded => _chartsLoaded;
  bool get isOffline => _isOffline;
  bool get showingCachedData => _showingCachedData;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;
  bool get activityRequested => _activityRequested;
  bool get reportsExpanded => _reportsExpanded;
  int get sessionPage => _sessionPage;
  int get errorPage => _errorPage;
  int get errorVisibleCount => errorPageSize * _errorPage;
  bool get chartsRequested => _chartsRequested;
  DateTime? get customRangeStart => _customRangeStart;
  DateTime? get customRangeEnd => _customRangeEnd;
  List<BackupHistoryEntry> get backupHistory => List.unmodifiable(_backupHistory);
  SystemErrorLogService get errorLogService => _errorLog;

  List<AppErrorEntry> get visibleErrors =>
      _errorLog.entries.take(errorVisibleCount).toList(growable: false);

  List<ActiveSessionEntry> get visibleSessions => _sessions
      .where((s) => !_terminatedSessions.contains(s.id))
      .toList(growable: false);

  int get effectiveLockedAccounts =>
      (_snapshot?.lockedAccounts ?? 0) + _lockedUserIds.length;

  bool isUserLocked(String userName) => _lockedUserIds.contains(userName);

  Future<void> activate() async {
    if (_dashboardActive) return;
    _dashboardActive = true;

    final cached = await _summaryRepo.loadCachedSummary();
    if (cached != null) {
      _applySummary(cached, fromCache: true);
      _showingCachedData = true;
      notifyListeners();
    }

    _refreshCriticalAlerts();
    await refreshStatistics(force: true);
    _startTimers();
  }

  void deactivate() {
    if (!_dashboardActive) return;
    _dashboardActive = false;
    _statisticsTimer?.cancel();
    _criticalTimer?.cancel();
    _statisticsTimer = null;
    _criticalTimer = null;
  }

  void _startTimers() {
    _statisticsTimer?.cancel();
    _criticalTimer?.cancel();
    _statisticsTimer = Timer.periodic(statisticsInterval, (_) {
      if (_dashboardActive) refreshStatistics();
    });
    _criticalTimer = Timer.periodic(criticalInterval, (_) {
      if (_dashboardActive) _refreshCriticalAlerts();
    });
  }

  @override
  void dispose() {
    _errorLog.removeListener(_onCriticalSignalsChanged);
    _statisticsTimer?.cancel();
    _criticalTimer?.cancel();
    super.dispose();
  }

  void _onCriticalSignalsChanged() => _refreshCriticalAlerts();

  Future<void> refresh() async {
    await refreshStatistics(force: true);
    if (_chartsLoaded || _isLoadingCharts) {
      await loadCharts(force: true);
    }
  }

  /// Phase 1 infrastructure refresh — statistics only (no chart reads).
  Future<void> refreshPhase1({bool force = false}) =>
      refreshStatistics(force: force, showPhase1Indicator: true);

  /// Phase 2 live statistics — reuses the same aggregated summary read.
  Future<void> refreshPhase2({bool force = false}) =>
      refreshStatistics(force: force);

  /// Full dashboard refresh — statistics plus optional activity feed sync.
  Future<void> refreshDashboard({bool force = false}) async {
    await refreshStatistics(force: force, showPhase1Indicator: true);
    await _activityFeed?.refresh(force: force);
  }

  Future<void> refreshPhase3({bool force = false}) async {
    if (_chartsRequested) await loadCharts(force: force);
  }

  Future<void> refreshStatistics({
    bool force = false,
    bool showPhase1Indicator = false,
  }) async {
    if (!_dashboardActive) return;
    if (_statisticsRefreshInFlight && !force) return;

    _statisticsRefreshInFlight = true;
    _isRefreshing = true;
    if (showPhase1Indicator) _isRefreshingPhase1 = true;
    _isRefreshingPhase2 = true;
    notifyListeners();

    final sw = Stopwatch()..start();
    try {
      final summary = await _summaryRepo.fetchSummary(
        staffData: _staffData,
        clinicData: _clinicData,
        communicationLog: _communicationLog,
        advertisementService: _advertisementService,
      );
      sw.stop();

      await _summaryRepo.cacheSummary(summary);
      _applySummary(summary, responseMs: sw.elapsedMilliseconds);
      _lastSuccessfulSync = DateTime.now();
      _isOffline = false;
      _showingCachedData = false;
    } catch (_) {
      _isOffline = true;
      if (_snapshot == null) {
        final cached = await _summaryRepo.loadCachedSummary();
        if (cached != null) {
          _applySummary(cached, fromCache: true);
          _showingCachedData = true;
        }
      } else {
        _showingCachedData = true;
      }
    } finally {
      _statisticsRefreshInFlight = false;
      _isRefreshing = false;
      _isRefreshingPhase1 = false;
      _isRefreshingPhase2 = false;
      _refreshCriticalAlerts();
      notifyListeners();
    }
  }

  Future<void> loadCharts({bool force = false}) async {
    if (!_dashboardActive) return;
    if ((_chartsLoaded && !force) || _chartsRefreshInFlight) return;

    _chartsRefreshInFlight = true;
    _isLoadingCharts = true;
    notifyListeners();

    try {
      final summary = _snapshot != null
          ? _summaryFromSnapshot(_snapshot!)
          : await _summaryRepo.loadCachedSummary();

      if (summary == null) {
        _chartsLoaded = false;
        return;
      }

      final bundle = await _summaryRepo.fetchCharts(
        range: _range,
        summary: summary,
      );
      _charts = bundle;
      await _summaryRepo.cacheCharts(_range, bundle);
      _chartsLoaded = true;
      _mergeChartsIntoSnapshot(bundle);
    } catch (_) {
      final cached = await _summaryRepo.loadCachedCharts(_range);
      if (cached != null) {
        _charts = cached;
        _chartsLoaded = true;
        _mergeChartsIntoSnapshot(cached);
      }
    } finally {
      _chartsRefreshInFlight = false;
      _isLoadingCharts = false;
      if (_snapshot != null) {
        _forecast?.generate(snapshot: _snapshot!, charts: _charts);
      }
      notifyListeners();
    }
  }

  void setRange(AnalyticsRange range) {
    if (_range == range) return;
    _range = range;
    if (range != AnalyticsRange.custom) {
      _customRangeStart = null;
      _customRangeEnd = null;
    }
    _chartsLoaded = false;
    _charts = null;
    notifyListeners();
    if (_dashboardActive && _chartsRequested) loadCharts(force: true);
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    _customRangeStart = start;
    _customRangeEnd = end;
    setRange(AnalyticsRange.custom);
  }

  void requestCharts() {
    if (_chartsRequested && _chartsLoaded) return;
    _chartsRequested = true;
    notifyListeners();
    if (_dashboardActive) loadCharts();
  }

  void requestActivityFeed() {
    if (_activityRequested) return;
    _activityRequested = true;
    notifyListeners();
  }

  void setReportsExpanded(bool expanded) {
    _reportsExpanded = expanded;
    notifyListeners();
  }

  void loadMoreSessions() {
    _sessionPage++;
    _rebuildSessionPage();
    notifyListeners();
  }

  void loadMoreErrors() {
    _errorPage++;
    notifyListeners();
  }

  void terminateSession(String sessionId) {
    _terminatedSessions.add(sessionId);
    _sessions = _sessions.where((s) => s.id != sessionId).toList();
    notifyListeners();
  }

  void lockUser(String userName) {
    if (_lockedUserIds.contains(userName)) return;
    _lockedUserIds.add(userName);
    notifyListeners();
  }

  void unlockUser(String userName) {
    if (!_lockedUserIds.remove(userName)) return;
    notifyListeners();
  }

  void forceLogout(String sessionId) => terminateSession(sessionId);

  String todaysRevenueLabel() {
    final s = _snapshot;
    if (s == null) return '—';
    final monthly = _parseRevenueNumber(s.monthlyRevenue);
    return '${(monthly / 30).round()}K IQD';
  }

  String advertisementRevenueLabel() {
    final s = _snapshot;
    if (s == null) return '—';
    final clicks = s.adClicks;
    return '${(clicks * 2.5).round()}K IQD';
  }

  String avgRevenuePerDoctorLabel() {
    final s = _snapshot;
    if (s == null || s.totalDoctors == 0) return '—';
    final monthly = _parseRevenueNumber(s.monthlyRevenue);
    return '${(monthly / s.totalDoctors).round()}K IQD';
  }

  int _parseRevenueNumber(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  String exportMonitoringReport(ReportExportFormat format) {
    final s = _snapshot;
    if (s == null) return '';
    final rows = <List<String>>[
      ['Metric', 'Value'],
      ['Total Users', '${s.totalUsers}'],
      ['Total Doctors', '${s.totalDoctors}'],
      ['Total Patients', '${s.totalPatients}'],
      ['Monthly Revenue', s.monthlyRevenue],
      ['Annual Revenue', s.annualRevenue],
      ['Active Queues', '${s.activeQueues}'],
      ['Today Appointments', '${s.todaysAppointments}'],
    ];
    return switch (format) {
      ReportExportFormat.csv => _rowsToCsv(rows),
      ReportExportFormat.excel => rows.map((r) => r.join('\t')).join('\n'),
      ReportExportFormat.pdf => _rowsToPdfText(rows),
    };
  }

  String exportBackupReport() {
    final buffer = StringBuffer('Backup Report\n');
    buffer.writeln('Status: ${_backup.status}');
    buffer.writeln('Size: ${_backup.sizeLabel}');
    buffer.writeln('Last: ${_backup.lastBackup}');
    buffer.writeln('Next: ${_backup.nextScheduled}');
    for (final h in _backupHistory) {
      buffer.writeln('${h.timestamp} | ${h.status} | ${h.sizeLabel} | ${h.trigger}');
    }
    return buffer.toString();
  }

  String _rowsToCsv(List<List<String>> rows) =>
      rows.map((r) => r.map(_csvCell).join(',')).join('\n');

  String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

  String _rowsToPdfText(List<List<String>> rows) {
    final buffer = StringBuffer('TABIB PLATFORM REPORT\n');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}\n');
    for (final row in rows) {
      buffer.writeln('${row.first}: ${row.length > 1 ? row[1] : ''}');
    }
    return buffer.toString();
  }

  Future<void> runManualBackup() async {
    final now = DateTime.now();
    _backup = BackupSnapshot(
      lastBackup: now,
      sizeLabel: _backup.sizeLabel,
      status: 'Completed',
      nextScheduled: now.add(const Duration(hours: 24)),
    );
    _backupHistory.insert(
      0,
      BackupHistoryEntry(
        id: 'backup_${now.millisecondsSinceEpoch}',
        timestamp: now,
        sizeLabel: _backup.sizeLabel,
        status: 'Completed',
        trigger: 'Manual',
      ),
    );
    notifyListeners();
  }

  void _applySummary(
    PlatformDashboardSummary summary, {
    bool fromCache = false,
    int? responseMs,
  }) {
    final configured = DefaultFirebaseOptions.isConfigured;
    final connected = FirebaseBootstrap.initialized;
    final openErrors = _errorLog.openEntries.length;
    final totalErrors = _errorLog.entries.length;
    final errorRate =
        totalErrors == 0 ? 0.0 : (openErrors / totalErrors) * 100;

    _criticalAlerts = _buildCriticalAlerts(
      connected: connected,
      configured: configured,
      storagePercent: summary.storageUsagePercent,
      responseMs: responseMs ?? summary.firestoreReads,
      errorRate: errorRate,
      expiringSoon: summary.expiringSoonSubscriptions,
      failedLogins: summary.failedLoginAttempts,
      backupStatus: _backup.status,
    );

    final health = _healthLevel(_criticalAlerts, connected, configured, errorRate);

    _sessions = _buildSessions(_staffData.staffIncludingHidden);
    _backup = BackupSnapshot(
      lastBackup: fromCache
          ? _backup.lastBackup
          : DateTime.now().subtract(const Duration(hours: 6)),
      sizeLabel: '${summary.storageUsageMb.toStringAsFixed(1)} MB',
      status: connected ? 'Healthy' : 'Demo snapshot',
      nextScheduled: DateTime.now().add(const Duration(hours: 18)),
    );

    _snapshot = _buildSnapshot(
      summary: summary,
      health: health,
      alerts: _criticalAlerts,
      connected: connected,
      configured: configured,
      errorRate: errorRate,
      openErrors: openErrors,
      responseMs: responseMs,
      fromCache: fromCache,
    );

    if (fromCache && _lastSuccessfulSync == null) {
      _lastSuccessfulSync = summary.updatedAt;
    }

    unawaited(_activityFeed?.syncFromSummary(summary));
    if (_snapshot != null) {
      _syncPhase4(_snapshot!, _snapshot!.healthLevel);
    }
  }

  SystemMonitoringSnapshot _buildSnapshot({
    required PlatformDashboardSummary summary,
    required SystemHealthLevel health,
    required List<OwnerAlert> alerts,
    required bool connected,
    required bool configured,
    required double errorRate,
    required int openErrors,
    int? responseMs,
    required bool fromCache,
  }) {
    return SystemMonitoringSnapshot(
      updatedAt: summary.updatedAt,
      healthLevel: health,
      totalUsers: summary.totalUsers,
      onlineUsers: summary.onlineUsers,
      activeToday: summary.activeToday,
      newRegistrationsToday: summary.newRegistrationsToday,
      totalDoctors: summary.totalDoctors,
      activeDoctors: summary.activeDoctors,
      suspendedDoctors: summary.suspendedDoctors,
      expiredPackages: summary.expiredPackages,
      onlineDoctors: summary.onlineDoctors,
      totalSecretaries: summary.totalSecretaries,
      onlineSecretaries: summary.onlineSecretaries,
      secretariesWithoutDoctor: summary.secretariesWithoutDoctor,
      recentSecretaries: summary.recentSecretaries,
      totalBusinesses: summary.totalBusinesses,
      clinics: summary.clinics,
      beautyCenters: summary.beautyCenters,
      laboratories: summary.laboratories,
      pharmacies: summary.pharmacies,
      otherHealthcare: summary.otherHealthcare,
      totalPatients: summary.totalPatients,
      onlinePatients: summary.onlinePatients,
      newPatientsToday: summary.newPatientsToday,
      activeQueues: summary.queueWaiting + summary.queueInProgress,
      waitingPatients: summary.queueWaiting,
      completedQueuesToday: summary.completedQueuesToday,
      cancelledQueues: summary.cancelledQueues,
      avgWaitingMinutes: summary.avgWaitingMinutes,
      todaysAppointments: summary.todaysAppointments,
      upcomingAppointments: summary.upcomingAppointments,
      missedAppointments: summary.missedAppointments,
      cancelledAppointments: summary.cancelledAppointments,
      firebaseConnected: connected,
      firebaseConfigured: configured,
      firestoreReads: summary.firestoreReads,
      firestoreWrites: summary.firestoreWrites,
      storageUsageMb: summary.storageUsageMb,
      imageStorageMb: summary.imageStorageMb,
      responseTimeMs: responseMs ?? 120,
      cacheEnabled: true,
      lastSync: fromCache ? _lastSuccessfulSync : DateTime.now(),
      storageUsagePercent: summary.storageUsagePercent,
      cpuUsagePercent: _simulateCpu(),
      memoryUsagePercent: _simulateMemory(),
      avgApiResponseMs: max(responseMs ?? 120, 120),
      slowQueries: openErrors > 0 ? 1 : 0,
      backgroundTasks: 3,
      cacheHitRate: fromCache ? 100 : 92,
      errorRatePercent: errorRate,
      pushSent: summary.pushSent,
      whatsappSent: summary.whatsappSent,
      smsSent: summary.smsSent,
      failedNotifications: max(summary.failedNotifications, openErrors),
      pendingNotifications: summary.pendingNotifications,
      activeAds: summary.activeAds,
      scheduledAds: summary.scheduledAds,
      expiredAds: summary.expiredAds,
      adViews: summary.adViews,
      adClicks: summary.adClicks,
      adClickRate: summary.adClickRate,
      monthlyRevenue: summary.monthlyRevenueLabel,
      annualRevenue: summary.annualRevenueLabel,
      activePackages: summary.activeSubscriptions,
      packagesExpiringSoon: summary.expiringSoonSubscriptions,
      renewalsToday: summary.expiringSoonSubscriptions > 0 ? 1 : 0,
      failedLoginAttempts: summary.failedLoginAttempts,
      lockedAccounts: summary.lockedAccounts,
      suspiciousLogins: _sessions.where((s) => s.suspicious).length,
      activeSessions: summary.activeSessionsCount,
      alerts: alerts,
      chartRegistrations: _charts?.registrations ?? const [],
      chartQueues: _charts?.queues ?? const [],
      chartAppointments: _charts?.appointments ?? const [],
      chartRevenue: _charts?.revenue ?? const [],
      chartAdPerformance: _charts?.adPerformance ?? const [],
      chartUserGrowth: _charts?.userGrowth ?? const [],
      chartActiveUsers: _charts?.activeUsers ?? const [],
      chartBusinessGrowth: _charts?.businessGrowth ?? const [],
      isFromCache: fromCache || _showingCachedData,
      isLiveDataAvailable: !_isOffline && !fromCache,
    );
  }

  void _mergeChartsIntoSnapshot(DashboardChartsBundle bundle) {
    final current = _snapshot;
    if (current == null) return;
    _snapshot = SystemMonitoringSnapshot(
      updatedAt: current.updatedAt,
      healthLevel: current.healthLevel,
      totalUsers: current.totalUsers,
      onlineUsers: current.onlineUsers,
      activeToday: current.activeToday,
      newRegistrationsToday: current.newRegistrationsToday,
      totalDoctors: current.totalDoctors,
      activeDoctors: current.activeDoctors,
      suspendedDoctors: current.suspendedDoctors,
      expiredPackages: current.expiredPackages,
      onlineDoctors: current.onlineDoctors,
      totalSecretaries: current.totalSecretaries,
      onlineSecretaries: current.onlineSecretaries,
      secretariesWithoutDoctor: current.secretariesWithoutDoctor,
      recentSecretaries: current.recentSecretaries,
      totalBusinesses: current.totalBusinesses,
      clinics: current.clinics,
      beautyCenters: current.beautyCenters,
      laboratories: current.laboratories,
      pharmacies: current.pharmacies,
      otherHealthcare: current.otherHealthcare,
      totalPatients: current.totalPatients,
      onlinePatients: current.onlinePatients,
      newPatientsToday: current.newPatientsToday,
      activeQueues: current.activeQueues,
      waitingPatients: current.waitingPatients,
      completedQueuesToday: current.completedQueuesToday,
      cancelledQueues: current.cancelledQueues,
      avgWaitingMinutes: current.avgWaitingMinutes,
      todaysAppointments: current.todaysAppointments,
      upcomingAppointments: current.upcomingAppointments,
      missedAppointments: current.missedAppointments,
      cancelledAppointments: current.cancelledAppointments,
      firebaseConnected: current.firebaseConnected,
      firebaseConfigured: current.firebaseConfigured,
      firestoreReads: current.firestoreReads,
      firestoreWrites: current.firestoreWrites,
      storageUsageMb: current.storageUsageMb,
      imageStorageMb: current.imageStorageMb,
      responseTimeMs: current.responseTimeMs,
      cacheEnabled: current.cacheEnabled,
      lastSync: current.lastSync,
      storageUsagePercent: current.storageUsagePercent,
      cpuUsagePercent: current.cpuUsagePercent,
      memoryUsagePercent: current.memoryUsagePercent,
      avgApiResponseMs: current.avgApiResponseMs,
      slowQueries: current.slowQueries,
      backgroundTasks: current.backgroundTasks,
      cacheHitRate: current.cacheHitRate,
      errorRatePercent: current.errorRatePercent,
      pushSent: current.pushSent,
      whatsappSent: current.whatsappSent,
      smsSent: current.smsSent,
      failedNotifications: current.failedNotifications,
      pendingNotifications: current.pendingNotifications,
      activeAds: current.activeAds,
      scheduledAds: current.scheduledAds,
      expiredAds: current.expiredAds,
      adViews: current.adViews,
      adClicks: current.adClicks,
      adClickRate: current.adClickRate,
      monthlyRevenue: current.monthlyRevenue,
      annualRevenue: current.annualRevenue,
      activePackages: current.activePackages,
      packagesExpiringSoon: current.packagesExpiringSoon,
      renewalsToday: current.renewalsToday,
      failedLoginAttempts: current.failedLoginAttempts,
      lockedAccounts: current.lockedAccounts,
      suspiciousLogins: current.suspiciousLogins,
      activeSessions: current.activeSessions,
      alerts: current.alerts,
      chartRegistrations: bundle.registrations,
      chartQueues: bundle.queues,
      chartAppointments: bundle.appointments,
      chartRevenue: bundle.revenue,
      chartAdPerformance: bundle.adPerformance,
      chartUserGrowth: bundle.userGrowth,
      chartActiveUsers: bundle.activeUsers,
      chartBusinessGrowth: bundle.businessGrowth,
      isFromCache: current.isFromCache,
      isLiveDataAvailable: current.isLiveDataAvailable,
    );
  }

  PlatformDashboardSummary _summaryFromSnapshot(SystemMonitoringSnapshot s) {
    return PlatformDashboardSummary(
      updatedAt: s.updatedAt,
      totalUsers: s.totalUsers,
      onlineUsers: s.onlineUsers,
      activeToday: s.activeToday,
      newRegistrationsToday: s.newRegistrationsToday,
      totalDoctors: s.totalDoctors,
      activeDoctors: s.activeDoctors,
      suspendedDoctors: s.suspendedDoctors,
      expiredPackages: s.expiredPackages,
      onlineDoctors: s.onlineDoctors,
      totalSecretaries: s.totalSecretaries,
      onlineSecretaries: s.onlineSecretaries,
      secretariesWithoutDoctor: s.secretariesWithoutDoctor,
      recentSecretaries: s.recentSecretaries,
      totalBusinesses: s.totalBusinesses,
      clinics: s.clinics,
      beautyCenters: s.beautyCenters,
      laboratories: s.laboratories,
      pharmacies: s.pharmacies,
      otherHealthcare: s.otherHealthcare,
      totalPatients: s.totalPatients,
      onlinePatients: s.onlinePatients,
      newPatientsToday: s.newPatientsToday,
      queueWaiting: s.waitingPatients,
      queueInProgress: s.activeQueues - s.waitingPatients,
      completedQueuesToday: s.completedQueuesToday,
      cancelledQueues: s.cancelledQueues,
      avgWaitingMinutes: s.avgWaitingMinutes,
      todaysAppointments: s.todaysAppointments,
      upcomingAppointments: s.upcomingAppointments,
      missedAppointments: s.missedAppointments,
      cancelledAppointments: s.cancelledAppointments,
      firestoreReads: s.firestoreReads,
      firestoreWrites: s.firestoreWrites,
      storageUsageMb: s.storageUsageMb,
      imageStorageMb: s.imageStorageMb,
      storageUsagePercent: s.storageUsagePercent,
      activeSubscriptions: s.activePackages,
      expiringSoonSubscriptions: s.packagesExpiringSoon,
      monthlyRevenueLabel: s.monthlyRevenue,
      annualRevenueLabel: s.annualRevenue,
      activeAds: s.activeAds,
      scheduledAds: s.scheduledAds,
      expiredAds: s.expiredAds,
      adViews: s.adViews,
      adClicks: s.adClicks,
      pushSent: s.pushSent,
      whatsappSent: s.whatsappSent,
      smsSent: s.smsSent,
      failedNotifications: s.failedNotifications,
      pendingNotifications: s.pendingNotifications,
      failedLoginAttempts: s.failedLoginAttempts,
      lockedAccounts: s.lockedAccounts,
      activeSessionsCount: s.activeSessions,
    );
  }

  void _refreshCriticalAlerts() {
    if (!_dashboardActive && _snapshot == null) return;

    final configured = DefaultFirebaseOptions.isConfigured;
    final connected = FirebaseBootstrap.initialized;
    final openErrors = _errorLog.openEntries.length;
    final totalErrors = _errorLog.entries.length;
    final errorRate =
        totalErrors == 0 ? 0.0 : (openErrors / totalErrors) * 100;
    final storagePercent = _snapshot?.storageUsagePercent ?? 0;
    final expiringSoon = _snapshot?.packagesExpiringSoon ?? 0;
    final failedLogins = _snapshot?.failedLoginAttempts ?? 0;

    final next = _buildCriticalAlerts(
      connected: connected,
      configured: configured,
      storagePercent: storagePercent,
      responseMs: _snapshot?.responseTimeMs ?? 0,
      errorRate: errorRate,
      expiringSoon: expiringSoon,
      failedLogins: failedLogins,
      backupStatus: _backup.status,
    );

    if (!_alertsChanged(_criticalAlerts, next)) return;

    _criticalAlerts = next;
    if (_snapshot != null) {
      final s = _snapshot!;
      final health = _healthLevel(next, connected, configured, errorRate);
      _snapshot = SystemMonitoringSnapshot(
        updatedAt: s.updatedAt,
        healthLevel: health,
        totalUsers: s.totalUsers,
        onlineUsers: s.onlineUsers,
        activeToday: s.activeToday,
        newRegistrationsToday: s.newRegistrationsToday,
        totalDoctors: s.totalDoctors,
        activeDoctors: s.activeDoctors,
        suspendedDoctors: s.suspendedDoctors,
        expiredPackages: s.expiredPackages,
        onlineDoctors: s.onlineDoctors,
        totalSecretaries: s.totalSecretaries,
        onlineSecretaries: s.onlineSecretaries,
        secretariesWithoutDoctor: s.secretariesWithoutDoctor,
        recentSecretaries: s.recentSecretaries,
        totalBusinesses: s.totalBusinesses,
        clinics: s.clinics,
        beautyCenters: s.beautyCenters,
        laboratories: s.laboratories,
        pharmacies: s.pharmacies,
        otherHealthcare: s.otherHealthcare,
        totalPatients: s.totalPatients,
        onlinePatients: s.onlinePatients,
        newPatientsToday: s.newPatientsToday,
        activeQueues: s.activeQueues,
        waitingPatients: s.waitingPatients,
        completedQueuesToday: s.completedQueuesToday,
        cancelledQueues: s.cancelledQueues,
        avgWaitingMinutes: s.avgWaitingMinutes,
        todaysAppointments: s.todaysAppointments,
        upcomingAppointments: s.upcomingAppointments,
        missedAppointments: s.missedAppointments,
        cancelledAppointments: s.cancelledAppointments,
        firebaseConnected: connected,
        firebaseConfigured: configured,
        firestoreReads: s.firestoreReads,
        firestoreWrites: s.firestoreWrites,
        storageUsageMb: s.storageUsageMb,
        imageStorageMb: s.imageStorageMb,
        responseTimeMs: s.responseTimeMs,
        cacheEnabled: s.cacheEnabled,
        lastSync: s.lastSync,
        storageUsagePercent: s.storageUsagePercent,
        cpuUsagePercent: s.cpuUsagePercent,
        memoryUsagePercent: s.memoryUsagePercent,
        avgApiResponseMs: s.avgApiResponseMs,
        slowQueries: s.slowQueries,
        backgroundTasks: s.backgroundTasks,
        cacheHitRate: s.cacheHitRate,
        errorRatePercent: errorRate,
        pushSent: s.pushSent,
        whatsappSent: s.whatsappSent,
        smsSent: s.smsSent,
        failedNotifications: max(s.failedNotifications, openErrors),
        pendingNotifications: s.pendingNotifications,
        activeAds: s.activeAds,
        scheduledAds: s.scheduledAds,
        expiredAds: s.expiredAds,
        adViews: s.adViews,
        adClicks: s.adClicks,
        adClickRate: s.adClickRate,
        monthlyRevenue: s.monthlyRevenue,
        annualRevenue: s.annualRevenue,
        activePackages: s.activePackages,
        packagesExpiringSoon: s.packagesExpiringSoon,
        renewalsToday: s.renewalsToday,
        failedLoginAttempts: s.failedLoginAttempts,
        lockedAccounts: s.lockedAccounts,
        suspiciousLogins: s.suspiciousLogins,
        activeSessions: s.activeSessions,
        alerts: next,
        chartRegistrations: s.chartRegistrations,
        chartQueues: s.chartQueues,
        chartAppointments: s.chartAppointments,
        chartRevenue: s.chartRevenue,
        chartAdPerformance: s.chartAdPerformance,
        chartUserGrowth: s.chartUserGrowth,
        chartActiveUsers: s.chartActiveUsers,
        chartBusinessGrowth: s.chartBusinessGrowth,
        isFromCache: s.isFromCache,
        isLiveDataAvailable: s.isLiveDataAvailable && connected,
      );
    }
    notifyListeners();
  }

  bool _alertsChanged(List<OwnerAlert> a, List<OwnerAlert> b) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i].type != b[i].type || a[i].message != b[i].message) return true;
    }
    return false;
  }

  void _rebuildSessionPage() {
    _sessions = _buildSessions(_staffData.staffIncludingHidden);
  }

  int _simulateCpu() => 24 + Random().nextInt(18);

  int _simulateMemory() => 38 + Random().nextInt(22);

  List<OwnerAlert> _buildCriticalAlerts({
    required bool connected,
    required bool configured,
    required int storagePercent,
    required int responseMs,
    required double errorRate,
    required int expiringSoon,
    required int failedLogins,
    required String backupStatus,
  }) {
    final now = DateTime.now();
    final alerts = <OwnerAlert>[];

    if (configured && !connected) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.firebaseDisconnected,
        message: 'Firebase is disconnected',
        severity: SystemHealthLevel.critical,
        timestamp: now,
      ));
    }
    if (backupStatus.toLowerCase().contains('fail')) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.backupFailed,
        message: 'Last backup failed',
        severity: SystemHealthLevel.critical,
        timestamp: now,
      ));
    }
    if (storagePercent >= 90) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.storageCritical,
        message: 'Storage usage at $storagePercent%',
        severity: SystemHealthLevel.critical,
        timestamp: now,
      ));
    } else if (storagePercent >= 80) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.storageWarning,
        message: 'Storage usage at $storagePercent%',
        severity: SystemHealthLevel.warning,
        timestamp: now,
      ));
    }
    if (responseMs >= 1200) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.slowPerformance,
        message: 'System performance is slow (${responseMs}ms)',
        severity: SystemHealthLevel.warning,
        timestamp: now,
      ));
    }
    if (errorRate >= 8) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.highErrorRate,
        message: 'High error rate ${errorRate.toStringAsFixed(1)}%',
        severity: SystemHealthLevel.warning,
        timestamp: now,
      ));
    }
    if (_errorLog.entries.any((e) =>
        e.severity == AppErrorSeverity.critical &&
        e.status == AppErrorStatus.open)) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.highErrorRate,
        message: 'Critical application errors detected',
        severity: SystemHealthLevel.critical,
        timestamp: now,
      ));
    }
    if (expiringSoon > 0) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.packageExpiresToday,
        message: '$expiringSoon package(s) expiring soon',
        severity: SystemHealthLevel.warning,
        timestamp: now,
      ));
    }
    if (failedLogins >= 8) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.loginFailures,
        message: '$failedLogins failed login attempts',
        severity: SystemHealthLevel.warning,
        timestamp: now,
      ));
    }
    if (_sessions.any((s) => s.suspicious)) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.loginFailures,
        message: 'Suspicious login activity detected',
        severity: SystemHealthLevel.critical,
        timestamp: now,
      ));
    }
    if (_errorLog.entries.any(
      (e) =>
          e.module.toLowerCase().contains('notification') &&
          e.status == AppErrorStatus.open,
    )) {
      alerts.add(OwnerAlert(
        type: OwnerAlertType.pushServiceFailed,
        message: 'Push notification service failures detected',
        severity: SystemHealthLevel.critical,
        timestamp: now,
      ));
    }
    return alerts;
  }

  SystemHealthLevel _healthLevel(
    List<OwnerAlert> alerts,
    bool connected,
    bool configured,
    double errorRate,
  ) {
    if (alerts.any((a) => a.severity == SystemHealthLevel.critical)) {
      return SystemHealthLevel.critical;
    }
    if (configured && !connected) return SystemHealthLevel.critical;
    if (errorRate >= 12) return SystemHealthLevel.critical;
    if (alerts.isNotEmpty) return SystemHealthLevel.warning;
    return SystemHealthLevel.healthy;
  }

  List<ActiveSessionEntry> _buildSessions(List<UserAccount> staff) {
    final pool = staff
        .where((a) => !SystemOwnerPrivacy.isInternalPlatformAccount(a))
        .take(sessionPageSize * _sessionPage)
        .toList();
    return [
      for (var i = 0; i < pool.length; i++)
        ActiveSessionEntry(
          id: 'session_${pool[i].id}',
          userName: pool[i].name.en.isNotEmpty
              ? pool[i].name.en
              : pool[i].name.ar,
          role: pool[i].role.name,
          device: i.isEven ? 'web' : 'android',
          platform: i.isEven ? 'Chrome' : 'Android',
          lastActive: DateTime.now().subtract(Duration(minutes: 5 * i)),
          suspicious: i == pool.length - 1 && pool.length > 3,
        ),
    ];
  }
}
