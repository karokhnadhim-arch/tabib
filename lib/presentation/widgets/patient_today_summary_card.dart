import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/queue_entry.dart';
import '../../services/queue_service.dart';
import '../../utils/localization_utils.dart';
import 'doctor_avatar.dart';
import 'patient_queue_utils.dart';

/// Hero card: today's appointment + primary active queue with live progress.
class PatientTodaySummaryCard extends StatelessWidget {
  const PatientTodaySummaryCard({
    super.key,
    this.todayAppointment,
    this.primaryQueue,
    this.doctor,
    required this.queueService,
  });

  final Appointment? todayAppointment;
  final QueueEntry? primaryQueue;
  final Doctor? doctor;
  final QueueService queueService;

  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (todayAppointment == null && primaryQueue == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.event_available_outlined,
                  color: scheme.onSurfaceVariant, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.noVisitToday,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            color: AppTheme.patientColor.withOpacity(0.08),
            child: Row(
              children: [
                Icon(Icons.today_outlined, color: AppTheme.patientColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.todayVisit,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.patientColor,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (todayAppointment != null)
                  _AppointmentBlock(appointment: todayAppointment!),
                if (todayAppointment != null && primaryQueue != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: scheme.outlineVariant.withOpacity(0.5)),
                  ),
                if (primaryQueue != null)
                  _QueueBlock(
                    entry: primaryQueue!,
                    doctor: doctor,
                    queueService: queueService,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentBlock extends StatelessWidget {
  const _AppointmentBlock({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timeFmt = DateFormat.jm();
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.event_outlined, color: Colors.orange.shade800, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.todayAppointment,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                appointment.doctorName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (appointment.clinicName.isNotEmpty)
                Text(
                  appointment.clinicName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              const SizedBox(height: 4),
              Text(
                timeFmt.format(appointment.dateTime.toLocal()),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QueueBlock extends StatelessWidget {
  const _QueueBlock({
    required this.entry,
    required this.doctor,
    required this.queueService,
  });

  final QueueEntry entry;
  final Doctor? doctor;
  final QueueService queueService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final currentServing = queueService.currentServingNumber(entry) ?? 0;
    final waitMin = queueService.estimatedWaitMinutes(entry);
    final progress = queueProgressRatio(currentServing, entry.position);
    final clinicName = doctor?.effectiveClinicName.localized(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DoctorAvatar(
              photoUrl: doctor?.photoUrl,
              thumbnailUrl: doctor?.photoThumbnailUrl,
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor?.name.localized(context) ?? entry.patientName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (clinicName != null && clinicName.isNotEmpty)
                    Text(
                      clinicName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: l10n.queueNumber,
                value: '${entry.position}',
                color: AppTheme.medicalBlue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                label: l10n.currentServing,
                value: '$currentServing',
                color: AppTheme.medicalGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                label: l10n.waitTime,
                value: l10n.minutesShort(waitMin),
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.04, 1.0),
            minHeight: 8,
            backgroundColor: scheme.surfaceContainerHighest,
            color: AppTheme.medicalGreen,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => context.push('/queue?entryId=${entry.id}'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.patientColor,
            minimumSize: const Size.fromHeight(44),
          ),
          icon: const Icon(Icons.visibility_outlined, size: 20),
          label: Text(l10n.viewQueueDetails),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.85)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
