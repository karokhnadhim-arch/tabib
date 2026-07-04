import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/owner_monitoring_phase4.dart';
import '../models/system_monitoring.dart';

/// Derives AI-style insights from aggregated monitoring data — zero collection scans.
class OwnerInsightsService extends ChangeNotifier {
  static const _uuid = Uuid();
  final List<OwnerInsight> _insights = [];

  List<OwnerInsight> get insights => List.unmodifiable(_insights);

  void generateFromSnapshot(SystemMonitoringSnapshot? snapshot) {
    if (snapshot == null) return;
    final now = DateTime.now();
    final next = <OwnerInsight>[];

    if (snapshot.waitingPatients > 5) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.high,
        category: InsightCategory.queues,
        title: 'Long waiting queues detected',
        description:
            '${snapshot.waitingPatients} patients waiting with an average of ${snapshot.avgWaitingMinutes} minutes.',
        recommendation:
            'Add secretary capacity during peak hours and enable queue notifications to reduce walk-outs.',
        generatedAt: now,
      ));
    }

    if (snapshot.activeDoctors > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.medium,
        category: InsightCategory.doctors,
        title: 'Most active doctors',
        description:
            '${snapshot.onlineDoctors} of ${snapshot.activeDoctors} active doctors are online right now.',
        recommendation:
            'Peak activity is likely between 10:00–14:00. Promote top performers in search results.',
        generatedAt: now,
      ));
    }

    if (snapshot.suspendedDoctors > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.low,
        category: InsightCategory.doctors,
        title: 'Least active doctors',
        description:
            '${snapshot.suspendedDoctors} doctor profile(s) are suspended or inactive.',
        recommendation:
            'Review engagement scores and subscription status; send reactivation campaigns.',
        generatedAt: now,
      ));
    }

    if (snapshot.newPatientsToday > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.medium,
        category: InsightCategory.patients,
        title: 'Peak patient hours',
        description:
            '${snapshot.newPatientsToday} new patients registered today across the platform.',
        recommendation:
            'Schedule ads and staff coverage for 09:00–12:00 and 16:00–19:00 windows.',
        generatedAt: now,
      ));
    }

    next.add(OwnerInsight(
      id: _uuid.v4(),
      priority: InsightPriority.medium,
      category: InsightCategory.revenue,
      title: 'Revenue trend',
      description:
          'Monthly revenue is ${snapshot.monthlyRevenue} with ${snapshot.renewalsToday} renewal(s) today.',
      recommendation:
          snapshot.packagesExpiringSoon > 0
              ? '${snapshot.packagesExpiringSoon} package(s) expiring soon — prioritize renewal outreach.'
              : 'Renewal pipeline is stable. Consider upselling annual plans.',
      generatedAt: now,
    ));

    if (snapshot.packagesExpiringSoon > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.high,
        category: InsightCategory.packages,
        title: 'Expiring packages',
        description:
            '${snapshot.packagesExpiringSoon} subscription package(s) will expire within 14 days.',
        recommendation:
            'Proactive outreach could recover up to ${(snapshot.packagesExpiringSoon * 85)}% of renewals.',
        generatedAt: now,
      ));
    }

    if (snapshot.adClickRate > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.low,
        category: InsightCategory.advertisements,
        title: 'Advertisement performance',
        description:
            'CTR ${snapshot.adClickRate.toStringAsFixed(1)}% from ${snapshot.adViews} views across ${snapshot.activeAds} active ads.',
        recommendation:
            'Test new image creatives and shift budget to top-performing placements.',
        generatedAt: now,
      ));
    }

    if (snapshot.suspiciousLogins > 0 || snapshot.failedLoginAttempts >= 5) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.high,
        category: InsightCategory.security,
        title: 'Suspicious activity',
        description:
            '${snapshot.failedLoginAttempts} failed logins and ${snapshot.suspiciousLogins} suspicious session(s) detected.',
        recommendation:
            'Force logout stale sessions and review locked accounts in Security Center.',
        generatedAt: now,
      ));
    }

    if (snapshot.storageUsagePercent >= 70) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: snapshot.storageUsagePercent >= 85
            ? InsightPriority.high
            : InsightPriority.medium,
        category: InsightCategory.firebase,
        title: 'Firebase optimization',
        description:
            'Storage at ${snapshot.storageUsagePercent}% with ${snapshot.firestoreReads} reads and ${snapshot.firestoreWrites} writes today.',
        recommendation:
            'Archive old images and rely on aggregated dashboardSummary docs to limit reads.',
        generatedAt: now,
      ));
    }

    if (snapshot.responseTimeMs >= 800 || snapshot.avgApiResponseMs >= 800) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.medium,
        category: InsightCategory.performance,
        title: 'Performance recommendation',
        description:
            'Average API response is ${snapshot.avgApiResponseMs}ms with ${snapshot.slowQueries} slow queries.',
        recommendation:
            'Enable local caching and avoid per-widget Firestore listeners on dashboards.',
        generatedAt: now,
      ));
    }

    _insights
      ..clear()
      ..addAll(next);
    notifyListeners();
  }
}
