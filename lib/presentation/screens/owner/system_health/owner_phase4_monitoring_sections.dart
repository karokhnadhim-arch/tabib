import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/owner_monitoring_phase4.dart';
import '../../../../services/firebase_cost_optimizer_service.dart';
import '../../../../services/owner_dashboard_appearance_service.dart';
import '../../../../services/owner_dashboard_filter_service.dart';
import '../../../../services/owner_dashboard_search_service.dart';
import '../../../../services/owner_forecast_service.dart';
import '../../../../services/owner_insights_service.dart';
import '../../../../services/smart_owner_notification_service.dart';
import '../../../../services/theme_service.dart';
import 'monitoring_filter_scope.dart';
import 'monitoring_interactive_chart.dart';
import 'system_health_widgets.dart';

// ─── Global search bar ───────────────────────────────────────────────────────

class OwnerGlobalSearchBar extends StatelessWidget {
  const OwnerGlobalSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final search = context.watch<OwnerDashboardSearchService>();
    final results = search.results;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBar(
          hintText: l10n.globalSearchHint,
          leading: const Icon(Icons.search),
          trailing: search.query.isNotEmpty
              ? [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: search.clear,
                  ),
                ]
              : null,
          onChanged: search.setQuery,
        ),
        if (results.isNotEmpty)
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(top: 4),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length.clamp(0, 8),
              itemBuilder: (context, index) {
                final r = results[index];
                return ListTile(
                  dense: true,
                  leading: Icon(_searchIcon(r.category)),
                  title: Text(r.title),
                  subtitle: Text(r.subtitle),
                );
              },
            ),
          ),
      ],
    );
  }

  IconData _searchIcon(DashboardSearchCategory c) => switch (c) {
        DashboardSearchCategory.doctor => Icons.medical_services_outlined,
        DashboardSearchCategory.patient => Icons.person_outline,
        DashboardSearchCategory.secretary => Icons.support_agent_outlined,
        DashboardSearchCategory.business => Icons.storefront_outlined,
        DashboardSearchCategory.advertisement => Icons.campaign_outlined,
        DashboardSearchCategory.package => Icons.card_membership_outlined,
        DashboardSearchCategory.queue => Icons.queue_outlined,
        DashboardSearchCategory.appointment => Icons.event_outlined,
        DashboardSearchCategory.auditLog => Icons.history,
      };
}

// ─── Global filters ──────────────────────────────────────────────────────────

class OwnerGlobalFilterBar extends StatelessWidget {
  const OwnerGlobalFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = context.watch<OwnerDashboardFilterService>();
    final f = filters.filter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.globalDashboardFilters,
          icon: Icons.filter_list,
          trailing: f.isActive
              ? TextButton(onPressed: filters.clearFilters, child: Text(l10n.clearFilters))
              : null,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _FilterMenu<String?>(
              label: l10n.filterByCity,
              value: f.city,
              items: [
                (null, l10n.activityFilterAll),
                ...filters.availableCities.map((c) => (c, c)),
              ],
              onSelected: (v) => filters.setFilter(f.copyWith(city: v, clearCity: v == null)),
            ),
            _FilterMenu<String?>(
              label: l10n.filterByBusiness,
              value: f.businessId,
              items: [
                (null, l10n.activityFilterAll),
                ...filters.availableBusinesses.map((b) => (b.id, b.label)),
              ],
              onSelected: (v) =>
                  filters.setFilter(f.copyWith(businessId: v, clearBusiness: v == null)),
            ),
            _FilterMenu<String?>(
              label: l10n.filterByDoctor,
              value: f.doctorId,
              items: [
                (null, l10n.activityFilterAll),
                ...filters.availableDoctors.map((d) => (d.id, d.label)),
              ],
              onSelected: (v) =>
                  filters.setFilter(f.copyWith(doctorId: v, clearDoctor: v == null)),
            ),
            _FilterMenu<DashboardStatusFilter>(
              label: l10n.filterByStatus,
              value: f.status,
              items: [
                (DashboardStatusFilter.all, l10n.activityFilterAll),
                (DashboardStatusFilter.active, l10n.statusActive),
                (DashboardStatusFilter.suspended, l10n.statusSuspended),
              ],
              onSelected: (v) => filters.setFilter(f.copyWith(status: v)),
            ),
            ActionChip(
              avatar: const Icon(Icons.date_range, size: 18),
              label: Text(
                f.dateRange != null
                    ? '${DateFormat.MMMd().format(f.dateRange!.start)} – ${DateFormat.MMMd().format(f.dateRange!.end)}'
                    : l10n.filterCustomRange,
              ),
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now,
                  initialDateRange: f.dateRange ??
                      DateTimeRange(
                        start: now.subtract(const Duration(days: 30)),
                        end: now,
                      ),
                );
                if (picked != null && context.mounted) {
                  filters.setFilter(f.copyWith(dateRange: picked));
                }
              },
            ),
          ],
        ),
        if (f.isActive)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.filterScaleHint('${(filters.scaleFactor * 100).round()}'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.value,
    required this.items,
    required this.onSelected,
  });

  final String label;
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = items.where((e) => e.$1 == value).map((e) => e.$2).firstOrNull ?? label;
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => items
          .map((e) => PopupMenuItem(value: e.$1, child: Text(e.$2)))
          .toList(),
      child: Chip(label: Text('$label: $selected')),
    );
  }
}

// ─── AI Insights ─────────────────────────────────────────────────────────────

class OwnerAiInsightsSection extends StatelessWidget {
  const OwnerAiInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insights = context.watch<OwnerInsightsService>().insights;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.aiInsightsCenter,
          icon: Icons.auto_awesome_outlined,
        ),
        Text(
          l10n.aiInsightsHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        ...insights.map((insight) {
          final color = switch (insight.priority) {
            InsightPriority.high => scheme.error,
            InsightPriority.medium => Colors.amber.shade800,
            InsightPriority.low => scheme.primary,
          };
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            color: color.withOpacity(scheme.brightness == Brightness.dark ? 0.12 : 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: color.withOpacity(0.25)),
            ),
            child: ListTile(
              leading: Icon(_categoryIcon(insight.category), color: color),
              title: Text(insight.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(insight.recommendation),
                  const SizedBox(height: 4),
                  Text(
                    '${_priorityLabel(l10n, insight.priority)} · ${_categoryLabel(l10n, insight.category)} · ${DateFormat.jm().format(insight.generatedAt)}',
                    style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        }),
      ],
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

// ─── Forecasts ───────────────────────────────────────────────────────────────

class OwnerForecastSection extends StatelessWidget {
  const OwnerForecastSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final forecast = context.watch<OwnerForecastService>();
    final series = forecast.series;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.forecastDashboard,
          icon: Icons.trending_up,
        ),
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
          const Center(child: CircularProgressIndicator())
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth >= 900 ? 2 : 1;
              final scaled = (List<double> v) => MonitoringFilterScope.scaleSeries(context, v);
              final charts = [
                (l10n.dailyRegistrations, scaled(series.registrations), scheme.primary),
                (l10n.dailyQueues, scaled(series.queueGrowth), Colors.orange),
                (l10n.dailyAppointments, scaled(series.appointmentGrowth), Colors.teal),
                (l10n.monthlyRevenue, scaled(series.revenue), AppTheme.medicalGreen),
                (l10n.storageUsage, scaled(series.storageUsage), Colors.indigo),
                (l10n.firebaseMonitoring, scaled(series.firebaseUsage), Colors.blueGrey),
                (l10n.advertisementRevenue, scaled(series.adRevenue), Colors.purple),
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: charts.length,
                itemBuilder: (context, i) {
                  final (title, values, color) = charts[i];
                  return MonitoringInteractiveChart(
                    title: title,
                    values: values,
                    color: color,
                    barMode: title == l10n.monthlyRevenue,
                  );
                },
              );
            },
          ),
      ],
    );
  }

  String _horizonLabel(AppLocalizations l10n, ForecastHorizon h) => switch (h) {
        ForecastHorizon.next7Days => l10n.forecastNext7Days,
        ForecastHorizon.nextMonth => l10n.forecastNextMonth,
        ForecastHorizon.nextYear => l10n.forecastNextYear,
      };
}

// ─── Smart notifications ─────────────────────────────────────────────────────

class OwnerSmartNotificationsSection extends StatelessWidget {
  const OwnerSmartNotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = context.watch<SmartOwnerNotificationService>();
    final items = service.inboxItems;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.smartOwnerNotifications,
          icon: Icons.notifications_active_outlined,
        ),
        ...items.map((n) {
          return Dismissible(
            key: ValueKey(n.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => service.delete(n.id),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: scheme.error,
              child: Icon(Icons.delete_outline, color: scheme.onError),
            ),
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              color: n.isRead
                  ? scheme.surfaceContainerLow
                  : scheme.primaryContainer.withOpacity(0.35),
              child: ListTile(
                leading: Icon(
                  n.isRead ? Icons.notifications_none : Icons.notifications,
                  color: scheme.primary,
                ),
                title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${n.message}\n${DateFormat.yMMMd().add_jm().format(n.timestamp)}',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'read':
                        service.markRead(n.id);
                      case 'archive':
                        service.archive(n.id);
                      case 'delete':
                        service.delete(n.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'read', child: Text(l10n.markAsRead)),
                    PopupMenuItem(value: 'archive', child: Text(l10n.archiveNotification)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.deleteError)),
                  ],
                ),
              ),
            ),
          );
        }),
        if (items.isEmpty)
          Text(l10n.noActiveAlerts, style: TextStyle(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

// ─── Firebase cost optimizer ─────────────────────────────────────────────────

class OwnerFirebaseCostSection extends StatelessWidget {
  const OwnerFirebaseCostSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analysis = context.watch<FirebaseCostOptimizerService>().analysis;
    if (analysis == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.firebaseCostOptimizer,
          icon: Icons.savings_outlined,
        ),
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
          ],
        ),
        if (analysis.expensiveOperationWarnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...analysis.expensiveOperationWarnings.map(
            (w) => Card(
              color: scheme.errorContainer.withOpacity(0.5),
              child: ListTile(
                leading: Icon(Icons.warning_amber, color: scheme.error),
                title: Text(w),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(l10n.optimizationSuggestions,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ...analysis.suggestions.map(
          (s) => ListTile(
            dense: true,
            leading: Icon(Icons.lightbulb_outline, color: scheme.tertiary),
            title: Text(s),
          ),
        ),
      ],
    );
  }
}

// ─── Appearance ──────────────────────────────────────────────────────────────

class OwnerAppearanceSection extends StatelessWidget {
  const OwnerAppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appearance = context.watch<OwnerDashboardAppearanceService>();
    final themeService = context.read<ThemeService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.themeAndAppearance,
          icon: Icons.palette_outlined,
        ),
        Text(l10n.themeAppearanceHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(value: ThemeMode.light, label: Text(l10n.lightMode), icon: const Icon(Icons.light_mode)),
            ButtonSegment(value: ThemeMode.dark, label: Text(l10n.darkMode), icon: const Icon(Icons.dark_mode)),
            ButtonSegment(value: ThemeMode.system, label: Text(l10n.systemMode), icon: const Icon(Icons.brightness_auto)),
          ],
          selected: {appearance.dashboardThemeMode},
          onSelectionChanged: (s) async {
            final mode = s.first;
            await appearance.setDashboardThemeMode(mode);
            await themeService.setThemeMode(mode);
          },
        ),
        const SizedBox(height: 12),
        Text(l10n.accentColor, style: const TextStyle(fontWeight: FontWeight.w600)),
        Wrap(
          spacing: 8,
          children: DashboardAccent.values.map((accent) {
            final color = switch (accent) {
              DashboardAccent.blue => const Color(0xFF1E88E5),
              DashboardAccent.green => const Color(0xFF2E7D32),
              DashboardAccent.teal => const Color(0xFF00897B),
              DashboardAccent.purple => const Color(0xFF7B1FA2),
              DashboardAccent.orange => const Color(0xFFF57C00),
            };
            return ChoiceChip(
              label: Text(accent.name),
              selected: appearance.accent == accent,
              avatar: CircleAvatar(backgroundColor: color, radius: 8),
              onSelected: (_) => appearance.setAccent(accent),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(l10n.cardDensity, style: const TextStyle(fontWeight: FontWeight.w600)),
        SegmentedButton<DashboardDensity>(
          segments: [
            ButtonSegment(value: DashboardDensity.compact, label: Text(l10n.compactMode)),
            ButtonSegment(value: DashboardDensity.comfortable, label: Text(l10n.comfortableMode)),
          ],
          selected: {appearance.density},
          onSelectionChanged: (s) => appearance.setDensity(s.first),
        ),
        const SizedBox(height: 12),
        Text(l10n.dashboardLayout, style: const TextStyle(fontWeight: FontWeight.w600)),
        SegmentedButton<DashboardLayout>(
          segments: [
            ButtonSegment(value: DashboardLayout.standard, label: Text(l10n.layoutStandard)),
            ButtonSegment(value: DashboardLayout.wide, label: Text(l10n.layoutWide)),
            ButtonSegment(value: DashboardLayout.focused, label: Text(l10n.layoutFocused)),
          ],
          selected: {appearance.layout},
          onSelectionChanged: (s) => appearance.setLayout(s.first),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => context.push('/owner/console/system-health/settings'),
            icon: const Icon(Icons.settings_outlined),
            label: Text(l10n.advancedSystemSettings),
          ),
        ),
      ],
    );
  }
}
