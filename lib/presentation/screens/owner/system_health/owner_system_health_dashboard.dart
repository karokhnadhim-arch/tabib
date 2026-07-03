import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/system_monitoring.dart';
import '../../../widgets/system_owner_guard.dart';
import '../../../../services/owner_audit_service.dart';
import '../../../../services/system_activity_feed_service.dart';
import '../../../../services/system_error_log_service.dart';
import '../../../../services/system_maintenance_service.dart';
import '../../../../services/system_monitoring_service.dart';
import 'system_health_widgets.dart';

class OwnerSystemHealthDashboard extends StatefulWidget {
  const OwnerSystemHealthDashboard({super.key});

  @override
  State<OwnerSystemHealthDashboard> createState() =>
      _OwnerSystemHealthDashboardState();
}

class _OwnerSystemHealthDashboardState extends State<OwnerSystemHealthDashboard> {
  late final TextEditingController _maintenanceMessageController;
  SystemMonitoringService? _monitoring;

  @override
  void initState() {
    super.initState();
    _maintenanceMessageController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _monitoring ??= context.read<SystemMonitoringService>()..activate();
  }

  @override
  void dispose() {
    _monitoring?.deactivate();
    _maintenanceMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final snapshot = monitoring.snapshot;
    final errors = context.watch<SystemErrorLogService>();
    final activity = context.watch<SystemActivityFeedService>();
    final maintenance = context.watch<SystemMaintenanceService>();
    final audit = context.watch<OwnerAuditService>();

    final maintenanceMessage = maintenance.message;
    if (_maintenanceMessageController.text.isEmpty &&
        maintenanceMessage.isNotEmpty) {
      _maintenanceMessageController.text = maintenanceMessage;
    }

    final lastSyncText = monitoring.lastSuccessfulSync != null
        ? '${l10n.dashboardLastSync}: ${DateFormat.yMMMd().add_jm().format(monitoring.lastSuccessfulSync!)}'
        : snapshot?.lastSync != null
            ? '${l10n.dashboardLastSync}: ${DateFormat.yMMMd().add_jm().format(snapshot!.lastSync!)}'
            : '';

    return SystemOwnerGuard(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(l10n.monitoringCenterTitle),
          actions: [
            if (monitoring.isRefreshing)
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
                onPressed: monitoring.refresh,
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),
        body: snapshot == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: monitoring.refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      l10n.monitoringCenterHint,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    DashboardDataStatusBanner(
                      showingCached: monitoring.showingCachedData || snapshot.isFromCache,
                      liveUnavailable: monitoring.isOffline || !snapshot.isLiveDataAvailable,
                      lastSyncLabel: lastSyncText,
                      cachedLabel: l10n.dashboardCachedData,
                      unavailableLabel: l10n.dashboardLiveDataUnavailable,
                    ),
                    SystemHealthStatusBanner(
                      label: _healthLabel(l10n, snapshot.healthLevel),
                      level: snapshot.healthLevel.name,
                      updatedAt: snapshot.updatedAt,
                    ),
                    if (snapshot.alerts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...snapshot.alerts.map(
                        (a) => Card(
                          color: a.severity == SystemHealthLevel.critical
                              ? Colors.red.shade50
                              : Colors.orange.shade50,
                          child: ListTile(
                            leading: Icon(
                              Icons.notifications_active_outlined,
                              color: a.severity == SystemHealthLevel.critical
                                  ? Colors.red
                                  : Colors.orange.shade800,
                            ),
                            title: Text(a.message),
                          ),
                        ),
                      ),
                    ],
                    MonitoringSectionHeader(
                      title: l10n.liveStatistics,
                      icon: Icons.insights_outlined,
                    ),
                    MonitoringSectionHeader(title: l10n.usersSection),
                    MonitoringMetricGrid(items: [
                      (label: l10n.totalUsers, value: '${snapshot.totalUsers}', icon: Icons.groups_outlined, color: AppTheme.primaryDark),
                      (label: l10n.onlineUsers, value: '${snapshot.onlineUsers}', icon: Icons.circle, color: AppTheme.medicalGreen),
                      (label: l10n.activeUsersToday, value: '${snapshot.activeToday}', icon: Icons.today_outlined, color: AppTheme.medicalBlue),
                      (label: l10n.newRegistrations, value: '${snapshot.newRegistrationsToday}', icon: Icons.person_add_outlined, color: Colors.teal),
                    ]),
                    MonitoringSectionHeader(title: l10n.doctorsSection),
                    MonitoringMetricGrid(items: [
                      (label: l10n.totalDoctors, value: '${snapshot.totalDoctors}', icon: Icons.medical_services_outlined, color: AppTheme.doctorColor),
                      (label: l10n.activeDoctors, value: '${snapshot.activeDoctors}', icon: Icons.check_circle_outline, color: AppTheme.medicalGreen),
                      (label: l10n.suspendedDoctors, value: '${snapshot.suspendedDoctors}', icon: Icons.block, color: Colors.red),
                      (label: l10n.expiredSubscriptions, value: '${snapshot.expiredPackages}', icon: Icons.event_busy, color: Colors.orange),
                      (label: l10n.onlineDoctors, value: '${snapshot.onlineDoctors}', icon: Icons.wifi, color: AppTheme.doctorColor),
                    ]),
                    MonitoringSectionHeader(title: l10n.secretariesSection),
                    MonitoringMetricGrid(items: [
                      (label: l10n.totalSecretaries, value: '${snapshot.totalSecretaries}', icon: Icons.support_agent_outlined, color: AppTheme.secretaryColor),
                      (label: l10n.onlineSecretaries, value: '${snapshot.onlineSecretaries}', icon: Icons.circle, color: AppTheme.medicalGreen),
                      (label: l10n.unassignedSecretaries, value: '${snapshot.secretariesWithoutDoctor}', icon: Icons.link_off, color: Colors.orange),
                      (label: l10n.recentSecretaries, value: '${snapshot.recentSecretaries}', icon: Icons.new_releases_outlined, color: AppTheme.secretaryColor),
                    ]),
                    MonitoringSectionHeader(title: l10n.businessesSection),
                    MonitoringMetricGrid(items: [
                      (label: l10n.totalBusinesses, value: '${snapshot.totalBusinesses}', icon: Icons.storefront_outlined, color: AppTheme.primaryDark),
                      (label: l10n.clinicsLabel, value: '${snapshot.clinics}', icon: Icons.local_hospital_outlined, color: AppTheme.medicalBlue),
                      (label: l10n.beautyCenters, value: '${snapshot.beautyCenters}', icon: Icons.spa_outlined, color: Colors.pink),
                      (label: l10n.laboratories, value: '${snapshot.laboratories}', icon: Icons.biotech_outlined, color: Colors.indigo),
                      (label: l10n.pharmacies, value: '${snapshot.pharmacies}', icon: Icons.local_pharmacy_outlined, color: Colors.green),
                      (label: l10n.otherHealthcare, value: '${snapshot.otherHealthcare}', icon: Icons.health_and_safety_outlined, color: Colors.blueGrey),
                    ]),
                    MonitoringSectionHeader(title: l10n.patientsSection),
                    MonitoringMetricGrid(items: [
                      (label: l10n.totalPatients, value: '${snapshot.totalPatients}', icon: Icons.people_outline, color: AppTheme.patientColor),
                      (label: l10n.onlinePatients, value: '${snapshot.onlinePatients}', icon: Icons.circle, color: AppTheme.medicalGreen),
                      (label: l10n.newPatientsToday, value: '${snapshot.newPatientsToday}', icon: Icons.person_add_alt_1_outlined, color: AppTheme.patientColor),
                    ]),
                    MonitoringSectionHeader(title: l10n.liveQueueStatistics, icon: Icons.queue_outlined),
                    MonitoringMetricGrid(items: [
                      (label: l10n.activeQueues, value: '${snapshot.activeQueues}', icon: Icons.queue, color: AppTheme.medicalBlue),
                      (label: l10n.queueWaiting, value: '${snapshot.waitingPatients}', icon: Icons.hourglass_top, color: Colors.orange),
                      (label: l10n.completedQueuesToday, value: '${snapshot.completedQueuesToday}', icon: Icons.done_all, color: AppTheme.medicalGreen),
                      (label: l10n.cancelledQueues, value: '${snapshot.cancelledQueues}', icon: Icons.cancel_outlined, color: Colors.red),
                      (label: l10n.avgWaitingTime, value: '${snapshot.avgWaitingMinutes} min', icon: Icons.timer_outlined, color: AppTheme.primaryDark),
                    ]),
                    MonitoringSectionHeader(title: l10n.appointmentStatistics),
                    MonitoringMetricGrid(items: [
                      (label: l10n.todaysAppointments, value: '${snapshot.todaysAppointments}', icon: Icons.event, color: AppTheme.medicalBlue),
                      (label: l10n.upcomingAppointments, value: '${snapshot.upcomingAppointments}', icon: Icons.upcoming, color: AppTheme.doctorColor),
                      (label: l10n.missedAppointments, value: '${snapshot.missedAppointments}', icon: Icons.event_busy, color: Colors.orange),
                      (label: l10n.cancelledAppointments, value: '${snapshot.cancelledAppointments}', icon: Icons.event_busy_outlined, color: Colors.red),
                    ]),
                    MonitoringSectionHeader(title: l10n.firebaseMonitoring, icon: Icons.cloud_outlined),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            MonitoringInfoRow(
                              label: l10n.firebaseStatus,
                              value: snapshot.firebaseConnected
                                  ? l10n.statusConnected
                                  : l10n.statusDemoOrOffline,
                              warning: snapshot.firebaseConfigured &&
                                  !snapshot.firebaseConnected,
                            ),
                            MonitoringInfoRow(label: l10n.firestoreReads, value: '${snapshot.firestoreReads}'),
                            MonitoringInfoRow(label: l10n.firestoreWrites, value: '${snapshot.firestoreWrites}'),
                            MonitoringInfoRow(label: l10n.storageUsage, value: '${snapshot.storageUsageMb.toStringAsFixed(1)} MB'),
                            MonitoringInfoRow(label: l10n.imageStorageUsage, value: '${snapshot.imageStorageMb.toStringAsFixed(1)} MB'),
                            MonitoringInfoRow(label: l10n.responseTime, value: '${snapshot.responseTimeMs} ms'),
                            MonitoringInfoRow(
                              label: l10n.cacheStatus,
                              value: snapshot.cacheEnabled
                                  ? l10n.statusConnected
                                  : l10n.statusDemoOrOffline,
                            ),
                            MonitoringInfoRow(
                              label: l10n.lastSynchronization,
                              value: snapshot.lastSync != null
                                  ? DateFormat.jm().format(snapshot.lastSync!)
                                  : '—',
                            ),
                            MonitoringInfoRow(
                              label: l10n.storageUsagePercent,
                              value: '${snapshot.storageUsagePercent}%',
                              warning: snapshot.storageUsagePercent >= 80,
                            ),
                          ],
                        ),
                      ),
                    ),
                    MonitoringSectionHeader(title: l10n.performanceMonitoring, icon: Icons.speed_outlined),
                    MonitoringMetricGrid(items: [
                      (label: l10n.cpuUsage, value: '${snapshot.cpuUsagePercent}%', icon: Icons.memory_outlined, color: Colors.deepPurple),
                      (label: l10n.memoryUsage, value: '${snapshot.memoryUsagePercent}%', icon: Icons.sd_storage_outlined, color: Colors.indigo),
                      (label: l10n.avgApiResponse, value: '${snapshot.avgApiResponseMs} ms', icon: Icons.network_check, color: AppTheme.medicalBlue),
                      (label: l10n.slowQueries, value: '${snapshot.slowQueries}', icon: Icons.query_stats, color: Colors.orange),
                      (label: l10n.backgroundTasks, value: '${snapshot.backgroundTasks}', icon: Icons.sync, color: AppTheme.primaryDark),
                      (label: l10n.cachePerformance, value: '${snapshot.cacheHitRate}%', icon: Icons.cached, color: AppTheme.medicalGreen),
                    ]),
                    MonitoringSectionHeader(title: l10n.notificationMonitoring, icon: Icons.notifications_outlined),
                    MonitoringMetricGrid(items: [
                      (label: l10n.pushSent, value: '${snapshot.pushSent}', icon: Icons.notifications_active, color: AppTheme.medicalBlue),
                      (label: l10n.whatsappSent, value: '${snapshot.whatsappSent}', icon: Icons.chat, color: const Color(0xFF25D366)),
                      (label: l10n.smsSent, value: '${snapshot.smsSent}', icon: Icons.sms, color: AppTheme.secretaryColor),
                      (label: l10n.failedNotifications, value: '${snapshot.failedNotifications}', icon: Icons.error_outline, color: Colors.red),
                      (label: l10n.pendingNotifications, value: '${snapshot.pendingNotifications}', icon: Icons.pending_outlined, color: Colors.orange),
                    ]),
                    MonitoringSectionHeader(title: l10n.advertisementMonitoring, icon: Icons.campaign_outlined),
                    MonitoringMetricGrid(items: [
                      (label: l10n.activeAdvertisements, value: '${snapshot.activeAds}', icon: Icons.play_circle_outline, color: AppTheme.medicalGreen),
                      (label: l10n.scheduledAdvertisements, value: '${snapshot.scheduledAds}', icon: Icons.schedule, color: AppTheme.medicalBlue),
                      (label: l10n.expiredAdvertisements, value: '${snapshot.expiredAds}', icon: Icons.history, color: Colors.grey),
                      (label: l10n.adViews, value: '${snapshot.adViews}', icon: Icons.visibility, color: AppTheme.primaryDark),
                      (label: l10n.adClicks, value: '${snapshot.adClicks}', icon: Icons.ads_click, color: Colors.orange),
                      (label: l10n.clickRate, value: '${snapshot.adClickRate.toStringAsFixed(1)}%', icon: Icons.percent, color: Colors.teal),
                    ]),
                    MonitoringSectionHeader(title: l10n.revenueDashboard, icon: Icons.payments_outlined),
                    MonitoringMetricGrid(items: [
                      (label: l10n.monthlyRevenue, value: snapshot.monthlyRevenue, icon: Icons.calendar_month, color: AppTheme.medicalGreen),
                      (label: l10n.annualRevenue, value: snapshot.annualRevenue, icon: Icons.date_range, color: AppTheme.primaryDark),
                      (label: l10n.activePackages, value: '${snapshot.activePackages}', icon: Icons.inventory_2_outlined, color: AppTheme.medicalBlue),
                      (label: l10n.packagesExpiringSoon, value: '${snapshot.packagesExpiringSoon}', icon: Icons.warning_amber, color: Colors.orange),
                      (label: l10n.renewalsToday, value: '${snapshot.renewalsToday}', icon: Icons.autorenew, color: AppTheme.medicalGreen),
                    ]),
                    MonitoringSectionHeader(title: l10n.securityCenter, icon: Icons.security),
                    MonitoringMetricGrid(items: [
                      (label: l10n.failedLoginAttempts, value: '${snapshot.failedLoginAttempts}', icon: Icons.lock_open, color: Colors.red),
                      (label: l10n.lockedAccounts, value: '${snapshot.lockedAccounts}', icon: Icons.lock, color: Colors.orange),
                      (label: l10n.suspiciousLogins, value: '${snapshot.suspiciousLogins}', icon: Icons.report_problem_outlined, color: Colors.red),
                      (label: l10n.activeSessions, value: '${snapshot.activeSessions}', icon: Icons.devices, color: AppTheme.primaryDark),
                    ]),
                    ...monitoring.activeSessions.map(
                      (s) => Card(
                        child: ListTile(
                          leading: Icon(
                            s.suspicious ? Icons.warning_amber : Icons.person_outline,
                            color: s.suspicious ? Colors.orange : AppTheme.primaryDark,
                          ),
                          title: Text(s.userName),
                          subtitle: Text('${s.role} • ${s.platform} • ${s.device}'),
                          trailing: TextButton(
                            onPressed: () => monitoring.terminateSession(s.id),
                            child: Text(l10n.terminateSession),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: TextButton(
                        onPressed: monitoring.loadMoreSessions,
                        child: Text(l10n.loadMore),
                      ),
                    ),
                    MonitoringSectionHeader(title: l10n.errorMonitoring, icon: Icons.bug_report_outlined),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: errors.exportCsv()),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.logsExported)),
                            );
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: Text(l10n.exportLogs),
                        ),
                      ],
                    ),
                    ...errors.entries.take(monitoring.errorVisibleCount).map(
                      (e) => Card(
                        child: ListTile(
                          title: Text('${e.module} • ${e.errorType}'),
                          subtitle: Text(
                            '${DateFormat.yMMMd().add_jm().format(e.timestamp)}\n${e.message}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'fix') errors.markFixed(e.id);
                              if (v == 'ignore') errors.ignore(e.id);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'fix', child: Text(l10n.markFixed)),
                              PopupMenuItem(value: 'ignore', child: Text(l10n.ignoreError)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (errors.entries.length > monitoring.errorVisibleCount)
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: TextButton(
                          onPressed: monitoring.loadMoreErrors,
                          child: Text(l10n.loadMore),
                        ),
                      ),
                    MonitoringSectionHeader(title: l10n.backupRestore, icon: Icons.backup_outlined),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            MonitoringInfoRow(
                              label: l10n.lastBackup,
                              value: monitoring.backup.lastBackup != null
                                  ? DateFormat.yMMMd().add_jm().format(
                                      monitoring.backup.lastBackup!,
                                    )
                                  : '—',
                            ),
                            MonitoringInfoRow(label: l10n.backupSize, value: monitoring.backup.sizeLabel),
                            MonitoringInfoRow(label: l10n.backupStatus, value: monitoring.backup.status),
                            MonitoringInfoRow(
                              label: l10n.nextScheduledBackup,
                              value: monitoring.backup.nextScheduled != null
                                  ? DateFormat.yMMMd().format(
                                      monitoring.backup.nextScheduled!,
                                    )
                                  : '—',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilledButton.icon(
                                  onPressed: () async {
                                    await monitoring.runManualBackup();
                                    audit.record(
                                      userId: 'owner',
                                      userName: 'System Owner',
                                      action: 'Manual backup completed',
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.backupCompleted)),
                                    );
                                  },
                                  icon: const Icon(Icons.backup),
                                  label: Text(l10n.manualBackup),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.restoreBackupHint)),
                                  ),
                                  icon: const Icon(Icons.restore),
                                  label: Text(l10n.restoreBackup),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.backupReportDownloaded)),
                                  ),
                                  icon: const Icon(Icons.description_outlined),
                                  label: Text(l10n.downloadBackupReport),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ExpansionTile(
                      leading: const Icon(Icons.rss_feed),
                      title: Text(l10n.liveActivityFeed),
                      subtitle: Text(l10n.showActivityFeed),
                      onExpansionChanged: (expanded) {
                        if (expanded) monitoring.requestActivityFeed();
                      },
                      children: [
                        if (!monitoring.activityRequested)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          ...activity.entries
                              .take(SystemMonitoringService.activityPageSize)
                              .map(
                            (e) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppTheme.primaryDark.withOpacity(0.1),
                                child: const Icon(Icons.flash_on, size: 18),
                              ),
                              title: Text(e.title),
                              subtitle: Text(
                                '${e.actorName ?? ''} • ${DateFormat.jm().format(e.timestamp)}',
                              ),
                            ),
                          ),
                      ],
                    ),
                    MonitoringSectionHeader(title: l10n.analytics, icon: Icons.bar_chart),
                    Wrap(
                      spacing: 8,
                      children: AnalyticsRange.values.map((r) {
                        final selected = monitoring.range == r;
                        return FilterChip(
                          label: Text(_rangeLabel(l10n, r)),
                          selected: selected,
                          onSelected: (_) => monitoring.setRange(r),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    LazyDashboardSection(
                      onVisible: () => monitoring.loadCharts(),
                      builder: (context) {
                        if (monitoring.isLoadingCharts && !monitoring.chartsLoaded) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(l10n.dashboardChartsLoading),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            _ChartCard(
                              title: l10n.dailyRegistrations,
                              values: snapshot.chartRegistrations,
                              color: AppTheme.medicalBlue,
                            ),
                            _ChartCard(
                              title: l10n.dailyQueues,
                              values: snapshot.chartQueues,
                              color: AppTheme.secretaryColor,
                            ),
                            _ChartCard(
                              title: l10n.dailyAppointments,
                              values: snapshot.chartAppointments,
                              color: AppTheme.doctorColor,
                            ),
                            _ChartCard(
                              title: l10n.monthlyRevenue,
                              values: snapshot.chartRevenue,
                              color: AppTheme.medicalGreen,
                            ),
                            _ChartCard(
                              title: l10n.adPerformance,
                              values: snapshot.chartAdPerformance,
                              color: Colors.orange,
                            ),
                            _ChartCard(
                              title: l10n.userGrowth,
                              values: snapshot.chartUserGrowth,
                              color: AppTheme.primaryDark,
                            ),
                            _ChartCard(
                              title: l10n.activeUsersChart,
                              values: snapshot.chartActiveUsers,
                              color: Colors.teal,
                            ),
                            _ChartCard(
                              title: l10n.businessGrowth,
                              values: snapshot.chartBusinessGrowth,
                              color: Colors.indigo,
                            ),
                          ],
                        );
                      },
                    ),
                    ExpansionTile(
                      leading: const Icon(Icons.summarize_outlined),
                      title: Text(l10n.reports),
                      subtitle: Text(l10n.showReports),
                      onExpansionChanged: monitoring.setReportsExpanded,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _exportReport(context, l10n, 'PDF'),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: const Text('PDF'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _exportReport(context, l10n, 'Excel'),
                              icon: const Icon(Icons.table_chart_outlined),
                              label: const Text('Excel'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: errors.exportCsv()),
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.reportExportedCsv)),
                                );
                              },
                              icon: const Icon(Icons.table_rows_outlined),
                              label: const Text('CSV'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    MonitoringSectionHeader(title: l10n.maintenanceMode, icon: Icons.build_circle_outlined),
                    SwitchListTile(
                      title: Text(l10n.enableMaintenanceMode),
                      subtitle: Text(l10n.maintenanceModeHint),
                      value: maintenance.enabled,
                      onChanged: (v) => maintenance.setMaintenance(enabled: v),
                    ),
                    TextField(
                      controller: _maintenanceMessageController,
                      decoration: InputDecoration(
                        labelText: l10n.maintenanceMessage,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => maintenance.setMaintenance(
                          enabled: maintenance.enabled,
                          message: _maintenanceMessageController.text,
                        ),
                        child: Text(l10n.saveTemplate),
                      ),
                    ),
                    MonitoringSectionHeader(title: l10n.auditLog, icon: Icons.history),
                    ExpansionTile(
                      title: Text(l10n.auditLog),
                      subtitle: Text(l10n.showAuditLog),
                      children: audit.entries.take(10).map(
                        (e) => ListTile(
                          title: Text(e.action),
                          subtitle: Text(
                            '${e.userName} • ${DateFormat.yMMMd().add_jm().format(e.timestamp)}'
                            '${e.ipAddress != null ? '\n${l10n.ipAddress}: ${e.ipAddress}' : ''}'
                            '${e.device != null ? '\n${l10n.device}: ${e.device}' : ''}',
                          ),
                          isThreeLine: true,
                        ),
                      ).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  String _healthLabel(AppLocalizations l10n, SystemHealthLevel level) =>
      switch (level) {
        SystemHealthLevel.healthy => l10n.systemHealthy,
        SystemHealthLevel.warning => l10n.systemWarning,
        SystemHealthLevel.critical => l10n.systemCritical,
      };

  String _rangeLabel(AppLocalizations l10n, AnalyticsRange range) =>
      switch (range) {
        AnalyticsRange.today => l10n.filterToday,
        AnalyticsRange.week => l10n.filterThisWeek,
        AnalyticsRange.month => l10n.filterThisMonth,
        AnalyticsRange.year => l10n.filterThisYear,
        AnalyticsRange.custom => l10n.filterCustomRange,
      };

  void _exportReport(BuildContext context, AppLocalizations l10n, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reportExported(format))),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.values,
    required this.color,
  });

  final String title;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            MonitoringBarChart(values: values, color: color),
          ],
        ),
      ),
    );
  }
}
