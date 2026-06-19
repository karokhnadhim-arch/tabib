import 'package:flutter/foundation.dart';

import '../../models/chat_message.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/visit_status.dart';

class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider({required AppointmentRepository repository})
      : _repository = repository;

  final AppointmentRepository _repository;

  List<Appointment> _appointments = [];
  bool _loading = false;
  String? _error;

  List<Appointment> get appointments => List.unmodifiable(_appointments);
  bool get isLoading => _loading;
  String? get error => _error;

  void watchPatient(String patientId) {
    _loading = true;
    _repository.watchPatientAppointments(patientId).listen(
      (list) {
        _appointments = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void watchDoctor(String doctorId) {
    _loading = true;
    _repository.watchDoctorAppointments(doctorId).listen(
      (list) {
        _appointments = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void watchClinic(String clinicId) {
    _loading = true;
    _repository.watchClinicAppointments(clinicId).listen(
      (list) {
        _appointments = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void watchDailySchedule(String clinicId, DateTime date) {
    _loading = true;
    _repository.watchDailySchedule(clinicId, date).listen(
      (list) {
        _appointments = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<String?> book({
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
  }) =>
      _repository.bookAppointment(
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        doctorId: doctorId,
        doctorName: doctorName,
        specialty: specialty,
        clinicName: clinicName,
        clinicId: clinicId,
        dateTime: dateTime,
        notes: notes,
      );

  Future<void> accept(String id) =>
      _repository.updateAppointmentStatus(id, AppointmentStatus.accepted);

  Future<void> reject(String id) =>
      _repository.updateAppointmentStatus(id, AppointmentStatus.rejected);

  Future<void> complete(String id) =>
      _repository.updateAppointmentStatus(id, AppointmentStatus.completed);

  Future<void> cancel(String id) => _repository.cancelAppointment(id);

  Future<void> markArrived(String id) =>
      _repository.updateVisitStatus(id, VisitStatus.arrived);

  Future<void> markAbsent(String id) =>
      _repository.updateVisitStatus(id, VisitStatus.absent);

  Future<void> sendToExamination(String id) =>
      _repository.updateVisitStatus(id, VisitStatus.inExamination);

  Future<void> addFollowUp(String id) =>
      _repository.updateVisitStatus(id, VisitStatus.followUp);

  Future<void> reschedule(String id, DateTime dateTime) =>
      _repository.rescheduleAppointment(id, dateTime);

  Future<void> moveAppointment(String id, int direction) =>
      _repository.moveAppointment(id, direction);

  List<Appointment> pendingForDoctor(String doctorId) =>
      _appointments.where((a) => a.doctorId == doctorId && a.isPending).toList();

  List<Appointment> acceptedForDoctor(String doctorId) =>
      _appointments.where((a) => a.doctorId == doctorId && a.isAccepted).toList();
}

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required NotificationRepository repository})
      : _repository = repository;

  final NotificationRepository _repository;

  List<AppNotification> _notifications = [];
  bool _loading = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.read).length;
  bool get isLoading => _loading;

  void watch(String userId) {
    _loading = true;
    _repository.watchUserNotifications(userId).listen(
      (list) {
        _notifications = list;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markRead(String id) => _repository.markAsRead(id);
}

class PrescriptionProvider extends ChangeNotifier {
  PrescriptionProvider({required PrescriptionRepository repository})
      : _repository = repository;

  final PrescriptionRepository _repository;

  List<Prescription> _prescriptions = [];
  bool _loading = false;

  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);
  bool get isLoading => _loading;

  void watchPatient(String patientId) {
    _loading = true;
    _repository.watchPatientPrescriptions(patientId).listen(
      (list) {
        _prescriptions = list;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );
  }

  void watchDoctor(String doctorId) {
    _loading = true;
    _repository.watchDoctorPrescriptions(doctorId).listen(
      (list) {
        _prescriptions = list;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> write({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String diagnosis,
    required String medications,
    String? notes,
  }) =>
      _repository.writePrescription(
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        diagnosis: diagnosis,
        medications: medications,
        notes: notes,
      );
}

class ChatProvider extends ChangeNotifier {
  ChatProvider({required ChatRepository repository})
      : _repository = repository;

  final ChatRepository _repository;

  List<ChatMessage> _messages = [];
  bool _loading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;

  void watch({required String clinicId, required String patientId}) {
    _loading = true;
    _repository.watchConversation(
      clinicId: clinicId,
      patientId: patientId,
    ).listen(
      (list) {
        _messages = list;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> send({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) =>
      _repository.sendMessage(
        clinicId: clinicId,
        patientId: patientId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        text: text,
      );

  Future<void> markRead({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) =>
      _repository.markConversationRead(
        clinicId: clinicId,
        patientId: patientId,
        readerRole: readerRole,
      );
}
