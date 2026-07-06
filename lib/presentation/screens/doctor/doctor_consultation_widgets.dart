import 'package:flutter/material.dart';

/// Visual tokens for the doctor consultation workspace.
abstract final class DoctorConsultationTokens {
  static const double radius = 16;
  static const double sectionGap = 10;
  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const double iconSize = 22;

  static BorderRadius get cardRadius => BorderRadius.circular(radius);
}

/// Compact patient header card — always visible during consultation.
class DoctorPatientSummaryCard extends StatelessWidget {
  const DoctorPatientSummaryCard({
    super.key,
    required this.patientName,
    required this.position,
    required this.statusLabel,
    required this.statusColor,
    required this.contactBar,
    this.autoSaved = false,
    this.autoSavedLabel,
    this.completedBanner,
  });

  final String patientName;
  final int position;
  final String statusLabel;
  final Color statusColor;
  final Widget contactBar;
  final bool autoSaved;
  final String? autoSavedLabel;
  final Widget? completedBanner;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: DoctorConsultationTokens.cardRadius,
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$position',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: textTheme.labelLarge?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (autoSaved && autoSavedLabel != null)
                  Icon(
                    Icons.cloud_done_outlined,
                    size: 20,
                    color: scheme.primary,
                    semanticLabel: autoSavedLabel,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            contactBar,
            if (completedBanner != null) ...[
              const SizedBox(height: 12),
              completedBanner!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Single-focus expandable consultation section.
class DoctorConsultationSectionTile extends StatelessWidget {
  const DoctorConsultationSectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.expanded,
    required this.onTap,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: DoctorConsultationTokens.sectionGap),
      decoration: BoxDecoration(
        color: expanded ? scheme.surface : scheme.surfaceContainerLowest,
        borderRadius: DoctorConsultationTokens.cardRadius,
        border: Border.all(
          color: expanded
              ? scheme.primary.withOpacity(0.45)
              : scheme.outlineVariant.withOpacity(0.4),
          width: expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: DoctorConsultationTokens.cardRadius,
              onTap: onTap,
              child: Padding(
                padding: DoctorConsultationTokens.sectionPadding,
                child: Row(
                  children: [
                    Icon(icon, size: DoctorConsultationTokens.iconSize, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (subtitle != null && !expanded) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
