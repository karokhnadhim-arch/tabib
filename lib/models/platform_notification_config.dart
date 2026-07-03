import 'notification_channel.dart';

/// Platform-wide notification settings controlled by the System Owner.
class PlatformNotificationConfig {
  const PlatformNotificationConfig({
    this.pushEnabled = true,
    this.whatsappEnabled = true,
    this.smsEnabled = false,
    this.queueThresholds = const [10, 5, 3, 0],
    this.templates = const {},
  });

  final bool pushEnabled;
  final bool whatsappEnabled;
  final bool smsEnabled;
  final List<int> queueThresholds;
  /// eventType -> localeCode -> template text with {PatientName}, {DoctorName}, etc.
  final Map<String, Map<String, String>> templates;

  factory PlatformNotificationConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return PlatformNotificationConfig.defaults();
    final thresholdsRaw = map['queueThresholds'];
    final thresholds = thresholdsRaw is List
        ? thresholdsRaw.whereType<num>().map((n) => n.toInt()).toList()
        : const [10, 5, 3, 0];
    final templatesRaw = map['templates'];
    final templates = <String, Map<String, String>>{};
    if (templatesRaw is Map) {
      for (final entry in templatesRaw.entries) {
        final localeMap = entry.value;
        if (localeMap is Map) {
          templates[entry.key.toString()] = localeMap.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
        }
      }
    }
    return PlatformNotificationConfig(
      pushEnabled: map['pushEnabled'] as bool? ?? true,
      whatsappEnabled: map['whatsappEnabled'] as bool? ?? true,
      smsEnabled: map['smsEnabled'] as bool? ?? false,
      queueThresholds: thresholds.isEmpty ? const [10, 5, 3, 0] : thresholds,
      templates: templates.isEmpty ? _defaultTemplates() : templates,
    );
  }

  Map<String, dynamic> toMap() => {
        'pushEnabled': pushEnabled,
        'whatsappEnabled': whatsappEnabled,
        'smsEnabled': smsEnabled,
        'queueThresholds': queueThresholds,
        'templates': templates,
      };

  PlatformNotificationConfig copyWith({
    bool? pushEnabled,
    bool? whatsappEnabled,
    bool? smsEnabled,
    List<int>? queueThresholds,
    Map<String, Map<String, String>>? templates,
  }) {
    return PlatformNotificationConfig(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      queueThresholds: queueThresholds ?? this.queueThresholds,
      templates: templates ?? this.templates,
    );
  }

  static PlatformNotificationConfig defaults() => PlatformNotificationConfig(
        templates: _defaultTemplates(),
      );

  static Map<String, Map<String, String>> _defaultTemplates() {
    return {
      NotificationEventType.queueTenRemaining.storageKey: {
        'en':
            'Hello {PatientName},\n\nYour appointment with Dr. {DoctorName} is approaching.\n\nThere are only 10 patients before your turn.\n\nPlease prepare to come.',
        'ar':
            'مرحباً {PatientName}،\n\nموعدك مع د. {DoctorName} يقترب.\n\nيتبقى 10 مرضى قبل دورك.\n\nيرجى الاستعداد للحضور.',
        'ku':
            'سڵاو {PatientName}،\n\nچاوپێکەوتنەکەت لەگەڵ د. {DoctorName} نزیکە.\n\nتەنها 10 نەخۆش ماوە پێش کاتەکەت.\n\nتکایە ئامادەبە بۆ هاتن.',
      },
      NotificationEventType.queueFiveRemaining.storageKey: {
        'en':
            'Hello {PatientName},\n\nOnly 5 patients remain before your turn.\n\nPlease head toward the clinic.',
        'ar':
            'مرحباً {PatientName}،\n\nيتبقى 5 مرضى فقط قبل دورك.\n\nيرجى التوجه إلى العيادة.',
        'ku':
            'سڵاو {PatientName}،\n\nتەنها 5 نەخۆش ماوە پێش کاتەکەت.\n\nتکایە بەرەو نۆرینگە بڕۆ.',
      },
      NotificationEventType.queueThreeRemaining.storageKey: {
        'en':
            'Hello {PatientName},\n\nYour turn is very close.\n\nPlease arrive at the clinic now.',
        'ar':
            'مرحباً {PatientName}،\n\nدورك قريب جداً.\n\nيرجى الوصول إلى العيادة الآن.',
        'ku':
            'سڵاو {PatientName}،\n\nکاتەکەت زۆر نزیکە.\n\nتکایە ئێستا بگەیتە نۆرینگە.',
      },
      NotificationEventType.queueYourTurn.storageKey: {
        'en':
            'Hello {PatientName},\n\nIt is now your turn.\n\nPlease proceed to the doctor\'s room.',
        'ar':
            'مرحباً {PatientName}،\n\nحان دورك الآن.\n\nيرجى التوجه إلى غرفة الطبيب.',
        'ku':
            'سڵاو {PatientName}،\n\nئێستا کاتەکەتە.\n\nتکایە بچۆ ژوورەوەی ژووری پزیشک.',
      },
      NotificationEventType.queueMissedTurn.storageKey: {
        'en':
            'Hello {PatientName},\n\nYou missed your turn with Dr. {DoctorName}.\n\nPlease contact the clinic or wait for staff instructions.',
        'ar':
            'مرحباً {PatientName}،\n\nلقد فاتك دورك مع د. {DoctorName}.\n\nيرجى التواصل مع العيادة أو انتظار تعليمات الموظفين.',
        'ku':
            'سڵاو {PatientName}،\n\nکاتەکەت لەگەڵ د. {DoctorName} لەدەستچوو.\n\nتکایە پەیوەندی بە نۆرینگەوە بکە یان چاوەڕوانی فەرمانەکانی کارمەندان بکە.',
      },
      NotificationEventType.doctorDelay.storageKey: {
        'en':
            'Dr. {DoctorName} is delayed by approximately {DelayMinutes} minutes.\n\nThank you for your patience.',
        'ar':
            'د. {DoctorName} متأخر بحوالي {DelayMinutes} دقيقة.\n\nشكراً على صبركم.',
        'ku':
            'د. {DoctorName} نزیکەی {DelayMinutes} خولەک دواکەوتووە.\n\nسوپاس بۆ ئارامگرتنتان.',
      },
      NotificationEventType.appointmentConfirmed.storageKey: {
        'en':
            'Hello {PatientName},\n\nYour appointment with Dr. {DoctorName} has been confirmed.',
        'ar':
            'مرحباً {PatientName}،\n\nتم تأكيد موعدك مع د. {DoctorName}.',
        'ku':
            'سڵاو {PatientName}،\n\nچاوپێکەوتنەکەت لەگەڵ د. {DoctorName} پشتڕاستکرایەوە.',
      },
      NotificationEventType.appointmentRescheduled.storageKey: {
        'en':
            'Hello {PatientName},\n\nYour appointment with Dr. {DoctorName} has been rescheduled to {AppointmentTime}.',
        'ar':
            'مرحباً {PatientName}،\n\nتم إعادة جدولة موعدك مع د. {DoctorName} إلى {AppointmentTime}.',
        'ku':
            'سڵاو {PatientName}،\n\nچاوپێکەوتنەکەت لەگەڵ د. {DoctorName} گۆڕدرا بۆ {AppointmentTime}.',
      },
      NotificationEventType.appointmentCancelled.storageKey: {
        'en':
            'Hello {PatientName},\n\nYour appointment with Dr. {DoctorName} has been cancelled.',
        'ar':
            'مرحباً {PatientName}،\n\nتم إلغاء موعدك مع د. {DoctorName}.',
        'ku':
            'سڵاو {PatientName}،\n\nچاوپێکەوتنەکەت لەگەڵ د. {DoctorName} هەڵوەشێندرایەوە.',
      },
      NotificationEventType.doctorUnavailable.storageKey: {
        'en':
            'Hello {PatientName},\n\nDr. {DoctorName} is temporarily unavailable. Please contact the clinic for alternatives.',
        'ar':
            'مرحباً {PatientName}،\n\nد. {DoctorName} غير متاح مؤقتاً. يرجى التواصل مع العيادة.',
        'ku':
            'سڵاو {PatientName}،\n\nد. {DoctorName} بۆ ماوەیەکی کورت بەردەست نییە. تکایە پەیوەندی بە نۆرینگەوە بکە.',
      },
      NotificationEventType.clinicClosed.storageKey: {
        'en':
            'Hello {PatientName},\n\nThe clinic is unexpectedly closed. We will contact you with updates.',
        'ar':
            'مرحباً {PatientName}،\n\nالعيادة مغلقة بشكل غير متوقع. سنتواصل معك بالتحديثات.',
        'ku':
            'سڵاو {PatientName}،\n\nنۆرینگە بە شێوەیەکی چاوەڕواننەکراو داخراوە. بە زووترین کات پەیوەندیت پێوە دەکەین.',
      },
    };
  }

  String templateFor(NotificationEventType event, String localeCode) {
    final locales = templates[event.storageKey];
    if (locales == null || locales.isEmpty) {
      return PlatformNotificationConfig.defaults()
          .templateFor(event, localeCode);
    }
    return locales[localeCode] ??
        locales['en'] ??
        locales.values.first;
  }
}
