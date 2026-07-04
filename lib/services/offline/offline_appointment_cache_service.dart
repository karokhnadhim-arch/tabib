import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/appointment.dart';
import '../../models/visit_status.dart';
import '../../presentation/providers/app_providers.dart';

/// Caches today's appointments per patient for offline viewing.
class OfflineAppointmentCacheService extends ChangeNotifier {
  static const _todayPrefix = 'offline_appts_today_v1_';

  List<Appointment> _todayAppointments = const [];
  String? _patientId;

  List<Appointment> get todayAppointments =>
      List.unmodifiable(_todayAppointments);

  Future<void> bindPatient(String? patientId) async {
    _patientId = patientId;
    if (patientId == null || patientId.isEmpty) {
      _todayAppointments = const [];
      notifyListeners();
      return;
    }
    _todayAppointments = await _loadToday(patientId);
    notifyListeners();
  }

  void attach(AppointmentProvider provider, String patientId) {
    void persist() {
      final today = _filterToday(provider.appointments);
      _saveToday(patientId, today);
    }

    provider.addListener(persist);
    persist();
  }

  List<Appointment> _filterToday(List<Appointment> source) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return source
        .where(
          (a) =>
              !a.dateTime.isBefore(start) && a.dateTime.isBefore(end),
        )
        .toList(growable: false);
  }

  Future<void> _saveToday(String patientId, List<Appointment> list) async {
    _todayAppointments = List.unmodifiable(list);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_todayPrefix$patientId',
      jsonEncode(list.map(_appointmentToMap).toList()),
    );
  }

  Future<List<Appointment>> _loadToday(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_todayPrefix$patientId');
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _appointmentFromMap(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> _appointmentToMap(Appointment a) => {
        'id': a.id,
        'doctorName': a.doctorName,
        'specialty': a.specialty,
        'clinicName': a.clinicName,
        'dateTime': a.dateTime.toUtc().millisecondsSinceEpoch,
        'status': a.status.name,
        'visitStatus': a.visitStatus.name,
        if (a.patientId != null) 'patientId': a.patientId,
        if (a.patientName != null) 'patientName': a.patientName,
        if (a.patientPhone != null) 'patientPhone': a.patientPhone,
        if (a.doctorId != null) 'doctorId': a.doctorId,
        if (a.clinicId != null) 'clinicId': a.clinicId,
        if (a.notes != null) 'notes': a.notes,
      };

  Appointment _appointmentFromMap(Map<String, dynamic> data) {
    return Appointment(
      id: data['id'] as String? ?? '',
      patientId: data['patientId'] as String?,
      patientName: data['patientName'] as String?,
      patientPhone: data['patientPhone'] as String?,
      doctorName: data['doctorName'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      clinicName: data['clinicName'] as String? ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (data['dateTime'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      doctorId: data['doctorId'] as String?,
      clinicId: data['clinicId'] as String?,
      notes: data['notes'] as String?,
      visitStatus: VisitStatus.values.firstWhere(
        (s) => s.name == data['visitStatus'],
        orElse: () => VisitStatus.scheduled,
      ),
    );
  }
}
