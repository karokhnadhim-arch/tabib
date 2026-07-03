import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../models/queue_entry.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../services/smart_notification_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/queue_status_utils.dart';
import '../../providers/app_providers.dart';

class SecretaryQueueManagementTab extends StatelessWidget {
  const SecretaryQueueManagementTab({
    super.key,
    required this.doctorId,
    required this.clinicId,
  });

  final String doctorId;
  final String clinicId;

  Appointment? _appointmentFor(
    List<Appointment> appointments,
    QueueEntry entry,
  ) {
    for (final a in appointments) {
      if (a.patientId == entry.patientId && a.doctorId == doctorId) {
        return a;
      }
    }
    return null;
  }

  Future<void> _syncVisitStatus(
    AppointmentProvider appointments,
    QueueEntry entry,
    Future<void> Function(String id) action,
  ) async {
    final matches = appointments.appointments.where(
      (a) => a.patientId == entry.patientId && a.doctorId == doctorId,
    );
    if (matches.isEmpty) return;
    await action(matches.first.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queueService = context.watch<QueueService>();
    final appointments = context.watch<AppointmentProvider>();
    final clinicData = context.watch<ClinicDataService>();
    final doctor = clinicData.doctorById(doctorId);
    final queue = queueService.secretaryQueueForDoctor(doctorId);

    if (doctor == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text(l10n.errorGeneric)),
      );
    }

    if (queue.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text(l10n.noPatientsInQueue)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DoctorQueueHeader(
          doctorName: doctor.name.localized(context),
          doctorId: doctorId,
          queue: queueService.queueForDoctor(doctorId),
        ),
        for (final entry in queue) ...[
          const SizedBox(height: 12),
          _SecretaryQueueRow(
            entry: entry,
            appointment: _appointmentFor(appointments.appointments, entry),
            clinicId: clinicId,
            doctorId: doctorId,
            doctorName: doctor.name.localized(context),
            onMarkEntered: () async {
              final queue = context.read<QueueService>();
              final provider = context.read<AppointmentProvider>();
              await queue.enterDoctorRoom(entry.id, doctorId);
              if (!context.mounted) return;
              await _syncVisitStatus(
                provider,
                entry,
                provider.markArrived,
              );
            },
            onMarkAbsent: () async {
              final queue = context.read<QueueService>();
              final provider = context.read<AppointmentProvider>();
              final notifications = context.read<SmartNotificationService>();
              await queue.updateEntryStatus(
                entry.id,
                doctorId,
                QueueStatus.absent,
              );
              await notifications.notifyMissedTurn(
                patientUserId: entry.patientId,
                patientName: entry.patientName,
                patientPhone: entry.patientPhone,
                doctorId: doctorId,
                doctorName: doctor.name.localized(context),
                queueEntryId: entry.id,
              );
              if (!context.mounted) return;
              await _syncVisitStatus(
                provider,
                entry,
                provider.markAbsent,
              );
            },
            onRecall: entry.status == QueueStatus.absent
                ? () async {
                    final queue = context.read<QueueService>();
                    final notifications =
                        context.read<SmartNotificationService>();
                    await queue.recallPatient(entry.id, doctorId);
                    notifications.clearDedupeForEntry(entry.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.patientRecalled)),
                    );
                  }
                : null,
            onMoveToEnd: entry.status == QueueStatus.absent
                ? () async {
                    await context
                        .read<QueueService>()
                        .moveToEnd(entry.id, doctorId);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.patientMovedToEnd)),
                    );
                  }
                : null,
            onCancelAppointment: entry.status == QueueStatus.absent
                ? () async {
                    final provider = context.read<AppointmentProvider>();
                    final queue = context.read<QueueService>();
                    await queue.cancelEntry(entry.id, doctorId);
                    final appt =
                        _appointmentFor(appointments.appointments, entry);
                    if (appt != null) {
                      await provider.cancel(appt.id);
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.appointmentCancelled)),
                    );
                  }
                : null,
            onReturnToReview: () => context
                .read<QueueService>()
                .returnToReview(entry.id, doctorId),
            onMoveUp: entry.status == QueueStatus.waiting
                ? () => context.read<QueueService>().moveUp(entry.id, doctorId)
                : null,
            onMoveDown: entry.status == QueueStatus.waiting
                ? () =>
                    context.read<QueueService>().moveDown(entry.id, doctorId)
                : null,
          ),
        ],
      ],
    );
  }
}

class _DoctorQueueHeader extends StatelessWidget {
  const _DoctorQueueHeader({
    required this.doctorName,
    required this.doctorId,
    required this.queue,
  });

  final String doctorName;
  final String doctorId;
  final List<QueueEntry> queue;

  Future<void> _notifyDelay(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final minutesController = TextEditingController(text: '15');
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notifyDoctorDelay),
        content: TextField(
          controller: minutesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.delayMinutes,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(minutesController.text.trim());
              Navigator.pop(context, value ?? 15);
            },
            child: Text(l10n.sendNotification),
          ),
        ],
      ),
    );
    if (minutes == null || !context.mounted) return;

    final waiting = queue
        .where((e) => e.isWaitingInLine)
        .map(
          (e) => (
            patientUserId: e.patientId,
            patientName: e.patientName,
            patientPhone: e.patientPhone,
            queueEntryId: e.id,
          ),
        );
    await context.read<SmartNotificationService>().broadcastDoctorDelay(
          doctorId: doctorId,
          doctorName: doctorName,
          delayMinutes: minutes,
          waitingPatients: waiting,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.delayNotificationSent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.secretaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secretaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services, color: AppTheme.secretaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              doctorName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: () => _notifyDelay(context),
            icon: const Icon(Icons.schedule_send_outlined, size: 18),
            label: Text(l10n.notifyDelayShort),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.medicalGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.medicalGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.live,
                      style: const TextStyle(
                        color: AppTheme.medicalGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecretaryQueueRow extends StatelessWidget {
  const _SecretaryQueueRow({
    required this.entry,
    required this.appointment,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
    required this.onMarkEntered,
    required this.onMarkAbsent,
    required this.onReturnToReview,
    this.onMoveUp,
    this.onMoveDown,
    this.onRecall,
    this.onMoveToEnd,
    this.onCancelAppointment,
  });

  final QueueEntry entry;
  final Appointment? appointment;
  final String clinicId;
  final String doctorId;
  final String doctorName;
  final VoidCallback onMarkEntered;
  final VoidCallback onMarkAbsent;
  final VoidCallback onReturnToReview;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRecall;
  final VoidCallback? onMoveToEnd;
  final VoidCallback? onCancelAppointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = entry.status.color();
    final timeLabel = appointment != null
        ? DateFormat.jm().format(appointment!.dateTime)
        : DateFormat.jm().format(entry.bookedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: statusColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _QueueRowLayout(
          entry: entry,
          statusColor: statusColor,
          timeLabel: timeLabel,
          l10n: l10n,
          onMarkEntered: onMarkEntered,
          onMarkAbsent: onMarkAbsent,
          onReturnToReview: onReturnToReview,
          onMoveUp: onMoveUp,
          onMoveDown: onMoveDown,
          onRecall: onRecall,
          onMoveToEnd: onMoveToEnd,
          onCancelAppointment: onCancelAppointment,
          clinicId: clinicId,
        ),
      ),
    );
  }
}

class _QueueNumberBadge extends StatelessWidget {
  const _QueueNumberBadge({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final showNumber = entry.isActive || entry.status == QueueStatus.review;
    final label = showNumber ? '${entry.position}' : '—';

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secretaryColor,
            AppTheme.secretaryColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secretaryColor.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = entry.status.color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        entry.status.label(l10n),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.entry,
    required this.l10n,
    required this.onMarkEntered,
    required this.onMarkAbsent,
    required this.onReturnToReview,
    this.onMoveUp,
    this.onMoveDown,
    this.onRecall,
    this.onMoveToEnd,
    this.onCancelAppointment,
    required this.clinicId,
  });

  final QueueEntry entry;
  final AppLocalizations l10n;
  final VoidCallback onMarkEntered;
  final VoidCallback onMarkAbsent;
  final VoidCallback onReturnToReview;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRecall;
  final VoidCallback? onMoveToEnd;
  final VoidCallback? onCancelAppointment;
  final String clinicId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (entry.isInExamination)
          MedicalActionChip(
            icon: Icons.replay,
            label: l10n.returnToReview,
            color: Colors.orange.shade700,
            onTap: onReturnToReview,
          ),
        if (entry.status == QueueStatus.waiting ||
            entry.status == QueueStatus.review) ...[
          MedicalActionChip(
            icon: Icons.login,
            label: l10n.markEntered,
            color: AppTheme.medicalBlue,
            onTap: onMarkEntered,
          ),
          MedicalActionChip(
            icon: Icons.person_off_outlined,
            label: l10n.markAbsent,
            color: Colors.red,
            onTap: onMarkAbsent,
          ),
        ],
        if (entry.status == QueueStatus.waiting) ...[
          if (onMoveUp != null)
            MedicalActionChip(
              icon: Icons.arrow_upward,
              label: l10n.moveAppointmentUp,
              color: AppTheme.secretaryColor,
              onTap: onMoveUp!,
            ),
          if (onMoveDown != null)
            MedicalActionChip(
              icon: Icons.arrow_downward,
              label: l10n.moveAppointmentDown,
              color: AppTheme.secretaryColor,
              onTap: onMoveDown!,
            ),
        ],
        if (entry.status == QueueStatus.absent) ...[
          if (onRecall != null)
            MedicalActionChip(
              icon: Icons.notifications_active_outlined,
              label: l10n.recallPatient,
              color: AppTheme.medicalGreen,
              onTap: onRecall!,
            ),
          if (onMoveToEnd != null)
            MedicalActionChip(
              icon: Icons.low_priority,
              label: l10n.moveToEndOfQueue,
              color: AppTheme.secretaryColor,
              onTap: onMoveToEnd!,
            ),
          if (onCancelAppointment != null)
            MedicalActionChip(
              icon: Icons.cancel_outlined,
              label: l10n.cancelAppointment,
              color: Colors.red,
              onTap: onCancelAppointment!,
            ),
        ],
        MedicalActionChip(
          icon: Icons.chat_bubble_outline,
          label: l10n.chatWithPatient,
          color: AppTheme.medicalBlueDark,
          onTap: () {
            context.push(
              '/chat?clinicId=$clinicId&patientId=${entry.patientId}&name=${Uri.encodeComponent(entry.patientName)}',
            );
          },
        ),
      ],
    );
  }
}

class _QueueRowLayout extends StatelessWidget {
  const _QueueRowLayout({
    required this.entry,
    required this.statusColor,
    required this.timeLabel,
    required this.l10n,
    required this.onMarkEntered,
    required this.onMarkAbsent,
    required this.onReturnToReview,
    this.onMoveUp,
    this.onMoveDown,
    this.onRecall,
    this.onMoveToEnd,
    this.onCancelAppointment,
    required this.clinicId,
  });

  final QueueEntry entry;
  final Color statusColor;
  final String timeLabel;
  final AppLocalizations l10n;
  final VoidCallback onMarkEntered;
  final VoidCallback onMarkAbsent;
  final VoidCallback onReturnToReview;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRecall;
  final VoidCallback? onMoveToEnd;
  final VoidCallback? onCancelAppointment;
  final String clinicId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSideBySide = constraints.maxWidth >= 900;

        final patientInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.patientName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.appointmentTime}: $timeLabel',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

        final actions = _RowActions(
          entry: entry,
          l10n: l10n,
          onMarkEntered: onMarkEntered,
          onMarkAbsent: onMarkAbsent,
          onReturnToReview: onReturnToReview,
          onMoveUp: onMoveUp,
          onMoveDown: onMoveDown,
          onRecall: onRecall,
          onMoveToEnd: onMoveToEnd,
          onCancelAppointment: onCancelAppointment,
          clinicId: clinicId,
        );

        if (useSideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QueueNumberBadge(entry: entry),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: patientInfo),
              const SizedBox(width: 12),
              Flexible(child: _StatusBadge(entry: entry)),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: actions),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QueueNumberBadge(entry: entry),
                const SizedBox(width: 14),
                Expanded(child: patientInfo),
                const SizedBox(width: 8),
                Flexible(
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: _StatusBadge(entry: entry),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            actions,
          ],
        );
      },
    );
  }
}
