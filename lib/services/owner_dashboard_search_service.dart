import 'package:flutter/foundation.dart';

import '../models/localized_text.dart';
import '../models/owner_monitoring_phase4.dart';
import '../models/system_monitoring.dart';
import 'advertisement_service.dart';
import 'clinic_data_service.dart';
import 'owner_audit_service.dart';
import 'staff_data_service.dart';

/// Instant in-memory search across already-loaded catalog data — no Firestore scans.
class OwnerDashboardSearchService extends ChangeNotifier {
  OwnerDashboardSearchService({
    required ClinicDataService clinicData,
    required StaffDataService staffData,
    required OwnerAuditService auditService,
    required AdvertisementService advertisementService,
  })  : _clinicData = clinicData,
        _staffData = staffData,
        _auditService = auditService,
        _advertisementService = advertisementService;

  final ClinicDataService _clinicData;
  final StaffDataService _staffData;
  final OwnerAuditService _auditService;
  final AdvertisementService _advertisementService;

  String _query = '';
  SystemMonitoringSnapshot? _snapshot;

  String get query => _query;

  void setSnapshot(SystemMonitoringSnapshot? snapshot) {
    _snapshot = snapshot;
    if (_query.isNotEmpty) notifyListeners();
  }

  void setQuery(String query) {
    final next = query.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void clear() => setQuery('');

  List<DashboardSearchResult> get results {
    if (_query.length < 2) return const [];
    final q = _query.toLowerCase();
    final out = <DashboardSearchResult>[];

    for (final d in _clinicData.doctors) {
      final name = _label(d.name).toLowerCase();
      if (name.contains(q) || d.id.toLowerCase().contains(q)) {
        out.add(DashboardSearchResult(
          id: d.id,
          category: DashboardSearchCategory.doctor,
          title: _label(d.name),
          subtitle: 'Doctor · ${d.clinicId}',
        ));
      }
    }

    for (final c in _clinicData.clinics) {
      final name = _label(c.name).toLowerCase();
      final location = _label(c.address).toLowerCase();
      if (name.contains(q) || location.contains(q) || c.id.toLowerCase().contains(q)) {
        out.add(DashboardSearchResult(
          id: c.id,
          category: DashboardSearchCategory.business,
          title: _label(c.name),
          subtitle: 'Business · ${_label(c.address)}',
        ));
      }
    }

    for (final a in _staffData.staff) {
      final name = _label(a.name).toLowerCase();
      if (!name.contains(q) && !a.id.toLowerCase().contains(q)) continue;
      final category = switch (a.role.name) {
        'secretary' => DashboardSearchCategory.secretary,
        'patient' => DashboardSearchCategory.patient,
        _ => DashboardSearchCategory.doctor,
      };
      out.add(DashboardSearchResult(
        id: a.id,
        category: category,
        title: _label(a.name),
        subtitle: '${a.role.name} · ${a.id}',
      ));
    }

    for (final ad in _advertisementService.advertisements) {
      if (ad.title.toLowerCase().contains(q) || ad.id.toLowerCase().contains(q)) {
        out.add(DashboardSearchResult(
          id: ad.id,
          category: DashboardSearchCategory.advertisement,
          title: ad.title,
          subtitle: 'Advertisement · ${ad.city}',
        ));
      }
    }

    for (final e in _auditService.entries) {
      if (e.action.toLowerCase().contains(q) ||
          e.userName.toLowerCase().contains(q)) {
        out.add(DashboardSearchResult(
          id: e.id,
          category: DashboardSearchCategory.auditLog,
          title: e.action,
          subtitle: 'Audit · ${e.userName}',
        ));
      }
    }

    final snap = _snapshot;
    if (snap != null) {
      if ('queue'.contains(q) || q.contains('queue')) {
        out.add(DashboardSearchResult(
          id: 'queue_summary',
          category: DashboardSearchCategory.queue,
          title: 'Active queues',
          subtitle: '${snap.activeQueues} active · ${snap.waitingPatients} waiting',
        ));
      }
      if ('appointment'.contains(q) || q.contains('appt') || q.contains('appointment')) {
        out.add(DashboardSearchResult(
          id: 'appt_summary',
          category: DashboardSearchCategory.appointment,
          title: 'Appointments overview',
          subtitle: '${snap.todaysAppointments} today · ${snap.upcomingAppointments} upcoming',
        ));
      }
      if ('package'.contains(q) || q.contains('package') || q.contains('subscription')) {
        out.add(DashboardSearchResult(
          id: 'pkg_summary',
          category: DashboardSearchCategory.package,
          title: 'Active packages',
          subtitle: '${snap.activePackages} active · ${snap.packagesExpiringSoon} expiring',
        ));
      }
    }

    return out.take(30).toList(growable: false);
  }

  String _label(LocalizedText name) =>
      name.en.isNotEmpty ? name.en : (name.ar.isNotEmpty ? name.ar : name.ku);
}
