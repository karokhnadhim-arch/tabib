import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../services/auth_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/queue_status_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/staff_patient_contact_bar.dart';
import 'doctor_visit_notes_store.dart';

/// Auto-saving diagnosis, prescription, and clinical notes for the selected patient.
class DoctorQueuePatientPanel extends StatefulWidget {
  const DoctorQueuePatientPanel({
    super.key,
    required this.entry,
    required this.doctorId,
    required this.doctorName,
    required this.notesStore,
  });

  final QueueEntry entry;
  final String doctorId;
  final String doctorName;
  final DoctorVisitNotesStore notesStore;

  @override
  State<DoctorQueuePatientPanel> createState() => _DoctorQueuePatientPanelState();
}

class _DoctorQueuePatientPanelState extends State<DoctorQueuePatientPanel> {
  final _diagnosisController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _clinicalNotesController = TextEditingController();
  Timer? _prescriptionDebounce;
  String? _loadedKey;
  bool _syncingPrescription = false;

  String get _storageKey => DoctorVisitNotesStore.storageKey(
        doctorId: widget.doctorId,
        queueEntryId: widget.entry.id,
      );

  @override
  void initState() {
    super.initState();
    _bootstrapNotes();
    widget.notesStore.addListener(_onNotesChanged);
  }

  @override
  void didUpdateWidget(covariant DoctorQueuePatientPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _bootstrapNotes();
    }
  }

  Future<void> _bootstrapNotes() async {
    final key = _storageKey;
    await widget.notesStore.load(key);
    if (!mounted) return;
    final notes = widget.notesStore.notesFor(key);
    _loadedKey = key;
    _diagnosisController.text = notes.diagnosis;
    _medicationsController.text = notes.medications;
    _clinicalNotesController.text = notes.clinicalNotes;
    setState(() {});
  }

  void _onNotesChanged() {
    if (_loadedKey == _storageKey) setState(() {});
  }

  void _onFieldChanged() {
    widget.notesStore.scheduleSave(
      _storageKey,
      diagnosis: _diagnosisController.text,
      medications: _medicationsController.text,
      clinicalNotes: _clinicalNotesController.text,
    );
    _schedulePrescriptionSync();
  }

  void _schedulePrescriptionSync() {
    _prescriptionDebounce?.cancel();
    _prescriptionDebounce = Timer(const Duration(seconds: 2), _maybeSyncPrescription);
  }

  Future<void> _maybeSyncPrescription() async {
    if (!mounted || _syncingPrescription) return;
    final notes = widget.notesStore.notesFor(_storageKey);
    if (!notes.canSyncPrescription || notes.prescriptionSynced) return;

    _syncingPrescription = true;
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      _syncingPrescription = false;
      return;
    }

    try {
      await context.read<PrescriptionProvider>().write(
            patientId: widget.entry.patientId,
            patientName: widget.entry.patientName,
            doctorId: widget.doctorId,
            doctorName: user.name.localized(context),
            diagnosis: notes.diagnosis.trim(),
            medications: notes.medications.trim(),
            notes: notes.clinicalNotes.trim().isEmpty
                ? null
                : notes.clinicalNotes.trim(),
          );
      await widget.notesStore.markPrescriptionSynced(_storageKey);
    } catch (_) {
      // Local drafts remain; retry on next edit.
    } finally {
      _syncingPrescription = false;
    }
  }

  @override
  void dispose() {
    widget.notesStore.removeListener(_onNotesChanged);
    _prescriptionDebounce?.cancel();
    _diagnosisController.dispose();
    _medicationsController.dispose();
    _clinicalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final notes = widget.notesStore.notesFor(_storageKey);
    final isCompleted = widget.entry.status == QueueStatus.completed;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.doctorColor.withOpacity(0.12),
                  child: Text(
                    '${widget.entry.position}',
                    style: TextStyle(
                      color: AppTheme.doctorColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entry.patientName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.entry.status.label(l10n),
                        style: TextStyle(
                          color: widget.entry.status.color(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (notes.updatedAt != null)
                  Chip(
                    avatar: Icon(
                      Icons.cloud_done_outlined,
                      size: 16,
                      color: scheme.primary,
                    ),
                    label: Text(l10n.notesAutoSaved),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            StaffPatientContactBar(
              phone: widget.entry.patientPhone,
              patientName: widget.entry.patientName,
              doctorId: widget.doctorId,
              doctorName: widget.doctorName,
              patientId: widget.entry.patientId,
              compact: true,
            ),
            if (isCompleted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.medicalGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.medicalGreen),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.visitCompletedReadOnly)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _diagnosisController,
              onChanged: (_) => _onFieldChanged(),
              readOnly: isCompleted,
              decoration: InputDecoration(
                labelText: l10n.diagnosis,
                prefixIcon: const Icon(Icons.medical_information_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _medicationsController,
              onChanged: (_) => _onFieldChanged(),
              readOnly: isCompleted,
              decoration: InputDecoration(
                labelText: l10n.medications,
                prefixIcon: const Icon(Icons.medication_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clinicalNotesController,
              onChanged: (_) => _onFieldChanged(),
              readOnly: isCompleted,
              decoration: InputDecoration(
                labelText: l10n.clinicalNotes,
                prefixIcon: const Icon(Icons.notes_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              minLines: 2,
              maxLines: 6,
            ),
          ],
        ),
      ),
    );
  }
}
