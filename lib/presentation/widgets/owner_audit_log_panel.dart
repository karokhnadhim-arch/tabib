import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/audit_log_entry.dart';
import '../../models/audit_module.dart';
import '../../models/system_monitoring.dart';
import '../../models/user_account.dart';
import '../../services/dashboard_report_exporter.dart';
import '../../services/owner_audit_service.dart';

/// Reusable owner audit log panel — search, filters, pagination, export.
class OwnerAuditLogPanel extends StatefulWidget {
  const OwnerAuditLogPanel({
    super.key,
    this.compact = false,
    this.showStats = true,
  });

  final bool compact;
  final bool showStats;

  @override
  State<OwnerAuditLogPanel> createState() => _OwnerAuditLogPanelState();
}

class _OwnerAuditLogPanelState extends State<OwnerAuditLogPanel> {
  final _searchController = TextEditingController();
  int _visibleCount = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerAuditService>().ensureLoaded();
    });
  }

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
    final stats = audit.statistics;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final visible = entries.take(_visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showStats) ...[
          _StatsRow(stats: stats, l10n: l10n),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.auditSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                onChanged: (v) {
                  audit.setSearchQuery(v);
                  setState(() => _visibleCount = 30);
                },
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: l10n.exportAuditLog,
              icon: const Icon(Icons.download_outlined),
              onSelected: (format) => _export(context, audit, format, l10n),
              itemBuilder: (ctx) => [
                PopupMenuItem(value: 'pdf', child: Text(l10n.exportPdf)),
                PopupMenuItem(value: 'excel', child: Text(l10n.exportExcel)),
                PopupMenuItem(value: 'csv', child: Text(l10n.exportCsv)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _FilterBar(audit: audit, onChanged: () => setState(() => _visibleCount = 30)),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              l10n.noAuditEntries,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else if (isWide && !widget.compact)
          _AuditDataTable(entries: visible, l10n: l10n)
        else
          ...visible.map((e) => _AuditTile(entry: e, l10n: l10n)),
        if (entries.length > _visibleCount)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => setState(() => _visibleCount += 30),
              child: Text(l10n.loadMore),
            ),
          ),
        if (audit.hasMore && _visibleCount >= entries.length)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: audit.isLoadingMore ? null : () => audit.loadMore(),
              child: audit.isLoadingMore
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.loadMore),
            ),
          ),
      ],
    );
  }

  Future<void> _export(
    BuildContext context,
    OwnerAuditService audit,
    String format,
    AppLocalizations l10n,
  ) async {
    if (format == 'pdf') {
      final bytes = await audit.exportPdfBytes(l10n.auditLog);
      await _savePdf(bytes, l10n);
    } else {
      final content =
          format == 'excel' ? audit.exportExcel() : audit.exportCsv();
      final result = await DashboardReportExporter.export(
        content: content,
        format: format == 'excel'
            ? ReportExportFormat.excel
            : ReportExportFormat.csv,
      );
      if (!context.mounted) return;
      if (result.message == 'clipboard' && result.content != null) {
        await Clipboard.setData(ClipboardData(text: result.content!));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.auditLogExported)),
      );
    }
  }

  Future<void> _savePdf(List<int> bytes, AppLocalizations l10n) async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.auditLogExported)),
      );
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/tabib_audit_$stamp.pdf');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.auditLogExported}\n${file.path}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.l10n});

  final AuditActivityStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(label: l10n.auditTotalEvents, value: '${stats.total}'),
        _StatChip(label: l10n.auditToday, value: '${stats.today}'),
        _StatChip(label: l10n.auditLastSevenDays, value: '${stats.lastSevenDays}'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: AppTheme.primaryDark.withOpacity(0.12),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
      ),
      label: Text(label),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.audit, required this.onChanged});

  final OwnerAuditService audit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = audit.filters;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...AuditModule.values.map(
            (m) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(_moduleLabel(l10n, m)),
                selected: filters.module == m,
                showCheckmark: false,
                onSelected: (selected) {
                  audit.updateFilters(
                    filters.copyWith(
                      module: selected ? m : null,
                      clearModule: !selected,
                    ),
                  );
                  onChanged();
                },
              ),
            ),
          ),
          ...UserRole.values.map(
            (r) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(_roleLabel(l10n, r)),
                selected: filters.role == r,
                showCheckmark: false,
                onSelected: (selected) {
                  audit.updateFilters(
                    filters.copyWith(
                      role: selected ? r : null,
                      clearRole: !selected,
                    ),
                  );
                  onChanged();
                },
              ),
            ),
          ),
          ActionChip(
            avatar: const Icon(Icons.date_range, size: 18),
            label: Text(l10n.filterByDate),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (range != null) {
                audit.updateFilters(
                  filters.copyWith(
                    startDate: range.start,
                    endDate: range.end,
                  ),
                );
                onChanged();
              }
            },
          ),
          if (filters.module != null ||
              filters.role != null ||
              filters.startDate != null)
            ActionChip(
              label: Text(l10n.clearFilters),
              onPressed: () {
                audit.clearFilters();
                onChanged();
              },
            ),
        ],
      ),
    );
  }

  String _moduleLabel(AppLocalizations l10n, AuditModule m) => switch (m) {
        AuditModule.authentication => l10n.auditModuleAuth,
        AuditModule.owner => l10n.auditModuleOwner,
        AuditModule.secretary => l10n.auditModuleSecretary,
        AuditModule.doctor => l10n.auditModuleDoctor,
        AuditModule.patient => l10n.auditModulePatient,
        AuditModule.system => l10n.auditModuleSystem,
      };

  String _roleLabel(AppLocalizations l10n, UserRole r) => switch (r) {
        UserRole.patient => l10n.patientApp,
        UserRole.doctor => l10n.roleDoctor,
        UserRole.secretary => l10n.roleSecretary,
        UserRole.admin => l10n.roleAdmin,
      };
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.entry, required this.l10n});

  final AuditLogEntry entry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ts = entry.timestamp.toLocal();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryDark.withOpacity(0.1),
          child: Icon(_iconFor(entry), color: AppTheme.primaryDark, size: 20),
        ),
        title: Text(entry.action, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry.userName} · ${_roleName(l10n, entry.userRole)}'),
            Text(DateFormat.yMMMd().add_Hm().format(ts)),
            if (entry.description != null) Text(entry.description!),
            if (entry.device != null)
              Text('${l10n.device}: ${entry.device} · ${entry.operatingSystem ?? ''}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _AuditDataTable extends StatelessWidget {
  const _AuditDataTable({required this.entries, required this.l10n});

  final List<AuditLogEntry> entries;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
            DataColumn(label: Text(l10n.user)),
            DataColumn(label: Text(l10n.role)),
            DataColumn(label: Text(l10n.auditModule)),
            DataColumn(label: Text(l10n.action)),
            DataColumn(label: Text(l10n.device)),
          ],
          rows: entries
              .map(
                (e) => DataRow(
                  cells: [
                    DataCell(Text(dateFmt.format(e.timestamp.toLocal()))),
                    DataCell(Text(e.userName)),
                    DataCell(Text(_roleName(l10n, e.userRole))),
                    DataCell(Text(e.module?.storageKey ?? '—')),
                    DataCell(
                      SizedBox(
                        width: 220,
                        child: Text(
                          e.description != null
                              ? '${e.action}\n${e.description}'
                              : e.action,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(e.device ?? '—')),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

IconData _iconFor(AuditLogEntry entry) {
  return switch (entry.module) {
    AuditModule.authentication => Icons.login,
    AuditModule.owner => Icons.admin_panel_settings_outlined,
    AuditModule.secretary => Icons.support_agent_outlined,
    AuditModule.doctor => Icons.medical_services_outlined,
    AuditModule.patient => Icons.person_outline,
    AuditModule.system => Icons.settings_outlined,
    null => Icons.history,
  };
}

String _roleName(AppLocalizations l10n, UserRole? role) => switch (role) {
      UserRole.patient => l10n.patientApp,
      UserRole.doctor => l10n.roleDoctor,
      UserRole.secretary => l10n.roleSecretary,
      UserRole.admin => l10n.roleAdmin,
      null => '—',
    };
