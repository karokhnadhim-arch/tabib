import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/owner_monitoring_phase4.dart';
import '../../../../services/owner_dashboard_filter_service.dart';
import '../../../../services/system_monitoring_service.dart';

/// Bridges global dashboard filters to monitoring refresh and analytics range.
class OwnerDashboardFilterSync extends StatefulWidget {
  const OwnerDashboardFilterSync({super.key, required this.child});

  final Widget child;

  @override
  State<OwnerDashboardFilterSync> createState() => _OwnerDashboardFilterSyncState();
}

class _OwnerDashboardFilterSyncState extends State<OwnerDashboardFilterSync> {
  OwnerDashboardFilterService? _filters;
  SystemMonitoringService? _monitoring;
  OwnerDashboardFilter? _lastApplied;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filters ??= context.read<OwnerDashboardFilterService>()
      ..addListener(_onFiltersChanged);
    _monitoring ??= context.read<SystemMonitoringService>();
    _onFiltersChanged();
  }

  @override
  void dispose() {
    _filters?.removeListener(_onFiltersChanged);
    super.dispose();
  }

  void _onFiltersChanged() {
    final filter = _filters!.filter;
    if (_filtersEqual(_lastApplied, filter)) return;
    _lastApplied = filter;
    _monitoring?.applyDashboardFilter(filter);
  }

  bool _filtersEqual(OwnerDashboardFilter? a, OwnerDashboardFilter b) {
    if (a == null) return false;
    if (a.city != b.city ||
        a.businessId != b.businessId ||
        a.doctorId != b.doctorId ||
        a.status != b.status) {
      return false;
    }
    final ar = a.dateRange;
    final br = b.dateRange;
    if (ar == null && br == null) return true;
    if (ar == null || br == null) return false;
    return ar.start == br.start && ar.end == br.end;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
