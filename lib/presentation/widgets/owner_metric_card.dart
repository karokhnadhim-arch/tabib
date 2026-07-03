import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 118;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(compact ? 6 : 8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: compact ? 20 : 22,
                        ),
                      ),
                      const Spacer(),
                      if (onTap != null)
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: compact ? 18 : 24,
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
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                value,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                      fontSize: compact ? 22 : null,
                                    ),
                              ),
                              SizedBox(height: compact ? 2 : 4),
                              Text(
                                label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: compact ? 11.5 : 12.5,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                              if (subtitleContent != null) ...[
                                SizedBox(height: compact ? 2 : 4),
                                subtitleContent!,
                              ] else if (subtitle != null) ...[
                                SizedBox(height: compact ? 2 : 4),
                                Text(
                                  subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: compact ? 10 : 11,
                                    color: Colors.grey.shade500,
                                    height: 1.2,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.medicalBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.medicalBlue.withOpacity(0.15)),
      ),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700),
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
