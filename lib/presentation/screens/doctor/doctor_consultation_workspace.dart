import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../models/prescription.dart';
import '../../../models/investigation_request_item.dart';
import '../../../models/queue_entry.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/queue_status_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/staff_patient_contact_bar.dart';
import 'doctor_consultation_session.dart';
import 'doctor_consultation_widgets.dart';
import 'doctor_visit_notes_store.dart';
import 'investigation/doctor_investigation_composer.dart';
import 'investigation/investigation_print_sheet.dart';
import 'prescription/doctor_prescription_composer.dart';
import 'prescription/prescription_print_sheet.dart';

/// Material 3 consultation workspace — single-focus sections, auto-save.
class DoctorConsultationWorkspace extends StatefulWidget {
  const DoctorConsultationWorkspace({
    super.key,
    required this.entry,
    required this.doctorId,
    required this.doctorName,
    required this.session,
    this.hidePatientSummary = false,
  });

  final QueueEntry entry;
  final String doctorId;
  final String doctorName;
  final DoctorConsultationSession session;
  final bool hidePatientSummary;

  @override
  State<DoctorConsultationWorkspace> createState() =>
      _DoctorConsultationWorkspaceState();
}

class _DoctorConsultationWorkspaceState extends State<DoctorConsultationWorkspace> {
  ConsultationFocusSection _focused = ConsultationFocusSection.diagnosis;
  Timer? _prescriptionSyncTimer;
  Timer? _investigationSyncTimer;
  bool _syncingPrescription = false;
  bool _syncingInvestigation = false;
  String? _watchedPatientId;

  String get _storageKey => DoctorVisitNotesStore.storageKey(
        doctorId: widget.doctorId,
        queueEntryId: widget.entry.id,
      );

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant DoctorConsultationWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    await widget.session.activate(_storageKey);
    if (!mounted) return;
    _watchPatientHistory(widget.entry.patientId);
    _hydrateInvestigationsFromRemote();
    if (widget.entry.status == QueueStatus.inProgress) {
      setState(() => _focused = ConsultationFocusSection.diagnosis);
    }
  }

  void _hydrateInvestigationsFromRemote() {
    final remote = context
        .read<InvestigationRequestProvider>()
        .requestForQueueEntry(widget.entry.id);
    if (remote == null || remote.items.isEmpty) return;
    final notes = widget.session.notesStore.notesFor(_storageKey);
    if (notes.investigationItems.isNotEmpty) return;
    widget.session.notesStore.scheduleSave(
      _storageKey,
      investigationItems: remote.items,
    );
  }

  void _watchPatientHistory(String patientId) {
    if (_watchedPatientId == patientId) return;
    _watchedPatientId = patientId;
    context.read<PrescriptionProvider>().watchPatient(patientId);
    context.read<InvestigationRequestProvider>().watchDoctor(widget.doctorId);
  }

  void _onFieldChanged() {
    widget.session.onFieldChanged(_storageKey);
    _schedulePrescriptionSync();
    setState(() {});
  }

  void _onInvestigationItemsChanged(List<InvestigationRequestItem> items) {
    widget.session.onInvestigationItemsChanged(_storageKey, items);
    _scheduleInvestigationSync();
    setState(() {});
  }

  void _scheduleInvestigationSync() {
    _investigationSyncTimer?.cancel();
    _investigationSyncTimer =
        Timer(const Duration(milliseconds: 900), _maybeSyncInvestigations);
  }

  Future<void> _maybeSyncInvestigations() async {
    if (!mounted || _syncingInvestigation) return;
    final notes = widget.session.notesStore.notesFor(_storageKey);
    if (notes.investigationSynced) return;

    _syncingInvestigation = true;
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      _syncingInvestigation = false;
      return;
    }

    try {
      await context.read<InvestigationRequestProvider>().upsertVisitRequest(
            queueEntryId: widget.entry.id,
            patientId: widget.entry.patientId,
            patientName: widget.entry.patientName,
            doctorId: widget.doctorId,
            doctorName: user.name.localized(context),
            items: notes.investigationItems,
          );
      await widget.session.notesStore.markInvestigationSynced(_storageKey);
      if (mounted) setState(() {});
    } catch (_) {
      // Retry on next edit.
    } finally {
      _syncingInvestigation = false;
    }
  }

  void _schedulePrescriptionSync() {
    _prescriptionSyncTimer?.cancel();
    _prescriptionSyncTimer = Timer(const Duration(seconds: 2), _maybeSyncPrescription);
  }

  Future<void> _maybeSyncPrescription() async {
    if (!mounted || _syncingPrescription) return;
    final notes = widget.session.notesStore.notesFor(_storageKey);
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
            items: notes.prescriptionItems,
          );
      await widget.session.notesStore.markPrescriptionSynced(_storageKey);
      if (mounted) setState(() {});
    } catch (_) {
      // Retry on next edit.
    } finally {
      _syncingPrescription = false;
    }
  }

  void _focusSection(ConsultationFocusSection section) {
    setState(() => _focused = section);
  }

  String? _prescriptionSubtitle(DoctorVisitNotes notes, AppLocalizations l10n) {
    if (notes.prescriptionItems.isNotEmpty) {
      return l10n.prescriptionMedicineCount(notes.prescriptionItems.length);
    }
    final text = notes.medications.trim();
    return text.isEmpty ? null : text;
  }

  String? _investigationSubtitle(DoctorVisitNotes notes, AppLocalizations l10n) {
    if (notes.investigationItems.isEmpty) return null;
    return l10n.investigationRequestCount(notes.investigationItems.length);
  }

  @override
  void dispose() {
    _prescriptionSyncTimer?.cancel();
    _investigationSyncTimer?.cancel();
    super.dispose();
  }

  InputDecoration _fieldDecoration(BuildContext context, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 22),
      border: OutlineInputBorder(borderRadius: DoctorConsultationTokens.cardRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: DoctorConsultationTokens.cardRadius,
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isCompleted = widget.entry.status == QueueStatus.completed;
    final notes = widget.session.notesStore.notesFor(_storageKey);
    final controllers = widget.session.controllersFor(_storageKey);
    final prescriptions = context
        .watch<PrescriptionProvider>()
        .prescriptions
        .where((p) => p.patientId == widget.entry.patientId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final appointments = context
        .watch<AppointmentProvider>()
        .appointments
        .where((a) =>
            a.patientId == widget.entry.patientId &&
            a.doctorId == widget.doctorId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final clinicData = context.watch<ClinicDataService>();
    final doctor = clinicData.doctorById(widget.doctorId);
    final clinic = doctor != null ? clinicData.clinicById(doctor.clinicId) : null;
    final clinicName = doctor?.effectiveClinicName.localized(context) ??
        clinic?.name.localized(context);
    final clinicAddress = clinic?.address.localized(context);
    final clinicPhone = doctor?.effectiveContactPhone ?? clinic?.phone;
    final doctorSpecialty = doctor?.specialty.name.localized(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.hidePatientSummary) ...[
        Text(
          l10n.patientInformation,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DoctorPatientSummaryCard(
          patientName: widget.entry.patientName,
          position: widget.entry.position,
          statusLabel: widget.entry.status.label(l10n),
          statusColor: widget.entry.status.color(),
          autoSaved: notes.updatedAt != null,
          autoSavedLabel: l10n.notesAutoSaved,
          contactBar: StaffPatientContactBar(
            phone: widget.entry.patientPhone,
            patientName: widget.entry.patientName,
            doctorId: widget.doctorId,
            doctorName: widget.doctorName,
            patientId: widget.entry.patientId,
            compact: true,
          ),
          completedBanner: isCompleted
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.medicalGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.medicalGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.visitCompletedReadOnly,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              : widget.entry.status == QueueStatus.review
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.replay_rounded,
                              color: Colors.orange.shade800, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.patientReturnedForReview,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
        ),
        const SizedBox(height: 14),
        ],
        DoctorConsultationSectionTile(
          icon: Icons.history_rounded,
          title: l10n.medicalHistory,
          subtitle: prescriptions.isEmpty
              ? l10n.noMedicalHistoryYet
              : l10n.medicalHistoryEntryCount(prescriptions.length),
          expanded: _focused == ConsultationFocusSection.medicalHistory,
          onTap: () => _focusSection(ConsultationFocusSection.medicalHistory),
          child: _MedicalHistoryBody(
            prescriptions: prescriptions,
            appointments: appointments,
            emptyLabel: l10n.noMedicalHistoryYet,
          ),
        ),
        DoctorConsultationSectionTile(
          icon: Icons.medical_information_outlined,
          title: l10n.diagnosis,
          subtitle: controllers.diagnosis.text.trim().isEmpty
              ? null
              : controllers.diagnosis.text.trim(),
          expanded: _focused == ConsultationFocusSection.diagnosis,
          onTap: () => _focusSection(ConsultationFocusSection.diagnosis),
          child: TextField(
            controller: controllers.diagnosis,
            onChanged: (_) => _onFieldChanged(),
            readOnly: isCompleted,
            autofocus: _focused == ConsultationFocusSection.diagnosis && !isCompleted,
            decoration: _fieldDecoration(
              context,
              l10n.diagnosis,
              Icons.medical_information_outlined,
            ),
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.next,
          ),
        ),
        DoctorConsultationSectionTile(
          icon: Icons.medication_outlined,
          title: l10n.writePrescription,
          subtitle: _prescriptionSubtitle(notes, l10n),
          expanded: _focused == ConsultationFocusSection.prescription,
          onTap: () => _focusSection(ConsultationFocusSection.prescription),
          child: DoctorPrescriptionComposer(
            doctorId: widget.doctorId,
            items: notes.prescriptionItems,
            readOnly: isCompleted,
            legacyMedications: notes.prescriptionItems.isEmpty
                ? notes.medications
                : null,
            onItemsChanged: (items) {
              widget.session.onPrescriptionItemsChanged(_storageKey, items);
              _schedulePrescriptionSync();
              setState(() {});
            },
            onPrint: notes.prescriptionItems.isEmpty
                ? null
                : () => showPrescriptionPrintSheet(
                      context: context,
                      patientName: widget.entry.patientName,
                      doctorName: widget.doctorName,
                      diagnosis: notes.diagnosis,
                      items: notes.prescriptionItems,
                      notes: notes.clinicalNotes.trim().isEmpty
                          ? null
                          : notes.clinicalNotes.trim(),
                      clinicName: clinicName,
                      clinicAddress: clinicAddress,
                      clinicPhone: clinicPhone,
                      doctorSpecialty: doctorSpecialty,
                    ),
          ),
        ),
        DoctorConsultationSectionTile(
          icon: Icons.biotech_outlined,
          title: l10n.requestInvestigation,
          subtitle: _investigationSubtitle(notes, l10n),
          expanded: _focused == ConsultationFocusSection.investigations,
          onTap: () => _focusSection(ConsultationFocusSection.investigations),
          child: DoctorInvestigationComposer(
            items: notes.investigationItems,
            readOnly: isCompleted,
            onItemsChanged: _onInvestigationItemsChanged,
          ),
        ),
        if (notes.investigationItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: DoctorConsultationTokens.sectionGap),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => showInvestigationPrintSheet(
                  context: context,
                  patientName: widget.entry.patientName,
                  doctorName: widget.doctorName,
                  items: notes.investigationItems,
                  clinicName: clinicName,
                  clinicAddress: clinicAddress,
                  clinicPhone: clinicPhone,
                  doctorSpecialty: doctorSpecialty,
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: Text(l10n.printInvestigationRequest),
              ),
            ),
          ),
        DoctorConsultationSectionTile(
          icon: Icons.notes_outlined,
          title: l10n.clinicalNotes,
          subtitle: controllers.clinicalNotes.text.trim().isEmpty
              ? null
              : controllers.clinicalNotes.text.trim(),
          expanded: _focused == ConsultationFocusSection.clinicalNotes,
          onTap: () => _focusSection(ConsultationFocusSection.clinicalNotes),
          child: TextField(
            controller: controllers.clinicalNotes,
            onChanged: (_) => _onFieldChanged(),
            readOnly: isCompleted,
            autofocus: _focused == ConsultationFocusSection.clinicalNotes && !isCompleted,
            decoration: _fieldDecoration(
              context,
              l10n.clinicalNotes,
              Icons.notes_outlined,
            ),
            minLines: 3,
            maxLines: 8,
          ),
        ),
      ],
    );
  }
}

class _MedicalHistoryBody extends StatelessWidget {
  const _MedicalHistoryBody({
    required this.prescriptions,
    required this.appointments,
    required this.emptyLabel,
  });

  final List<Prescription> prescriptions;
  final List<Appointment> appointments;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat.yMMMd();

    if (prescriptions.isEmpty && appointments.isEmpty) {
      return Text(
        emptyLabel,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (prescriptions.isNotEmpty) ...[
          for (final rx in prescriptions.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFmt.format(rx.createdAt.toLocal()),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    if (rx.diagnosis.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.diagnosis}: ${rx.diagnosis}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (rx.medications.isNotEmpty || rx.items.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.medications}: ${rx.items.isNotEmpty ? rx.items.map((e) => e.formatLine()).join('; ') : rx.medications}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
        if (appointments.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            l10n.recentVisits,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          for (final appt in appointments.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${dateFmt.format(appt.dateTime.toLocal())} — ${appt.status.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ],
    );
  }
}
