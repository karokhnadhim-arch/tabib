import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/queue_entry.dart';
import '../../utils/queue_status_utils.dart';
import '../providers/app_providers.dart';
import '../screens/doctor/doctor_consultation_widgets.dart';
import '../screens/doctor/doctor_visit_notes_store.dart';
import 'staff_patient_contact_bar.dart';

/// Right-side patient summary panel for desktop doctor workspace.
class DoctorPatientSummaryPanel extends StatelessWidget {
  const DoctorPatientSummaryPanel({
    super.key,
    required this.entry,
    required this.doctorId,
    required this.doctorName,
    required this.notesStore,
    required this.storageKey,
  });

  final QueueEntry entry;
  final String doctorId;
  final String doctorName;
  final DoctorVisitNotesStore notesStore;
  final String storageKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final notes = notesStore.notesFor(storageKey);
    final isCompleted = entry.status == QueueStatus.completed;
    final prescriptions = context
        .watch<PrescriptionProvider>()
        .prescriptions
        .where((p) => p.patientId == entry.patientId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final appointments = context
        .watch<AppointmentProvider>()
        .appointments
        .where((a) =>
            a.patientId == entry.patientId && a.doctorId == doctorId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final dateFmt = DateFormat.yMMMd();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.patientSummary,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            DoctorPatientSummaryCard(
              patientName: entry.patientName,
              position: entry.position,
              statusLabel: entry.status.label(l10n),
              statusColor: entry.status.color(),
              autoSaved: notes.updatedAt != null,
              autoSavedLabel: l10n.notesAutoSaved,
              contactBar: StaffPatientContactBar(
                phone: entry.patientPhone,
                patientName: entry.patientName,
                doctorId: doctorId,
                doctorName: doctorName,
                patientId: entry.patientId,
                compact: true,
              ),
              completedBanner: isCompleted
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.medicalGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l10n.visitCompletedReadOnly,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : null,
            ),
            if (prescriptions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.medicalHistory,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              for (final rx in prescriptions.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFmt.format(rx.createdAt.toLocal()),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        if (rx.diagnosis.isNotEmpty)
                          Text(
                            rx.diagnosis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
            if (appointments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.myAppointments,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              for (final appt in appointments.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${dateFmt.format(appt.dateTime.toLocal())} · ${appt.status.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
