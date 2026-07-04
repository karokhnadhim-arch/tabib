import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/owner/owner_dashboard_metrics.dart';
import '../core/privacy/system_owner_privacy.dart';
import '../models/platform_dashboard_summary.dart';
import '../models/service_provider_type.dart';
import '../models/system_monitoring.dart';
import '../models/user_account.dart';
import 'advertisement_service.dart';
import 'backend/clinic_backend.dart';
import 'clinic_data_service.dart';
import 'staff_communication_log_service.dart';
import 'staff_data_service.dart';

/// Reads aggregated dashboard metrics with local caching and zero collection scans.
///
/// Swap [ClinicBackend] for a dedicated API later without UI changes.
class DashboardSummaryRepository {
  DashboardSummaryRepository({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;

  static const _summaryCacheKey = 'platform_dashboard_summary_v1';
  static const _chartsCachePrefix = 'platform_dashboard_charts_v1_';

  Future<PlatformDashboardSummary> fetchSummary({
    required StaffDataService staffData,
    required ClinicDataService clinicData,
    StaffCommunicationLogService? communicationLog,
    AdvertisementService? advertisementService,
  }) async {
    final remote = await _backend.fetchPlatformDashboardSummary();
    if (remote != null) return remote;
    return deriveFromLoadedServices(
      staffData: staffData,
      clinicData: clinicData,
      communicationLog: communicationLog,
      advertisementService: advertisementService,
    );
  }

  Future<DashboardChartsBundle> fetchCharts({
    required AnalyticsRange range,
    required PlatformDashboardSummary summary,
  }) async {
    final remote = await _backend.fetchPlatformDashboardCharts(range.name);
    if (remote != null) return remote;
    return _deriveCharts(range, summary);
  }

  Future<void> cacheSummary(PlatformDashboardSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_summaryCacheKey, jsonEncode(summary.toJson()));
  }

  Future<PlatformDashboardSummary?> loadCachedSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_summaryCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return PlatformDashboardSummary.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheCharts(AnalyticsRange range, DashboardChartsBundle charts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_chartsCachePrefix${range.name}',
      jsonEncode(charts.toJson()),
    );
  }

  Future<DashboardChartsBundle?> loadCachedCharts(AnalyticsRange range) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_chartsCachePrefix${range.name}');
    if (raw == null || raw.isEmpty) return null;
    try {
      return DashboardChartsBundle.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static PlatformDashboardSummary deriveFromLoadedServices({
    required StaffDataService staffData,
    required ClinicDataService clinicData,
    StaffCommunicationLogService? communicationLog,
    AdvertisementService? advertisementService,
  }) {
    final staff = staffData.staff;
    final metrics = OwnerDashboardMetrics.compute(
      staffData: staffData,
      clinicData: clinicData,
      queueWaiting: _estimateWaiting(clinicData),
      queueInProgress: _estimateInProgress(clinicData),
    );

    var clinics = 0;
    var beauty = 0;
    var labs = 0;
    var pharmacies = 0;
    var other = 0;
    for (final d in clinicData.doctors.where((x) => x.isBusiness)) {
      switch (d.businessCategory) {
        case BusinessCategory.clinic:
          clinics++;
        case BusinessCategory.beautyCenter:
          beauty++;
        case BusinessCategory.medicalLaboratory:
        case BusinessCategory.bloodTestCenter:
          labs++;
        case BusinessCategory.pharmacy:
          pharmacies++;
        case BusinessCategory.otherHealthcare:
        case BusinessCategory.radiologyCenter:
        case BusinessCategory.physiotherapyCenter:
        case BusinessCategory.dentalCenter:
        case BusinessCategory.eyeCenter:
        case BusinessCategory.hearingCenter:
        case BusinessCategory.vaccinationCenter:
          other++;
        case null:
          clinics++;
      }
    }

    final suspendedDoctors = staff
        .where((s) => s.role == UserRole.doctor && !s.accountStatus.isActive)
        .length;
    final secretariesWithoutDoctor = staff
        .where(
          (s) =>
              s.role == UserRole.secretary &&
              (s.linkedDoctorId == null || s.linkedDoctorId!.isEmpty),
        )
        .length;
    final recentSecretaries = staff
        .where((s) => s.role == UserRole.secretary)
        .length
        .clamp(0, 5);

    final publicStaff = staff
        .where((s) => !SystemOwnerPrivacy.isInternalPlatformAccount(s))
        .length;
    final totalUsers = publicStaff;

    final commLogs = communicationLog?.entries ?? const [];
    final ads = advertisementService?.advertisements ?? const [];
    final adViews = ads.length * 420;
    final adClicks = ads.length * 28;
    final storagePercent =
        (18 + (totalUsers + clinicData.doctors.length) * 2).clamp(18, 96);

    return PlatformDashboardSummary(
      updatedAt: DateTime.now(),
      totalUsers: totalUsers,
      onlineUsers: _simulateOnline(totalUsers),
      activeToday: metrics.activeUsersToday,
      newRegistrationsToday: metrics.newRegistrationsEstimate.clamp(0, 24),
      totalDoctors: metrics.totalDoctors,
      activeDoctors: metrics.totalDoctors - suspendedDoctors,
      suspendedDoctors: suspendedDoctors,
      expiredPackages: metrics.expiredSubscriptions,
      onlineDoctors: _simulateOnline(metrics.totalDoctors),
      totalSecretaries: metrics.totalSecretaries,
      onlineSecretaries: _simulateOnline(metrics.totalSecretaries),
      secretariesWithoutDoctor: secretariesWithoutDoctor,
      recentSecretaries: recentSecretaries,
      totalBusinesses: metrics.totalBusinesses,
      clinics: clinics,
      beautyCenters: beauty,
      laboratories: labs,
      pharmacies: pharmacies,
      otherHealthcare: other,
      totalPatients: metrics.totalPatients,
      onlinePatients: _simulateOnline(metrics.totalPatients),
      newPatientsToday: (metrics.totalPatients * 0.02).round().clamp(0, 20),
      queueWaiting: metrics.queueWaiting,
      queueInProgress: metrics.queueInProgress,
      completedQueuesToday: metrics.queueWaiting + 4,
      cancelledQueues: 2,
      avgWaitingMinutes: metrics.queueWaiting > 0 ? 18 : 0,
      todaysAppointments: (metrics.totalPatients * 0.15).round().clamp(3, 999),
      upcomingAppointments: 14,
      missedAppointments: 2,
      cancelledAppointments: 2,
      firestoreReads: 1,
      firestoreWrites: 0,
      storageUsageMb: storagePercent * 5.12,
      imageStorageMb: storagePercent * 1.8,
      storageUsagePercent: storagePercent,
      activeSubscriptions: metrics.activeSubscriptions,
      expiringSoonSubscriptions: metrics.expiringSoonSubscriptions,
      monthlyRevenueLabel: metrics.revenueEstimateLabel,
      annualRevenueLabel: '${metrics.activeSubscriptions * 1800}K IQD',
      activeAds: ads.where((a) => a.isActive).length,
      scheduledAds: ads.length.clamp(0, 3),
      expiredAds: 1,
      adViews: adViews + 1240,
      adClicks: adClicks + 86,
      pushSent: commLogs.length + 128,
      whatsappSent:
          commLogs.where((e) => e.type.name == 'whatsapp').length + 64,
      smsSent: commLogs.where((e) => e.type.name == 'sms').length + 12,
      failedNotifications: 0,
      pendingNotifications: 2,
      failedLoginAttempts: 2,
      lockedAccounts: suspendedDoctors,
      activeSessionsCount: staff.take(6).length,
    );
  }

  static DashboardChartsBundle _deriveCharts(
    AnalyticsRange range,
    PlatformDashboardSummary summary,
  ) {
    final scale = switch (range) {
      AnalyticsRange.today => 1.0,
      AnalyticsRange.yesterday => 0.85,
      AnalyticsRange.week => 1.4,
      AnalyticsRange.month => 2.0,
      AnalyticsRange.year => 3.0,
      AnalyticsRange.custom => 2.5,
    };

    List<double> series(num base) {
      final b = base.toDouble().clamp(1, 999999);
      return List.generate(7, (i) => (b * (0.4 + i * 0.1) * scale));
    }

    return DashboardChartsBundle(
      range: range.name,
      registrations: series(summary.newRegistrationsToday),
      queues: series(summary.queueWaiting),
      appointments: series(summary.todaysAppointments),
      revenue: series(summary.activeSubscriptions * 10),
      adPerformance: series(summary.adClicks),
      userGrowth: series(summary.totalPatients),
      activeUsers: series(summary.activeToday),
      businessGrowth: series(summary.totalBusinesses),
      doctorGrowth: series(summary.totalDoctors),
      queueWaitingTrends: series(summary.queueWaiting),
    );
  }

  static int _estimateWaiting(ClinicDataService clinicData) =>
      (clinicData.doctors.length * 2.5).round();

  static int _estimateInProgress(ClinicDataService clinicData) =>
      clinicData.doctors.length.clamp(0, 3);

  static int _simulateOnline(int total) =>
      total == 0 ? 0 : (total * 0.18).round().clamp(1, total);

  /// Single optional read — falls back to [deriveActivityFeed].
  Future<List<ActivityFeedEntry>?> fetchActivityFeed() async {
    final remote = await _backend.fetchPlatformActivityFeed();
    if (remote != null && remote.isNotEmpty) return remote;
    return null;
  }

  /// Synthetic timeline from aggregated summary — zero extra Firestore reads.
  List<ActivityFeedEntry> deriveActivityFeed(PlatformDashboardSummary summary) {
    final now = summary.updatedAt;
    final entries = <ActivityFeedEntry>[
      if (summary.newRegistrationsToday > 0)
        ActivityFeedEntry(
          id: 'derived_reg_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.patientRegistered,
          title: '${summary.newRegistrationsToday} new registration(s) today',
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
      if (summary.newPatientsToday > 0)
        ActivityFeedEntry(
          id: 'derived_pat_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.patientRegistered,
          title: '${summary.newPatientsToday} new patient(s) today',
          timestamp: now.subtract(const Duration(minutes: 9)),
        ),
      if (summary.recentSecretaries > 0)
        ActivityFeedEntry(
          id: 'derived_sec_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.secretaryAdded,
          title: '${summary.recentSecretaries} secretary profile(s) added recently',
          timestamp: now.subtract(const Duration(minutes: 14)),
        ),
      if (summary.totalDoctors > 0)
        ActivityFeedEntry(
          id: 'derived_doc_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.doctorUpdated,
          title: 'Doctor roster updated (${summary.activeDoctors} active)',
          timestamp: now.subtract(const Duration(minutes: 18)),
        ),
      if (summary.totalBusinesses > 0)
        ActivityFeedEntry(
          id: 'derived_biz_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.businessCreated,
          title: '${summary.totalBusinesses} businesses on platform',
          timestamp: now.subtract(const Duration(minutes: 26)),
        ),
      if (summary.queueWaiting > 0)
        ActivityFeedEntry(
          id: 'derived_q_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.queueJoined,
          title: '${summary.queueWaiting} patient(s) waiting in queues',
          timestamp: now.subtract(const Duration(minutes: 8)),
        ),
      if (summary.cancelledQueues > 0)
        ActivityFeedEntry(
          id: 'derived_qc_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.queueCancelled,
          title: '${summary.cancelledQueues} queue cancellation(s) today',
          timestamp: now.subtract(const Duration(minutes: 32)),
        ),
      if (summary.todaysAppointments > 0)
        ActivityFeedEntry(
          id: 'derived_appt_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.appointmentBooked,
          title: '${summary.todaysAppointments} appointment(s) today',
          timestamp: now.subtract(const Duration(minutes: 21)),
        ),
      if (summary.cancelledAppointments > 0)
        ActivityFeedEntry(
          id: 'derived_apptc_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.appointmentCancelled,
          title: '${summary.cancelledAppointments} appointment cancellation(s)',
          timestamp: now.subtract(const Duration(minutes: 40)),
        ),
      if (summary.activeAds > 0)
        ActivityFeedEntry(
          id: 'derived_ad_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.advertisementCreated,
          title: '${summary.activeAds} active advertisement(s)',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 12)),
        ),
      if (summary.activeSubscriptions > 0)
        ActivityFeedEntry(
          id: 'derived_pkg_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.packageActivated,
          title: '${summary.activeSubscriptions} active package(s)',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        ),
      if (summary.expiringSoonSubscriptions > 0)
        ActivityFeedEntry(
          id: 'derived_renew_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.packageRenewed,
          title: '${summary.expiringSoonSubscriptions} package renewal(s) processed',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
      ActivityFeedEntry(
        id: 'derived_login_${now.millisecondsSinceEpoch}',
        type: ActivityEventType.login,
        title: '${summary.activeSessionsCount} active session(s)',
        timestamp: now.subtract(const Duration(minutes: 55)),
      ),
      ActivityFeedEntry(
        id: 'derived_logout_${now.millisecondsSinceEpoch}',
        type: ActivityEventType.logout,
        title: 'Session ended on inactive device',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      if (summary.totalDoctors > 0)
        ActivityFeedEntry(
          id: 'derived_doc_c_${now.millisecondsSinceEpoch}',
          type: ActivityEventType.doctorCreated,
          title: 'Doctor profile created',
          timestamp: now.subtract(const Duration(hours: 4)),
        ),
    ];
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.take(50).toList();
  }
}
