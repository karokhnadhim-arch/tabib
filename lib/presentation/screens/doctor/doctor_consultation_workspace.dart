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
import 'investigation/investigation_print_sheet.dart';
import 'investigation/investigation_request_panel.dart';
import 'prescription/doctor_prescription_composer.dart';
import 'prescription/prescription_action_bar.dart';
import 'prescription/prescription_formatter.dart';
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
    this.hideMedicalHistory = false,
    this.expandedSections = false,
  });

  final QueueEntry entry;
  final String doctorId;
  final String doctorName;
  final DoctorConsultationSession session;
  /// Hides duplicate patient card when the right summary panel is visible.
  final bool hidePatientSummary;
  /// When true, medical history is shown in the right panel instead.
  final bool hideMedicalHistory;
  /// Desktop scroll layout — all sections visible without accordion taps.
  final bool expandedSections;

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
  bool _saving = false;
  bool _savedForPrint = false;
  String? _watchedPatientId;

  String get _storageKey => DoctorVisitNotesStore.storageKey(
        doctorId: widget.doctorId,
        queueEntryId: widget.entry.id,
      );

  @override
  void initState() {
    super.initState();
    widget.session.notesStore.addListener(_onNotesStoreChanged);
    _bootstrap();
  }

  void _onNotesStoreChanged() {
    if (mounted) setState(() {});
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
    final notes = widget.session.notesStore.notesFor(_storageKey);
    _savedForPrint = notes.prescriptionSynced && notes.prescriptionItems.isNotEmpty;
    if (widget.entry.status == QueueStatus.inProgress) {
      setState(() => _focused = ConsultationFocusSection.diagnosis);
    }
  }

  String _diagnosisText(
    DoctorConsultationControllers controllers,
    DoctorVisitNotes notes,
  ) {
    final fromController = controllers.diagnosis.text.trim();
    return fromController.isNotEmpty ? fromController : notes.diagnosis.trim();
  }

  bool _canSave(
    DoctorConsultationControllers controllers,
    DoctorVisitNotes notes,
  ) {
    return _diagnosisText(controllers, notes).isNotEmpty &&
        notes.prescriptionItems.isNotEmpty;
  }

  void _invalidatePrint() {
    if (_savedForPrint) {
      setState(() => _savedForPrint = false);
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
    _invalidatePrint();
    widget.session.onFieldChanged(_storageKey);
    _schedulePrescriptionSync();
    setState(() {});
  }

  void _onInvestigationItemsChanged(List<InvestigationRequestItem> items) {
    _invalidatePrint();
    widget.session.onInvestigationItemsChanged(_storageKey, items);
    _scheduleInvestigationSync();
    setState(() {});
  }

  void _scheduleInvestigationSync() {
    _investigationSyncTimer?.cancel();
    _investigationSyncTimer =
        Timer(const Duration(milliseconds: 900), _maybeSyncInvestigations);
  }

  Future<void> _maybeSyncInvestigations({bool force = false}) async {
    if (!mounted || _syncingInvestigation) return;
    final notes = widget.session.notesStore.notesFor(_storageKey);
    if (!force && notes.investigationSynced) return;
    if (notes.investigationItems.isEmpty) {
      if (force && !notes.investigationSynced) {
        await widget.session.notesStore.markInvestigationSynced(_storageKey);
        if (mounted) setState(() {});
      }
      return;
    }

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

  Future<bool> _maybeSyncPrescription({bool force = false}) async {
    if (!mounted) return false;
    if (_syncingPrescription) {
      if (!force) return false;
      while (_syncingPrescription && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      if (!mounted) return false;
    }
    if (force) {
      widget.session.onFieldChanged(_storageKey);
    }
    final controllers = widget.session.controllersFor(_storageKey);
    final notes = widget.session.notesStore.notesFor(_storageKey);
    if (!force && notes.prescriptionSynced) return true;

    final diagnosis = _diagnosisText(controllers, notes);
    final clinicalNotes = controllers.clinicalNotes.text.trim().isNotEmpty
        ? controllers.clinicalNotes.text.trim()
        : notes.clinicalNotes.trim();
    final items = notes.prescriptionItems;
    final medications = items.isNotEmpty
        ? PrescriptionFormatter.formatItems(items)
        : notes.medications.trim();

    if (diagnosis.isEmpty || items.isEmpty) return false;

    _syncingPrescription = true;
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      _syncingPrescription = false;
      return false;
    }

    try {
      await context.read<PrescriptionProvider>().write(
            patientId: widget.entry.patientId,
            patientName: widget.entry.patientName,
            doctorId: widget.doctorId,
            doctorName: user.name.localized(context),
            diagnosis: diagnosis,
            medications: medications,
            notes: clinicalNotes.isEmpty ? null : clinicalNotes,
            items: items,
          );
      await widget.session.notesStore.markPrescriptionSynced(_storageKey);
      if (mounted) setState(() {});
      return true;
    } catch (_) {
      // Retry on next edit.
      return false;
    } finally {
      _syncingPrescription = false;
    }
  }

  void _focusSection(ConsultationFocusSection section) {
    setState(() => _focused = section);
  }

  Future<void> _saveNow() async {
    if (_saving || widget.entry.status == QueueStatus.completed) return;
    final controllers = widget.session.controllersFor(_storageKey);
    final notes = widget.session.notesStore.notesFor(_storageKey);
    final l10n = AppLocalizations.of(context);

    if (!_canSave(controllers, notes)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notes.prescriptionItems.isEmpty
                ? l10n.errorGeneric
                : l10n.diagnosis,
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
      _savedForPrint = false;
    });
    widget.session.onFieldChanged(_storageKey);
    final auth = context.read<AuthService>();
    final prescriptionProvider = context.read<PrescriptionProvider>();
    final user = auth.currentUser;
    final doctorName = user?.name.localized(context) ?? widget.doctorName;
    await widget.session.notesStore.flushPersist(_storageKey);
    if (!mounted) return;
    _prescriptionSyncTimer?.cancel();
    _investigationSyncTimer?.cancel();

    var prescriptionSaved = false;
    final diagnosis = _diagnosisText(controllers, notes);
    final clinicalNotes = controllers.clinicalNotes.text.trim().isNotEmpty
        ? controllers.clinicalNotes.text.trim()
        : notes.clinicalNotes.trim();
    final items = notes.prescriptionItems;
    final medications = PrescriptionFormatter.formatItems(items);

    if (user != null) {
      try {
        await prescriptionProvider.write(
              patientId: widget.entry.patientId,
              patientName: widget.entry.patientName,
              doctorId: widget.doctorId,
              doctorName: doctorName,
              diagnosis: diagnosis,
              medications: medications,
              notes: clinicalNotes.isEmpty ? null : clinicalNotes,
              items: items,
            );
        await widget.session.notesStore.markPrescriptionSynced(_storageKey);
        prescriptionSaved = true;
      } catch (_) {
        prescriptionSaved = false;
      }
    }

    await _maybeSyncInvestigations(force: true);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (prescriptionSaved) _savedForPrint = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          prescriptionSaved ? l10n.savedSuccessfully : l10n.errorGeneric,
        ),
      ),
    );
  }

  void _printPrescription({
    required DoctorConsultationControllers controllers,
    String? clinicName,
    String? clinicAddress,
    String? clinicPhone,
    String? doctorSpecialty,
  }) {
    widget.session.onFieldChanged(_storageKey);
    final fresh = widget.session.notesStore.notesFor(_storageKey);
    final diagnosis = controllers.diagnosis.text.trim().isNotEmpty
        ? controllers.diagnosis.text.trim()
        : fresh.diagnosis.trim();
    final clinicalNotes = controllers.clinicalNotes.text.trim().isNotEmpty
        ? controllers.clinicalNotes.text.trim()
        : fresh.clinicalNotes.trim();

    showPrescriptionPrintSheet(
      context: context,
      patientName: widget.entry.patientName,
      doctorName: widget.doctorName,
      diagnosis: diagnosis,
      items: fresh.prescriptionItems,
      notes: clinicalNotes.isEmpty ? null : clinicalNotes,
      clinicName: clinicName,
      clinicAddress: clinicAddress,
      clinicPhone: clinicPhone,
      doctorSpecialty: doctorSpecialty,
    );
  }

  String? _prescriptionSubtitle(DoctorVisitNotes notes, AppLocalizations l10n) {
    if (notes.prescriptionItems.isNotEmpty) {
      return l10n.prescriptionMedicineCount(notes.prescriptionItems.length);
    }
    final text = notes.medications.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _openInvestigationPanel({
    required bool isCompleted,
    required DoctorVisitNotes notes,
    String? clinicName,
    String? clinicAddress,
    String? clinicPhone,
    String? doctorSpecialty,
  }) async {
    await showInvestigationRequestPanel(
      context: context,
      initialItems: notes.investigationItems,
      readOnly: isCompleted,
      onPrint: (items) => showInvestigationPrintSheet(
        context: context,
        patientName: widget.entry.patientName,
        doctorName: widget.doctorName,
        items: items,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        clinicPhone: clinicPhone,
        doctorSpecialty: doctorSpecialty,
      ),
      onSave: (items) async {
        _onInvestigationItemsChanged(items);
        _investigationSyncTimer?.cancel();
        await _maybeSyncInvestigations();
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.session.notesStore.removeListener(_onNotesStoreChanged);
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
    final scheme = Theme.of(context).colorScheme;

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
            completedBanner: _statusBanner(context, l10n, isCompleted),
          ),
          const SizedBox(height: DoctorConsultationTokens.sectionGap),
        ],
        if (!widget.hideMedicalHistory)
          _buildSection(
            context: context,
            l10n: l10n,
            section: ConsultationFocusSection.medicalHistory,
            icon: Icons.history_rounded,
            title: l10n.medicalHistory,
            subtitle: prescriptions.isEmpty
                ? l10n.noMedicalHistoryYet
                : l10n.medicalHistoryEntryCount(prescriptions.length),
            child: _MedicalHistoryBody(
              prescriptions: prescriptions,
              appointments: appointments,
              emptyLabel: l10n.noMedicalHistoryYet,
            ),
          ),
        _buildSection(
          context: context,
          l10n: l10n,
          section: ConsultationFocusSection.diagnosis,
          icon: Icons.medical_information_outlined,
          title: l10n.diagnosis,
          subtitle: controllers.diagnosis.text.trim().isEmpty
              ? null
              : controllers.diagnosis.text.trim(),
          child: TextField(
            controller: controllers.diagnosis,
            onChanged: (_) => _onFieldChanged(),
            readOnly: isCompleted,
            autofocus: !widget.expandedSections &&
                _focused == ConsultationFocusSection.diagnosis &&
                !isCompleted,
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
        _buildSection(
          context: context,
          l10n: l10n,
          section: ConsultationFocusSection.prescription,
          icon: Icons.medication_outlined,
          title: l10n.writePrescription,
          subtitle: _prescriptionSubtitle(notes, l10n),
          child: DoctorPrescriptionComposer(
            doctorId: widget.doctorId,
            items: notes.prescriptionItems,
            readOnly: isCompleted,
            legacyMedications: notes.prescriptionItems.isEmpty
                ? notes.medications
                : null,
                onItemsChanged: (items) {
                  _invalidatePrint();
                  widget.session.onPrescriptionItemsChanged(_storageKey, items);
                  _schedulePrescriptionSync();
                  setState(() {});
                },
          ),
        ),
        _buildSection(
          context: context,
          l10n: l10n,
          section: ConsultationFocusSection.clinicalNotes,
          icon: Icons.notes_outlined,
          title: l10n.clinicalNotes,
          subtitle: controllers.clinicalNotes.text.trim().isEmpty
              ? null
              : controllers.clinicalNotes.text.trim(),
          child: TextField(
            controller: controllers.clinicalNotes,
            onChanged: (_) => _onFieldChanged(),
            readOnly: isCompleted,
            autofocus: !widget.expandedSections &&
                _focused == ConsultationFocusSection.clinicalNotes &&
                !isCompleted,
            decoration: _fieldDecoration(
              context,
              l10n.clinicalNotes,
              Icons.notes_outlined,
            ),
            minLines: 3,
            maxLines: 8,
          ),
        ),
        DoctorPrescriptionActionBar(
          saving: _saving,
          saveEnabled: !isCompleted && _canSave(controllers, notes),
          canPrint: !isCompleted && notes.prescriptionItems.isNotEmpty,
          onSave: isCompleted ? null : _saveNow,
          onPrint: () => _printPrescription(
            controllers: controllers,
            clinicName: clinicName,
            clinicAddress: clinicAddress,
            clinicPhone: clinicPhone,
            doctorSpecialty: doctorSpecialty,
          ),
        ),
        const SizedBox(height: DoctorConsultationTokens.sectionGap),
        Align(
          alignment: Alignment.centerRight,
          child: InvestigationRequestActionButton(
            count: notes.investigationItems.length,
            enabled: true,
            onPressed: () => _openInvestigationPanel(
              isCompleted: isCompleted,
              notes: notes,
              clinicName: clinicName,
              clinicAddress: clinicAddress,
              clinicPhone: clinicPhone,
              doctorSpecialty: doctorSpecialty,
            ),
          ),
        ),
        if (notes.updatedAt != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l10n.notesAutoSaved,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget? _statusBanner(
    BuildContext context,
    AppLocalizations l10n,
    bool isCompleted,
  ) {
    if (isCompleted) {
      return Container(
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
      );
    }
    if (widget.entry.status == QueueStatus.review) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.replay_rounded, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.patientReturnedForReview,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }

  Widget _buildSection({
    required BuildContext context,
    required AppLocalizations l10n,
    required ConsultationFocusSection section,
    required IconData icon,
    required String title,
    required Widget child,
    String? subtitle,
  }) {
    if (widget.expandedSections) {
      return DoctorConsultationSectionCard(
        icon: icon,
        title: title,
        subtitle: subtitle,
        child: child,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DoctorConsultationSectionTile(
          icon: icon,
          title: title,
          subtitle: subtitle,
          expanded: _focused == section,
          onTap: () => _focusSection(section),
          child: child,
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
