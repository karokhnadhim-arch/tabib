import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/owner_monitoring_phase4.dart';
import '../../../../services/owner_dashboard_navigation_service.dart';

/// Wraps a dashboard section with a [GlobalKey] for scroll-to navigation.
class OwnerDashboardSectionAnchor extends StatelessWidget {
  const OwnerDashboardSectionAnchor({
    super.key,
    required this.section,
    required this.child,
  });

  final MonitoringDashboardSection section;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final key = context.read<OwnerDashboardNavigationService>().keyFor(section);
    return KeyedSubtree(
      key: key,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: child,
      ),
    );
  }
}

/// Horizontal section index — jump to any monitoring module instantly.
class OwnerDashboardSectionNavigator extends StatelessWidget {
  const OwnerDashboardSectionNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nav = context.read<OwnerDashboardNavigationService>();
    final scheme = Theme.of(context).colorScheme;

    final sections = <(MonitoringDashboardSection, String)>[
      (MonitoringDashboardSection.systemHealth, l10n.systemHealth),
      (MonitoringDashboardSection.liveStatistics, l10n.liveStatistics),
      (MonitoringDashboardSection.activityFeed, l10n.liveActivityFeed),
      (MonitoringDashboardSection.aiInsights, l10n.aiInsightsCenter),
      (MonitoringDashboardSection.forecast, l10n.forecastDashboard),
      (MonitoringDashboardSection.smartNotifications, l10n.smartOwnerNotifications),
      (MonitoringDashboardSection.firebaseCost, l10n.firebaseCostOptimizer),
      (MonitoringDashboardSection.advertisementMonitoring, l10n.advertisementMonitoring),
      (MonitoringDashboardSection.notificationMonitoring, l10n.notificationMonitoring),
      (MonitoringDashboardSection.queueAnalytics, l10n.queueAnalytics),
      (MonitoringDashboardSection.appointmentAnalytics, l10n.appointmentAnalytics),
      (MonitoringDashboardSection.packageAnalytics, l10n.packageAnalytics),
      (MonitoringDashboardSection.analyticsCharts, l10n.analyticsDashboard),
      (MonitoringDashboardSection.revenue, l10n.revenueDashboard),
      (MonitoringDashboardSection.security, l10n.securityCenter),
      (MonitoringDashboardSection.sessionManager, l10n.sessionManager),
      (MonitoringDashboardSection.errorMonitoring, l10n.errorMonitoring),
      (MonitoringDashboardSection.backup, l10n.backupRestore),
      (MonitoringDashboardSection.auditLog, l10n.auditLog),
      (MonitoringDashboardSection.reports, l10n.generateReports),
      (MonitoringDashboardSection.maintenance, l10n.maintenanceMode),
      (MonitoringDashboardSection.appearance, l10n.appearance),
    ];

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.dashboardSectionNavigator,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sections.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(_iconFor(entry.$1), size: 18),
                      label: Text(entry.$2),
                      onPressed: () => nav.requestScroll(entry.$1),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(MonitoringDashboardSection section) => switch (section) {
        MonitoringDashboardSection.systemHealth => Icons.monitor_heart_outlined,
        MonitoringDashboardSection.liveStatistics => Icons.analytics_outlined,
        MonitoringDashboardSection.activityFeed => Icons.timeline_outlined,
        MonitoringDashboardSection.aiInsights => Icons.auto_awesome_outlined,
        MonitoringDashboardSection.forecast => Icons.trending_up,
        MonitoringDashboardSection.smartNotifications => Icons.notifications_active_outlined,
        MonitoringDashboardSection.firebaseCost => Icons.savings_outlined,
        MonitoringDashboardSection.advertisementMonitoring => Icons.campaign_outlined,
        MonitoringDashboardSection.notificationMonitoring => Icons.notifications_outlined,
        MonitoringDashboardSection.queueAnalytics => Icons.queue_outlined,
        MonitoringDashboardSection.appointmentAnalytics => Icons.calendar_month_outlined,
        MonitoringDashboardSection.packageAnalytics => Icons.card_membership_outlined,
        MonitoringDashboardSection.analyticsCharts => Icons.insights_outlined,
        MonitoringDashboardSection.revenue => Icons.payments_outlined,
        MonitoringDashboardSection.security => Icons.shield_outlined,
        MonitoringDashboardSection.sessionManager => Icons.manage_accounts_outlined,
        MonitoringDashboardSection.errorMonitoring => Icons.bug_report_outlined,
        MonitoringDashboardSection.backup => Icons.backup_outlined,
        MonitoringDashboardSection.auditLog => Icons.history,
        MonitoringDashboardSection.reports => Icons.summarize_outlined,
        MonitoringDashboardSection.maintenance => Icons.build_circle_outlined,
        MonitoringDashboardSection.appearance => Icons.palette_outlined,
      };
}

/// Maps global search categories to dashboard scroll targets.
MonitoringDashboardSection? searchCategorySection(DashboardSearchCategory category) {
  return switch (category) {
    DashboardSearchCategory.advertisement =>
      MonitoringDashboardSection.advertisementMonitoring,
    DashboardSearchCategory.auditLog => MonitoringDashboardSection.auditLog,
    DashboardSearchCategory.queue => MonitoringDashboardSection.queueAnalytics,
    DashboardSearchCategory.appointment =>
      MonitoringDashboardSection.appointmentAnalytics,
    DashboardSearchCategory.package => MonitoringDashboardSection.packageAnalytics,
    DashboardSearchCategory.doctor ||
    DashboardSearchCategory.patient ||
    DashboardSearchCategory.secretary ||
    DashboardSearchCategory.business =>
      MonitoringDashboardSection.security,
  };
}
