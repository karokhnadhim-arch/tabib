import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/owner_dashboard_appearance_service.dart';
import '../../../../services/owner_dashboard_filter_service.dart';
import '../../../../services/owner_dashboard_navigation_service.dart';
import '../../../../services/system_activity_feed_service.dart';
import '../../../../services/system_monitoring_service.dart';
import '../../../widgets/system_owner_guard.dart';
import 'monitoring_filter_scope.dart';
import 'owner_dashboard_filter_sync.dart';
import 'owner_dashboard_navigation.dart';
import 'owner_monitoring_theme.dart';
import 'owner_phase1_monitoring_section.dart';
import 'owner_phase2_monitoring_sections.dart';
import 'owner_phase3_monitoring_sections.dart';
import 'owner_step3_operations_sections.dart';
import 'owner_step4_final_sections.dart';
import 'owner_phase4_monitoring_sections.dart';

/// Owner monitoring center — Phases 1–4 complete.
class OwnerSystemHealthDashboard extends StatefulWidget {
  const OwnerSystemHealthDashboard({super.key});

  @override
  State<OwnerSystemHealthDashboard> createState() =>
      _OwnerSystemHealthDashboardState();
}

class _OwnerSystemHealthDashboardState extends State<OwnerSystemHealthDashboard> {
  SystemMonitoringService? _monitoring;
  SystemActivityFeedService? _activity;
  OwnerDashboardNavigationService? _navigation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _monitoring ??= context.read<SystemMonitoringService>()..activate();
    _activity ??= context.read<SystemActivityFeedService>()..activate();
    _navigation ??= context.read<OwnerDashboardNavigationService>();

    final sectionParam = GoRouterState.of(context).uri.queryParameters['section'];
    final section = _navigation!.sectionFromQuery(sectionParam);
    if (section != null) {
      _navigation!.requestScroll(section);
    }
  }

  @override
  void dispose() {
    _monitoring?.deactivate();
    _activity?.deactivate();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await _monitoring?.refreshDashboard(force: true);
    await _monitoring?.refreshPhase3(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final filters = context.watch<OwnerDashboardFilterService>();
    final appearance = context.watch<OwnerDashboardAppearanceService>();
    final navigation = context.watch<OwnerDashboardNavigationService>();
    final hasSnapshot = monitoring.snapshot != null;
    final isRefreshing =
        monitoring.isRefreshingPhase1 || monitoring.isRefreshingPhase2;

    if (hasSnapshot && navigation.pendingSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_navigation?.consumePendingScroll() != true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigation?.consumePendingScroll();
          });
        }
      });
    }

    return SystemOwnerGuard(
      child: OwnerMonitoringTheme(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            title: Text(l10n.monitoringCenterTitle),
            actions: [
              IconButton(
                tooltip: l10n.advancedSystemSettings,
                icon: const Icon(Icons.tune_outlined),
                onPressed: () => context.push('/owner/console/system-health/settings'),
              ),
              if (isRefreshing)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  tooltip: l10n.dashboardRefreshNow,
                  onPressed: _refreshAll,
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
          body: !hasSnapshot
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: OwnerDashboardFilterSync(
                    child: MonitoringFilterScope(
                      scaleFactor: filters.scaleFactor,
                      child: OwnerDashboardResponsiveShell(
                        child: AnimatedPadding(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(
                            horizontal: appearance.horizontalPadding,
                            vertical: appearance.cardPadding,
                          ),
                          child: ListView(
                            children: [
                              const OwnerGlobalSearchBar(),
                              SizedBox(height: appearance.sectionSpacing),
                              const OwnerGlobalFilterBar(),
                              SizedBox(height: appearance.sectionSpacing),
                              const OwnerDashboardSectionNavigator(),
                              SizedBox(height: appearance.sectionSpacing * 1.25),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.systemHealth,
                                child: const OwnerPhase1MonitoringSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.liveStatistics,
                                child: const OwnerLiveStatisticsSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.activityFeed,
                                child: const OwnerActivityFeedSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.aiInsights,
                                child: const OwnerStep4AiInsightsSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.forecast,
                                child: const OwnerStep4ForecastSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.smartNotifications,
                                child: const OwnerSmartNotificationsSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.firebaseCost,
                                child: const OwnerStep4FirebaseCostSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.advertisementMonitoring,
                                child: const OwnerAdvertisementMonitoringSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.notificationMonitoring,
                                child: const OwnerNotificationMonitoringSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.queueAnalytics,
                                child: const OwnerQueueAnalyticsSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.appointmentAnalytics,
                                child: const OwnerAppointmentAnalyticsSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.packageAnalytics,
                                child: const OwnerPackageAnalyticsSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.analyticsCharts,
                                child: const OwnerPhase3AnalyticsSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.revenue,
                                child: const OwnerRevenueDashboardSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.security,
                                child: const OwnerSecurityCenterSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.sessionManager,
                                child: const OwnerSessionManagerSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.errorMonitoring,
                                child: const OwnerErrorMonitoringSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.backup,
                                child: const OwnerBackupCenterSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.auditLog,
                                child: const OwnerAuditLogSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.reports,
                                child: const OwnerReportsSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.maintenance,
                                child: const OwnerMaintenanceModeSection(),
                              ),
                              OwnerDashboardSectionAnchor(
                                section: MonitoringDashboardSection.appearance,
                                child: const OwnerAppearanceSection(),
                              ),
                              SizedBox(height: appearance.sectionSpacing * 1.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
