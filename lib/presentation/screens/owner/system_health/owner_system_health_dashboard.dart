import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/owner_dashboard_appearance_service.dart';
import '../../../../services/owner_dashboard_filter_service.dart';
import '../../../../services/system_activity_feed_service.dart';
import '../../../../services/system_monitoring_service.dart';
import '../../../widgets/system_owner_guard.dart';
import 'monitoring_filter_scope.dart';
import 'owner_dashboard_filter_sync.dart';
import 'owner_monitoring_theme.dart';
import 'owner_phase1_monitoring_section.dart';
import 'owner_phase2_monitoring_sections.dart';
import 'owner_phase3_monitoring_sections.dart';
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
    final hasSnapshot = monitoring.snapshot != null;
    final isRefreshing =
        monitoring.isRefreshingPhase1 || monitoring.isRefreshingPhase2;

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
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.all(appearance.cardPadding),
                        child: ListView(
                          children: [
                            const OwnerGlobalSearchBar(),
                            SizedBox(height: appearance.sectionSpacing),
                            const OwnerGlobalFilterBar(),
                            SizedBox(height: appearance.sectionSpacing),
                            const OwnerPhase1MonitoringSection(),
                            const OwnerLiveStatisticsSection(),
                            const OwnerActivityFeedSection(),
                            const OwnerAiInsightsSection(),
                            const OwnerForecastSection(),
                            const OwnerSmartNotificationsSection(),
                            const OwnerFirebaseCostSection(),
                            const OwnerPhase3AnalyticsSection(),
                            const OwnerRevenueDashboardSection(),
                            const OwnerSecurityCenterSection(),
                            const OwnerErrorMonitoringSection(),
                            const OwnerBackupCenterSection(),
                            const OwnerAuditLogSection(),
                            const OwnerReportsSection(),
                            const OwnerAppearanceSection(),
                            const SizedBox(height: 24),
                          ],
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
