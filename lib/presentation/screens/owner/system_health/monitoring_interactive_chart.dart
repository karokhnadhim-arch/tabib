import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Material 3 interactive line/bar chart with hover tooltips and animations.
class MonitoringInteractiveChart extends StatefulWidget {
  const MonitoringInteractiveChart({
    super.key,
    required this.title,
    required this.values,
    required this.color,
    this.height = 200,
    this.barMode = false,
    this.valueSuffix = '',
  });

  final String title;
  final List<double> values;
  final Color color;
  final double height;
  final bool barMode;
  final String valueSuffix;

  @override
  State<MonitoringInteractiveChart> createState() =>
      _MonitoringInteractiveChartState();
}

class _MonitoringInteractiveChartState extends State<MonitoringInteractiveChart>
    with SingleTickerProviderStateMixin {
  int? _hoverIndex;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant MonitoringInteractiveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final values = widget.values;

    if (values.isEmpty) {
      return _ChartShell(
        title: widget.title,
        height: widget.height,
        child: Center(
          child: Text(
            '—',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return _ChartShell(
      title: widget.title,
      height: widget.height,
      tooltip: _hoverIndex != null
          ? '${values[_hoverIndex!].toStringAsFixed(values[_hoverIndex!] % 1 == 0 ? 0 : 1)}${widget.valueSuffix}'
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return MouseRegion(
            onExit: (_) => setState(() => _hoverIndex = null),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => _updateHover(d.localPosition, constraints),
              onTapDown: (d) => _updateHover(d.localPosition, constraints),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, widget.height - 48),
                    painter: _ChartPainter(
                      values: values,
                      color: widget.color,
                      progress: _animation.value,
                      hoverIndex: _hoverIndex,
                      barMode: widget.barMode,
                      gridColor: scheme.outlineVariant.withOpacity(0.35),
                      labelColor: scheme.onSurfaceVariant,
                      isDark: scheme.brightness == Brightness.dark,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateHover(Offset local, BoxConstraints constraints) {
    final values = widget.values;
    if (values.isEmpty) return;
    final width = constraints.maxWidth;
    final index = ((local.dx / width) * values.length)
        .floor()
        .clamp(0, values.length - 1);
    if (_hoverIndex != index) setState(() => _hoverIndex = index);
  }
}

class _ChartShell extends StatelessWidget {
  const _ChartShell({
    required this.title,
    required this.height,
    required this.child,
    this.tooltip,
  });

  final String title;
  final double height;
  final Widget child;
  final String? tooltip;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (tooltip != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tooltip!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(height: height - 48, child: child),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.color,
    required this.progress,
    required this.hoverIndex,
    required this.barMode,
    required this.gridColor,
    required this.labelColor,
    required this.isDark,
  });

  final List<double> values;
  final Color color;
  final double progress;
  final int? hoverIndex;
  final bool barMode;
  final Color gridColor;
  final Color labelColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = values.reduce(math.max);
    final minVal = 0.0;
    final range = (maxVal - minVal).clamp(1, double.infinity);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (barMode) {
      final barWidth = size.width / values.length * 0.65;
      final gap = size.width / values.length;
      for (var i = 0; i < values.length; i++) {
        final v = values[i] * progress;
        final h = (v - minVal) / range * size.height;
        final left = gap * i + (gap - barWidth) / 2;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - h, barWidth, h),
          const Radius.circular(6),
        );
        final paint = Paint()
          ..color = i == hoverIndex
              ? color
              : color.withOpacity(isDark ? 0.75 : 0.85);
        canvas.drawRRect(rect, paint);
      }
    } else {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = size.width * i / (values.length - 1).clamp(1, values.length);
        final v = values[i] * progress;
        final y = size.height - ((v - minVal) / range * size.height);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);

      for (var i = 0; i < values.length; i++) {
        final x = size.width * i / (values.length - 1).clamp(1, values.length);
        final v = values[i] * progress;
        final y = size.height - ((v - minVal) / range * size.height);
        final dotPaint = Paint()
          ..color = i == hoverIndex ? color : color.withOpacity(0.5);
        canvas.drawCircle(Offset(x, y), i == hoverIndex ? 5 : 3, dotPaint);
      }

      if (hoverIndex != null) {
        final x = size.width *
            hoverIndex! /
            (values.length - 1).clamp(1, values.length);
        final dashPaint = Paint()
          ..color = color.withOpacity(0.45)
          ..strokeWidth = 1;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.progress != progress ||
      oldDelegate.hoverIndex != hoverIndex;
}
