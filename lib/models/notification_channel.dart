enum NotificationChannel {
  push,
  whatsapp,
  sms,
  inApp,
}

enum NotificationDeliveryStatus {
  pending,
  sent,
  delivered,
  failed,
  skipped,
}

enum NotificationEventType {
  queueTenRemaining,
  queueFiveRemaining,
  queueThreeRemaining,
  queueYourTurn,
  queueMissedTurn,
  doctorDelay,
  appointmentConfirmed,
  appointmentRescheduled,
  appointmentCancelled,
  doctorUnavailable,
  clinicClosed,
  general,
}

enum PatientNotificationMethod {
  automatic,
  push,
  whatsapp,
  sms,
  inApp,
}

extension NotificationChannelLabels on NotificationChannel {
  String get storageKey => name;
}

extension NotificationEventTypeLabels on NotificationEventType {
  String get storageKey => name;

  String get dedupePrefix => switch (this) {
        NotificationEventType.queueTenRemaining => 'q10',
        NotificationEventType.queueFiveRemaining => 'q5',
        NotificationEventType.queueThreeRemaining => 'q3',
        NotificationEventType.queueYourTurn => 'turn',
        NotificationEventType.queueMissedTurn => 'missed',
        NotificationEventType.doctorDelay => 'delay',
        NotificationEventType.appointmentConfirmed => 'appt_ok',
        NotificationEventType.appointmentRescheduled => 'appt_resched',
        NotificationEventType.appointmentCancelled => 'appt_cancel',
        NotificationEventType.doctorUnavailable => 'doc_unavail',
        NotificationEventType.clinicClosed => 'clinic_closed',
        NotificationEventType.general => 'general',
      };
}
