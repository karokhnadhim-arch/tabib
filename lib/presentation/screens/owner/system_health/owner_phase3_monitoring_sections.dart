import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/system_monitoring.dart';
import '../../../../services/owner_audit_service.dart';
import '../../../../services/system_monitoring_service.dart';
import 'monitoring_interactive_chart.dart';
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
          title: l10n.reportsAnalytics,
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
        _AnalyticsRangeFilters(monitoring: monitoring),
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
              final crossCount = constraints.maxWidth >= 900
                  ? 2
                  : 1;
              final chartDefs = [
                (l10n.dailyRegistrations, charts.registrations, scheme.primary, false),
                (l10n.dailyQueues, charts.queues, Colors.orange, false),
                (l10n.dailyAppointments, charts.appointments, Colors.teal, false),
                (l10n.monthlyRevenue, charts.revenue, AppTheme.medicalGreen, true),
                (l10n.adPerformance, charts.adPerformance, Colors.purple, false),
                (l10n.userGrowth, charts.userGrowth, scheme.tertiary, false),
                (l10n.doctorGrowthChart, charts.doctorGrowth, Colors.indigo, false),
                (l10n.businessGrowth, charts.businessGrowth, Colors.brown, false),
                (l10n.activeUsersChart, charts.activeUsers, Colors.blue, false),
                (l10n.queueWaitingTrends, charts.queueWaitingTrends, Colors.deepOrange, false),
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: crossCount == 2 ? 1.55 : 1.35,
                ),
                itemCount: chartDefs.length,
                itemBuilder: (context, index) {
                  final (title, values, color, bar) = chartDefs[index];
                  return MonitoringInteractiveChart(
                    title: title,
                    values: values,
                    color: color,
                    barMode: bar,
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _AnalyticsRangeFilters extends StatelessWidget {
  const _AnalyticsRangeFilters({required this.monitoring});

  final SystemMonitoringService monitoring;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ranges = <(AnalyticsRange, String)>[
      (AnalyticsRange.today, l10n.filterToday),
      (AnalyticsRange.yesterday, l10n.filterYesterday),
      (AnalyticsRange.week, l10n.filterLast7Days),
      (AnalyticsRange.month, l10n.filterThisMonth),
      (AnalyticsRange.year, l10n.filterThisYear),
      (AnalyticsRange.custom, l10n.filterCustomRange),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: ranges.map((entry) {
        final selected = monitoring.range == entry.$1;
        return FilterChip(
          label: Text(entry.$2),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) async {
            if (entry.$1 == AnalyticsRange.custom) {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: now.subtract(const Duration(days: 365 * 3)),
                lastDate: now,
                initialDateRange: DateTimeRange(
                  start: monitoring.customRangeStart ??
                      now.subtract(const Duration(days: 7)),
                  end: monitoring.customRangeEnd ?? now,
                ),
              );
              if (picked != null && context.mounted) {
                monitoring.setCustomDateRange(picked.start, picked.end);
              }
            } else {
              monitoring.setRange(entry.$1);
            }
          },
        );
      }).toList(),
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
            (l10n.activePackages, '${snapshot.activePackages}', Icons.card_membership, Colors.blue),
            (l10n.packagesExpiringSoon, '${snapshot.packagesExpiringSoon}', Icons.event_busy, Colors.orange),
            (l10n.renewalsToday, '${snapshot.renewalsToday}', Icons.autorenew, scheme.tertiary),
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
        _AnalyticsRangeFilters(monitoring: monitoring),
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

  void _export(
    BuildContext context,
    SystemMonitoringService monitoring,
    ReportExportFormat format,
    String label,
  ) {
    final l10n = AppLocalizations.of(context);
    final payload = monitoring.exportMonitoringReport(format);
    Clipboard.setData(ClipboardData(text: payload));
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
