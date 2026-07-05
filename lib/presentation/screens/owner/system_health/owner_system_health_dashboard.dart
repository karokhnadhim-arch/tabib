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
import 'owner_dashboard_ui.dart';
import 'owner_monitoring_theme.dart';
import 'owner_phase1_monitoring_section.dart';
import 'owner_phase2_monitoring_sections.dart';
import 'owner_phase3_monitoring_sections.dart';
import 'owner_step3_operations_sections.dart';
import 'owner_step4_final_sections.dart';
import 'owner_phase4_monitoring_sections.dart';

/// Owner monitoring center — enterprise Material 3 layout.
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

  Widget _anchor(MonitoringDashboardSection section, Widget child) {
    return OwnerDashboardSectionAnchor(section: section, child: child);
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
    final groupGap = SizedBox(height: appearance.sectionSpacing + 4);

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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.monitoringCenterTitle),
                Text(
                  l10n.monitoringCenterHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: l10n.advancedSystemSettings,
                icon: const Icon(Icons.tune_rounded),
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
                  icon: const Icon(Icons.refresh_rounded),
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
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
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
                              groupGap,
                              OwnerDashboardGroup(
                                title: l10n.systemHealth,
                                subtitle: l10n.monitoringPhase1Hint,
                                icon: Icons.monitor_heart_outlined,
                                children: [
                                  _anchor(
                                    MonitoringDashboardSection.systemHealth,
                                    const OwnerPhase1MonitoringSection(),
                                  ),
                                ],
                              ),
                              groupGap,
                              OwnerDashboardGroup(
                                title: l10n.liveStatistics,
                                subtitle: l10n.monitoringPhase2Hint,
                                icon: Icons.insights_outlined,
                                children: [
                                  _anchor(
                                    MonitoringDashboardSection.liveStatistics,
                                    const OwnerLiveStatisticsSection(),
                                  ),
                                ],
                              ),
                              groupGap,
                              OwnerDashboardGroup(
                                title: l10n.liveActivityFeed,
                                icon: Icons.timeline_outlined,
                                children: [
                                  _anchor(
                                    MonitoringDashboardSection.activityFeed,
                                    const OwnerActivityFeedSection(),
                                  ),
                                ],
                              ),
                              groupGap,
                              OwnerDashboardGroup(
                                title: l10n.ownerSmartAlerts,
                                subtitle: l10n.smartOwnerNotifications,
                                icon: Icons.notifications_active_outlined,
                                children: [
                                  _anchor(
                                    MonitoringDashboardSection.aiInsights,
                                    const OwnerStep4AiInsightsSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.forecast,
                                    const OwnerStep4ForecastSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.smartNotifications,
                                    const OwnerSmartNotificationsSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.firebaseCost,
                                    const OwnerStep4FirebaseCostSection(),
                                  ),
                                ],
                              ),
                              groupGap,
                              OwnerDashboardGroup(
                                title: l10n.analyticsDashboard,
                                subtitle: l10n.monitoringPhase3AnalyticsHint,
                                icon: Icons.analytics_outlined,
                                children: [
                                  _anchor(
                                    MonitoringDashboardSection.advertisementMonitoring,
                                    const OwnerAdvertisementMonitoringSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.notificationMonitoring,
                                    const OwnerNotificationMonitoringSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.queueAnalytics,
                                    const OwnerQueueAnalyticsSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.appointmentAnalytics,
                                    const OwnerAppointmentAnalyticsSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.packageAnalytics,
                                    const OwnerPackageAnalyticsSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.analyticsCharts,
                                    const OwnerPhase3AnalyticsSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.revenue,
                                    const OwnerRevenueDashboardSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.reports,
                                    const OwnerReportsSection(),
                                  ),
                                ],
                              ),
                              groupGap,
                              OwnerDashboardGroup(
                                title: l10n.securityCenter,
                                subtitle: l10n.securityCenterHint,
                                icon: Icons.shield_outlined,
                                children: [
                                  _anchor(
                                    MonitoringDashboardSection.security,
                                    const OwnerSecurityCenterSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.sessionManager,
                                    const OwnerSessionManagerSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.errorMonitoring,
                                    const OwnerErrorMonitoringSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.auditLog,
                                    const OwnerAuditLogSection(),
                                  ),
                                ],
                              ),
                              groupGap,
                              OwnerDashboardGroup(
                                title: l10n.backupRestore,
                                subtitle: l10n.backupRestoreHint,
                                icon: Icons.cloud_upload_outlined,
                                children: [
                                  _anchor(
                                    MonitoringDashboardSection.backup,
                                    const OwnerBackupCenterSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.maintenance,
                                    const OwnerMaintenanceModeSection(),
                                  ),
                                  _anchor(
                                    MonitoringDashboardSection.appearance,
                                    const OwnerAppearanceSection(),
                                  ),
                                ],
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
