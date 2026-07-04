import 'package:flutter/material.dart';

import '../models/owner_monitoring_phase4.dart';
import '../models/system_monitoring.dart';
import 'clinic_data_service.dart';
import 'dashboard_date_presets.dart';

/// Global dashboard filters — client-side scaling from loaded catalog data.
class OwnerDashboardFilterService extends ChangeNotifier {
  OwnerDashboardFilterService({required ClinicDataService clinicData})
      : _clinicData = clinicData;

  final ClinicDataService _clinicData;

  OwnerDashboardFilter _filter = const OwnerDashboardFilter();
  double _scaleFactor = 1.0;

  OwnerDashboardFilter get filter => _filter;
  double get scaleFactor => _scaleFactor;

  List<String> get availableCities {
    final cities = _clinicData.clinics
        .map((c) => c.address.en.isNotEmpty ? c.address.en : c.address.ar)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return cities;
  }

  List<({String id, String label})> get availableBusinesses =>
      _clinicData.clinics
          .map((c) => (id: c.id, label: c.name.en.isNotEmpty ? c.name.en : c.name.ar))
          .toList();

  List<({String id, String label})> get availableDoctors =>
      _clinicData.doctors
          .map((d) => (id: d.id, label: d.name.en.isNotEmpty ? d.name.en : d.name.ar))
          .toList();

  void setFilter(OwnerDashboardFilter filter) {
    _filter = filter;
    _scaleFactor = _computeScale(filter);
    notifyListeners();
  }

  void clearFilters() => setFilter(const OwnerDashboardFilter());

  void applyDatePreset(AnalyticsRange range) {
    final dateRange = DashboardDatePresets.forAnalyticsRange(range);
    setFilter(
      _filter.copyWith(
        dateRange: dateRange,
        clearDateRange: dateRange == null,
      ),
    );
  }

  void applyCustomDateRange(DateTimeRange range) {
    setFilter(_filter.copyWith(dateRange: range));
  }

  int scaled(int value) => (value * _scaleFactor).round();

  double scaledDouble(double value) => value * _scaleFactor;

  List<double> scaledSeries(List<double> values) =>
      values.map((v) => v * _scaleFactor).toList();

  double _computeScale(OwnerDashboardFilter f) {
    if (!f.isActive) return 1.0;

    var factor = 1.0;
    final clinicCount = _clinicData.clinics.length.clamp(1, 999);
    final doctorCount = _clinicData.doctors.length.clamp(1, 999);

    if (f.city != null) {
      final inCity = _clinicData.clinics
          .where((c) =>
              c.address.en == f.city ||
              c.address.ar == f.city ||
              c.address.ku == f.city)
          .length;
      factor *= inCity / clinicCount;
    }
    if (f.businessId != null) factor *= 1 / clinicCount;
    if (f.doctorId != null) factor *= 1 / doctorCount;
    if (f.status == DashboardStatusFilter.active) factor *= 0.85;
    if (f.status == DashboardStatusFilter.suspended) factor *= 0.15;
    if (f.dateRange != null) {
      final days = f.dateRange!.duration.inDays.clamp(1, 365);
      factor *= (days / 30).clamp(0.1, 1.0);
    }

    return factor.clamp(0.02, 1.0);
  }
}
