import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/system_monitoring.dart';
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
