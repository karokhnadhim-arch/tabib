import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/owner_dashboard_filter_service.dart';

/// Provides global filter scaling to descendant monitoring widgets.
class MonitoringFilterScope extends InheritedWidget {
  const MonitoringFilterScope({
    super.key,
    required this.scaleFactor,
    required super.child,
  });

  final double scaleFactor;

  static double scaleOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MonitoringFilterScope>();
    return scope?.scaleFactor ?? 1.0;
  }

  static int scaleInt(BuildContext context, int value) =>
      (value * scaleOf(context)).round();

  static String scaleText(BuildContext context, int value) =>
      '${scaleInt(context, value)}';

  static List<double> scaleSeries(BuildContext context, List<double> values) =>
      values.map((v) => v * scaleOf(context)).toList();

  @override
  bool updateShouldNotify(MonitoringFilterScope oldWidget) =>
      oldWidget.scaleFactor != scaleFactor;
}

extension MonitoringFilterContext on BuildContext {
  OwnerDashboardFilterService get dashboardFilters =>
      read<OwnerDashboardFilterService>();
}
