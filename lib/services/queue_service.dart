import 'package:flutter/foundation.dart';

import '../core/utils/subscription_manager.dart';
import '../models/queue_entry.dart';
import 'backend/clinic_backend.dart';
import 'owner_audit_service.dart';
import 'audit_logger.dart';
import '../models/audit_module.dart';
import 'auth_service.dart';

class QueueService extends ChangeNotifier {
  QueueService({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;
  AuditLogger? _audit;
  AuthService? _auth;
  final SubscriptionManager _subscriptions = SubscriptionManager();
  final Map<String, List<QueueEntry>> _queuesByDoctor = {};
  final Map<String, List<QueueEntry>> _secretaryQueuesByDoctor = {};
  final Set<String> _patientAutoDoctorWatches = {};
  List<QueueEntry> _patientQueues = [];
  QueueEntry? _patientQueue;

  void attachAudit({
    required OwnerAuditService audit,
    required AuthService auth,
  }) {
    _audit = AuditLogger(audit);
    _auth = auth;
  }

  void _logQueue(
    AuditActionType type,
    String action, {
    String? description,
    String? clinicId,
  }) {
    _audit?.log(
      actor: _auth?.currentUser,
      module: AuditModule.secretary,
      actionType: type,
      action: action,
      description: description,
      clinicId: clinicId,
    );
  }

  List<QueueEntry> activeQueuesForPatient(String patientId) =>
      List.unmodifiable(_patientQueues);

  List<QueueEntry> queueForDoctor(String doctorId) {
    return List.unmodifiable(_queuesByDoctor[doctorId] ?? []);
  }

  List<QueueEntry> secretaryQueueForDoctor(String doctorId) {
    return List.unmodifiable(_secretaryQueuesByDoctor[doctorId] ?? []);
  }

  /// Doctor queue streams currently subscribed (for notification monitoring).
  Iterable<String> get watchedDoctorIds => _queuesByDoctor.keys;

  QueueEntry? activeEntryForPatient(String patientId) =>
      _patientQueues.isNotEmpty ? _patientQueues.first : null;

  QueueEntry? queueEntryById(String patientId, String entryId) {
    for (final e in _patientQueues) {
      if (e.id == entryId && e.patientId == patientId) return e;
    }
    return null;
  }

  void watchPatientQueue(String patientId) => watchPatientQueues(patientId);

  void watchPatientQueues(String patientId) {
    _subscriptions.replace(
      'patientQueues:$patientId',
      _backend.watchPatientActiveQueues(patientId),
      (List<QueueEntry> entries) {
        _patientQueues = entries;
        _patientQueue = entries.isNotEmpty ? entries.first : null;
        _syncAutoDoctorWatches(entries);
        notifyListeners();
      },
    );
  }

  void _syncAutoDoctorWatches(List<QueueEntry> entries) {
    final needed = entries.map((e) => e.doctorId).toSet();
    for (final doctorId in needed) {
      if (!_patientAutoDoctorWatches.contains(doctorId)) {
        watchDoctorQueue(doctorId);
        _patientAutoDoctorWatches.add(doctorId);
      }
    }
    for (final doctorId in List<String>.from(_patientAutoDoctorWatches)) {
      if (!needed.contains(doctorId)) {
        _patientAutoDoctorWatches.remove(doctorId);
        stopWatchingDoctorQueue(doctorId);
      }
    }
  }

  void refreshPatientQueues(String patientId) => watchPatientQueues(patientId);

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

  void watchSecretaryQueue(String doctorId) {
    _subscriptions.replace(
      'secretaryQueue:$doctorId',
      _backend.watchSecretaryQueue(doctorId),
      (entries) {
        _secretaryQueuesByDoctor[doctorId] = entries;
        _queuesByDoctor[doctorId] = entries
            .where((e) => activeQueueStatuses.contains(e.status))
            .toList();
        notifyListeners();
      },
    );
  }

  void stopWatchingDoctorQueue([String? doctorId]) {
    if (doctorId != null) {
      _subscriptions.cancel('doctorQueue:$doctorId');
      _subscriptions.cancel('secretaryQueue:$doctorId');
      _queuesByDoctor.remove(doctorId);
      _secretaryQueuesByDoctor.remove(doctorId);
    } else {
      _subscriptions.cancelAll();
      _queuesByDoctor.clear();
      _secretaryQueuesByDoctor.clear();
    }
    notifyListeners();
  }

  void stopWatchingPatientQueue(String patientId) {
    _subscriptions.cancel('patientQueues:$patientId');
    for (final doctorId in List<String>.from(_patientAutoDoctorWatches)) {
      _patientAutoDoctorWatches.remove(doctorId);
      stopWatchingDoctorQueue(doctorId);
    }
    _patientQueues = [];
    _patientQueue = null;
    notifyListeners();
  }

  int peopleAhead(QueueEntry entry) {
    if (!entry.isWaitingInLine) return 0;
    final inLine = queueForDoctor(entry.doctorId)
        .where((e) => e.isWaitingInLine && e.isSameSlotAs(entry))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final index = inLine.indexWhere((e) => e.id == entry.id);
    if (index <= 0) return 0;
    return index;
  }

  int? currentServingNumber(QueueEntry entry) {
    final active = queueForDoctor(entry.doctorId)
        .where((e) => e.isSameSlotAs(entry))
        .toList();
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

  int? currentServingNumberForDoctor(String doctorId) {
    final active = queueForDoctor(doctorId);
    if (active.isEmpty) return 0;
    for (final e in active) {
      if (e.status == QueueStatus.inProgress) return e.position;
    }
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
    for (final e in secretaryQueueForDoctor(doctorId)) {
      if (e.patientId == patientId) return e;
    }
    for (final e in queueForDoctor(doctorId)) {
      if (e.patientId == patientId) return e;
    }
    for (final e in _patientQueues) {
      if (e.patientId == patientId && e.doctorId == doctorId) return e;
    }
    return null;
  }

  Future<QueueEntry?> bookQueue({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String queueDate,
    required String slotStart,
    required String slotEnd,
  }) async {
    final entry = await _backend.bookQueue(
      doctorId: doctorId,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      queueDate: queueDate,
      slotStart: slotStart,
      slotEnd: slotEnd,
    );
    if (entry != null) {
      _logQueue(
        AuditActionType.queueCreated,
        'Queue entry created',
        description: '$patientName · #${entry.position}',
      );
    }
    return entry;
  }

  Future<void> cancelEntry(String entryId, String doctorId) async {
    await _backend.cancelEntry(entryId, doctorId);
    _logQueue(
      AuditActionType.patientCancelled,
      'Queue entry cancelled',
      description: entryId,
    );
  }

  Future<void> moveUp(String entryId, String doctorId) async {
    await _backend.moveUp(entryId, doctorId);
    _logQueue(AuditActionType.queueModified, 'Queue position moved up', description: entryId);
  }

  Future<void> moveDown(String entryId, String doctorId) async {
    await _backend.moveDown(entryId, doctorId);
    _logQueue(AuditActionType.queueModified, 'Queue position moved down', description: entryId);
  }

  Future<void> moveToEnd(String entryId, String doctorId) async {
    await _backend.moveToEnd(entryId, doctorId);
    _logQueue(AuditActionType.queueModified, 'Queue entry moved to end', description: entryId);
  }

  Future<void> recallPatient(String entryId, String doctorId) async {
    await _backend.recallPatient(entryId, doctorId);
    _logQueue(AuditActionType.queueModified, 'Patient recalled', description: entryId);
  }

  Future<void> callNext(String doctorId) async {
    await _backend.callNext(doctorId);
    _logQueue(AuditActionType.patientSentToDoctor, 'Next patient called');
  }

  Future<void> completeCurrent(String doctorId) async {
    await _backend.completeCurrent(doctorId);
    _logQueue(AuditActionType.patientCompleted, 'Consultation completed');
  }

  Future<void> updateEntryStatus(
    String entryId,
    String doctorId,
    QueueStatus status,
  ) async {
    await _backend.updateEntryStatus(entryId, doctorId, status);
    _logQueue(
      AuditActionType.queueModified,
      'Queue status updated',
      description: '${status.name} · $entryId',
    );
  }

  Future<void> enterDoctorRoom(String entryId, String doctorId) async {
    await _backend.enterDoctorRoom(entryId, doctorId);
    _logQueue(
      AuditActionType.patientSentToDoctor,
      'Patient sent to doctor',
      description: entryId,
    );
  }

  Future<void> sendToExamination(String entryId, String doctorId) async {
    await _backend.sendToExamination(entryId, doctorId);
    _logQueue(AuditActionType.queueModified, 'Patient sent to examination', description: entryId);
  }

  Future<void> returnToReview(String entryId, String doctorId) async {
    await _backend.returnToReview(entryId, doctorId);
    _logQueue(AuditActionType.queueModified, 'Patient returned for review', description: entryId);
  }

  Future<void> updateQueueEntryContact(
    String entryId,
    String doctorId, {
    required String patientName,
    required String patientPhone,
  }) async {
    await _backend.updateQueueEntryContact(
      entryId,
      doctorId,
      patientName: patientName,
      patientPhone: patientPhone,
    );
    _logQueue(
      AuditActionType.queueModified,
      'Queue contact updated',
      description: patientName,
    );
  }

  QueueEntry? _entryInDoctorCaches(String entryId, String doctorId) {
    for (final e in _secretaryQueuesByDoctor[doctorId] ?? const <QueueEntry>[]) {
      if (e.id == entryId) return e;
    }
    for (final e in _queuesByDoctor[doctorId] ?? const <QueueEntry>[]) {
      if (e.id == entryId) return e;
    }
    return null;
  }

  /// Toggles ready flag without changing queue order.
  /// Applies an optimistic local update so the secretary status refreshes
  /// immediately; rolls back if the backend write fails.
  Future<void> togglePatientReady(String entryId, String doctorId) async {
    final local = _entryInDoctorCaches(entryId, doctorId);
    final previous = local?.patientReady;
    final next = previous == null ? null : !previous;

    if (local != null && next != null) {
      local.patientReady = next;
      notifyListeners();
    }

    try {
      await _backend.togglePatientReady(entryId, doctorId);
    } catch (_) {
      if (local != null && previous != null) {
        local.patientReady = previous;
        notifyListeners();
      }
      rethrow;
    }

    // In-memory backends mutate the shared instance again; re-assert intent.
    if (local != null && next != null && local.patientReady != next) {
      local.patientReady = next;
      notifyListeners();
    }

    _logQueue(
      AuditActionType.queueModified,
      'Patient ready toggled',
      description: entryId,
    );
  }

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
    if (status == QueueStatus.examination) {
      await sendToExamination(entry.id, doctorId);
      return;
    }
    if (status == QueueStatus.review) {
      await returnToReview(entry.id, doctorId);
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
