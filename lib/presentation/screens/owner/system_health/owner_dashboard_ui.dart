import 'package:flutter/material.dart';

/// Enterprise dashboard visual tokens — Material 3, healthcare admin style.
abstract final class OwnerDashboardTokens {
  static const double cardRadius = 18;
  static const double groupRadius = 20;
  static const double sectionGap = 32;
  static const double innerGap = 20;
  static const double gridGap = 16;
  static const double metricTileHeight = 148;

  static BorderRadius get cardShape => BorderRadius.circular(cardRadius);
  static BorderRadius get groupShape => BorderRadius.circular(groupRadius);

  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
        blurRadius: isDark ? 18 : 24,
        offset: Offset(0, isDark ? 6 : 4),
      ),
    ];
  }
}

/// Premium elevated surface used across monitoring modules.
class OwnerDashboardSurfaceCard extends StatelessWidget {
  const OwnerDashboardSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: OwnerDashboardTokens.cardShape,
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(isDark ? 0.35 : 0.55),
        ),
        boxShadow: OwnerDashboardTokens.cardShadow(context),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Top-level visual group — e.g. System Health, Statistics, Security.
class OwnerDashboardGroup extends StatelessWidget {
  const OwnerDashboardGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OwnerDashboardFadeIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OwnerDashboardGroupHeader(
            title: title,
            icon: icon,
            subtitle: subtitle,
            trailing: trailing,
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest.withOpacity(
                scheme.brightness == Brightness.dark ? 0.55 : 0.85,
              ),
              borderRadius: OwnerDashboardTokens.groupShape,
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.35),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerDashboardGroupHeader extends StatelessWidget {
  const OwnerDashboardGroupHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withOpacity(0.65),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: scheme.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Subtle entrance animation for dashboard blocks.
class OwnerDashboardFadeIn extends StatefulWidget {
  const OwnerDashboardFadeIn({super.key, required this.child, this.delay = 0});

  final Widget child;
  final int delay;

  @override
  State<OwnerDashboardFadeIn> createState() => _OwnerDashboardFadeInState();
}

class _OwnerDashboardFadeInState extends State<OwnerDashboardFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future<void>.delayed(Duration(milliseconds: widget.delay * 40), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
