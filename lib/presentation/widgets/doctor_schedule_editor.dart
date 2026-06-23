import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/doctor_working_schedule.dart';
import '../../utils/schedule_utils.dart';

/// Interactive weekly schedule editor for doctors.
class DoctorScheduleEditor extends StatelessWidget {
  const DoctorScheduleEditor({
    super.key,
    required this.schedule,
    required this.onChanged,
  });

  final DoctorWorkingSchedule schedule;
  final ValueChanged<DoctorWorkingSchedule> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: DoctorWorkingSchedule.weekdays.map((weekday) {
        final day = schedule.daySchedule(weekday) ??
            DoctorDaySchedule(weekday: weekday);
        return _DayScheduleCard(
          key: ValueKey(weekday),
          dayLabel: ScheduleUtils.weekdayLabel(l10n, weekday),
          day: day,
          onChanged: (updated) => _updateDay(updated),
        );
      }).toList(),
    );
  }

  void _updateDay(DoctorDaySchedule updated) {
    final nextDays = DoctorWorkingSchedule.weekdays.map((weekday) {
      if (weekday == updated.weekday) return updated;
      return schedule.daySchedule(weekday) ??
          DoctorDaySchedule(weekday: weekday);
    }).toList();
    onChanged(DoctorWorkingSchedule(days: nextDays));
  }
}

class _DayScheduleCard extends StatelessWidget {
  const _DayScheduleCard({
    super.key,
    required this.dayLabel,
    required this.day,
    required this.onChanged,
  });

  final String dayLabel;
  final DoctorDaySchedule day;
  final ValueChanged<DoctorDaySchedule> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOpen = !day.isClosed;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isOpen
              ? AppTheme.doctorColor.withOpacity(0.25)
              : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dayLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  isOpen ? l10n.markDayOpen : l10n.markDayClosed,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOpen
                        ? AppTheme.medicalGreen
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: isOpen,
                  activeColor: AppTheme.doctorColor,
                  onChanged: (open) {
                    if (open) {
                      onChanged(
                        day.copyWith(
                          isClosed: false,
                          periods: day.periods.isEmpty
                              ? [TimePeriod.defaults()]
                              : day.periods,
                        ),
                      );
                    } else {
                      onChanged(day.copyWith(isClosed: true, periods: []));
                    }
                  },
                ),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: 8),
              ...day.periods.asMap().entries.map((entry) {
                final index = entry.key;
                final period = entry.value;
                return _PeriodEditorRow(
                  period: period,
                  canRemove: day.periods.length > 1,
                  onChanged: (updated) {
                    final next = List<TimePeriod>.from(day.periods);
                    next[index] = updated;
                    onChanged(day.copyWith(periods: next));
                  },
                  onRemove: () {
                    final next = List<TimePeriod>.from(day.periods)
                      ..removeAt(index);
                    onChanged(day.copyWith(periods: next));
                  },
                );
              }),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () {
                    final next = List<TimePeriod>.from(day.periods)
                      ..add(TimePeriod.defaults());
                    onChanged(day.copyWith(periods: next));
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(l10n.addTimePeriod),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodEditorRow extends StatelessWidget {
  const _PeriodEditorRow({
    required this.period,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final TimePeriod period;
  final bool canRemove;
  final ValueChanged<TimePeriod> onChanged;
  final VoidCallback onRemove;

  Future<void> _pickTime(
    BuildContext context, {
    required bool isStart,
  }) async {
    final initial = isStart ? period.startTime : period.endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.doctorColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    final value = TimePeriod.fromTimeOfDay(picked);
    if (isStart) {
      onChanged(period.copyWith(start: value));
    } else {
      onChanged(period.copyWith(end: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final startLabel =
        material.formatTimeOfDay(period.startTime, alwaysUse24HourFormat: true);
    final endLabel =
        material.formatTimeOfDay(period.endTime, alwaysUse24HourFormat: true);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.medicalBlue.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.medicalBlue.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TimeChip(
              label: l10n.openingTime,
              value: startLabel,
              onTap: () => _pickTime(context, isStart: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.arrow_forward, color: Colors.grey.shade500, size: 18),
          ),
          Expanded(
            child: _TimeChip(
              label: l10n.closingTime,
              value: endLabel,
              onTap: () => _pickTime(context, isStart: false),
            ),
          ),
          if (canRemove)
            IconButton(
              tooltip: l10n.removeTimePeriod,
              onPressed: onRemove,
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
