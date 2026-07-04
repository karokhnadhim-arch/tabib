import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/system_monitoring.dart';
import '../../../../services/owner_audit_service.dart';
import '../../../../services/dashboard_report_exporter.dart';
import '../../../../services/system_monitoring_service.dart';
import 'analytics_chart_grid.dart';
import 'analytics_range_filters.dart';
import 'monitoring_filter_scope.dart';
import 'system_health_widgets.dart';

class OwnerPhase3AnalyticsSection extends StatelessWidget {
  const OwnerPhase3AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LazyDashboardSection(
      onVisible: () => context.read<SystemMonitoringService>().requestCharts(),
      placeholderHeight: 160,
      builder: (context) => const _AnalyticsBody(),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final charts = monitoring.charts;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.analyticsDashboard,
          icon: Icons.insights_outlined,
          trailing: monitoring.isLoadingCharts
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        Text(
          l10n.monitoringPhase3AnalyticsHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        AnalyticsRangeFilters(monitoring: monitoring, syncGlobalFilter: true),
        const SizedBox(height: 12),
        if (monitoring.isLoadingCharts && charts == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (charts == null)
          Text(l10n.dashboardChartsLoading)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = (List<double> v) => MonitoringFilterScope.scaleSeries(context, v);
              final coreCharts = <AnalyticsChartDef>[
                (title: l10n.dailyRegistrations, values: scale(charts.registrations), color: scheme.primary, barMode: false),
                (title: l10n.dailyQueues, values: scale(charts.queues), color: Colors.orange, barMode: false),
                (title: l10n.dailyAppointments, values: scale(charts.appointments), color: Colors.teal, barMode: false),
                (title: l10n.userGrowth, values: scale(charts.userGrowth), color: scheme.tertiary, barMode: false),
                (title: l10n.doctorGrowthChart, values: scale(charts.doctorGrowth), color: Colors.indigo, barMode: false),
                (title: l10n.businessGrowth, values: scale(charts.businessGrowth), color: Colors.brown, barMode: false),
              ];
              final extendedCharts = <AnalyticsChartDef>[
                (title: l10n.monthlyRevenue, values: scale(charts.revenue), color: AppTheme.medicalGreen, barMode: true),
                (title: l10n.adPerformance, values: scale(charts.adPerformance), color: Colors.purple, barMode: false),
                (title: l10n.activeUsersChart, values: scale(charts.activeUsers), color: Colors.blue, barMode: false),
                (title: l10n.queueWaitingTrends, values: scale(charts.queueWaitingTrends), color: Colors.deepOrange, barMode: false),
              ];
              return PaginatedAnalyticsChartGrid(
                coreCharts: coreCharts,
                extendedCharts: extendedCharts,
              );
            },
          ),
      ],
    );
  }
}

class OwnerRevenueDashboardSection extends StatelessWidget {
  const OwnerRevenueDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = context.select<SystemMonitoringService, SystemMonitoringSnapshot?>(
      (m) => m.snapshot,
    );
    final monitoring = context.read<SystemMonitoringService>();
    if (snapshot == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.revenueDashboard,
          icon: Icons.payments_outlined,
        ),
        MonitoringMetricGrid(
          items: [
            (l10n.monthlyRevenue, snapshot.monthlyRevenue, Icons.calendar_month, scheme.primary),
            (l10n.annualRevenue, snapshot.annualRevenue, Icons.trending_up, AppTheme.medicalGreen),
            (l10n.todaysRevenue, monitoring.todaysRevenueLabel(), Icons.today, Colors.teal),
            (
              l10n.activePackages,
              MonitoringFilterScope.scaleText(context, snapshot.activePackages),
              Icons.card_membership,
              Colors.blue,
            ),
            (
              l10n.packagesExpiringSoon,
              MonitoringFilterScope.scaleText(context, snapshot.packagesExpiringSoon),
              Icons.event_busy,
              Colors.orange,
            ),
            (
              l10n.renewalsToday,
              MonitoringFilterScope.scaleText(context, snapshot.renewalsToday),
              Icons.autorenew,
              scheme.tertiary,
            ),
            (l10n.avgRevenuePerDoctor, monitoring.avgRevenuePerDoctorLabel(), Icons.medical_services, Colors.indigo),
            (l10n.advertisementRevenue, monitoring.advertisementRevenueLabel(), Icons.campaign, Colors.purple),
          ].map((e) => (label: e.$1, value: e.$2, icon: e.$3, color: e.$4)).toList(),
        ),
      ],
    );
  }
}

class OwnerSecurityCenterSection extends StatelessWidget {
  const OwnerSecurityCenterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final snapshot = monitoring.snapshot;
    if (snapshot == null) return const SizedBox.shrink();

    final sessions = monitoring.visibleSessions;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.securityCenter,
          icon: Icons.shield_outlined,
        ),
        Text(
          l10n.securityCenterHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        MonitoringMetricGrid(
          items: [
            (l10n.failedLoginAttempts, '${snapshot.failedLoginAttempts}', Icons.lock_open, scheme.error),
            (l10n.lockedAccounts, '${monitoring.effectiveLockedAccounts}', Icons.lock, Colors.orange),
            (l10n.suspiciousLogins, '${snapshot.suspiciousLogins}', Icons.warning_amber, Colors.amber),
            (l10n.activeSessions, '${sessions.length}', Icons.devices, scheme.primary),
          ].map((e) => (label: e.$1, value: e.$2, icon: e.$3, color: e.$4)).toList(),
        ),
        const SizedBox(height: 8),
        ...sessions.map((session) {
          final locked = monitoring.isUserLocked(session.userName);
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            color: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(
                session.suspicious ? Icons.warning_amber : Icons.person_outline,
                color: session.suspicious ? Colors.amber : scheme.primary,
              ),
              title: Text(session.userName),
              subtitle: Text(
                '${session.role} · ${session.platform} · ${DateFormat.jm().format(session.lastActive)}',
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  if (locked)
                    Chip(
                      label: Text(l10n.lockedStatus),
                      visualDensity: VisualDensity.compact,
                    ),
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'terminate':
                          monitoring.terminateSession(session.id);
                        case 'lock':
                          monitoring.lockUser(session.userName);
                        case 'unlock':
                          monitoring.unlockUser(session.userName);
                        case 'logout':
                          monitoring.forceLogout(session.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'terminate', child: Text(l10n.terminateSession)),
                      PopupMenuItem(
                        value: locked ? 'unlock' : 'lock',
                        child: Text(locked ? l10n.unlockUser : l10n.lockUser),
                      ),
                      PopupMenuItem(value: 'logout', child: Text(l10n.forceLogout)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        if (sessions.length >= monitoring.sessionPage * SystemMonitoringService.sessionPageSize)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: monitoring.loadMoreSessions,
              child: Text(l10n.loadMore),
            ),
          ),
      ],
    );
  }
}

class OwnerErrorMonitoringSection extends StatelessWidget {
  const OwnerErrorMonitoringSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final errors = monitoring.visibleErrors;
    final errorLog = monitoring.errorLogService;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.errorMonitoring,
          icon: Icons.bug_report_outlined,
          trailing: IconButton(
            tooltip: l10n.exportLogs,
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: errorLog.exportCsv()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.logsExported)),
              );
            },
          ),
        ),
        ...errors.map((error) => _ErrorCard(error: error, monitoring: monitoring)),
        if (errors.length < errorLog.entries.length)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: monitoring.loadMoreErrors,
              child: Text(l10n.loadMore),
            ),
          ),
        if (errors.isEmpty)
          Card(
            elevation: 0,
            color: scheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.noActiveAlerts,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error, required this.monitoring});

  final AppErrorEntry error;
  final SystemMonitoringService monitoring;

  Color _severityColor(AppErrorSeverity severity, ColorScheme scheme) =>
      switch (severity) {
        AppErrorSeverity.critical => scheme.error,
        AppErrorSeverity.high => Colors.deepOrange,
        AppErrorSeverity.medium => Colors.amber,
        AppErrorSeverity.low => scheme.outline,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = _severityColor(error.severity, scheme);
    final ts = error.timestamp.toLocal();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.error_outline, color: color),
        title: Text(error.message, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${DateFormat.yMMMd().format(ts)} ${DateFormat.jm().format(ts)} · ${error.module} · ${error.severity.name}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ErrorDetailRow(l10n.errorTypeLabel, error.errorType),
                _ErrorDetailRow(l10n.device, error.device),
                _ErrorDetailRow('Platform', error.platform),
                _ErrorDetailRow('Status', error.status.name),
                if (error.stackTrace != null) ...[
                  const SizedBox(height: 8),
                  Text(l10n.stackTrace, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.stackTrace!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => monitoring.errorLogService.markFixed(error.id),
                      child: Text(l10n.markFixed),
                    ),
                    TextButton(
                      onPressed: () => monitoring.errorLogService.ignore(error.id),
                      child: Text(l10n.ignoreError),
                    ),
                    TextButton(
                      onPressed: () => monitoring.errorLogService.delete(error.id),
                      child: Text(l10n.deleteError),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorDetailRow extends StatelessWidget {
  const _ErrorDetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class OwnerBackupCenterSection extends StatelessWidget {
  const OwnerBackupCenterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final backup = monitoring.backup;
    final history = monitoring.backupHistory;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.backupRestore,
          icon: Icons.backup_outlined,
        ),
        MonitoringPanelCard(
          child: Column(
            children: [
              MonitoringInfoRow(
                label: l10n.lastBackup,
                value: backup.lastBackup != null
                    ? DateFormat.yMMMd().add_jm().format(backup.lastBackup!)
                    : '—',
              ),
              MonitoringInfoRow(label: l10n.backupStatus, value: backup.status),
              MonitoringInfoRow(label: l10n.backupSize, value: backup.sizeLabel),
              MonitoringInfoRow(
                label: l10n.nextScheduledBackup,
                value: backup.nextScheduled != null
                    ? DateFormat.yMMMd().add_jm().format(backup.nextScheduled!)
                    : '—',
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () async {
                await monitoring.runManualBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.backupCompleted)),
                  );
                }
              },
              icon: const Icon(Icons.backup),
              label: Text(l10n.runManualBackup),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.restoreBackupHint)),
                );
              },
              icon: const Icon(Icons.restore),
              label: Text(l10n.restoreBackup),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: monitoring.exportBackupReport()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.backupReportDownloaded)),
                );
              },
              icon: const Icon(Icons.download),
              label: Text(l10n.downloadBackupReport),
            ),
          ],
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.backupHistory,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...history.take(5).map(
                (entry) => ListTile(
                  dense: true,
                  leading: Icon(Icons.history, color: scheme.primary),
                  title: Text('${entry.status} · ${entry.sizeLabel}'),
                  subtitle: Text(
                    '${DateFormat.yMMMd().add_jm().format(entry.timestamp)} · ${entry.trigger}',
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class OwnerAuditLogSection extends StatefulWidget {
  const OwnerAuditLogSection({super.key});

  @override
  State<OwnerAuditLogSection> createState() => _OwnerAuditLogSectionState();
}

class _OwnerAuditLogSectionState extends State<OwnerAuditLogSection> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final audit = context.watch<OwnerAuditService>();
    final entries = audit.filteredEntries;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.auditLog,
          icon: Icons.history,
        ),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.auditSearchHint,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
          onChanged: audit.setSearchQuery,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AuditLogFilter.values.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_auditFilterLabel(l10n, filter)),
                  selected: audit.filter == filter,
                  showCheckmark: false,
                  onSelected: (_) => audit.setFilter(filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        ...entries.take(20).map(
              (entry) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                color: scheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.history, color: scheme.onPrimaryContainer, size: 20),
                  ),
                  title: Text(entry.action),
                  subtitle: Text(
                    [
                      '${l10n.user}: ${entry.userName}',
                      DateFormat.yMMMd().add_jm().format(entry.timestamp),
                      if (entry.device != null) '${l10n.device}: ${entry.device}',
                      if (entry.ipAddress != null &&
                          entry.ipAddress!.isNotEmpty &&
                          entry.ipAddress != '—')
                        '${l10n.ipAddress}: ${entry.ipAddress}',
                    ].join(' · '),
                  ),
                ),
              ),
            ),
        if (entries.isEmpty)
          Text(
            l10n.noAuditEntries,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
      ],
    );
  }

  String _auditFilterLabel(AppLocalizations l10n, AuditLogFilter filter) =>
      switch (filter) {
        AuditLogFilter.all => l10n.activityFilterAll,
        AuditLogFilter.login => l10n.activityEventLogin,
        AuditLogFilter.userManagement => l10n.usersSection,
        AuditLogFilter.packages => l10n.activePackages,
        AuditLogFilter.ads => l10n.advertisementMonitoring,
        AuditLogFilter.backup => l10n.backupRestore,
        AuditLogFilter.settings => l10n.systemSettings,
      };
}

class OwnerReportsSection extends StatelessWidget {
  const OwnerReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.generateReports,
          icon: Icons.summarize_outlined,
        ),
        Text(
          l10n.reportsFilterHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        AnalyticsRangeFilters(monitoring: monitoring, syncGlobalFilter: true),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ReportButton(
              label: 'CSV',
              icon: Icons.table_chart_outlined,
              onExport: () => _export(context, monitoring, ReportExportFormat.csv, 'CSV'),
            ),
            _ReportButton(
              label: 'Excel',
              icon: Icons.grid_on_outlined,
              onExport: () => _export(context, monitoring, ReportExportFormat.excel, 'Excel'),
            ),
            _ReportButton(
              label: 'PDF',
              icon: Icons.picture_as_pdf_outlined,
              onExport: () => _export(context, monitoring, ReportExportFormat.pdf, 'PDF'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _export(
    BuildContext context,
    SystemMonitoringService monitoring,
    ReportExportFormat format,
    String label,
  ) async {
    final l10n = AppLocalizations.of(context);
    final payload = monitoring.exportMonitoringReport(format);
    if (payload.isEmpty) return;

    final result = await DashboardReportExporter.export(
      content: payload,
      format: format,
    );

    if (!context.mounted) return;

    if (result.message == 'clipboard' && result.content != null) {
      await Clipboard.setData(ClipboardData(text: result.content!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportExported(label))),
      );
      return;
    }

    if (result.success && result.filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportSavedToFile(result.filePath!))),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: payload));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reportExported(label))),
    );
  }
}

class _ReportButton extends StatelessWidget {
  const _ReportButton({
    required this.label,
    required this.icon,
    required this.onExport,
  });

  final String label;
  final IconData icon;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onExport,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
