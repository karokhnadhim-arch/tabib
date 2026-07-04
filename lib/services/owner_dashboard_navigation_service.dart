import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/auth/admin_routes.dart';

/// Scroll targets within the Owner Monitoring Center dashboard.
enum MonitoringDashboardSection {
  systemHealth,
  liveStatistics,
  activityFeed,
  aiInsights,
  forecast,
  smartNotifications,
  firebaseCost,
  advertisementMonitoring,
  notificationMonitoring,
  queueAnalytics,
  appointmentAnalytics,
  packageAnalytics,
  analyticsCharts,
  revenue,
  security,
  sessionManager,
  errorMonitoring,
  backup,
  auditLog,
  reports,
  maintenance,
  appearance,
}

/// Scrolls to anchored dashboard sections — no Firestore reads.
class OwnerDashboardNavigationService extends ChangeNotifier {
  final Map<MonitoringDashboardSection, GlobalKey> _keys = {
    for (final section in MonitoringDashboardSection.values)
      section: GlobalKey(debugLabel: section.name),
  };

  MonitoringDashboardSection? _pendingSection;

  GlobalKey keyFor(MonitoringDashboardSection section) => _keys[section]!;

  MonitoringDashboardSection? get pendingSection => _pendingSection;

  static String routeFor(MonitoringDashboardSection section) =>
      '${AdminRoutes.platformPrefix}/system-health?section=${section.name}';

  void requestScroll(MonitoringDashboardSection section) {
    _pendingSection = section;
    notifyListeners();
  }

  void clearPending() {
    if (_pendingSection == null) return;
    _pendingSection = null;
    notifyListeners();
  }

  bool scrollTo(MonitoringDashboardSection section) {
    final context = _keys[section]?.currentContext;
    if (context == null) return false;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
    return true;
  }

  bool consumePendingScroll() {
    final section = _pendingSection;
    if (section == null) return false;
    final scrolled = scrollTo(section);
    if (scrolled) _pendingSection = null;
    return scrolled;
  }

  MonitoringDashboardSection? sectionFromQuery(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final section in MonitoringDashboardSection.values) {
      if (section.name == raw) return section;
    }
    return null;
  }
}
