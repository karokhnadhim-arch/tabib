import 'dart:async';

import '../../models/appointment.dart';
import '../../models/chat_message.dart';
import '../../models/notification.dart';
import '../../models/prescription.dart';
import '../../models/visit_status.dart';
import '../../domain/repositories/repositories.dart';

class InMemoryAppointmentRepository implements AppointmentRepository {
  final List<Appointment> _appointments = [];
  final _change = StreamController<void>.broadcast();
  int _idCounter = 0;

  void _notify() => _change.add(null);

  List<Appointment> get appointments => List.unmodifiable(_appointments);

  void seedDemoAppointments() {
    if (_appointments.isNotEmpty) return;
    final now = DateTime.now();
    _appointments.addAll([
      Appointment(
        id: 'demo_appt_seed_1',
        patientId: 'demo_patient_seed',
        patientName: 'نەخۆشی نموونە',
        patientPhone: '07501111111',
        doctorId: 'doc_1',
        doctorName: 'د. ئاراس محەمەد',
        specialty: 'پزیشکی گشتی',
        clinicName: 'نۆرینگەی شەفا',
        clinicId: 'clinic_erbil_1',
        dateTime: now.add(const Duration(hours: 1)),
        status: AppointmentStatus.accepted,
        visitStatus: VisitStatus.scheduled,
      ),
      Appointment(
        id: 'demo_appt_seed_2',
        patientId: 'demo_patient_seed2',
        patientName: 'کاروان ئەحمەد',
        patientPhone: '07502222222',
        doctorId: 'doc_2',
        doctorName: 'د. سارا ئەحمەد',
        specialty: 'ددان',
        clinicName: 'نۆرینگەی شەفا',
        clinicId: 'clinic_erbil_1',
        dateTime: now.add(const Duration(hours: 2)),
        status: AppointmentStatus.accepted,
        visitStatus: VisitStatus.arrived,
      ),
    ]);
    _notify();
  }

  List<Appointment> _filtered(bool Function(Appointment) filter) {
    final list = _appointments.where(filter).toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  Stream<List<Appointment>> _watch(bool Function(Appointment) filter) async* {
    yield _filtered(filter);
    await for (final _ in _change.stream) {
      yield _filtered(filter);
    }
  }

  Appointment? _byId(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<Appointment>> watchPatientAppointments(String patientId) =>
      _watch((a) => a.patientId == patientId);

  @override
  Stream<List<Appointment>> watchDoctorAppointments(String doctorId) =>
      _watch((a) => a.doctorId == doctorId);

  @override
  Stream<List<Appointment>> watchClinicAppointments(String clinicId) =>
      _watch((a) => a.clinicId == clinicId);

  @override
  Stream<List<Appointment>> watchDailySchedule(
    String clinicId,
    DateTime date,
  ) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _watch((a) {
      if (a.clinicId != clinicId) return false;
      return !a.dateTime.isBefore(start) && a.dateTime.isBefore(end);
    });
  }

  @override
  Future<String?> bookAppointment({
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String doctorId,
    required String doctorName,
    required String specialty,
    required String clinicName,
    required String clinicId,
    required DateTime dateTime,
    String? notes,
  }) async {
    final id = 'demo_appt_${_idCounter++}';
    _appointments.add(
      Appointment(
        id: id,
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        doctorId: doctorId,
        doctorName: doctorName,
        specialty: specialty,
        clinicName: clinicName,
        clinicId: clinicId,
        dateTime: dateTime,
        status: AppointmentStatus.pending,
        notes: notes,
      ),
    );
    _notify();
    return null;
  }

  @override
  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;
    _appointments[index] = _appointments[index].copyWith(status: status);
    _notify();
  }

  @override
  Future<void> updateVisitStatus(
    String appointmentId,
    VisitStatus visitStatus,
  ) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;
    _appointments[index] =
        _appointments[index].copyWith(visitStatus: visitStatus);
    _notify();
  }

  @override
  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime dateTime,
  ) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;
    _appointments[index] = _appointments[index].copyWith(dateTime: dateTime);
    _notify();
  }

  @override
  Future<void> moveAppointment(String appointmentId, int direction) async {
    final today = _appointments
        .where((a) => a.clinicId == _byId(appointmentId)?.clinicId)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final index = today.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= today.length) return;
    final a = today[index];
    final b = today[newIndex];
    final aTime = a.dateTime;
    final bTime = b.dateTime;
    final ai = _appointments.indexWhere((x) => x.id == a.id);
    final bi = _appointments.indexWhere((x) => x.id == b.id);
    _appointments[ai] = a.copyWith(dateTime: bTime);
    _appointments[bi] = b.copyWith(dateTime: aTime);
    _notify();
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(
      appointmentId,
      AppointmentStatus.cancelled,
    );
  }
}

class InMemoryNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications = [];
  final _change = StreamController<void>.broadcast();

  void _notify() => _change.add(null);

  @override
  Stream<List<AppNotification>> watchUserNotifications(String userId) async* {
    yield _notifications.where((n) => n.userId == userId).toList();
    await for (final _ in _change.stream) {
      yield _notifications.where((n) => n.userId == userId).toList();
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    final old = _notifications[index];
    _notifications[index] = AppNotification(
      id: old.id,
      userId: old.userId,
      title: old.title,
      body: old.body,
      createdAt: old.createdAt,
      read: true,
      type: old.type,
    );
    _notify();
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
  }) async {
    _notifications.insert(
      0,
      AppNotification(
        id: 'demo_notif_${_notifications.length}',
        userId: userId,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        read: false,
        type: AppNotificationType.values.firstWhere(
          (t) => t.name == type,
          orElse: () => AppNotificationType.general,
        ),
      ),
    );
    _notify();
  }
}

class InMemoryPrescriptionRepository implements PrescriptionRepository {
  final List<Prescription> _prescriptions = [];
  final _change = StreamController<void>.broadcast();
  final InMemoryNotificationRepository? _notifications;

  InMemoryPrescriptionRepository({InMemoryNotificationRepository? notifications})
      : _notifications = notifications;

  void _notify() => _change.add(null);

  @override
  Stream<List<Prescription>> watchPatientPrescriptions(String patientId) async* {
    yield _prescriptions.where((p) => p.patientId == patientId).toList();
    await for (final _ in _change.stream) {
      yield _prescriptions.where((p) => p.patientId == patientId).toList();
    }
  }

  @override
  Stream<List<Prescription>> watchDoctorPrescriptions(String doctorId) async* {
    yield _prescriptions.where((p) => p.doctorId == doctorId).toList();
    await for (final _ in _change.stream) {
      yield _prescriptions.where((p) => p.doctorId == doctorId).toList();
    }
  }

  @override
  Future<void> writePrescription({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String diagnosis,
    required String medications,
    String? notes,
  }) async {
    _prescriptions.insert(
      0,
      Prescription(
        id: 'demo_rx_${_prescriptions.length}',
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        diagnosis: diagnosis,
        medications: medications,
        createdAt: DateTime.now(),
        notes: notes,
      ),
    );
    _notify();
    await _notifications?.sendNotification(
      userId: patientId,
      title: 'New prescription',
      body: 'Dr. $doctorName wrote a prescription for you',
      type: AppNotificationType.prescription.name,
    );
  }
}

class InMemoryChatRepository implements ChatRepository {
  final List<ChatMessage> _messages = [];
  final _change = StreamController<void>.broadcast();
  int _idCounter = 0;

  void _notify() => _change.add(null);

  String _key(String clinicId, String patientId) => '$clinicId::$patientId';

  @override
  Stream<List<ChatMessage>> watchConversation({
    required String clinicId,
    required String patientId,
  }) async* {
    yield _for(clinicId, patientId);
    await for (final _ in _change.stream) {
      yield _for(clinicId, patientId);
    }
  }

  List<ChatMessage> _for(String clinicId, String patientId) {
    return _messages
        .where((m) => m.clinicId == clinicId && m.patientId == patientId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> sendMessage({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    _messages.add(
      ChatMessage(
        id: 'chat_${_idCounter++}',
        clinicId: clinicId,
        patientId: patientId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    _notify();
  }

  @override
  Future<void> markConversationRead({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) async {
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.clinicId != clinicId || m.patientId != patientId) continue;
      if (m.senderRole == readerRole) continue;
      _messages[i] = m.copyWith(read: true);
    }
    _notify();
  }
}
