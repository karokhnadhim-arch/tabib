import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/system_monitoring.dart';
import '../../../widgets/owner_metric_card.dart';

class SystemHealthStatusBanner extends StatelessWidget {
  const SystemHealthStatusBanner({
    super.key,
    required this.label,
    required this.level,
    required this.updatedAt,
  });

  final String label;
  final String level;
  final DateTime updatedAt;

  IconData get _icon => switch (level) {
        'critical' => Icons.error_outline,
        'warning' => Icons.warning_amber_rounded,
        _ => Icons.check_circle_outline,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (level) {
      'critical' => scheme.error,
      'warning' => const Color(0xFFF9A825),
      _ => AppTheme.medicalGreen,
    };

    return Card(
      elevation: 0,
      color: color.withOpacity(scheme.brightness == Brightness.dark ? 0.18 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    updatedAt.toLocal().toString().substring(0, 19),
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
    );
  }
}

class MonitoringSectionHeader extends StatelessWidget {
  const MonitoringSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class MonitoringMetricGrid extends StatelessWidget {
  const MonitoringMetricGrid({
    super.key,
    required this.items,
  });

  final List<({String label, String value, IconData icon, Color color})> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
                ? 3
                : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return OwnerMetricCard(
              label: item.label,
              value: item.value,
              icon: item.icon,
              color: item.color,
            );
          },
        );
      },
    );
  }
}

class MonitoringInfoRow extends StatelessWidget {
  const MonitoringInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valueColor =
        warning ? const Color(0xFFF9A825) : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class DashboardDataStatusBanner extends StatelessWidget {
  const DashboardDataStatusBanner({
    super.key,
    required this.showingCached,
    required this.liveUnavailable,
    required this.lastSyncLabel,
    required this.cachedLabel,
    required this.unavailableLabel,
  });

  final bool showingCached;
  final bool liveUnavailable;
  final String lastSyncLabel;
  final String cachedLabel;
  final String unavailableLabel;

  @override
  Widget build(BuildContext context) {
    if (!showingCached && !liveUnavailable) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final color = liveUnavailable ? scheme.error : scheme.primary;
    final bg = color.withOpacity(scheme.brightness == Brightness.dark ? 0.15 : 0.08);
    final message = liveUnavailable ? unavailableLabel : cachedLabel;

    return Card(
      elevation: 0,
      color: bg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.25)),
      ),
      child: ListTile(
        leading: Icon(
          liveUnavailable ? Icons.cloud_off_outlined : Icons.cached,
          color: color,
        ),
        title: Text(
          message,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        subtitle: lastSyncLabel.isNotEmpty
            ? Text(
                lastSyncLabel,
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            : null,
      ),
    );
  }
}

/// Defers loading until the section scrolls into view (lazy, non-blocking).
class LazyDashboardSection extends StatefulWidget {
  const LazyDashboardSection({
    super.key,
    required this.onVisible,
    required this.builder,
    this.placeholderHeight = 120,
  });

  final VoidCallback onVisible;
  final Widget Function(BuildContext context) builder;
  final double placeholderHeight;

  @override
  State<LazyDashboardSection> createState() => _LazyDashboardSectionState();
}

class _LazyDashboardSectionState extends State<LazyDashboardSection> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loaded) return;
      setState(() => _loaded = true);
      widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return SizedBox(
        height: widget.placeholderHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return widget.builder(context    );
  }
}

/// Material 3 panel wrapping infrastructure metric rows.
class MonitoringPanelCard extends StatelessWidget {
  const MonitoringPanelCard({
    super.key,
    required this.child,
    this.leading,
  });

  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leading != null) ...[leading!, const SizedBox(height: 8)],
            child,
          ],
        ),
      ),
    );
  }
}

class OwnerSmartAlertsSection extends StatelessWidget {
  const OwnerSmartAlertsSection({
    super.key,
    required this.alerts,
    required this.emptyLabel,
    required this.alertLabel,
  });

  final List<OwnerAlert> alerts;
  final String emptyLabel;
  final String Function(OwnerAlert alert) alertLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (alerts.isEmpty) {
      return Card(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.verified_outlined, color: AppTheme.medicalGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  emptyLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: alerts.map((alert) {
        final color = alert.severity == SystemHealthLevel.critical
            ? scheme.error
            : const Color(0xFFF9A825);
        final bg = color.withOpacity(
          scheme.brightness == Brightness.dark ? 0.14 : 0.08,
        );
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
          child: ListTile(
            leading: Icon(
              alert.severity == SystemHealthLevel.critical
                  ? Icons.error_outline
                  : Icons.warning_amber_rounded,
              color: color,
            ),
            title: Text(
              alertLabel(alert),
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
            subtitle: Text(
              alert.timestamp.toLocal().toString().substring(0, 19),
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class LiveActivityTimeline extends StatelessWidget {
  const LiveActivityTimeline({
    super.key,
    required this.entries,
    required this.emptyLabel,
    required this.eventLabel,
  });

  final List<ActivityFeedEntry> entries;
  final String emptyLabel;
  final String Function(ActivityEventType type) eventLabel;

  IconData _iconFor(ActivityEventType type) => switch (type) {
        ActivityEventType.doctorCreated ||
        ActivityEventType.doctorUpdated =>
          Icons.medical_services_outlined,
        ActivityEventType.secretaryAdded => Icons.support_agent_outlined,
        ActivityEventType.patientRegistered => Icons.person_add_outlined,
        ActivityEventType.businessCreated => Icons.storefront_outlined,
        ActivityEventType.queueJoined => Icons.queue_outlined,
        ActivityEventType.queueCancelled => Icons.cancel_schedule_send_outlined,
        ActivityEventType.appointmentBooked => Icons.event_available_outlined,
        ActivityEventType.appointmentCancelled => Icons.event_busy_outlined,
        ActivityEventType.advertisementCreated => Icons.campaign_outlined,
        ActivityEventType.packageActivated ||
        ActivityEventType.packageRenewed =>
          Icons.card_membership_outlined,
        ActivityEventType.login => Icons.login_outlined,
        ActivityEventType.logout => Icons.logout_outlined,
      };

  Color _colorFor(ActivityEventType type, ColorScheme scheme) =>
      switch (type) {
        ActivityEventType.queueCancelled ||
        ActivityEventType.appointmentCancelled ||
        ActivityEventType.logout =>
          scheme.error,
        ActivityEventType.doctorCreated ||
        ActivityEventType.patientRegistered ||
        ActivityEventType.appointmentBooked ||
        ActivityEventType.packageActivated =>
          AppTheme.medicalGreen,
        _ => scheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (entries.isEmpty) {
      return Card(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(Icons.history_toggle_off, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  emptyLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < entries.length; i++)
              _ActivityTimelineTile(
                entry: entries[i],
                icon: _iconFor(entries[i].type),
                color: _colorFor(entries[i].type, scheme),
                typeLabel: eventLabel(entries[i].type),
                isLast: i == entries.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTimelineTile extends StatelessWidget {
  const _ActivityTimelineTile({
    required this.entry,
    required this.icon,
    required this.color,
    required this.typeLabel,
    required this.isLast,
  });

  final ActivityFeedEntry entry;
  final IconData icon;
  final Color color;
  final String typeLabel;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final timestamp = entry.timestamp.toLocal();
    final timeLabel =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.outlineVariant.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.only(right: 16, bottom: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(
                    scheme.brightness == Brightness.dark ? 0.2 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              title: Text(
                entry.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                [
                  typeLabel,
                  if (entry.actorName != null) entry.actorName!,
                  timeLabel,
                ].join(' · '),
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonitoringBarChart extends StatelessWidget {
  const MonitoringBarChart({
    super.key,
    required this.values,
    required this.color,
  });

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox(height: 120);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: maxVal == 0 ? 4 : (v / maxVal) * 120,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
