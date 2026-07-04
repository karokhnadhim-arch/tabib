import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/owner_monitoring_phase4.dart';
import '../models/platform_dashboard_summary.dart';
import '../models/system_monitoring.dart';

/// Forecast engine using aggregated metrics — no extra Firestore reads.
class OwnerForecastService extends ChangeNotifier {
  ForecastHorizon _horizon = ForecastHorizon.next7Days;
  ForecastSeries? _series;

  ForecastHorizon get horizon => _horizon;
  ForecastSeries? get series => _series;

  void setHorizon(ForecastHorizon horizon) {
    if (_horizon == horizon) return;
    _horizon = horizon;
    notifyListeners();
    if (_lastSnapshot != null) {
      _rebuild(_lastSnapshot!, _lastCharts);
    }
  }

  SystemMonitoringSnapshot? _lastSnapshot;
  DashboardChartsBundle? _lastCharts;

  void generate({
    required SystemMonitoringSnapshot snapshot,
    DashboardChartsBundle? charts,
  }) {
    _lastSnapshot = snapshot;
    _lastCharts = charts;
    _rebuild(snapshot, charts);
  }

  void _rebuild(SystemMonitoringSnapshot s, DashboardChartsBundle? charts) {
    final points = switch (_horizon) {
      ForecastHorizon.next7Days => 7,
      ForecastHorizon.nextMonth => 30,
      ForecastHorizon.nextYear => 12,
    };

    List<double> project(List<double> base, double seed, {double growth = 1.05}) {
      if (base.isNotEmpty) seed = base.last;
      return List.generate(points, (i) => seed * math.pow(growth, i + 1) * (0.92 + (i % 3) * 0.04));
    }

    final regBase = charts?.registrations ?? s.chartRegistrations;
    final queueBase = charts?.queues ?? s.chartQueues;
    final apptBase = charts?.appointments ?? s.chartAppointments;
    final revBase = charts?.revenue ?? s.chartRevenue;
    final adBase = charts?.adPerformance ?? s.chartAdPerformance;

    _series = ForecastSeries(
      horizon: _horizon,
      registrations: project(regBase, s.newRegistrationsToday.toDouble(), growth: 1.03),
      queueGrowth: project(queueBase, s.waitingPatients.toDouble(), growth: 1.02),
      appointmentGrowth: project(apptBase, s.todaysAppointments.toDouble(), growth: 1.04),
      revenue: project(revBase, _parseRevenue(s.monthlyRevenue), growth: 1.06),
      storageUsage: List.generate(
        points,
        (i) => s.storageUsageMb * (1 + (i + 1) * 0.008),
      ),
      firebaseUsage: List.generate(
        points,
        (i) => (s.firestoreReads + s.firestoreWrites).toDouble() * (1 + i * 0.01),
      ),
      adRevenue: project(adBase, s.adClicks * 2.5, growth: 1.05),
    );
    notifyListeners();
  }

  double _parseRevenue(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return double.tryParse(match?.group(1) ?? '') ?? 100;
  }
}
