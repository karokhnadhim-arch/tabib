import '../l10n/app_localizations.dart';

class ScheduleUtils {
  ScheduleUtils._();

  static String weekdayLabel(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.dayMonday;
      case DateTime.tuesday:
        return l10n.dayTuesday;
      case DateTime.wednesday:
        return l10n.dayWednesday;
      case DateTime.thursday:
        return l10n.dayThursday;
      case DateTime.friday:
        return l10n.dayFriday;
      case DateTime.saturday:
        return l10n.daySaturday;
      case DateTime.sunday:
        return l10n.daySunday;
      default:
        return '';
    }
  }
}
