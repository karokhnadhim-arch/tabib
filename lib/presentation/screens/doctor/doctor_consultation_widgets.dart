import 'package:flutter/material.dart';

/// Visual tokens for the doctor consultation workspace.
abstract final class DoctorConsultationTokens {
  static const double radius = 16;
  static const double sectionGap = 14;
  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(horizontal: 18, vertical: 16);
  static const double iconSize = 22;

  static BorderRadius get cardRadius => BorderRadius.circular(radius);
}

/// Professional panel chrome for desktop workspace columns.
class DoctorWorkspacePanel extends StatelessWidget {
  const DoctorWorkspacePanel({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.scrollable = true,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = scrollable
        ? SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          );

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: DoctorConsultationTokens.cardRadius,
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(icon, color: scheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Always-visible consultation section for desktop scroll layout.
class DoctorConsultationSectionCard extends StatelessWidget {
  const DoctorConsultationSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: DoctorConsultationTokens.sectionGap),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: DoctorConsultationTokens.cardRadius,
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
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
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
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
    this.embedded = false,
  });

  final String patientName;
  final int position;
  final String statusLabel;
  final Color statusColor;
  final Widget contactBar;
  final bool autoSaved;
  final String? autoSavedLabel;
  final Widget? completedBanner;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final content = Padding(
      padding: EdgeInsets.all(embedded ? 0 : 16),
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
    );

    if (embedded) return content;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: DoctorConsultationTokens.cardRadius,
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: content,
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
