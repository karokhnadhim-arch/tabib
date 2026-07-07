import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/investigation_request.dart';
import '../../../models/prescription.dart';
import '../../../models/queue_entry.dart';
import '../../../models/patient_profile.dart';
import '../../../services/patient_profile_service.dart';
import '../providers/app_providers.dart';
import '../screens/doctor/doctor_consultation_widgets.dart';

/// Right panel — patient demographics and clinical history (read-only).
class DoctorPatientSummaryPanel extends StatefulWidget {
  const DoctorPatientSummaryPanel({
    super.key,
    required this.entry,
    required this.doctorId,
  });

  final QueueEntry entry;
  final String doctorId;

  @override
  State<DoctorPatientSummaryPanel> createState() =>
      _DoctorPatientSummaryPanelState();
}

class _DoctorPatientSummaryPanelState extends State<DoctorPatientSummaryPanel> {
  late Future<PatientProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant DoctorPatientSummaryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.patientId != widget.entry.patientId) {
      _loadProfile();
    }
  }

  void _loadProfile() {
    _profileFuture = context
        .read<PatientProfileService>()
        .readProfileForUser(widget.entry.patientId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prescriptions = context
        .watch<PrescriptionProvider>()
        .prescriptions
        .where((p) => p.patientId == widget.entry.patientId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final investigations = context
        .watch<InvestigationRequestProvider>()
        .requests
        .where((r) => r.patientId == widget.entry.patientId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return DoctorWorkspacePanel(
      title: l10n.patientSummary,
      icon: Icons.person_outline_rounded,
      child: FutureBuilder<PatientProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final profile = snapshot.data ?? const PatientProfile();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DemographicsCard(
                phone: widget.entry.patientPhone,
                gender: profile.gender,
                city: profile.city,
              ),
              const SizedBox(height: DoctorConsultationTokens.sectionGap),
              _HistorySection(
                title: l10n.diagnosisHistory,
                emptyLabel: l10n.noDiagnosisHistory,
                child: _DiagnosisHistoryList(prescriptions: prescriptions),
              ),
              const SizedBox(height: DoctorConsultationTokens.sectionGap),
              _HistorySection(
                title: l10n.previousPrescriptions,
                emptyLabel: l10n.noMedicalHistoryYet,
                child: _PrescriptionHistoryList(prescriptions: prescriptions),
              ),
              const SizedBox(height: DoctorConsultationTokens.sectionGap),
              _HistorySection(
                title: l10n.investigationRequests,
                emptyLabel: l10n.noInvestigationsYet,
                child: _InvestigationHistoryList(requests: investigations),
              ),
              const SizedBox(height: DoctorConsultationTokens.sectionGap),
              _HistorySection(
                title: l10n.allergies,
                emptyLabel: l10n.noAllergiesRecorded,
                child: Text(
                  l10n.noAllergiesRecorded,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DemographicsCard extends StatelessWidget {
  const _DemographicsCard({
    required this.phone,
    this.gender,
    this.city,
  });

  final String phone;
  final String? gender;
  final String? city;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: DoctorConsultationTokens.cardRadius,
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          _DemographicRow(
            icon: Icons.phone_outlined,
            label: l10n.phone,
            value: phone.trim().isEmpty ? l10n.notAvailable : phone,
          ),
          const SizedBox(height: 10),
          _DemographicRow(
            icon: Icons.wc_outlined,
            label: l10n.genderLabel,
            value: (gender ?? '').trim().isEmpty ? l10n.notAvailable : gender!,
          ),
          const SizedBox(height: 10),
          _DemographicRow(
            icon: Icons.cake_outlined,
            label: l10n.age,
            value: l10n.ageNotRecorded,
          ),
          if ((city ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _DemographicRow(
              icon: Icons.location_city_outlined,
              label: l10n.city,
              value: city!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DemographicRow extends StatelessWidget {
  const _DemographicRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.emptyLabel,
    required this.child,
  });

  final String title;
  final String emptyLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _DiagnosisHistoryList extends StatelessWidget {
  const _DiagnosisHistoryList({required this.prescriptions});

  final List<Prescription> prescriptions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final diagnoses = prescriptions
        .where((p) => p.diagnosis.trim().isNotEmpty)
        .take(6)
        .toList();
    if (diagnoses.isEmpty) {
      return Text(
        l10n.noDiagnosisHistory,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }
    final dateFmt = DateFormat.yMMMd();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final rx in diagnoses)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFmt.format(rx.createdAt.toLocal()),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  rx.diagnosis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PrescriptionHistoryList extends StatelessWidget {
  const _PrescriptionHistoryList({required this.prescriptions});

  final List<Prescription> prescriptions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (prescriptions.isEmpty) {
      return Text(
        l10n.noMedicalHistoryYet,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }
    final dateFmt = DateFormat.yMMMd();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final rx in prescriptions.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFmt.format(rx.createdAt.toLocal()),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  rx.items.isNotEmpty
                      ? rx.items.map((e) => e.formatLine()).join(' · ')
                      : rx.medications,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InvestigationHistoryList extends StatelessWidget {
  const _InvestigationHistoryList({required this.requests});

  final List<InvestigationRequest> requests;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (requests.isEmpty) {
      return Text(
        l10n.noInvestigationsYet,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }
    final dateFmt = DateFormat.yMMMd();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final req in requests.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFmt.format(req.updatedAt.toLocal()),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  req.items.map((e) => e.name).join(' · '),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
