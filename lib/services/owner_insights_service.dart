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
        recommendation:
            '${snapshot.waitingPatients} patients waiting (avg ${snapshot.avgWaitingMinutes} min). Consider adding secretary capacity during peak hours.',
        generatedAt: now,
      ));
    }

    if (snapshot.activeDoctors > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.medium,
        category: InsightCategory.doctors,
        title: 'Most active doctors',
        recommendation:
            '${snapshot.onlineDoctors} of ${snapshot.activeDoctors} active doctors are online. Peak activity likely between 10:00–14:00.',
        generatedAt: now,
      ));
    }

    if (snapshot.suspendedDoctors > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.low,
        category: InsightCategory.doctors,
        title: 'Least active doctors',
        recommendation:
            '${snapshot.suspendedDoctors} suspended doctor profile(s). Review engagement and subscription status.',
        generatedAt: now,
      ));
    }

    if (snapshot.newPatientsToday > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.medium,
        category: InsightCategory.patients,
        title: 'Peak patient hours',
        recommendation:
            '${snapshot.newPatientsToday} new patients today. Schedule ads and staff coverage for 09:00–12:00 and 16:00–19:00.',
        generatedAt: now,
      ));
    }

    next.add(OwnerInsight(
      id: _uuid.v4(),
      priority: InsightPriority.medium,
      category: InsightCategory.revenue,
      title: 'Revenue trend',
      recommendation:
          'Monthly revenue at ${snapshot.monthlyRevenue}. ${snapshot.packagesExpiringSoon > 0 ? "${snapshot.packagesExpiringSoon} renewal(s) expected soon." : "Renewal pipeline is stable."}',
      generatedAt: now,
    ));

    if (snapshot.packagesExpiringSoon > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.high,
        category: InsightCategory.packages,
        title: 'Package renewal prediction',
        recommendation:
            '${snapshot.packagesExpiringSoon} package(s) expiring soon. Proactive outreach could recover ${(snapshot.packagesExpiringSoon * 85)}% renewals.',
        generatedAt: now,
      ));
    }

    if (snapshot.adClickRate > 0) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.low,
        category: InsightCategory.advertisements,
        title: 'Advertisement performance',
        recommendation:
            'CTR ${snapshot.adClickRate.toStringAsFixed(1)}% with ${snapshot.adViews} views. Test image creatives in ${snapshot.activeAds} active campaigns.',
        generatedAt: now,
      ));
    }

    if (snapshot.suspiciousLogins > 0 || snapshot.failedLoginAttempts >= 5) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.high,
        category: InsightCategory.security,
        title: 'Suspicious account activity',
        recommendation:
            '${snapshot.failedLoginAttempts} failed logins and ${snapshot.suspiciousLogins} suspicious session(s). Enable forced logout for stale sessions.',
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
        title: 'Firebase usage recommendation',
        recommendation:
            'Storage at ${snapshot.storageUsagePercent}%. Archive old images and rely on aggregated dashboard docs to limit reads.',
        generatedAt: now,
      ));
    }

    if (snapshot.responseTimeMs >= 800 || snapshot.avgApiResponseMs >= 800) {
      next.add(OwnerInsight(
        id: _uuid.v4(),
        priority: InsightPriority.medium,
        category: InsightCategory.performance,
        title: 'Performance improvement',
        recommendation:
            'API response ${snapshot.avgApiResponseMs}ms. Enable caching and avoid per-widget Firestore listeners on dashboards.',
        generatedAt: now,
      ));
    }

    _insights
      ..clear()
      ..addAll(next);
    notifyListeners();
  }
}
