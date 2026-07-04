import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/system_activity_feed_service.dart';
import '../../../../services/system_monitoring_service.dart';
import '../../../widgets/system_owner_guard.dart';
import 'owner_phase1_monitoring_section.dart';
import 'owner_phase2_monitoring_sections.dart';
import 'owner_phase3_monitoring_sections.dart';

/// Owner monitoring center — Phase 1 infrastructure + Phase 2 live statistics.
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
    final hasSnapshot = monitoring.snapshot != null;
    final isRefreshing = monitoring.isRefreshingPhase1 || monitoring.isRefreshingPhase2;

    return SystemOwnerGuard(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(l10n.monitoringCenterTitle),
          actions: [
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    OwnerPhase1MonitoringSection(),
                    OwnerLiveStatisticsSection(),
                    OwnerActivityFeedSection(),
                    OwnerPhase3AnalyticsSection(),
                    OwnerRevenueDashboardSection(),
                    OwnerSecurityCenterSection(),
                    OwnerErrorMonitoringSection(),
                    OwnerBackupCenterSection(),
                    OwnerAuditLogSection(),
                    OwnerReportsSection(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
