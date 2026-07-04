import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/owner_dashboard_filter_service.dart';
import '../../../../services/owner_dashboard_navigation_service.dart';
import '../../../../services/system_activity_feed_service.dart';
import '../../../../services/system_monitoring_service.dart';
import '../../../widgets/system_owner_guard.dart';
import 'owner_dashboard_filter_sync.dart';
import 'monitoring_filter_scope.dart';
import 'owner_monitoring_theme.dart';
import 'owner_phase1_monitoring_section.dart';
import 'owner_phase2_monitoring_sections.dart';
import 'owner_phase3_monitoring_sections.dart';
import 'owner_step3_operations_sections.dart';
import 'owner_step4_final_sections.dart';
import 'owner_phase4_monitoring_sections.dart';

/// Focused monitoring screen for sidebar / hub routes — embeds live dashboard sections.
class OwnerMonitoringFocusedScreen extends StatefulWidget {
  const OwnerMonitoringFocusedScreen({
    super.key,
    required this.section,
    required this.title,
    this.extraSections = const [],
  });

  final MonitoringDashboardSection section;
  final String title;
  final List<MonitoringDashboardSection> extraSections;

  @override
  State<OwnerMonitoringFocusedScreen> createState() =>
      _OwnerMonitoringFocusedScreenState();
}

class _OwnerMonitoringFocusedScreenState extends State<OwnerMonitoringFocusedScreen> {
  SystemMonitoringService? _monitoring;
  SystemActivityFeedService? _activity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _monitoring ??= context.read<SystemMonitoringService>()..activate();
    _activity ??= context.read<SystemActivityFeedService>()..activate();
  }

  @override
  void dispose() {
    _monitoring?.deactivate();
    _activity?.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final hasSnapshot = monitoring.snapshot != null;

    return SystemOwnerGuard(
      child: OwnerMonitoringTheme(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              TextButton.icon(
                onPressed: () => context.go(
                  OwnerDashboardNavigationService.routeFor(widget.section),
                ),
                icon: const Icon(Icons.open_in_full, size: 20),
                label: Text(l10n.viewFullMonitoringCenter),
              ),
            ],
          ),
          body: !hasSnapshot
              ? const Center(child: CircularProgressIndicator())
              : OwnerDashboardFilterSync(
                  child: MonitoringFilterScope(
                    scaleFactor: context.watch<OwnerDashboardFilterService>().scaleFactor,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final section in [widget.section, ...widget.extraSections])
                          _sectionWidget(section),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionWidget(MonitoringDashboardSection section) {
    return switch (section) {
      MonitoringDashboardSection.systemHealth =>
        const OwnerPhase1MonitoringSection(),
      MonitoringDashboardSection.liveStatistics =>
        const OwnerLiveStatisticsSection(),
      MonitoringDashboardSection.activityFeed =>
        const OwnerActivityFeedSection(),
      MonitoringDashboardSection.aiInsights =>
        const OwnerStep4AiInsightsSection(),
      MonitoringDashboardSection.forecast => const OwnerStep4ForecastSection(),
      MonitoringDashboardSection.smartNotifications =>
        const OwnerSmartNotificationsSection(),
      MonitoringDashboardSection.firebaseCost =>
        const OwnerStep4FirebaseCostSection(),
      MonitoringDashboardSection.advertisementMonitoring =>
        const OwnerAdvertisementMonitoringSection(),
      MonitoringDashboardSection.notificationMonitoring =>
        const OwnerNotificationMonitoringSection(),
      MonitoringDashboardSection.queueAnalytics =>
        const OwnerQueueAnalyticsSection(),
      MonitoringDashboardSection.appointmentAnalytics =>
        const OwnerAppointmentAnalyticsSection(),
      MonitoringDashboardSection.packageAnalytics =>
        const OwnerPackageAnalyticsSection(),
      MonitoringDashboardSection.analyticsCharts =>
        const OwnerPhase3AnalyticsSection(),
      MonitoringDashboardSection.revenue => const OwnerRevenueDashboardSection(),
      MonitoringDashboardSection.security => const OwnerSecurityCenterSection(),
      MonitoringDashboardSection.sessionManager =>
        const OwnerSessionManagerSection(),
      MonitoringDashboardSection.errorMonitoring =>
        const OwnerErrorMonitoringSection(),
      MonitoringDashboardSection.backup => const OwnerBackupCenterSection(),
      MonitoringDashboardSection.auditLog => const OwnerAuditLogSection(),
      MonitoringDashboardSection.reports => const OwnerReportsSection(),
      MonitoringDashboardSection.maintenance =>
        const OwnerMaintenanceModeSection(),
      MonitoringDashboardSection.appearance => const OwnerAppearanceSection(),
    };
  }
}

/// Reports & analytics hub — analytics, revenue, and export modules.
class OwnerMonitoringReportsScreen extends StatelessWidget {
  const OwnerMonitoringReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OwnerMonitoringFocusedScreen(
      section: MonitoringDashboardSection.analyticsCharts,
      title: l10n.reportsAnalytics,
      extraSections: const [
        MonitoringDashboardSection.revenue,
        MonitoringDashboardSection.reports,
      ],
    );
  }
}
