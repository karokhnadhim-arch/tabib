import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/doctor_working_schedule.dart';
import '../../utils/schedule_utils.dart';

/// Read-only weekly schedule for patients.
class DoctorScheduleView extends StatelessWidget {
  const DoctorScheduleView({
    super.key,
    required this.schedule,
    this.compact = false,
  });

  final DoctorWorkingSchedule schedule;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = schedule.sortedDays.where((day) {
      return day.isOpen || !compact;
    }).toList();

    if (days.isEmpty || !schedule.hasConfiguredSchedule) {
      return Text(
        l10n.noScheduleSet,
        style: TextStyle(color: Colors.grey.shade600),
      );
    }

    return Column(
      children: days.map((day) {
        return _DayScheduleRow(
          dayLabel: ScheduleUtils.weekdayLabel(l10n, day.weekday),
          isClosed: !day.isOpen,
          closedLabel: l10n.dayClosed,
          periods: day.periods,
        );
      }).toList(),
    );
  }
}

class _DayScheduleRow extends StatelessWidget {
  const _DayScheduleRow({
    required this.dayLabel,
    required this.isClosed,
    required this.closedLabel,
    required this.periods,
  });

  final String dayLabel;
  final bool isClosed;
  final String closedLabel;
  final List<TimePeriod> periods;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              dayLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: isClosed
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      closedLabel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: periods
                        .map(
                          (period) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.medicalGreen.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.medicalGreen.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                period.formatRange(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.medicalGreen,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
