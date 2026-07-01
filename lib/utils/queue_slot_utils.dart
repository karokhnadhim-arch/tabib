import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../models/doctor_working_schedule.dart';
import '../models/queue_entry.dart';

/// A bookable queue time window on a specific calendar day.
class QueueTimeSlot {
  const QueueTimeSlot({
    required this.date,
    required this.start,
    required this.end,
  });

  final DateTime date;
  final String start;
  final String end;

  String get dateKey => QueueEntry.dateKey(date);

  TimePeriod get period => TimePeriod(start: start, end: end);
}

/// Builds available queue slots from a provider working schedule.
abstract final class QueueSlotUtils {
  static const defaultSlotMinutes = 30;
  static const defaultDaysAhead = 14;

  static List<DateTime> openDates(
    Doctor provider, {
    int daysAhead = defaultDaysAhead,
  }) {
    final today = DateUtils.dateOnly(DateTime.now());
    final schedule = provider.effectiveWorkingSchedule;
    return List.generate(daysAhead, (i) => today.add(Duration(days: i)))
        .where(schedule.isOpenOn)
        .toList();
  }

  static List<QueueTimeSlot> slotsForDate(
    Doctor provider,
    DateTime date, {
    int slotMinutes = defaultSlotMinutes,
  }) {
    final schedule = provider.effectiveWorkingSchedule;
    final day = schedule.daySchedule(date.weekday);
    if (day == null || !day.isOpen) return [];

    final normalized = DateUtils.dateOnly(date);
    final slots = <QueueTimeSlot>[];

    for (final period in day.periods) {
      var cursor = period.startMinutes;
      while (cursor + slotMinutes <= period.endMinutes) {
        slots.add(
          QueueTimeSlot(
            date: normalized,
            start: _minutesToHHmm(cursor),
            end: _minutesToHHmm(cursor + slotMinutes),
          ),
        );
        cursor += slotMinutes;
      }
    }

    return slots;
  }

  static List<QueueTimeSlot> upcomingSlots(
    Doctor provider, {
    int daysAhead = defaultDaysAhead,
    int slotMinutes = defaultSlotMinutes,
  }) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final nowMinutes = now.hour * 60 + now.minute;
    final slots = <QueueTimeSlot>[];

    for (final date in openDates(provider, daysAhead: daysAhead)) {
      for (final slot in slotsForDate(provider, date, slotMinutes: slotMinutes)) {
        if (date == today && slot.period.endMinutes <= nowMinutes) {
          continue;
        }
        slots.add(slot);
      }
    }

    return slots;
  }

  static String formatSlot(BuildContext context, QueueTimeSlot slot) {
    final dateLabel =
        MaterialLocalizations.of(context).formatMediumDate(slot.date);
    return '$dateLabel · ${slot.period.formatRange(context)}';
  }

  static String _minutesToHHmm(int minutes) {
    final hour = (minutes ~/ 60).clamp(0, 23);
    final minute = (minutes % 60).clamp(0, 59);
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
