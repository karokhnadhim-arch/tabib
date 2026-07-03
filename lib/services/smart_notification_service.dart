import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/repositories/repositories.dart';
import '../models/doctor.dart';
import '../models/notification.dart';
import '../models/notification_channel.dart';
import '../models/platform_notification_config.dart';
import '../models/user_app_preferences.dart';
import '../models/user_account.dart';
import 'auth_service.dart';
import 'notification_template_resolver.dart';
import 'patient_communication_policy.dart';
import 'platform_notification_config_service.dart';
import 'user_preferences_service.dart';

class SmartNotificationRequest {
  const SmartNotificationRequest({
    required this.patientUserId,
    required this.patientName,
    required this.eventType,
    this.patientPhone,
    this.doctorId,
    this.doctorName,
    this.queueEntryId,
    this.localeCode,
    this.variables = const {},
    this.sentByUserId,
    this.sentByName,
    this.forceInAppOnly = false,
    this.dedupeKey,
  });

  final String patientUserId;
  final String patientName;
  final String? patientPhone;
  final String? doctorId;
  final String? doctorName;
  final String? queueEntryId;
  final NotificationEventType eventType;
  final String? localeCode;
  final Map<String, String> variables;
  final String? sentByUserId;
  final String? sentByName;
  final bool forceInAppOnly;
  final String? dedupeKey;
}

/// Dispatches patient notifications with channel priority:
/// push → WhatsApp → SMS → in-app fallback.
class SmartNotificationService extends ChangeNotifier {
  SmartNotificationService({
    required NotificationRepository notifications,
    required PlatformNotificationConfigService configService,
    required UserPreferencesService userPreferences,
    required AuthService authService,
  })  : _notifications = notifications,
        _configService = configService,
        _userPreferences = userPreferences,
        _authService = authService;

  final NotificationRepository _notifications;
  final PlatformNotificationConfigService _configService;
  final UserPreferencesService _userPreferences;
  final AuthService _authService;

  final Set<String> _sentDedupeKeys = {};

  PlatformNotificationConfig get config => _configService.config;

  NotificationTemplateResolver get _templates =>
      NotificationTemplateResolver(config: config);

  Future<NotificationChannel?> notifyPatient(
    SmartNotificationRequest request, {
    bool requireAuthorization = true,
  }) async {
    if (requireAuthorization &&
        !PatientCommunicationPolicy.canSendToPatient(
          _authService,
          doctorId: request.doctorId,
        ) &&
        request.sentByUserId != 'system') {
      return null;
    }

    final dedupe = request.dedupeKey ??
        '${request.patientUserId}_${request.eventType.dedupePrefix}_${request.queueEntryId ?? ''}';
    if (_sentDedupeKeys.contains(dedupe)) return null;
    _sentDedupeKeys.add(dedupe);

    final prefs = _resolvePatientPrefs(request.patientUserId);
    if (!prefs.reminderNotifications && _isReminderEvent(request.eventType)) {
      return null;
    }
    if (!prefs.queueNotifications && _isQueueEvent(request.eventType)) {
      return null;
    }

    final locale = request.localeCode?.isNotEmpty == true
        ? request.localeCode!
        : (prefs.preferredLanguageCode.isNotEmpty
            ? prefs.preferredLanguageCode
            : 'en');

    final vars = {
      'PatientName': request.patientName,
      if (request.doctorName != null) 'DoctorName': request.doctorName!,
      ...request.variables,
    };
    final title = _templates.titleFor(request.eventType, locale);
    final body = _templates.resolveBody(
      event: request.eventType,
      localeCode: locale,
      variables: vars,
    );

    final channel = request.forceInAppOnly
        ? NotificationChannel.inApp
        : _pickChannel(
            prefs: prefs,
            phone: request.patientPhone,
            hasAppInstalled: true,
          );

    final appType = _appTypeForEvent(request.eventType);
    final status = channel == NotificationChannel.inApp
        ? NotificationDeliveryStatus.sent
        : NotificationDeliveryStatus.delivered;

    await _notifications.sendSmartNotification(
      userId: request.patientUserId,
      title: title,
      body: body,
      type: appType.name,
      eventType: request.eventType,
      deliveryChannel: channel,
      deliveryStatus: status,
      sentByUserId: request.sentByUserId ?? _authService.currentUser?.id,
      sentByName: request.sentByName ??
          (_authService.currentUser?.name.en.isNotEmpty == true
              ? _authService.currentUser!.name.en
              : _authService.currentUser?.name.ar),
      localeCode: locale,
      doctorId: request.doctorId,
      queueEntryId: request.queueEntryId,
      metadata: {
        if (request.patientPhone != null) 'phone': request.patientPhone!,
        'simulated': 'true',
      },
    );

    if (channel == NotificationChannel.push && prefs.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
    if (channel == NotificationChannel.push && prefs.vibrationEnabled) {
      await HapticFeedback.mediumImpact();
    }

    notifyListeners();
    return channel;
  }

  Future<void> notifyQueueThreshold({
    required String patientUserId,
    required String patientName,
    required String patientPhone,
    required String doctorId,
    required String doctorName,
    required String queueEntryId,
    required int peopleAhead,
    String? localeCode,
  }) async {
    final event = _eventForThreshold(peopleAhead);
    if (event == null) return;
    if (!config.queueThresholds.contains(peopleAhead)) return;

    await notifyPatient(
      SmartNotificationRequest(
        patientUserId: patientUserId,
        patientName: patientName,
        patientPhone: patientPhone,
        doctorId: doctorId,
        doctorName: doctorName,
        queueEntryId: queueEntryId,
        eventType: event,
        localeCode: localeCode,
        sentByUserId: 'system',
        sentByName: 'System',
        dedupeKey: '${queueEntryId}_${event.dedupePrefix}',
      ),
      requireAuthorization: false,
    );
  }

  Future<void> notifyMissedTurn({
    required String patientUserId,
    required String patientName,
    required String patientPhone,
    required String doctorId,
    required String doctorName,
    required String queueEntryId,
  }) async {
    await notifyPatient(
      SmartNotificationRequest(
        patientUserId: patientUserId,
        patientName: patientName,
        patientPhone: patientPhone,
        doctorId: doctorId,
        doctorName: doctorName,
        queueEntryId: queueEntryId,
        eventType: NotificationEventType.queueMissedTurn,
        dedupeKey: '${queueEntryId}_missed_${DateTime.now().millisecondsSinceEpoch ~/ 60000}',
      ),
    );
  }

  Future<void> broadcastDoctorDelay({
    required String doctorId,
    required String doctorName,
    required int delayMinutes,
    required Iterable<({
      String patientUserId,
      String patientName,
      String patientPhone,
      String queueEntryId,
    })> waitingPatients,
  }) async {
    for (final patient in waitingPatients) {
      await notifyPatient(
        SmartNotificationRequest(
          patientUserId: patient.patientUserId,
          patientName: patient.patientName,
          patientPhone: patient.patientPhone,
          doctorId: doctorId,
          doctorName: doctorName,
          queueEntryId: patient.queueEntryId,
          eventType: NotificationEventType.doctorDelay,
          variables: {'DelayMinutes': '$delayMinutes'},
          dedupeKey:
              '${doctorId}_delay_${delayMinutes}_${DateTime.now().millisecondsSinceEpoch ~/ 300000}',
        ),
      );
    }
  }

  Future<void> notifyAppointmentEvent({
    required NotificationEventType event,
    required String patientUserId,
    required String patientName,
    required String patientPhone,
    required String doctorId,
    required String doctorName,
    Map<String, String> variables = const {},
  }) async {
    await notifyPatient(
      SmartNotificationRequest(
        patientUserId: patientUserId,
        patientName: patientName,
        patientPhone: patientPhone,
        doctorId: doctorId,
        doctorName: doctorName,
        eventType: event,
        variables: variables,
        dedupeKey:
            '${patientUserId}_${event.dedupePrefix}_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  void clearDedupeForEntry(String queueEntryId) {
    _sentDedupeKeys.removeWhere((k) => k.startsWith(queueEntryId));
  }

  NotificationChannel? _pickChannel({
    required UserAppPreferences prefs,
    required String? phone,
    required bool hasAppInstalled,
  }) {
    final cfg = config;
    final hasPhone = phone != null && phone.trim().length >= 8;

    NotificationChannel? tryChannel(NotificationChannel channel) {
      return switch (channel) {
        NotificationChannel.push =>
          cfg.pushEnabled && prefs.pushNotifications && hasAppInstalled
              ? NotificationChannel.push
              : null,
        NotificationChannel.whatsapp =>
          cfg.whatsappEnabled && hasPhone ? NotificationChannel.whatsapp : null,
        NotificationChannel.sms =>
          cfg.smsEnabled && hasPhone ? NotificationChannel.sms : null,
        NotificationChannel.inApp => NotificationChannel.inApp,
      };
    }

    if (prefs.preferredNotificationMethod != PatientNotificationMethod.automatic) {
      final forced = switch (prefs.preferredNotificationMethod) {
        PatientNotificationMethod.push => NotificationChannel.push,
        PatientNotificationMethod.whatsapp => NotificationChannel.whatsapp,
        PatientNotificationMethod.sms => NotificationChannel.sms,
        PatientNotificationMethod.inApp => NotificationChannel.inApp,
        PatientNotificationMethod.automatic => NotificationChannel.inApp,
      };
      return tryChannel(forced) ?? NotificationChannel.inApp;
    }

    for (final channel in [
      NotificationChannel.push,
      NotificationChannel.whatsapp,
      NotificationChannel.sms,
      NotificationChannel.inApp,
    ]) {
      final picked = tryChannel(channel);
      if (picked != null) return picked;
    }
    return NotificationChannel.inApp;
  }

  UserAppPreferences _resolvePatientPrefs(String patientUserId) {
    final current = _authService.currentUser;
    if (current?.id == patientUserId) {
      return _userPreferences.preferences;
    }
    return const UserAppPreferences();
  }

  NotificationEventType? _eventForThreshold(int peopleAhead) {
    return switch (peopleAhead) {
      10 => NotificationEventType.queueTenRemaining,
      5 => NotificationEventType.queueFiveRemaining,
      3 => NotificationEventType.queueThreeRemaining,
      0 => NotificationEventType.queueYourTurn,
      _ => null,
    };
  }

  bool _isQueueEvent(NotificationEventType event) =>
      event == NotificationEventType.queueTenRemaining ||
      event == NotificationEventType.queueFiveRemaining ||
      event == NotificationEventType.queueThreeRemaining ||
      event == NotificationEventType.queueYourTurn ||
      event == NotificationEventType.queueMissedTurn ||
      event == NotificationEventType.doctorDelay;

  bool _isReminderEvent(NotificationEventType event) =>
      _isQueueEvent(event) ||
      event == NotificationEventType.appointmentConfirmed ||
      event == NotificationEventType.appointmentRescheduled;

  AppNotificationType _appTypeForEvent(NotificationEventType event) {
    if (_isQueueEvent(event)) return AppNotificationType.queue;
    if (event == NotificationEventType.appointmentConfirmed ||
        event == NotificationEventType.appointmentRescheduled ||
        event == NotificationEventType.appointmentCancelled ||
        event == NotificationEventType.doctorUnavailable ||
        event == NotificationEventType.clinicClosed) {
      return AppNotificationType.appointment;
    }
    return AppNotificationType.general;
  }
}

extension DoctorNameExt on Doctor {
  String get displayName =>
      name.en.isNotEmpty ? name.en : (name.ar.isNotEmpty ? name.ar : name.ku);
}

extension UserNameExt on UserAccount {
  String get displayName =>
      name.en.isNotEmpty ? name.en : (name.ar.isNotEmpty ? name.ar : name.ku);
}
