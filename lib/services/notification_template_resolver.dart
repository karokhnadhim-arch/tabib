import '../models/notification_channel.dart';
import '../models/platform_notification_config.dart';

class NotificationTemplateResolver {
  const NotificationTemplateResolver({required this.config});

  final PlatformNotificationConfig config;

  String resolveBody({
    required NotificationEventType event,
    required String localeCode,
    required Map<String, String> variables,
  }) {
    var text = config.templateFor(event, _normalizeLocale(localeCode));
    for (final entry in variables.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  String titleFor(NotificationEventType event, String localeCode) {
    final code = _normalizeLocale(localeCode);
    return switch (event) {
      NotificationEventType.queueTenRemaining => _t(
            code,
            en: 'Almost your turn',
            ar: 'دورك يقترب',
            ku: 'کاتەکەت نزیکە',
          ),
      NotificationEventType.queueFiveRemaining => _t(
            code,
            en: '5 patients ahead',
            ar: '5 مرضى قبلك',
            ku: '5 نەخۆش پێش تۆ',
          ),
      NotificationEventType.queueThreeRemaining => _t(
            code,
            en: 'Get ready now',
            ar: 'استعد الآن',
            ku: 'ئامادەبە',
          ),
      NotificationEventType.queueYourTurn => _t(
            code,
            en: 'Your turn now',
            ar: 'دورك الآن',
            ku: 'کاتەکەتە',
          ),
      NotificationEventType.queueMissedTurn => _t(
            code,
            en: 'Missed turn',
            ar: 'فاتك الدور',
            ku: 'کات لەدەستچوو',
          ),
      NotificationEventType.doctorDelay => _t(
            code,
            en: 'Doctor delayed',
            ar: 'تأخر الطبيب',
            ku: 'دواکەوتنی پزیشک',
          ),
      NotificationEventType.appointmentConfirmed => _t(
            code,
            en: 'Appointment confirmed',
            ar: 'تم تأكيد الموعد',
            ku: 'چاوپێکەوتن پشتڕاستکرایەوە',
          ),
      NotificationEventType.appointmentRescheduled => _t(
            code,
            en: 'Appointment rescheduled',
            ar: 'تم إعادة جدولة الموعد',
            ku: 'چاوپێکەوتن گۆڕدرا',
          ),
      NotificationEventType.appointmentCancelled => _t(
            code,
            en: 'Appointment cancelled',
            ar: 'تم إلغاء الموعد',
            ku: 'چاوپێکەوتن هەڵوەشێندرایەوە',
          ),
      NotificationEventType.doctorUnavailable => _t(
            code,
            en: 'Doctor unavailable',
            ar: 'الطبيب غير متاح',
            ku: 'پزیشک بەردەست نییە',
          ),
      NotificationEventType.clinicClosed => _t(
            code,
            en: 'Clinic closed',
            ar: 'العيادة مغلقة',
            ku: 'نۆرینگە داخراوە',
          ),
      NotificationEventType.general => _t(
            code,
            en: 'Notification',
            ar: 'إشعار',
            ku: 'ئاگاداری',
          ),
    };
  }

  String _normalizeLocale(String code) {
    if (code.isEmpty) return 'en';
    if (code.startsWith('ar')) return 'ar';
    if (code.startsWith('ku')) return 'ku';
    if (code.startsWith('en')) return 'en';
    return 'en';
  }

  String _t(
    String code, {
    required String en,
    required String ar,
    required String ku,
  }) {
    return switch (code) {
      'ar' => ar,
      'ku' => ku,
      _ => en,
    };
  }
}
