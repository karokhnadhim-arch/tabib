import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/auth/admin_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/system_monitoring.dart';
import '../../../../services/dashboard_report_exporter.dart';
import '../../../../services/platform_backup_service.dart';
import '../../../../services/system_error_log_service.dart';
import '../../../../services/system_monitoring_service.dart';
import '../../../../presentation/widgets/owner_audit_log_panel.dart';
import 'monitoring_filter_scope.dart';
import 'system_health_widgets.dart';

// ─── Security Center ─────────────────────────────────────────────────────────

class OwnerSecurityCenterSection extends StatefulWidget {
  const OwnerSecurityCenterSection({super.key});

  @override
  State<OwnerSecurityCenterSection> createState() =>
      _OwnerSecurityCenterSectionState();
}

class _OwnerSecurityCenterSectionState extends State<OwnerSecurityCenterSection> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final snapshot = monitoring.snapshot;
    if (snapshot == null) return const SizedBox.shrink();

    final sessions = monitoring.searchableSessions;
    final scheme = Theme.of(context).colorScheme;
    final scale = (int v) => MonitoringFilterScope.scaleText(context, v);

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
        const SizedBox(height: 12),
        MonitoringMetricGrid(
          items: [
            (
              label: l10n.failedLoginAttempts,
              value: scale(snapshot.failedLoginAttempts),
              icon: Icons.lock_open,
              color: scheme.error,
            ),
            (
              label: l10n.lockedAccounts,
              value: scale(monitoring.effectiveLockedAccounts),
              icon: Icons.lock,
              color: Colors.orange,
            ),
            (
              label: l10n.suspiciousLogins,
              value: scale(snapshot.suspiciousLogins),
              icon: Icons.warning_amber,
              color: Colors.amber,
            ),
            (
              label: l10n.activeSessions,
              value: '${sessions.length}',
              icon: Icons.devices,
              color: scheme.primary,
            ),
            (
              label: l10n.loggedInDevices,
              value: '${monitoring.loggedInDevicesCount}',
              icon: Icons.phone_android_outlined,
              color: Colors.teal,
            ),
            (
              label: l10n.onlineUsers,
              value: scale(snapshot.onlineUsers),
              icon: Icons.wifi_tethering,
              color: AppTheme.medicalGreen,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchUsers,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
          onChanged: monitoring.setSessionSearch,
        ),
        if (monitoring.recentlyLoggedInUsers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.recentlyLoggedInUsers,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: monitoring.recentlyLoggedInUsers.map((session) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    session.userName.isNotEmpty ? session.userName[0] : '?',
                    style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 12),
                  ),
                ),
                label: Text(session.userName),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 12),
        ...sessions.map(
          (session) => _SessionCard(
            session: session,
            monitoring: monitoring,
            compact: true,
          ),
        ),
        if (sessions.length >=
            monitoring.sessionPage * SystemMonitoringService.sessionPageSize)
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

// ─── Session Manager ───────────────────────────────────────────────────────────

class OwnerSessionManagerSection extends StatelessWidget {
  const OwnerSessionManagerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final sessions = monitoring.visibleSessions;
    final scheme = Theme.of(context).colorScheme;

    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.sessionManager,
          icon: Icons.manage_accounts_outlined,
        ),
        Text(
          l10n.sessionManagerHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        ...sessions.map(
          (session) => _SessionCard(session: session, monitoring: monitoring),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.monitoring,
    this.compact = false,
  });

  final ActiveSessionEntry session;
  final SystemMonitoringService monitoring;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locked = monitoring.isUserLocked(session.userName);
    final canTerminate = monitoring.canTerminateSession(session.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: session.isCurrent
            ? scheme.primaryContainer.withOpacity(
                scheme.brightness == Brightness.dark ? 0.35 : 0.45,
              )
            : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: session.suspicious
                ? Colors.amber.withOpacity(0.5)
                : session.isCurrent
                    ? scheme.primary.withOpacity(0.35)
                    : scheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    session.suspicious ? Icons.warning_amber : Icons.person_outline,
                    color: session.suspicious ? Colors.amber : scheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                session.userName,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            if (session.isCurrent)
                              Chip(
                                label: Text(l10n.currentSession),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: scheme.primary.withOpacity(0.15),
                              ),
                            if (locked)
                              Chip(
                                label: Text(l10n.lockedStatus),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                        Text(
                          '${session.role} · ${session.browser.isNotEmpty ? session.browser : session.platform}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleAction(context, action, locked),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'terminate',
                        enabled: canTerminate,
                        child: Text(l10n.terminateSession),
                      ),
                      PopupMenuItem(
                        value: locked ? 'unlock' : 'lock',
                        child: Text(locked ? l10n.unlockUser : l10n.lockUser),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        enabled: canTerminate,
                        child: Text(l10n.forceLogout),
                      ),
                    ],
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _SessionMeta(
                      icon: Icons.devices,
                      label: l10n.browserDevice,
                      value: '${session.platform} · ${session.device}',
                    ),
                    _SessionMeta(
                      icon: Icons.login,
                      label: l10n.loginTime,
                      value: DateFormat.yMMMd().add_jm().format(session.loginTime),
                    ),
                    _SessionMeta(
                      icon: Icons.schedule,
                      label: l10n.lastActivity,
                      value: DateFormat.yMMMd().add_jm().format(session.lastActive),
                    ),
                  ],
                ),
              ],
              if (!canTerminate)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.cannotTerminateCurrentSession,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action, bool locked) {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case 'terminate':
        if (!monitoring.canTerminateSession(session.id)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cannotTerminateCurrentSession)),
          );
          return;
        }
        monitoring.terminateSession(session.id);
      case 'lock':
        monitoring.lockUser(session.userName);
      case 'unlock':
        monitoring.unlockUser(session.userName);
      case 'logout':
        if (!monitoring.canTerminateSession(session.id)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cannotTerminateCurrentSession)),
          );
          return;
        }
        monitoring.forceLogout(session.id);
    }
  }
}

class _SessionMeta extends StatelessWidget {
  const _SessionMeta({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ─── Error Monitoring ──────────────────────────────────────────────────────────

class OwnerErrorMonitoringSection extends StatelessWidget {
  const OwnerErrorMonitoringSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = context.watch<SystemMonitoringService>();
    final errorLog = monitoring.errorLogService;
    final errors = monitoring.visibleErrors;
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
            onPressed: () => _exportErrors(context, errorLog),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilterChip(
              label: Text(l10n.filterToday),
              selected: errorLog.timeFilter == ErrorLogTimeFilter.today,
              showCheckmark: false,
              onSelected: (_) => errorLog.setTimeFilter(ErrorLogTimeFilter.today),
            ),
            FilterChip(
              label: Text(l10n.filterThisWeek),
              selected: errorLog.timeFilter == ErrorLogTimeFilter.thisWeek,
              showCheckmark: false,
              onSelected: (_) => errorLog.setTimeFilter(ErrorLogTimeFilter.thisWeek),
            ),
            FilterChip(
              label: Text(l10n.errorFilterCriticalOnly),
              selected: errorLog.severityFilter == ErrorLogSeverityFilter.criticalOnly,
              showCheckmark: false,
              onSelected: (_) {
                errorLog.setSeverityFilter(
                  errorLog.severityFilter == ErrorLogSeverityFilter.criticalOnly
                      ? ErrorLogSeverityFilter.all
                      : ErrorLogSeverityFilter.criticalOnly,
                );
              },
            ),
            FilterChip(
              label: Text(l10n.activityFilterAll),
              selected: errorLog.timeFilter == ErrorLogTimeFilter.all &&
                  errorLog.severityFilter == ErrorLogSeverityFilter.all &&
                  errorLog.moduleFilter == null,
              showCheckmark: false,
              onSelected: (_) {
                errorLog.setTimeFilter(ErrorLogTimeFilter.all);
                errorLog.setSeverityFilter(ErrorLogSeverityFilter.all);
                errorLog.setModuleFilter(null);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(l10n.allModules),
                  selected: errorLog.moduleFilter == null,
                  showCheckmark: false,
                  onSelected: (_) => errorLog.setModuleFilter(null),
                ),
              ),
              ...errorLog.availableModules.map(
                (module) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(module),
                    selected: errorLog.moduleFilter == module,
                    showCheckmark: false,
                    onSelected: (_) => errorLog.setModuleFilter(module),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...errors.map((error) => _ErrorCard(error: error, monitoring: monitoring)),
        if (errors.length < monitoring.filteredErrorCount)
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Future<void> _exportErrors(
    BuildContext context,
    SystemErrorLogService errorLog,
  ) async {
    final l10n = AppLocalizations.of(context);
    final payload = errorLog.exportCsv();
    final result = await DashboardReportExporter.export(
      content: payload,
      format: ReportExportFormat.csv,
    );
    if (!context.mounted) return;
    if (result.message == 'clipboard' && result.content != null) {
      await Clipboard.setData(ClipboardData(text: result.content!));
    } else if (result.filePath != null) {
      // saved to disk
    } else {
      await Clipboard.setData(ClipboardData(text: payload));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.logsExported)),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.35)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(Icons.error_outline, color: color),
            title: Text(error.message, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${DateFormat.yMMMd().format(ts)} ${DateFormat.jm().format(ts)} · ${error.module}',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(l10n.errorTypeLabel, error.errorType),
                    _DetailRow(l10n.errorStatus, error.status.name),
                    _DetailRow(l10n.severity, error.severity.name),
                    _DetailRow(l10n.device, error.device),
                    _DetailRow(l10n.platformLabel, error.platform),
                    if (error.stackTrace != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.stackTrace,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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
                        FilledButton.tonal(
                          onPressed: () => monitoring.errorLogService.markFixed(error.id),
                          child: Text(l10n.markFixed),
                        ),
                        OutlinedButton(
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
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ─── Backup Center ─────────────────────────────────────────────────────────────

class OwnerBackupCenterSection extends StatelessWidget {
  const OwnerBackupCenterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final backup = context.watch<PlatformBackupService>();
    final metrics = backup.dashboard;
    final dateFmt = DateFormat.yMMMd().add_jm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.backupRestore,
          icon: Icons.backup_outlined,
          trailing: TextButton(
            onPressed: () => context.push('${AdminRoutes.platformPrefix}/backup'),
            child: Text(l10n.openBackupDashboard),
          ),
        ),
        MonitoringPanelCard(
          child: Column(
            children: [
              MonitoringInfoRow(
                label: l10n.lastBackup,
                value: metrics.lastBackup != null
                    ? dateFmt.format(metrics.lastBackup!)
                    : '—',
              ),
              MonitoringInfoRow(
                label: l10n.backupStatus,
                value: metrics.statusLabel,
              ),
              MonitoringInfoRow(
                label: l10n.storageUsage,
                value: metrics.storageUsageLabel,
              ),
              MonitoringInfoRow(
                label: l10n.nextScheduledBackup,
                value: metrics.nextScheduledBackup != null
                    ? dateFmt.format(metrics.nextScheduledBackup!)
                    : '—',
              ),
            ],
          ),
        ),
        if (backup.backupInProgress || backup.restoreInProgress) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: backup.progress),
          if (backup.progressLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(backup.progressLabel),
            ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: backup.backupInProgress || backup.restoreInProgress
                  ? null
                  : () async {
                      await backup.runManualBackup();
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
              onPressed: () =>
                  context.push('${AdminRoutes.platformPrefix}/backup'),
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.openBackupDashboard),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Audit Log ─────────────────────────────────────────────────────────────────

class OwnerAuditLogSection extends StatelessWidget {
  const OwnerAuditLogSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.auditLog,
          icon: Icons.history,
        ),
        const OwnerAuditLogPanel(compact: true),
      ],
    );
  }
}
