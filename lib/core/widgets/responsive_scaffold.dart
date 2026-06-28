import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Centers content on wide screens with a max width constraint.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? EdgeInsets.all(responsivePadding(context));
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );
  }
}

/// Scrollable body with responsive max width and keyboard-aware bottom padding.
class ScrollableResponsiveBody extends StatelessWidget {
  const ScrollableResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding,
    this.keyboardInset = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool keyboardInset;

  @override
  Widget build(BuildContext context) {
    final base = padding ?? EdgeInsets.all(responsivePadding(context));
    final resolved = base.resolve(Directionality.of(context));
    final bottomInset =
        keyboardInset ? MediaQuery.viewInsetsOf(context).bottom : 0.0;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            resolved.left,
            resolved.top,
            resolved.right,
            resolved.bottom + bottomInset,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: child,
        ),
      ),
    );
  }
}

/// Prevents [SegmentedButton] label overflow on narrow or RTL locales.
class ResponsiveSegmentedButton<T> extends StatelessWidget {
  const ResponsiveSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final void Function(Set<T>) onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;

  @override
  Widget build(BuildContext context) {
    final button = SegmentedButton<T>(
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      showSelectedIcon: false,
    );

    if (screenSizeOf(context) != ScreenSize.mobile) {
      return button;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: button,
    );
  }
}

/// Stacks action buttons vertically on narrow screens to avoid horizontal overflow.
class ResponsiveActionButtons extends StatelessWidget {
  const ResponsiveActionButtons({
    super.key,
    required this.children,
    this.spacing = 10,
    this.breakpoint = 420,
  });

  final List<Widget> children;
  final double spacing;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                Expanded(child: children[i]),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              children[i],
            ],
          ],
        );
      },
    );
  }
}

/// Header with title and trailing controls; stacks on narrow widths.
class ResponsiveHeaderRow extends StatelessWidget {
  const ResponsiveHeaderRow({
    super.key,
    required this.title,
    this.leading,
    this.trailing = const [],
    this.breakpoint = 560,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> trailing;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trailingWrap = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.end,
          children: trailing,
        );

        if (constraints.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(child: title),
              trailingWrap,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Expanded(child: title),
              ],
            ),
            if (trailing.isNotEmpty) ...[
              const SizedBox(height: 12),
              trailingWrap,
            ],
          ],
        );
      },
    );
  }
}

/// Label + value row for forms and detail panels.
class ResponsiveLabelValueRow extends StatelessWidget {
  const ResponsiveLabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.labelFlex = 2,
    this.valueFlex = 3,
  });

  final String label;
  final String value;
  final IconData? icon;
  final int labelFlex;
  final int valueFlex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
        ],
        Flexible(
          flex: labelFlex,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: valueFlex,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
