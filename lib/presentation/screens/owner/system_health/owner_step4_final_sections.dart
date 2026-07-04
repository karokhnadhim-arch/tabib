import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/owner_monitoring_phase4.dart';
import '../../../../models/system_monitoring.dart';
import '../../../../services/firebase_cost_optimizer_service.dart';
import '../../../../services/owner_dashboard_appearance_service.dart';
import '../../../../services/owner_forecast_service.dart';
import '../../../../services/owner_insights_service.dart';
import '../../../../services/system_maintenance_service.dart';
import '../../../../services/system_monitoring_service.dart';
import 'monitoring_filter_scope.dart';
import 'monitoring_interactive_chart.dart';
import 'system_health_widgets.dart';

/// Responsive section shell with consistent Material 3 spacing.
class DashboardSectionShell extends StatelessWidget {
  const DashboardSectionShell({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonitoringSectionHeader(title: title, icon: icon, trailing: trailing),
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

List<({String label, String value, IconData icon, Color color})> _scaledMetrics(
  BuildContext context,
  List<({String label, int value, IconData icon, Color color})> items,
) =>
    items
        .map(
          (e) => (
            label: e.label,
            value: MonitoringFilterScope.scaleText(context, e.value),
            icon: e.icon,
            color: e.color,
          ),
        )
        .toList();

// ─── 1. AI Insights Center ───────────────────────────────────────────────────

class OwnerStep4AiInsightsSection extends StatelessWidget {
  const OwnerStep4AiInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insights = context.watch<OwnerInsightsService>().insights;
    final scheme = Theme.of(context).colorScheme;

    return LazyDashboardSection(
      placeholderHeight: 120,
      onVisible: () {},
      builder: (context) => DashboardSectionShell(
        title: l10n.aiInsightsCenter,
        icon: Icons.auto_awesome_outlined,
        subtitle: l10n.aiInsightsHint,
        child: insights.isEmpty
            ? _EmptyPanel(message: l10n.noActiveAlerts)
            : Column(
                children: insights.map((insight) {
                  final color = switch (insight.priority) {
                    InsightPriority.high => scheme.error,
                    InsightPriority.medium => Colors.amber.shade800,
                    InsightPriority.low => scheme.primary,
                  };
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      elevation: 0,
                      color: color.withOpacity(
                        scheme.brightness == Brightness.dark ? 0.14 : 0.07,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: color.withOpacity(0.28)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_categoryIcon(insight.category), color: color),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    insight.title,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(insight.description),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.tips_and_updates_outlined,
                                            size: 18, color: scheme.tertiary),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(insight.recommendation)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_priorityLabel(l10n, insight.priority)} · '
                                    '${_categoryLabel(l10n, insight.category)} · '
                                    '${DateFormat.yMMMd().add_jm().format(insight.generatedAt)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  IconData _categoryIcon(InsightCategory c) => switch (c) {
        InsightCategory.patients => Icons.people_outline,
        InsightCategory.doctors => Icons.medical_services_outlined,
        InsightCategory.queues => Icons.queue_outlined,
        InsightCategory.revenue => Icons.payments_outlined,
        InsightCategory.packages => Icons.card_membership_outlined,
        InsightCategory.advertisements => Icons.campaign_outlined,
        InsightCategory.security => Icons.shield_outlined,
        InsightCategory.firebase => Icons.cloud_outlined,
        InsightCategory.performance => Icons.speed_outlined,
      };

  String _priorityLabel(AppLocalizations l10n, InsightPriority p) => switch (p) {
        InsightPriority.high => l10n.priorityHigh,
        InsightPriority.medium => l10n.priorityMedium,
        InsightPriority.low => l10n.priorityLow,
      };

  String _categoryLabel(AppLocalizations l10n, InsightCategory c) => switch (c) {
        InsightCategory.patients => l10n.patientsSection,
        InsightCategory.doctors => l10n.doctorsSection,
        InsightCategory.queues => l10n.queuesSection,
        InsightCategory.revenue => l10n.revenueDashboard,
        InsightCategory.packages => l10n.activePackages,
        InsightCategory.advertisements => l10n.advertisementMonitoring,
        InsightCategory.security => l10n.securityCenter,
        InsightCategory.firebase => l10n.firebaseMonitoring,
        InsightCategory.performance => l10n.performanceMonitoring,
      };
}

// ─── 2. Forecast Dashboard ───────────────────────────────────────────────────

class OwnerStep4ForecastSection extends StatelessWidget {
  const OwnerStep4ForecastSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final forecast = context.watch<OwnerForecastService>();
    final monitoring = context.read<SystemMonitoringService>();
    final series = forecast.series;
    final scheme = Theme.of(context).colorScheme;

    return LazyDashboardSection(
      placeholderHeight: 140,
      onVisible: () => monitoring.requestCharts(),
      builder: (context) => DashboardSectionShell(
        title: l10n.forecastDashboard,
        icon: Icons.trending_up,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: ForecastHorizon.values.map((h) {
                return FilterChip(
                  label: Text(_horizonLabel(l10n, h)),
                  selected: forecast.horizon == h,
                  showCheckmark: false,
                  onSelected: (_) => forecast.setHorizon(h),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (series == null)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final cross = constraints.maxWidth >= 900 ? 2 : 1;
                  final scale = (List<double> v) =>
                      MonitoringFilterScope.scaleSeries(context, v);
                  final charts = [
                    (l10n.dailyRegistrations, scale(series.registrations), scheme.primary, false),
                    (l10n.dailyQueues, scale(series.queueGrowth), Colors.orange, false),
                    (l10n.dailyAppointments, scale(series.appointmentGrowth), Colors.teal, false),
                    (l10n.monthlyRevenue, scale(series.revenue), AppTheme.medicalGreen, true),
                    (l10n.storageUsage, scale(series.storageUsage), Colors.indigo, false),
                    (l10n.firebaseMonitoring, scale(series.firebaseUsage), Colors.blueGrey, false),
                  ];
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: cross == 2 ? 1.55 : 1.4,
                    ),
                    itemCount: charts.length,
                    itemBuilder: (context, i) {
                      final (title, values, color, bar) = charts[i];
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
        ),
      ),
    );
  }

  String _horizonLabel(AppLocalizations l10n, ForecastHorizon h) => switch (h) {
        ForecastHorizon.next7Days => l10n.forecastNext7Days,
        ForecastHorizon.nextMonth => l10n.forecastNextMonth,
        ForecastHorizon.nextYear => l10n.forecastNextYear,
      };
}

// ─── 3. Firebase Cost Analyzer ───────────────────────────────────────────────

class OwnerStep4FirebaseCostSection extends StatelessWidget {
  const OwnerStep4FirebaseCostSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analysis = context.watch<FirebaseCostOptimizerService>().analysis;
    if (analysis == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return DashboardSectionShell(
      title: l10n.firebaseCostOptimizer,
      icon: Icons.savings_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonitoringMetricGrid(
            items: [
              (
                label: l10n.estimatedMonthlyCost,
                value: '\$${analysis.estimatedMonthlyUsd.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: AppTheme.medicalGreen,
              ),
              (
                label: l10n.firestoreReads,
                value: '${analysis.readOperations}',
                icon: Icons.read_more,
                color: scheme.primary,
              ),
              (
                label: l10n.firestoreWrites,
                value: '${analysis.writeOperations}',
                icon: Icons.edit_note,
                color: Colors.orange,
              ),
              (
                label: l10n.storageUsage,
                value: '${analysis.storageMb.toStringAsFixed(1)} MB',
                icon: Icons.storage,
                color: Colors.indigo,
              ),
              (
                label: l10n.bandwidthUsage,
                value: '${analysis.bandwidthMb.toStringAsFixed(1)} MB',
                icon: Icons.swap_vert,
                color: Colors.teal,
              ),
              (
                label: l10n.imageStorageUsage,
                value: '${analysis.imageStorageMb.toStringAsFixed(1)} MB',
                icon: Icons.image_outlined,
                color: Colors.deepPurple,
              ),
              (
                label: l10n.cacheEfficiency,
                value: '${analysis.cacheHitRate}%',
                icon: Icons.cached_outlined,
                color: analysis.cacheHitRate >= 90 ? AppTheme.medicalGreen : Colors.amber,
              ),
            ],
          ),
          if (analysis.expensiveOperationWarnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...analysis.expensiveOperationWarnings.map(
              (w) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                color: scheme.errorContainer.withOpacity(0.45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.warning_amber_rounded, color: scheme.error),
                  title: Text(w, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(l10n.highCostOperationWarning),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l10n.optimizationSuggestions,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ...analysis.suggestions.map(
            (s) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 6),
              color: scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.lightbulb_outline, color: scheme.tertiary),
                title: Text(s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 4–8. Domain analytics ───────────────────────────────────────────────────

class OwnerAdvertisementMonitoringSection extends StatelessWidget {
  const OwnerAdvertisementMonitoringSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = context.select<SystemMonitoringService, SystemMonitoringSnapshot?>(
      (m) => m.snapshot,
    );
    if (snapshot == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return DashboardSectionShell(
      title: l10n.advertisementMonitoring,
      icon: Icons.campaign_outlined,
      child: MonitoringMetricGrid(
        items: [
          ..._scaledMetrics(context, [
            (label: l10n.activeAdvertisements, value: snapshot.activeAds, icon: Icons.play_circle_outline, color: scheme.primary),
            (label: l10n.scheduledAdvertisements, value: snapshot.scheduledAds, icon: Icons.schedule, color: Colors.blue),
            (label: l10n.expiredAdvertisements, value: snapshot.expiredAds, icon: Icons.history_toggle_off, color: Colors.orange),
            (label: l10n.adViews, value: snapshot.adViews, icon: Icons.visibility_outlined, color: Colors.teal),
            (label: l10n.adClicks, value: snapshot.adClicks, icon: Icons.ads_click, color: Colors.indigo),
          ]),
          (
            label: l10n.clickRate,
            value: '${snapshot.adClickRate.toStringAsFixed(1)}%',
            icon: Icons.percent,
            color: AppTheme.medicalGreen,
          ),
        ],
      ),
    );
  }
}

class OwnerNotificationMonitoringSection extends StatelessWidget {
  const OwnerNotificationMonitoringSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = context.select<SystemMonitoringService, SystemMonitoringSnapshot?>(
      (m) => m.snapshot,
    );
    if (snapshot == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return DashboardSectionShell(
      title: l10n.notificationMonitoring,
      icon: Icons.notifications_outlined,
      child: MonitoringMetricGrid(
        items: _scaledMetrics(context, [
          (label: l10n.pushSent, value: snapshot.pushSent, icon: Icons.notifications_active, color: scheme.primary),
          (label: l10n.whatsappSent, value: snapshot.whatsappSent, icon: Icons.chat, color: AppTheme.medicalGreen),
          (label: l10n.smsSent, value: snapshot.smsSent, icon: Icons.sms_outlined, color: Colors.teal),
          (label: l10n.failedNotifications, value: snapshot.failedNotifications, icon: Icons.error_outline, color: scheme.error),
          (label: l10n.pendingNotifications, value: snapshot.pendingNotifications, icon: Icons.pending_outlined, color: Colors.orange),
        ]),
      ),
    );
  }
}

class OwnerQueueAnalyticsSection extends StatelessWidget {
  const OwnerQueueAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = context.select<SystemMonitoringService, SystemMonitoringSnapshot?>(
      (m) => m.snapshot,
    );
    if (snapshot == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final avgService = (snapshot.avgWaitingMinutes * 0.55).round().clamp(5, 60);

    return DashboardSectionShell(
      title: l10n.queueAnalytics,
      icon: Icons.queue_outlined,
      child: MonitoringMetricGrid(
        items: [
          ..._scaledMetrics(context, [
            (label: l10n.activeQueues, value: snapshot.activeQueues, icon: Icons.pending_actions, color: scheme.primary),
            (label: l10n.waitingPatients, value: snapshot.waitingPatients, icon: Icons.hourglass_top, color: Colors.orange),
            (label: l10n.completedQueuesToday, value: snapshot.completedQueuesToday, icon: Icons.check_circle_outline, color: AppTheme.medicalGreen),
            (label: l10n.cancelledQueuesToday, value: snapshot.cancelledQueues, icon: Icons.cancel_outlined, color: scheme.error),
          ]),
          (
            label: l10n.avgWaitingTime,
            value: l10n.waitingMinutesLabel(snapshot.avgWaitingMinutes),
            icon: Icons.timer_outlined,
            color: scheme.tertiary,
          ),
          (
            label: l10n.avgServiceTime,
            value: l10n.waitingMinutesLabel(avgService),
            icon: Icons.medical_services_outlined,
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }
}

class OwnerAppointmentAnalyticsSection extends StatelessWidget {
  const OwnerAppointmentAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = context.select<SystemMonitoringService, SystemMonitoringSnapshot?>(
      (m) => m.snapshot,
    );
    if (snapshot == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final completed = (snapshot.todaysAppointments -
            snapshot.missedAppointments -
            snapshot.cancelledAppointments)
        .clamp(0, 9999);

    return DashboardSectionShell(
      title: l10n.appointmentAnalytics,
      icon: Icons.calendar_month_outlined,
      child: MonitoringMetricGrid(
        items: _scaledMetrics(context, [
          (label: l10n.todaysAppointments, value: snapshot.todaysAppointments, icon: Icons.event_available, color: scheme.primary),
          (label: l10n.upcomingAppointments, value: snapshot.upcomingAppointments, icon: Icons.upcoming_outlined, color: Colors.blue),
          (label: l10n.completedAppointments, value: completed, icon: Icons.task_alt, color: AppTheme.medicalGreen),
          (label: l10n.missedAppointments, value: snapshot.missedAppointments, icon: Icons.event_busy, color: Colors.orange),
          (label: l10n.cancelledAppointments, value: snapshot.cancelledAppointments, icon: Icons.event_busy_outlined, color: scheme.error),
        ]),
      ),
    );
  }
}

class OwnerPackageAnalyticsSection extends StatelessWidget {
  const OwnerPackageAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = context.select<SystemMonitoringService, SystemMonitoringSnapshot?>(
      (m) => m.snapshot,
    );
    if (snapshot == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final revenuePerPackage = snapshot.activePackages > 0
        ? snapshot.monthlyRevenue
        : '—';

    return DashboardSectionShell(
      title: l10n.packageAnalytics,
      icon: Icons.card_membership_outlined,
      child: MonitoringMetricGrid(
        items: [
          ..._scaledMetrics(context, [
            (label: l10n.activePackages, value: snapshot.activePackages, icon: Icons.verified_outlined, color: scheme.primary),
            (label: l10n.packagesExpiringSoon, value: snapshot.packagesExpiringSoon, icon: Icons.event_busy, color: Colors.orange),
            (label: l10n.renewalsToday, value: snapshot.renewalsToday, icon: Icons.autorenew, color: AppTheme.medicalGreen),
            (label: l10n.suspendedPackages, value: snapshot.expiredPackages, icon: Icons.block, color: scheme.error),
          ]),
          (
            label: l10n.revenueByPackage,
            value: revenuePerPackage,
            icon: Icons.payments_outlined,
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }
}

// ─── 9. Maintenance Mode ─────────────────────────────────────────────────────

class OwnerMaintenanceModeSection extends StatefulWidget {
  const OwnerMaintenanceModeSection({super.key});

  @override
  State<OwnerMaintenanceModeSection> createState() => _OwnerMaintenanceModeSectionState();
}

class _OwnerMaintenanceModeSectionState extends State<OwnerMaintenanceModeSection> {
  late final TextEditingController _messageController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _messageController = TextEditingController(
        text: context.read<SystemMaintenanceService>().message,
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    if (_initialized) _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maintenance = context.watch<SystemMaintenanceService>();
    final scheme = Theme.of(context).colorScheme;

    return DashboardSectionShell(
      title: l10n.maintenanceMode,
      icon: Icons.build_circle_outlined,
      subtitle: l10n.maintenanceModeHint,
      child: Card(
        elevation: 0,
        color: maintenance.enabled
            ? scheme.errorContainer.withOpacity(0.35)
            : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.enableMaintenanceMode),
                subtitle: Text(l10n.maintenanceAllowOwnerAdmin),
                value: maintenance.enabled,
                onChanged: (value) => maintenance.setMaintenance(
                  enabled: value,
                  message: _messageController.text,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.maintenanceMessage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (text) => maintenance.setMaintenance(
                  enabled: maintenance.enabled,
                  message: text,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () async {
                  await maintenance.setMaintenance(
                    enabled: maintenance.enabled,
                    message: _messageController.text,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.savedSuccessfully)),
                    );
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
      ),
    );
  }
}

/// Centers dashboard content on wide screens with max width constraint.
class OwnerDashboardResponsiveShell extends StatelessWidget {
  const OwnerDashboardResponsiveShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<OwnerDashboardAppearanceService>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth >= 1400
            ? appearance.contentMaxWidth
            : constraints.maxWidth >= 900
                ? (constraints.maxWidth < appearance.contentMaxWidth
                    ? constraints.maxWidth
                    : appearance.contentMaxWidth)
                : constraints.maxWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
