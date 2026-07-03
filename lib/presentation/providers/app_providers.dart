import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../core/utils/subscription_manager.dart';
import '../../models/chat_message.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/visit_status.dart';
import '../../models/notification.dart';
import '../../models/notification_channel.dart';
import '../../models/appointment.dart';
import '../../services/smart_notification_service.dart';

class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider({
    required AppointmentRepository repository,
    SmartNotificationService? smartNotifications,
  })  : _repository = repository,
        _smartNotifications = smartNotifications;

  final AppointmentRepository _repository;
  SmartNotificationService? _smartNotifications;
  final SubscriptionManager _subscriptions = SubscriptionManager();

  List<Appointment> _appointments = [];
  bool _loading = false;
  String? _error;
  String? _watchKey;

  List<Appointment> get appointments => List.unmodifiable(_appointments);
  bool get isLoading => _loading;
  String? get error => _error;

  void _bind(String key, Stream<List<Appointment>> stream) {
    if (_watchKey == key) return;
    _watchKey = key;
    _loading = true;
    _subscriptions.replace(
      'appointments',
      stream,
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

  void watchPatient(String patientId) =>
      _bind('patient:$patientId', _repository.watchPatientAppointments(patientId));

  void watchDoctor(String doctorId) =>
      _bind('doctor:$doctorId', _repository.watchDoctorAppointments(doctorId));

  void watchClinic(String clinicId) =>
      _bind('clinic:$clinicId', _repository.watchClinicAppointments(clinicId));

  void watchDailySchedule(String clinicId, DateTime date) {
    final dayKey =
        '${clinicId}_${date.year}${date.month}${date.day}';
    _bind('daily:$dayKey', _repository.watchDailySchedule(clinicId, date));
  }

  void stopWatching() {
    _subscriptions.cancel('appointments');
    _watchKey = null;
    _appointments = [];
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
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

  Future<void> accept(String id) async {
    final appt = _appointmentById(id);
    await _repository.updateAppointmentStatus(id, AppointmentStatus.accepted);
    if (appt != null) {
      await _notifyPatient(appt, NotificationEventType.appointmentConfirmed);
    }
  }

  Future<void> reject(String id) async {
    final appt = _appointmentById(id);
    await _repository.updateAppointmentStatus(id, AppointmentStatus.rejected);
    if (appt != null) {
      await _notifyPatient(appt, NotificationEventType.appointmentCancelled);
    }
  }

  Future<void> complete(String id) =>
      _repository.updateAppointmentStatus(id, AppointmentStatus.completed);

  Future<void> cancel(String id) async {
    final appt = _appointmentById(id);
    await _repository.cancelAppointment(id);
    if (appt != null) {
      await _notifyPatient(appt, NotificationEventType.appointmentCancelled);
    }
  }

  Future<void> markArrived(String id) =>
      _repository.updateVisitStatus(id, VisitStatus.arrived);

  Future<void> markAbsent(String id) =>
      _repository.updateVisitStatus(id, VisitStatus.absent);

  Future<void> sendToExamination(String id) =>
      _repository.updateVisitStatus(id, VisitStatus.inExamination);

  Future<void> addFollowUp(String id) =>
      _repository.updateVisitStatus(id, VisitStatus.followUp);

  Future<void> reschedule(String id, DateTime dateTime) async {
    final appt = _appointmentById(id);
    await _repository.rescheduleAppointment(id, dateTime);
    if (appt != null) {
      await _notifyPatient(
        appt,
        NotificationEventType.appointmentRescheduled,
        variables: {
          'AppointmentTime':
              DateFormat.yMMMd().add_jm().format(dateTime),
        },
      );
    }
  }

  Future<void> moveAppointment(String id, int direction) =>
      _repository.moveAppointment(id, direction);

  List<Appointment> pendingForDoctor(String doctorId) =>
      _appointments.where((a) => a.doctorId == doctorId && a.isPending).toList();

  List<Appointment> acceptedForDoctor(String doctorId) =>
      _appointments.where((a) => a.doctorId == doctorId && a.isAccepted).toList();

  void attachSmartNotifications(SmartNotificationService service) {
    _smartNotifications = service;
  }

  Appointment? _appointmentById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _notifyPatient(
    Appointment appointment,
    NotificationEventType event, {
    Map<String, String> variables = const {},
  }) async {
    await _smartNotifications?.notifyAppointmentEvent(
      event: event,
      patientUserId: appointment.patientId ?? '',
      patientName: appointment.patientName ?? '',
      patientPhone: appointment.patientPhone ?? '',
      doctorId: appointment.doctorId ?? '',
      doctorName: appointment.doctorName,
      variables: variables,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required NotificationRepository repository})
      : _repository = repository;

  final NotificationRepository _repository;
  final SubscriptionManager _subscriptions = SubscriptionManager();

  List<AppNotification> _notifications = [];
  bool _loading = false;
  String? _watchUserId;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.read).length;
  bool get isLoading => _loading;

  void watch(String userId) {
    if (_watchUserId == userId) return;
    _watchUserId = userId;
    _loading = true;
    _subscriptions.replace(
      'notifications',
      _repository.watchUserNotifications(userId),
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

  void stopWatching() {
    _subscriptions.cancel('notifications');
    _watchUserId = null;
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
  }

  Future<void> markRead(String id) => _repository.markAsRead(id);

  Future<void> send({
    required String userId,
    required String title,
    required String body,
    String? type,
  }) =>
      _repository.sendNotification(
        userId: userId,
        title: title,
        body: body,
        type: type,
      );
}

class PrescriptionProvider extends ChangeNotifier {
  PrescriptionProvider({required PrescriptionRepository repository})
      : _repository = repository;

  final PrescriptionRepository _repository;
  final SubscriptionManager _subscriptions = SubscriptionManager();

  List<Prescription> _prescriptions = [];
  bool _loading = false;
  String? _watchKey;

  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);
  bool get isLoading => _loading;

  void watchPatient(String patientId) {
    if (_watchKey == 'patient:$patientId') return;
    _watchKey = 'patient:$patientId';
    _loading = true;
    _subscriptions.replace(
      'prescriptions',
      _repository.watchPatientPrescriptions(patientId),
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
    if (_watchKey == 'doctor:$doctorId') return;
    _watchKey = 'doctor:$doctorId';
    _loading = true;
    _subscriptions.replace(
      'prescriptions',
      _repository.watchDoctorPrescriptions(doctorId),
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

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
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
  final SubscriptionManager _subscriptions = SubscriptionManager();

  List<ChatMessage> _messages = [];
  bool _loading = false;
  String? _watchKey;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;

  void watch({required String clinicId, required String patientId}) {
    final key = '$clinicId:$patientId';
    if (_watchKey == key) return;
    _watchKey = key;
    _loading = true;
    _subscriptions.replace(
      'chat',
      _repository.watchConversation(clinicId: clinicId, patientId: patientId),
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

  void stopWatching() {
    _subscriptions.cancel('chat');
    _watchKey = null;
    _messages = [];
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
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
