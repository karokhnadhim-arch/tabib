import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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

  Color get _color => switch (level) {
        'critical' => Colors.red.shade700,
        'warning' => const Color(0xFFF9A825),
        _ => AppTheme.medicalGreen,
      };

  IconData get _icon => switch (level) {
        'critical' => Icons.error_outline,
        'warning' => Icons.warning_amber_rounded,
        _ => Icons.check_circle_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: _color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _color.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_icon, color: _color, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _color,
                    ),
                  ),
                  Text(
                    updatedAt.toLocal().toString().substring(0, 19),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
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
  });

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.primaryDark, size: 22),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: warning ? Colors.orange.shade800 : null,
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

    final color = liveUnavailable ? Colors.orange.shade800 : Colors.blue.shade800;
    final bg = liveUnavailable ? Colors.orange.shade50 : Colors.blue.shade50;
    final message = liveUnavailable ? unavailableLabel : cachedLabel;

    return Card(
      color: bg,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          liveUnavailable ? Icons.cloud_off_outlined : Icons.cached,
          color: color,
        ),
        title: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        subtitle: lastSyncLabel.isNotEmpty ? Text(lastSyncLabel) : null,
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
    return widget.builder(context);
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
