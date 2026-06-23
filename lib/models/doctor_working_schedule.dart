import 'package:flutter/material.dart';

/// A single open interval within a day, stored as 24-hour "HH:mm" strings.
class TimePeriod {
  const TimePeriod({required this.start, required this.end});

  final String start;
  final String end;

  static const defaultStart = '09:00';
  static const defaultEnd = '17:00';

  factory TimePeriod.defaults() =>
      const TimePeriod(start: defaultStart, end: defaultEnd);

  int get startMinutes => _toMinutes(start);
  int get endMinutes => _toMinutes(end);

  bool get isValid => endMinutes > startMinutes;

  bool containsMinutes(int minutes) =>
      minutes >= startMinutes && minutes < endMinutes;

  TimeOfDay get startTime => _toTimeOfDay(start);
  TimeOfDay get endTime => _toTimeOfDay(end);

  String formatRange(BuildContext context) {
    final startLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(startTime, alwaysUse24HourFormat: true);
    final endLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(endTime, alwaysUse24HourFormat: true);
    return '$startLabel – $endLabel';
  }

  Map<String, dynamic> toMap() => {'start': start, 'end': end};

  factory TimePeriod.fromMap(Map<String, dynamic> map) {
    return TimePeriod(
      start: map['start'] as String? ?? defaultStart,
      end: map['end'] as String? ?? defaultEnd,
    );
  }

  TimePeriod copyWith({String? start, String? end}) {
    return TimePeriod(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  static int _toMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return (hour.clamp(0, 23) * 60) + minute.clamp(0, 59);
  }

  static TimeOfDay _toTimeOfDay(String value) {
    final minutes = _toMinutes(value);
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  static String fromTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Working hours for a single weekday (1 = Monday … 7 = Sunday).
class DoctorDaySchedule {
  const DoctorDaySchedule({
    required this.weekday,
    this.isClosed = true,
    this.periods = const [],
  });

  final int weekday;
  final bool isClosed;
  final List<TimePeriod> periods;

  bool get isOpen => !isClosed && periods.isNotEmpty;

  bool containsTime(int hour, int minute) {
    if (!isOpen) return false;
    final minutes = hour * 60 + minute;
    return periods.any((period) => period.containsMinutes(minutes));
  }

  Map<String, dynamic> toMap() => {
        'weekday': weekday,
        'isClosed': isClosed,
        'periods': periods.map((p) => p.toMap()).toList(),
      };

  factory DoctorDaySchedule.fromMap(Map<String, dynamic> map) {
    final rawPeriods = map['periods'] as List<dynamic>? ?? const [];
    return DoctorDaySchedule(
      weekday: (map['weekday'] as num?)?.toInt() ?? DateTime.monday,
      isClosed: map['isClosed'] as bool? ?? true,
      periods: rawPeriods
          .map((p) => TimePeriod.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }

  DoctorDaySchedule copyWith({
    bool? isClosed,
    List<TimePeriod>? periods,
  }) {
    return DoctorDaySchedule(
      weekday: weekday,
      isClosed: isClosed ?? this.isClosed,
      periods: periods ?? this.periods,
    );
  }
}

/// Full weekly working schedule for a doctor.
class DoctorWorkingSchedule {
  const DoctorWorkingSchedule({required this.days});

  static const weekdays = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  final List<DoctorDaySchedule> days;

  factory DoctorWorkingSchedule.empty() {
    return DoctorWorkingSchedule(
      days: weekdays
          .map((weekday) => DoctorDaySchedule(weekday: weekday))
          .toList(),
    );
  }

  factory DoctorWorkingSchedule.fromMapList(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return DoctorWorkingSchedule.empty();

    final byWeekday = <int, DoctorDaySchedule>{};
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        final day = DoctorDaySchedule.fromMap(item);
        byWeekday[day.weekday] = day;
      }
    }

    return DoctorWorkingSchedule(
      days: weekdays
          .map((weekday) => byWeekday[weekday] ?? DoctorDaySchedule(weekday: weekday))
          .toList(),
    );
  }

  factory DoctorWorkingSchedule.fromLegacy({List<int>? workingDays}) {
    final openDays = workingDays ?? const <int>[];
    return DoctorWorkingSchedule(
      days: weekdays.map((weekday) {
        if (!openDays.contains(weekday)) {
          return DoctorDaySchedule(weekday: weekday);
        }
        return DoctorDaySchedule(
          weekday: weekday,
          isClosed: false,
          periods: const [TimePeriod(start: '09:00', end: '17:00')],
        );
      }).toList(),
    );
  }

  List<DoctorDaySchedule> get sortedDays {
    final copy = List<DoctorDaySchedule>.from(days);
    copy.sort((a, b) => a.weekday.compareTo(b.weekday));
    return copy;
  }

  List<int> get openWeekdays =>
      days.where((day) => day.isOpen).map((day) => day.weekday).toList();

  DoctorDaySchedule? daySchedule(int weekday) {
    for (final day in days) {
      if (day.weekday == weekday) return day;
    }
    return null;
  }

  bool isOpenOn(DateTime date) {
    final day = daySchedule(date.weekday);
    return day?.isOpen ?? false;
  }

  bool isDateTimeWithinSchedule(DateTime dateTime) {
    final day = daySchedule(dateTime.weekday);
    if (day == null || !day.isOpen) return false;
    return day.containsTime(dateTime.hour, dateTime.minute);
  }

  TimeOfDay? firstAvailableTimeOn(DateTime date) {
    final day = daySchedule(date.weekday);
    if (day == null || !day.isOpen || day.periods.isEmpty) return null;
    final sorted = List<TimePeriod>.from(day.periods)
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return sorted.first.startTime;
  }

  List<Map<String, dynamic>> toMapList() =>
      sortedDays.map((day) => day.toMap()).toList();

  bool get hasConfiguredSchedule => days.any((day) => day.isOpen);

  /// Validates editor state. Returns a localization key for the error message.
  String? validationErrorKey() {
    for (final day in days) {
      if (day.isClosed) continue;
      if (day.periods.isEmpty) return 'scheduleOpenDayNeedsPeriod';
      for (final period in day.periods) {
        if (!period.isValid) return 'schedulePeriodInvalid';
      }
      final sorted = List<TimePeriod>.from(day.periods)
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
      for (var i = 0; i < sorted.length - 1; i++) {
        if (sorted[i].endMinutes > sorted[i + 1].startMinutes) {
          return 'schedulePeriodOverlap';
        }
      }
    }
    return null;
  }

  DoctorWorkingSchedule copyWithDays(List<DoctorDaySchedule> newDays) {
    return DoctorWorkingSchedule(days: newDays);
  }

  /// Demo schedule illustrating split periods and closed days.
  static List<DoctorDaySchedule> demoSchedule() {
    return [
      const DoctorDaySchedule(
        weekday: DateTime.monday,
        isClosed: true,
      ),
      const DoctorDaySchedule(
        weekday: DateTime.tuesday,
        isClosed: false,
        periods: [TimePeriod(start: '09:00', end: '17:00')],
      ),
      const DoctorDaySchedule(
        weekday: DateTime.wednesday,
        isClosed: false,
        periods: [TimePeriod(start: '09:00', end: '17:00')],
      ),
      const DoctorDaySchedule(
        weekday: DateTime.thursday,
        isClosed: false,
        periods: [TimePeriod(start: '09:00', end: '17:00')],
      ),
      const DoctorDaySchedule(
        weekday: DateTime.friday,
        isClosed: false,
        periods: [TimePeriod(start: '09:00', end: '13:00')],
      ),
      const DoctorDaySchedule(
        weekday: DateTime.saturday,
        isClosed: false,
        periods: [
          TimePeriod(start: '09:00', end: '13:00'),
          TimePeriod(start: '16:00', end: '20:00'),
        ],
      ),
      const DoctorDaySchedule(
        weekday: DateTime.sunday,
        isClosed: false,
        periods: [TimePeriod(start: '09:00', end: '15:00')],
      ),
    ];
  }
}
