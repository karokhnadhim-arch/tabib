import 'dart:async';

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
import '../../models/prescription_line_item.dart';
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
    List<PrescriptionLineItem> items = const [],
  }) =>
      _repository.writePrescription(
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        diagnosis: diagnosis,
        medications: medications,
        notes: notes,
        items: items,
      );
}

class ChatProvider extends ChangeNotifier {
  ChatProvider({required ChatRepository repository})
      : _repository = repository;

  final ChatRepository _repository;
  final SubscriptionManager _subscriptions = SubscriptionManager();

  List<ChatMessage> _messages = [];
  bool _loading = false;
  bool _loadingOlder = false;
  bool _hasMore = true;
  String? _watchKey;
  String? _clinicId;
  String? _patientId;
  ChatTypingState? _typing;
  Timer? _typingClearTimer;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;
  bool get isLoadingOlder => _loadingOlder;
  bool get hasMore => _hasMore;
  ChatTypingState? get typing => _typing;

  void watch({required String clinicId, required String patientId}) {
    final key = '$clinicId:$patientId';
    if (_watchKey == key) return;

    stopWatching();
    _watchKey = key;
    _clinicId = clinicId;
    _patientId = patientId;
    _loading = true;
    _hasMore = true;

    _subscriptions.replace(
      'chat',
      _repository.watchConversation(clinicId: clinicId, patientId: patientId),
      (list) {
        _messages = list;
        _loading = false;
        if (list.length < 50) _hasMore = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );

    _subscriptions.replace(
      'chatTyping',
      _repository.watchTyping(clinicId: clinicId, patientId: patientId),
      (state) {
        _typing = state;
        notifyListeners();
      },
    );
  }

  void stopWatching() {
    _typingClearTimer?.cancel();
    _typingClearTimer = null;
    _subscriptions.cancel('chat');
    _subscriptions.cancel('chatTyping');
    _watchKey = null;
    _clinicId = null;
    _patientId = null;
    _messages = [];
    _typing = null;
    _loading = false;
    _loadingOlder = false;
    _hasMore = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _typingClearTimer?.cancel();
    _subscriptions.cancelAll();
    super.dispose();
  }

  Future<void> loadOlderMessages() async {
    if (_loadingOlder || !_hasMore) return;
    final clinicId = _clinicId;
    final patientId = _patientId;
    if (clinicId == null || patientId == null || _messages.isEmpty) return;

    _loadingOlder = true;
    notifyListeners();

    try {
      final older = await _repository.loadOlderMessages(
        clinicId: clinicId,
        patientId: patientId,
        before: _messages.first.createdAt,
      );
      if (older.isEmpty) {
        _hasMore = false;
      } else {
        final existingIds = _messages.map((m) => m.id).toSet();
        final merged = [
          ...older.where((m) => !existingIds.contains(m.id)),
          ..._messages,
        ];
        _messages = merged;
        if (older.length < 30) _hasMore = false;
      }
    } finally {
      _loadingOlder = false;
      notifyListeners();
    }
  }

  Future<void> send({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    await _repository.sendMessage(
      clinicId: clinicId,
      patientId: patientId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
    );
    await setTyping(
      clinicId: clinicId,
      patientId: patientId,
      userId: senderId,
      userName: senderName,
      role: senderRole,
      isTyping: false,
    );
  }

  Future<void> sendImage({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String imageUrl,
    required String imageThumbnailUrl,
    String caption = '',
  }) async {
    await _repository.sendImageMessage(
      clinicId: clinicId,
      patientId: patientId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      imageUrl: imageUrl,
      imageThumbnailUrl: imageThumbnailUrl,
      caption: caption,
    );
  }

  Future<void> setTyping({
    required String clinicId,
    required String patientId,
    required String userId,
    required String userName,
    required String role,
    required bool isTyping,
  }) async {
    _typingClearTimer?.cancel();
    await _repository.setTyping(
      clinicId: clinicId,
      patientId: patientId,
      userId: userId,
      userName: userName,
      role: role,
      isTyping: isTyping,
    );
    if (isTyping) {
      _typingClearTimer = Timer(const Duration(seconds: 4), () {
        _repository.setTyping(
          clinicId: clinicId,
          patientId: patientId,
          userId: userId,
          userName: userName,
          role: role,
          isTyping: false,
        );
      });
    }
  }

  Future<void> acknowledgeIncoming({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) async {
    await _repository.markDelivered(
      clinicId: clinicId,
      patientId: patientId,
      readerRole: readerRole,
    );
    await _repository.markConversationRead(
      clinicId: clinicId,
      patientId: patientId,
      readerRole: readerRole,
    );
  }

  Future<void> markRead({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) =>
      acknowledgeIncoming(
        clinicId: clinicId,
        patientId: patientId,
        readerRole: readerRole,
      );
}
