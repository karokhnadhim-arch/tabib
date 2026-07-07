import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../models/investigation_request.dart';
import '../../../models/queue_entry.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/queue_status_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/pending_investigations_panel.dart';
import 'secretary_patient_edit_sheet.dart';
import 'secretary_queue_actions.dart';

/// Material 3 secretary queue workspace — search, one-click actions, live updates.
class SecretaryQueueManagementTab extends StatefulWidget {
  const SecretaryQueueManagementTab({
    super.key,
    required this.doctorId,
    required this.clinicId,
    this.expanded = false,
    this.searchFocusNode,
  });

  final String doctorId;
  final String clinicId;
  final bool expanded;
  final FocusNode? searchFocusNode;

  @override
  State<SecretaryQueueManagementTab> createState() =>
      _SecretaryQueueManagementTabState();
}

class _SecretaryQueueManagementTabState extends State<SecretaryQueueManagementTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueueEntry> _filterQueue(List<QueueEntry> queue, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return queue;
    return queue.where((e) {
      return e.patientName.toLowerCase().contains(q) ||
          e.patientPhone.toLowerCase().contains(q) ||
          '${e.position}'.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final queueService = context.watch<QueueService>();
    final appointments = context.watch<AppointmentProvider>();
    final clinicData = context.watch<ClinicDataService>();
    final investigations = context.watch<InvestigationRequestProvider>();
    final doctor = clinicData.doctorById(widget.doctorId);
    final queue = queueService.secretaryQueueForDoctor(widget.doctorId);
    final filtered = _filterQueue(queue, _searchController.text);
    final doctorName = doctor?.name.localized(context) ?? widget.doctorId;

    if (doctor == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text(l10n.errorGeneric)),
      );
    }

    final inRoom = queue.where((e) => e.status == QueueStatus.inProgress).toList();
    final waitingCount =
        queue.where((e) => e.status == QueueStatus.waiting || e.status == QueueStatus.review).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QueueStatsBar(
          waitingCount: waitingCount,
          inRoomCount: inRoom.length,
          totalCount: queue.length,
          l10n: l10n,
        ),
        const SizedBox(height: 12),
        SearchBar(
          focusNode: widget.searchFocusNode,
          controller: _searchController,
          hintText: l10n.searchPatientsHint,
          leading: const Icon(Icons.search_rounded),
          trailing: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
          ],
          onChanged: (_) => setState(() {}),
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(scheme.surfaceContainerLowest),
          side: WidgetStateProperty.all(
            BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
          ),
        ),
        if (inRoom.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InRoomBanner(
            entry: inRoom.first,
            l10n: l10n,
            onComplete: () => SecretaryQueueActions.completeVisit(
              context,
              entry: inRoom.first,
              doctorId: widget.doctorId,
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (queue.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                l10n.noPatientsInQueue,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          )
        else if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(l10n.noSearchResults)),
          )
        else
          widget.expanded
              ? Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return RepaintBoundary(
                        child: _SecretaryQueueTile(
                          entry: entry,
                          doctorId: widget.doctorId,
                          doctorName: doctorName,
                          clinicId: widget.clinicId,
                          appointment: SecretaryQueueActions.appointmentFor(
                            appointments.appointments,
                            entry,
                            widget.doctorId,
                          ),
                          investigationRequest:
                              investigations.requestForQueueEntry(entry.id),
                          l10n: l10n,
                        ),
                      );
                    },
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    return RepaintBoundary(
                      child: _SecretaryQueueTile(
                        entry: entry,
                        doctorId: widget.doctorId,
                        doctorName: doctorName,
                        clinicId: widget.clinicId,
                        appointment: SecretaryQueueActions.appointmentFor(
                          appointments.appointments,
                          entry,
                          widget.doctorId,
                        ),
                        investigationRequest:
                            investigations.requestForQueueEntry(entry.id),
                        l10n: l10n,
                      ),
                    );
                  },
                ),
      ],
    );
  }
}

class _QueueStatsBar extends StatelessWidget {
  const _QueueStatsBar({
    required this.waitingCount,
    required this.inRoomCount,
    required this.totalCount,
    required this.l10n,
  });

  final int waitingCount;
  final int inRoomCount;
  final int totalCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _StatChip(
          label: l10n.waiting,
          value: '$waitingCount',
          color: scheme.outline,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: l10n.inDoctorRoom,
          value: '$inRoomCount',
          color: AppTheme.medicalGreen,
        ),
        const Spacer(),
        Text(
          l10n.patientsInQueue(totalCount),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.circle, size: 8, color: AppTheme.medicalGreen),
        const SizedBox(width: 4),
        Text(
          l10n.live,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.medicalGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _InRoomBanner extends StatelessWidget {
  const _InRoomBanner({
    required this.entry,
    required this.l10n,
    required this.onComplete,
  });

  final QueueEntry entry;
  final AppLocalizations l10n;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.medicalGreen.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.meeting_room_outlined, color: AppTheme.medicalGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.inDoctorRoom,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.medicalGreen,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    entry.patientName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              child: Text(l10n.completeVisit),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecretaryQueueTile extends StatelessWidget {
  const _SecretaryQueueTile({
    required this.entry,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.appointment,
    required this.investigationRequest,
    required this.l10n,
  });

  final QueueEntry entry;
  final String doctorId;
  final String doctorName;
  final String clinicId;
  final Appointment? appointment;
  final InvestigationRequest? investigationRequest;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final timeLabel = appointment != null
        ? DateFormat.jm().format(appointment!.dateTime)
        : DateFormat.jm().format(entry.bookedAt);
    final isInRoom = entry.status == QueueStatus.inProgress;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isInRoom
              ? AppTheme.medicalGreen.withOpacity(0.45)
              : scheme.outlineVariant.withOpacity(0.45),
          width: isInRoom ? 1.5 : 1,
        ),
      ),
      color: isInRoom ? AppTheme.medicalGreen.withOpacity(0.04) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QueueNumber(position: entry.position, entry: entry),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.patientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.patientPhone,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.appointmentTime}: $timeLabel',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusPill(entry: entry, l10n: l10n),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (entry.status != QueueStatus.completed &&
                            entry.status != QueueStatus.cancelled)
                          _PatientReadyButton(
                            entry: entry,
                            doctorId: doctorId,
                            l10n: l10n,
                          ),
                        IconButton(
                          tooltip: l10n.editPatientInfo,
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => showSecretaryPatientEditSheet(
                            context: context,
                            entry: entry,
                            doctorId: doctorId,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (investigationRequest != null && investigationRequest!.hasPending) ...[
              const SizedBox(height: 8),
              PendingInvestigationsPanel(
                requests: [investigationRequest!],
                compact: true,
              ),
            ],
            const SizedBox(height: 8),
            _QuickActions(
              entry: entry,
              doctorId: doctorId,
              doctorName: doctorName,
              clinicId: clinicId,
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueNumber extends StatelessWidget {
  const _QueueNumber({required this.position, required this.entry});

  final int position;
  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final show = entry.isActive || entry.status == QueueStatus.review;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        show ? '$position' : '—',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.entry, required this.l10n});

  final QueueEntry entry;
  final AppLocalizations l10n;

  String _label() {
    if (entry.arrivalStatus == PatientArrivalStatus.readyForConsultation &&
        (entry.status == QueueStatus.waiting ||
            entry.status == QueueStatus.review)) {
      return l10n.patientReadyForConsultation;
    }
    switch (entry.status) {
      case QueueStatus.inProgress:
        return l10n.inDoctorRoom;
      case QueueStatus.waiting:
      case QueueStatus.review:
        return l10n.waiting;
      case QueueStatus.examination:
      case QueueStatus.sentForTests:
        return l10n.queueStatusExamination;
      case QueueStatus.completed:
        return l10n.completed;
      case QueueStatus.absent:
        return l10n.queueStatusAbsent;
      case QueueStatus.cancelled:
        return l10n.queueStatusCancelled;
      case QueueStatus.followUp:
        return l10n.waiting;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = entry.status.color();
    final ready = entry.patientReady &&
        entry.arrivalStatus == PatientArrivalStatus.readyForConsultation;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (ready ? AppTheme.medicalGreen : color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ready) ...[
            const Icon(Icons.waving_hand_rounded,
                size: 12, color: AppTheme.medicalGreen),
            const SizedBox(width: 4),
          ],
          Text(
            _label(),
            style: TextStyle(
              color: ready ? AppTheme.medicalGreen : color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientReadyButton extends StatelessWidget {
  const _PatientReadyButton({
    required this.entry,
    required this.doctorId,
    required this.l10n,
  });

  final QueueEntry entry;
  final String doctorId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = entry.patientReady;
    return IconButton(
      tooltip: l10n.patientReady,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.waving_hand_rounded,
        size: 22,
        color: active ? AppTheme.medicalGreen : scheme.onSurfaceVariant,
      ),
      style: IconButton.styleFrom(
        backgroundColor: active
            ? AppTheme.medicalGreen.withOpacity(0.12)
            : scheme.surfaceContainerHighest.withOpacity(0.5),
      ),
      onPressed: () =>
          context.read<QueueService>().togglePatientReady(entry.id, doctorId),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.entry,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.l10n,
  });

  final QueueEntry entry;
  final String doctorId;
  final String doctorName;
  final String clinicId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final appointments = context.read<AppointmentProvider>().appointments;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (entry.status != QueueStatus.completed &&
              entry.status != QueueStatus.cancelled)
            _ActionButton(
              icon: Icons.waving_hand_rounded,
              label: l10n.patientReady,
              filled: entry.patientReady,
              onPressed: () => context
                  .read<QueueService>()
                  .togglePatientReady(entry.id, doctorId),
            ),
          if (entry.isInExamination)
            _ActionButton(
              icon: Icons.replay_rounded,
              label: l10n.returnToReview,
              onPressed: () => SecretaryQueueActions.returnToReview(
                context,
                entry: entry,
                doctorId: doctorId,
              ),
            ),
          if (entry.status == QueueStatus.waiting ||
              entry.status == QueueStatus.review) ...[
            _ActionButton(
              icon: Icons.login_rounded,
              label: l10n.callToDoctorRoom,
              filled: true,
              onPressed: () => SecretaryQueueActions.enterRoom(
                context,
                entry: entry,
                doctorId: doctorId,
              ),
            ),
            _ActionButton(
              icon: Icons.person_off_outlined,
              label: l10n.markAbsent,
              onPressed: () => SecretaryQueueActions.markAbsent(
                context,
                entry: entry,
                doctorId: doctorId,
                doctorName: doctorName,
              ),
            ),
          ],
          if (entry.status == QueueStatus.inProgress) ...[
            _ActionButton(
              icon: Icons.check_circle_outline,
              label: l10n.completeVisit,
              filled: true,
              onPressed: () => SecretaryQueueActions.completeVisit(
                context,
                entry: entry,
                doctorId: doctorId,
              ),
            ),
            _ActionButton(
              icon: Icons.hourglass_empty_rounded,
              label: l10n.markAsWaiting,
              onPressed: () => SecretaryQueueActions.markWaiting(
                context,
                entry: entry,
                doctorId: doctorId,
              ),
            ),
            _ActionButton(
              icon: Icons.biotech_outlined,
              label: l10n.sendToExamination,
              onPressed: () => SecretaryQueueActions.sendToExamination(
                context,
                entry: entry,
                doctorId: doctorId,
              ),
            ),
          ],
          if (entry.status == QueueStatus.waiting) ...[
            _ActionButton(
              icon: Icons.arrow_upward_rounded,
              label: l10n.moveAppointmentUp,
              onPressed: () =>
                  context.read<QueueService>().moveUp(entry.id, doctorId),
            ),
            _ActionButton(
              icon: Icons.arrow_downward_rounded,
              label: l10n.moveAppointmentDown,
              onPressed: () =>
                  context.read<QueueService>().moveDown(entry.id, doctorId),
            ),
          ],
          if (entry.status == QueueStatus.absent) ...[
            _ActionButton(
              icon: Icons.notifications_active_outlined,
              label: l10n.recallPatient,
              onPressed: () async {
                await context.read<QueueService>().recallPatient(entry.id, doctorId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.patientRecalled)),
                );
              },
            ),
          ],
          if (entry.status != QueueStatus.cancelled &&
              entry.status != QueueStatus.completed)
            _ActionButton(
              icon: Icons.cancel_outlined,
              label: l10n.cancelAppointment,
              destructive: true,
              onPressed: () async {
                await SecretaryQueueActions.cancelEntry(
                  context,
                  entry: entry,
                  doctorId: doctorId,
                  appointments: appointments,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.appointmentCancelled)),
                );
              },
            ),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: l10n.chatWithPatient,
            onPressed: () => context.push(
              '/chat?clinicId=$clinicId&patientId=${entry.patientId}&name=${Uri.encodeComponent(entry.patientName)}',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.red.shade700 : AppTheme.secretaryColor;
    if (filled) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.secretaryColor.withOpacity(0.12),
            foregroundColor: AppTheme.secretaryColor,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(fontSize: 12, color: color)),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          side: BorderSide(color: color.withOpacity(0.35)),
        ),
      ),
    );
  }
}
