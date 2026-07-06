import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/platform_backup.dart';
import '../../../models/system_monitoring.dart';
import '../../../presentation/widgets/system_owner_guard.dart';
import '../../../services/dashboard_report_exporter.dart';
import '../../../services/platform_backup_service.dart';

/// Owner backup, restore, and disaster recovery dashboard.
class OwnerBackupDashboardScreen extends StatelessWidget {
  const OwnerBackupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SystemOwnerGuard(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(l10n.backupRestore),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: const _BackupDashboardBody(),
      ),
    );
  }
}

class _BackupDashboardBody extends StatefulWidget {
  const _BackupDashboardBody();

  @override
  State<_BackupDashboardBody> createState() => _BackupDashboardBodyState();
}

class _BackupDashboardBodyState extends State<_BackupDashboardBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformBackupService>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final backup = context.watch<PlatformBackupService>();
    final metrics = backup.dashboard;
    final dateFmt = DateFormat.yMMMd().add_jm();
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return ListView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      children: [
        Text(
          l10n.backupRestoreHint,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              icon: Icons.schedule,
              label: l10n.lastBackup,
              value: metrics.lastBackup != null
                  ? dateFmt.format(metrics.lastBackup!)
                  : '—',
            ),
            _MetricCard(
              icon: Icons.event,
              label: l10n.nextScheduledBackup,
              value: metrics.nextScheduledBackup != null
                  ? dateFmt.format(metrics.nextScheduledBackup!)
                  : '—',
            ),
            _MetricCard(
              icon: Icons.health_and_safety_outlined,
              label: l10n.backupStatus,
              value: metrics.statusLabel,
            ),
            _MetricCard(
              icon: Icons.inventory_2_outlined,
              label: l10n.totalBackupCount,
              value: '${metrics.totalBackups}',
            ),
            _MetricCard(
              icon: Icons.sd_storage_outlined,
              label: l10n.storageUsage,
              value: metrics.storageUsageLabel,
            ),
            _MetricCard(
              icon: Icons.restore,
              label: l10n.latestRestoreDate,
              value: metrics.latestRestoreDate != null
                  ? dateFmt.format(metrics.latestRestoreDate!)
                  : '—',
            ),
          ],
        ),
        if (backup.backupInProgress || backup.restoreInProgress) ...[
          const SizedBox(height: 20),
          Text(
            backup.restoreInProgress
                ? l10n.restoreInProgress
                : l10n.backupInProgress,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: backup.progress),
          const SizedBox(height: 4),
          Text(backup.progressLabel),
        ],
        const SizedBox(height: 20),
        _ScheduleCard(
          schedule: backup.schedule,
          onChanged: (config) => backup.updateSchedule(config),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: backup.backupInProgress || backup.restoreInProgress
                  ? null
                  : () => _runManualBackup(context),
              icon: const Icon(Icons.backup_outlined),
              label: Text(l10n.runManualBackup),
            ),
            OutlinedButton.icon(
              onPressed: backup.latestHealthyBackup == null ||
                      backup.restoreInProgress ||
                      backup.backupInProgress
                  ? null
                  : () => _recoverLatest(context),
              icon: const Icon(Icons.healing_outlined),
              label: Text(l10n.recoverLatestBackup),
            ),
            OutlinedButton.icon(
              onPressed: () => _downloadReport(context),
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.downloadBackupReport),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.backupHistory,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (backup.history.isEmpty)
          Text(l10n.noBackupsYet, style: TextStyle(color: Colors.grey.shade600))
        else if (isWide)
          _BackupHistoryTable(
            records: backup.history,
            onRestore: (id) => _confirmRestore(context, id),
            onDownload: (id) => _downloadBackup(context, id),
          )
        else
          ...backup.history.map(
            (r) => _BackupHistoryTile(
              record: r,
              onRestore: () => _confirmRestore(context, r.id),
              onDownload: () => _downloadBackup(context, r.id),
            ),
          ),
      ],
    );
  }

  Future<void> _runManualBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final service = context.read<PlatformBackupService>();
    final result = await service.runManualBackup();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null ? l10n.backupCompleted : l10n.backupFailed,
        ),
      ),
    );
  }

  Future<void> _recoverLatest(BuildContext context) async {
    final latest = context.read<PlatformBackupService>().latestHealthyBackup;
    if (latest == null) return;
    await _confirmRestore(context, latest.id);
  }

  Future<void> _confirmRestore(BuildContext context, String backupId) async {
    final l10n = AppLocalizations.of(context);
    final service = context.read<PlatformBackupService>();
    final record = service.history.firstWhere((r) => r.id == backupId);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: Text(l10n.confirmRestoreTitle),
        content: Text(l10n.confirmRestoreMessage(record.sizeLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelQueue),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.restoreBackup),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await service.restoreBackup(backupId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.restoreCompleted)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.restoreFailed)),
      );
    }
  }

  Future<void> _downloadBackup(BuildContext context, String backupId) async {
    final l10n = AppLocalizations.of(context);
    final payload =
        await context.read<PlatformBackupService>().downloadBackupPayload(backupId);
    if (!context.mounted) return;
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupCorrupted)),
      );
      return;
    }
    final result = await DashboardReportExporter.export(
      content: payload,
      format: ReportExportFormat.csv,
    );
    if (result.message == 'clipboard' && result.content != null) {
      await Clipboard.setData(ClipboardData(text: payload));
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.backupDownloaded)),
    );
  }

  Future<void> _downloadReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final payload =
        await context.read<PlatformBackupService>().exportBackupReport();
    final result = await DashboardReportExporter.export(
      content: payload,
      format: ReportExportFormat.csv,
    );
    if (!context.mounted) return;
    if (result.message == 'clipboard' && result.content != null) {
      await Clipboard.setData(ClipboardData(text: payload));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.backupReportDownloaded)),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onChanged,
  });

  final BackupScheduleConfig schedule;
  final ValueChanged<BackupScheduleConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                l10n.autoBackup,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SwitchListTile(
              title: const Text('Daily'),
              subtitle: Text('${schedule.dailyHour}:00'),
              value: schedule.dailyEnabled,
              onChanged: (v) =>
                  onChanged(schedule.copyWith(dailyEnabled: v)),
            ),
            SwitchListTile(
              title: const Text('Weekly'),
              subtitle: Text(
                'Weekday ${schedule.weeklyWeekday} · ${schedule.weeklyHour}:00',
              ),
              value: schedule.weeklyEnabled,
              onChanged: (v) =>
                  onChanged(schedule.copyWith(weeklyEnabled: v)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primaryDark, size: 22),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackupHistoryTable extends StatelessWidget {
  const _BackupHistoryTable({
    required this.records,
    required this.onRestore,
    required this.onDownload,
  });

  final List<PlatformBackupRecord> records;
  final ValueChanged<String> onRestore;
  final ValueChanged<String> onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFmt = DateFormat.yMMMd().add_Hm();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text(l10n.date)),
            DataColumn(label: Text(l10n.backupType)),
            DataColumn(label: Text(l10n.backupStatus)),
            DataColumn(label: Text(l10n.backupSize)),
            DataColumn(label: Text(l10n.createdBy)),
            DataColumn(label: Text(l10n.action)),
          ],
          rows: records
              .map(
                (r) => DataRow(
                  cells: [
                    DataCell(Text(dateFmt.format(r.createdAt))),
                    DataCell(Text(r.type.storageKey)),
                    DataCell(Text(r.status.storageKey)),
                    DataCell(Text(r.sizeLabel)),
                    DataCell(Text(r.createdByName)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download_outlined),
                            tooltip: l10n.downloadBackup,
                            onPressed: r.isRestorable
                                ? () => onDownload(r.id)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: l10n.restoreBackup,
                            onPressed: r.isRestorable
                                ? () => onRestore(r.id)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _BackupHistoryTile extends StatelessWidget {
  const _BackupHistoryTile({
    required this.record,
    required this.onRestore,
    required this.onDownload,
  });

  final PlatformBackupRecord record;
  final VoidCallback onRestore;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            record.status.isHealthy ? Icons.check : Icons.error_outline,
          ),
        ),
        title: Text('${record.type.storageKey} · ${record.sizeLabel}'),
        subtitle: Text(
          '${DateFormat.yMMMd().add_Hm().format(record.createdAt)} · ${record.createdByName}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'restore') onRestore();
            if (action == 'download') onDownload();
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(value: 'download', child: Text(l10n.downloadBackup)),
            if (record.isRestorable)
              PopupMenuItem(value: 'restore', child: Text(l10n.restoreBackup)),
          ],
        ),
      ),
    );
  }
}
