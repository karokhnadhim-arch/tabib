import 'package:flutter/foundation.dart';

import '../core/utils/subscription_manager.dart';
import '../models/queue_entry.dart';
import 'backend/clinic_backend.dart';

class QueueService extends ChangeNotifier {
  QueueService({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;
  final SubscriptionManager _subscriptions = SubscriptionManager();
  final Map<String, List<QueueEntry>> _queuesByDoctor = {};
  QueueEntry? _patientQueue;

  List<QueueEntry> queueForDoctor(String doctorId) {
    return List.unmodifiable(_queuesByDoctor[doctorId] ?? []);
  }

  QueueEntry? activeEntryForPatient(String patientId) => _patientQueue;

  void watchDoctorQueue(String doctorId) {
    _subscriptions.replace(
      'doctorQueue:$doctorId',
      _backend.watchQueue(doctorId),
      (entries) {
        _queuesByDoctor[doctorId] = entries;
        notifyListeners();
      },
    );
  }

  void watchPatientQueue(String patientId) {
    _subscriptions.replace(
      'patientQueue:$patientId',
      _backend.watchPatientActiveQueue(patientId),
      (QueueEntry? entry) {
        _patientQueue = entry;
        notifyListeners();
      },
    );
  }

  void stopWatchingDoctorQueue([String? doctorId]) {
    if (doctorId != null) {
      _subscriptions.cancel('doctorQueue:$doctorId');
      _queuesByDoctor.remove(doctorId);
    } else {
      _subscriptions.cancelAll();
      _queuesByDoctor.clear();
    }
    notifyListeners();
  }

  void stopWatchingPatientQueue(String patientId) {
    _subscriptions.cancel('patientQueue:$patientId');
    _patientQueue = null;
    notifyListeners();
  }

  int peopleAhead(QueueEntry entry) {
    if (!entry.isWaitingInLine) return 0;
    final waiting = queueForDoctor(entry.doctorId)
        .where((e) => e.status == QueueStatus.waiting)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final index = waiting.indexWhere((e) => e.id == entry.id);
    if (index <= 0) return 0;
    return index;
  }

  int? currentServingNumber(String doctorId) {
    final active = queueForDoctor(doctorId);
    for (final e in active) {
      if (e.status == QueueStatus.inProgress) return e.position;
    }
    if (active.isEmpty) return 0;
    final waiting = active
        .where((e) => e.status == QueueStatus.waiting)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    if (waiting.isEmpty) return 0;
    return waiting.first.position > 1 ? waiting.first.position - 1 : 0;
  }

  int estimatedWaitMinutes(QueueEntry entry) {
    final ahead = peopleAhead(entry);
    return entry.estimatedWaitMinutes ?? ahead * 15;
  }

  QueueEntry? entryForPatient(String patientId, String doctorId) {
    for (final e in queueForDoctor(doctorId)) {
      if (e.patientId == patientId && e.isActive) return e;
    }
    return _patientQueue?.patientId == patientId ? _patientQueue : null;
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

  Future<void> updateEntryStatus(
    String entryId,
    String doctorId,
    QueueStatus status,
  ) =>
      _backend.updateEntryStatus(entryId, doctorId, status);

  Future<void> enterDoctorRoom(String entryId, String doctorId) =>
      _backend.enterDoctorRoom(entryId, doctorId);

  Future<void> syncPatientQueueStatus({
    required String patientId,
    required String doctorId,
    required QueueStatus status,
  }) async {
    final entry = entryForPatient(patientId, doctorId);
    if (entry == null) return;
    if (status == QueueStatus.inProgress) {
      await enterDoctorRoom(entry.id, doctorId);
      return;
    }
    await updateEntryStatus(entry.id, doctorId, status);
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
  }
}
