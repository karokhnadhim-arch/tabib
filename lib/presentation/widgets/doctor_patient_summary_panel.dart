import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/queue_entry.dart';
import '../../utils/queue_status_utils.dart';
import '../providers/app_providers.dart';
import '../screens/doctor/doctor_visit_notes_store.dart';
import 'staff_patient_contact_bar.dart';

/// Left-side patient summary — one flat card, no nested sections.
class DoctorPatientSummaryPanel extends StatelessWidget {
  const DoctorPatientSummaryPanel({
    super.key,
    required this.entry,
    required this.doctorId,
    required this.doctorName,
    required this.notesStore,
    required this.storageKey,
    this.embedded = false,
  });

  final QueueEntry entry;
  final String doctorId;
  final String doctorName;
  final DoctorVisitNotesStore notesStore;
  final String storageKey;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final notes = notesStore.notesFor(storageKey);
    final isCompleted = entry.status == QueueStatus.completed;
    final statusColor = entry.status.color();
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
    final latestRx = prescriptions.isNotEmpty ? prescriptions.first : null;
    final latestAppt = appointments.isNotEmpty ? appointments.first : null;

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.position}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.patientName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              entry.status.label(l10n),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (notes.updatedAt != null)
                  Icon(
                    Icons.cloud_done_outlined,
                    size: 18,
                    color: scheme.primary,
                    semanticLabel: l10n.notesAutoSaved,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            StaffPatientContactBar(
              phone: entry.patientPhone,
              patientName: entry.patientName,
              doctorId: doctorId,
              doctorName: doctorName,
              patientId: entry.patientId,
              compact: true,
            ),
            if (latestAppt != null) ...[
              const SizedBox(height: 12),
              _InlineFact(
                icon: Icons.event_available_outlined,
                text:
                    '${dateFmt.format(latestAppt.dateTime.toLocal())} · ${latestAppt.status.name}',
                scheme: scheme,
              ),
            ],
            if (latestRx != null) ...[
              const SizedBox(height: 8),
              _InlineFact(
                icon: Icons.history_rounded,
                text: latestRx.diagnosis.isNotEmpty
                    ? latestRx.diagnosis
                    : dateFmt.format(latestRx.createdAt.toLocal()),
                scheme: scheme,
              ),
            ],
            if (isCompleted) ...[
              const SizedBox(height: 12),
              Text(
                l10n.visitCompletedReadOnly,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.medicalGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
    );

    if (embedded) return body;

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: body,
    );
  }
}

class _InlineFact extends StatelessWidget {
  const _InlineFact({
    required this.icon,
    required this.text,
    required this.scheme,
  });

  final IconData icon;
  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}
