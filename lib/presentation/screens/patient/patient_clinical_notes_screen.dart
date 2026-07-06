import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/prescription.dart';
import '../../../services/auth_service.dart';
import '../../providers/app_providers.dart';

/// Clinical notes shared by the doctor via prescription notes field.
class PatientClinicalNotesScreen extends StatefulWidget {
  const PatientClinicalNotesScreen({super.key});

  @override
  State<PatientClinicalNotesScreen> createState() =>
      _PatientClinicalNotesScreenState();
}

class _PatientClinicalNotesScreenState extends State<PatientClinicalNotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientId = context.read<AuthService>().patientId;
      if (patientId.isNotEmpty) {
        context.read<PrescriptionProvider>().watchPatient(patientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<PrescriptionProvider>();
    final notes = provider.prescriptions
        .where((p) => p.notes != null && p.notes!.trim().isNotEmpty)
        .toList();
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sharedClinicalNotes),
        backgroundColor: AppTheme.medicalBlue,
      ),
      body: ScrollableResponsiveBody(
        child: provider.isLoading && notes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : notes.isEmpty
                ? _EmptyState(message: l10n.noClinicalNotesShared)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rx = notes[index];
                      return _NoteCard(
                        prescription: rx,
                        dateLabel: dateFmt.format(rx.createdAt.toLocal()),
                      );
                    },
                  ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.notes_outlined,
              size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.prescription,
    required this.dateLabel,
  });

  final Prescription prescription;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    prescription.doctorName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              prescription.notes!.trim(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
