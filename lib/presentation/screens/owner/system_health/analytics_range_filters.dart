import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/system_monitoring.dart';
import '../../../../services/dashboard_date_presets.dart';
import '../../../../services/owner_dashboard_filter_service.dart';
import '../../../../services/system_monitoring_service.dart';

/// Date-range chips for analytics and global dashboard filters.
class AnalyticsRangeFilters extends StatelessWidget {
  const AnalyticsRangeFilters({
    super.key,
    required this.monitoring,
    this.syncGlobalFilter = false,
  });

  final SystemMonitoringService monitoring;
  final bool syncGlobalFilter;

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
                if (syncGlobalFilter) {
                  _syncGlobalFilter(context, AnalyticsRange.custom, picked);
                }
              }
            } else {
              monitoring.setRange(entry.$1);
              if (syncGlobalFilter) {
                _syncGlobalFilter(context, entry.$1, null);
              }
            }
          },
        );
      }).toList(),
    );
  }

  void _syncGlobalFilter(
    BuildContext context,
    AnalyticsRange range,
    DateTimeRange? custom,
  ) {
    final filters = context.read<OwnerDashboardFilterService>();
    final dateRange = custom ??
        DashboardDatePresets.forAnalyticsRange(
          range,
          customStart: monitoring.customRangeStart,
          customEnd: monitoring.customRangeEnd,
        );
    filters.setFilter(
      filters.filter.copyWith(
        dateRange: dateRange,
        clearDateRange: dateRange == null,
      ),
    );
  }
}

/// Global filter date presets (City/Business/Doctor companion chips).
class DashboardDatePresetFilters extends StatelessWidget {
  const DashboardDatePresetFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = context.watch<OwnerDashboardFilterService>();
    final f = filters.filter;

    final presets = <(String, DateTimeRange?)>[
      (l10n.filterToday, DashboardDatePresets.today()),
      (l10n.filterYesterday, DashboardDatePresets.yesterday()),
      (l10n.filterLast7Days, DashboardDatePresets.last7Days()),
      (l10n.filterThisMonth, DashboardDatePresets.thisMonth()),
      (l10n.filterThisYear, DashboardDatePresets.thisYear()),
    ];

    bool isSelected(DateTimeRange range) {
      final current = f.dateRange;
      if (current == null) return false;
      return current.start == range.start && current.end == range.end;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...presets.map((entry) {
          final selected = isSelected(entry.$2!);
          return FilterChip(
            label: Text(entry.$1),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) {
              filters.setFilter(f.copyWith(dateRange: entry.$2));
            },
          );
        }),
        ActionChip(
          avatar: const Icon(Icons.date_range, size: 18),
          label: Text(
            f.dateRange != null &&
                    !presets.any((p) => isSelected(p.$2!))
                ? '${MaterialLocalizations.of(context).formatShortDate(f.dateRange!.start)} – ${MaterialLocalizations.of(context).formatShortDate(f.dateRange!.end)}'
                : l10n.filterCustomRange,
          ),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: now.subtract(const Duration(days: 365 * 3)),
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
    );
  }
}
