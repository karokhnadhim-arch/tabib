import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../screens/owner/system_health/owner_dashboard_ui.dart';

/// Metric summary tile for the System Owner overview dashboard.
class OwnerMetricCard extends StatelessWidget {
  const OwnerMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.subtitleContent,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final Widget? subtitleContent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Material(
      color: scheme.surface,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: OwnerDashboardTokens.cardShape,
        side: BorderSide(
          color: scheme.outlineVariant.withOpacity(isDark ? 0.35 : 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            boxShadow: OwnerDashboardTokens.cardShadow(context),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 136;
              final padding = compact ? 12.0 : 16.0;
              final valueSize = compact ? 22.0 : 26.0;
              final iconBox = compact ? 8.0 : 10.0;
              final iconSize = compact ? 20.0 : 22.0;

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(iconBox),
                          decoration: BoxDecoration(
                            color: color.withOpacity(isDark ? 0.22 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: iconSize),
                        ),
                        const Spacer(),
                        if (onTap != null)
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: scheme.onSurfaceVariant.withOpacity(0.55),
                            size: 14,
                          ),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                        fontSize: valueSize,
                                        height: 1.05,
                                      ),
                                ),
                                SizedBox(height: compact ? 4 : 6),
                                Text(
                                  label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: scheme.onSurfaceVariant,
                                        height: 1.2,
                                        fontSize: compact ? 12.5 : null,
                                      ),
                                ),
                                if (subtitleContent != null) ...[
                                  SizedBox(height: compact ? 4 : 6),
                                  subtitleContent!,
                                ] else if (subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant.withOpacity(0.85),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Compact queue stat chips for the live queue metric card.
class OwnerQueueMetricDetails extends StatelessWidget {
  const OwnerQueueMetricDetails({
    super.key,
    required this.waitingLabel,
    required this.waitingCount,
    required this.inProgressLabel,
    required this.inProgressCount,
  });

  final String waitingLabel;
  final int waitingCount;
  final String inProgressLabel;
  final int inProgressCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _QueueStatChip(label: waitingLabel, value: '$waitingCount'),
        _QueueStatChip(label: inProgressLabel, value: '$inProgressCount'),
      ],
    );
  }
}

class _QueueStatChip extends StatelessWidget {
  const _QueueStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.medicalBlue.withOpacity(
          scheme.brightness == Brightness.dark ? 0.18 : 0.08,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.medicalBlue.withOpacity(0.2),
        ),
      ),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 10.5,
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.medicalBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
