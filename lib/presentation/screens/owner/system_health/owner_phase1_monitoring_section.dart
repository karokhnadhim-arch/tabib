import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/system_monitoring.dart';
import '../../../../services/system_monitoring_service.dart';
import 'monitoring_view_models.dart';
import 'system_health_widgets.dart';

/// Phase 1 — infrastructure health, Firebase, performance, and smart alerts.
class OwnerPhase1MonitoringSection extends StatelessWidget {
  const OwnerPhase1MonitoringSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.select<SystemMonitoringService, Phase1MonitoringViewModel?>(
      (m) {
        final snapshot = m.snapshot;
        if (snapshot == null) return null;
        return Phase1MonitoringViewModel.from(
          snapshot: snapshot,
          healthLevel: m.phase1HealthLevel,
          phase1Alerts: m.phase1Alerts,
          showingCached: m.showingCachedData,
          isOffline: m.isOffline,
          lastSuccessfulSync: m.lastSuccessfulSync,
          isRefreshing: m.isRefreshingPhase1,
        );
      },
    );

    if (vm == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final lastSyncText = vm.lastSuccessfulSync != null
        ? '${l10n.dashboardLastSync}: ${DateFormat.yMMMd().add_jm().format(vm.lastSuccessfulSync!)}'
        : vm.lastSync != null
            ? '${l10n.dashboardLastSync}: ${DateFormat.yMMMd().add_jm().format(vm.lastSync!)}'
            : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.monitoringPhase1Hint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        DashboardDataStatusBanner(
          showingCached: vm.showingCached,
          liveUnavailable: vm.isOffline || !vm.isLiveDataAvailable,
          lastSyncLabel: lastSyncText,
          cachedLabel: l10n.dashboardCachedData,
          unavailableLabel: l10n.dashboardLiveDataUnavailable,
        ),
        OwnerSystemHealthCard(
          healthLabel: _healthLabel(l10n, vm.healthLevel),
          healthLevel: vm.healthLevel,
          firebaseConnected: vm.firebaseConnected,
          firebaseConfigured: vm.firebaseConfigured,
          lastSync: vm.lastSuccessfulSync ?? vm.lastSync,
          avgResponseMs: vm.avgApiResponseMs,
          isRefreshing: vm.isRefreshing,
        ),
        const SizedBox(height: 12),
        MonitoringSectionHeader(
          title: l10n.ownerSmartAlerts,
          icon: Icons.notifications_active_outlined,
        ),
        OwnerSmartAlertsSection(
          alerts: vm.phase1Alerts,
          emptyLabel: l10n.noActiveAlerts,
          alertLabel: (a) => _alertMessage(l10n, a, vm.storageUsagePercent),
        ),
        MonitoringSectionHeader(
          title: l10n.firebaseMonitoring,
          icon: Icons.cloud_outlined,
        ),
        FirebaseUsageWarningsPanel(
          reads: vm.firestoreReads,
          writes: vm.firestoreWrites,
          storageUsagePercent: vm.storageUsagePercent,
        ),
        MonitoringPanelCard(
          child: Column(
            children: [
              MonitoringInfoRow(
                label: l10n.firebaseStatus,
                value: vm.firebaseConnected
                    ? l10n.statusConnected
                    : l10n.statusDemoOrOffline,
                warning: vm.firebaseConfigured && !vm.firebaseConnected,
              ),
              MonitoringInfoRow(
                label: l10n.firestoreReads,
                value: '${vm.firestoreReads}',
                warning: vm.firestoreReads >= FirebaseUsageLimits.readWarning,
              ),
              MonitoringInfoRow(
                label: l10n.firestoreWrites,
                value: '${vm.firestoreWrites}',
                warning: vm.firestoreWrites >= FirebaseUsageLimits.writeWarning,
              ),
              MonitoringInfoRow(
                label: l10n.storageUsage,
                value: '${vm.storageUsageMb.toStringAsFixed(1)} MB',
              ),
              MonitoringInfoRow(
                label: l10n.imageStorageUsage,
                value: '${vm.imageStorageMb.toStringAsFixed(1)} MB',
              ),
              MonitoringInfoRow(
                label: l10n.responseTime,
                value: '${vm.responseTimeMs} ms',
                warning: vm.responseTimeMs >= 1200,
              ),
              MonitoringInfoRow(
                label: l10n.cacheStatus,
                value: vm.cacheEnabled
                    ? l10n.statusConnected
                    : l10n.statusDemoOrOffline,
              ),
              MonitoringInfoRow(
                label: l10n.lastSynchronization,
                value: vm.lastSync != null
                    ? DateFormat.yMMMd().add_jm().format(vm.lastSync!)
                    : '—',
              ),
              MonitoringInfoRow(
                label: l10n.storageUsagePercent,
                value: '${vm.storageUsagePercent}%',
                warning: vm.storageUsagePercent >= 80,
              ),
            ],
          ),
        ),
        MonitoringSectionHeader(
          title: l10n.performanceMonitoring,
          icon: Icons.speed_outlined,
        ),
        MonitoringMetricGrid(
          items: [
            (
              label: l10n.cpuUsage,
              value: _cpuLabel(l10n, vm.cpuUsagePercent),
              icon: Icons.memory_outlined,
              color: Colors.deepPurple,
            ),
            (
              label: l10n.memoryUsage,
              value: _memoryLabel(l10n, vm.memoryUsagePercent),
              icon: Icons.sd_storage_outlined,
              color: Colors.indigo,
            ),
            (
              label: l10n.avgApiResponse,
              value: '${vm.avgApiResponseMs} ms',
              icon: Icons.network_check,
              color: Theme.of(context).colorScheme.primary,
            ),
            (
              label: l10n.backgroundTasks,
              value: '${vm.backgroundTasks}',
              icon: Icons.sync,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            (
              label: l10n.cachePerformance,
              value: '${vm.cacheHitRate}%',
              icon: Icons.cached,
              color: AppTheme.medicalGreen,
            ),
            (
              label: l10n.slowQueries,
              value: '${vm.slowQueries}',
              icon: Icons.query_stats_outlined,
              color: vm.slowQueries > 0 ? Colors.orange.shade800 : Colors.blueGrey,
            ),
          ],
        ),
      ],
    );
  }

  String _healthLabel(AppLocalizations l10n, SystemHealthLevel level) =>
      switch (level) {
        SystemHealthLevel.healthy => l10n.systemHealthy,
        SystemHealthLevel.warning => l10n.systemWarning,
        SystemHealthLevel.critical => l10n.systemCritical,
      };

  String _cpuLabel(AppLocalizations l10n, int percent) {
    if (kIsWeb) return l10n.metricNotAvailable;
    return '$percent%';
  }

  String _memoryLabel(AppLocalizations l10n, int percent) {
    if (kIsWeb) return l10n.metricNotAvailable;
    return '$percent%';
  }

  String _alertMessage(
    AppLocalizations l10n,
    OwnerAlert alert,
    int storagePercent,
  ) {
    return switch (alert.type) {
      OwnerAlertType.firebaseDisconnected => l10n.alertFirebaseDisconnected,
      OwnerAlertType.backupFailed => l10n.alertBackupFailed,
      OwnerAlertType.storageWarning ||
      OwnerAlertType.storageCritical =>
        l10n.alertStorageHigh(
          RegExp(r'(\d+)').firstMatch(alert.message)?.group(1) ??
              '$storagePercent',
        ),
      OwnerAlertType.slowPerformance => l10n.alertSlowResponse,
      OwnerAlertType.highErrorRate => l10n.alertHighErrorRate,
      OwnerAlertType.packageExpiresToday => l10n.alertPackageExpiresToday,
      OwnerAlertType.pushServiceFailed => l10n.alertNotificationServiceFailed,
      _ => alert.message,
    };
  }
}
