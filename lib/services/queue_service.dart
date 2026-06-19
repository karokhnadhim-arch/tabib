import 'package:flutter/foundation.dart';

import '../models/queue_entry.dart';
import 'backend/clinic_backend.dart';

class QueueService extends ChangeNotifier {
  QueueService({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;
  final Map<String, List<QueueEntry>> _queuesByDoctor = {};
  QueueEntry? _patientQueue;
  String? _watchedDoctorId;
  String? _watchedPatientId;

  List<QueueEntry> queueForDoctor(String doctorId) {
    return List.unmodifiable(_queuesByDoctor[doctorId] ?? []);
  }

  QueueEntry? activeEntryForPatient(String patientId) => _patientQueue;

  void watchDoctorQueue(String doctorId) {
    if (_watchedDoctorId == doctorId) return;
    _watchedDoctorId = doctorId;
    _backend.watchQueue(doctorId).listen((entries) {
      _queuesByDoctor[doctorId] = entries;
      notifyListeners();
    });
  }

  void watchPatientQueue(String patientId) {
    if (_watchedPatientId == patientId) return;
    _watchedPatientId = patientId;
    _backend.watchPatientActiveQueue(patientId).listen((QueueEntry? entry) {
      _patientQueue = entry;
      notifyListeners();
    });
  }

  int peopleAhead(QueueEntry entry) {
    final active = queueForDoctor(entry.doctorId);
    final index = active.indexWhere((e) => e.id == entry.id);
    if (index <= 0) return 0;
    return index;
  }

  int? currentServingNumber(String doctorId) {
    final active = queueForDoctor(doctorId);
    QueueEntry? inProgress;
    for (final e in active) {
      if (e.status == QueueStatus.inProgress) {
        inProgress = e;
        break;
      }
    }
    if (inProgress != null) return inProgress.position;
    if (active.isEmpty) return 0;
    return active.first.position > 1 ? active.first.position - 1 : 0;
  }

  int estimatedWaitMinutes(QueueEntry entry) {
    final ahead = peopleAhead(entry);
    return entry.estimatedWaitMinutes ?? ahead * 15;
  }

  Future<QueueEntry?> bookQueue({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
  }) {
    return _backend.bookQueue(
      doctorId: doctorId,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
    );
  }

  Future<void> cancelEntry(String entryId, String doctorId) =>
      _backend.cancelEntry(entryId, doctorId);

  Future<void> moveUp(String entryId, String doctorId) =>
      _backend.moveUp(entryId, doctorId);

  Future<void> moveDown(String entryId, String doctorId) =>
      _backend.moveDown(entryId, doctorId);

  Future<void> callNext(String doctorId) => _backend.callNext(doctorId);

  Future<void> completeCurrent(String doctorId) =>
      _backend.completeCurrent(doctorId);
}
