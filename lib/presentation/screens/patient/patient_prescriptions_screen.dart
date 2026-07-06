import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/prescription.dart';
import '../../../models/prescription_line_item.dart';
import '../../../services/auth_service.dart';
import '../../providers/app_providers.dart';

/// Patient-facing prescription history — always available in the app.
class PatientPrescriptionsScreen extends StatefulWidget {
  const PatientPrescriptionsScreen({super.key});

  @override
  State<PatientPrescriptionsScreen> createState() =>
      _PatientPrescriptionsScreenState();
}

class _PatientPrescriptionsScreenState extends State<PatientPrescriptionsScreen> {
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
    final prescriptions = provider.prescriptions;
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myPrescriptions),
        backgroundColor: AppTheme.medicalBlue,
      ),
      body: ScrollableResponsiveBody(
        child: provider.isLoading && prescriptions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : prescriptions.isEmpty
                ? _EmptyState(message: l10n.noPrescriptionsYet)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prescriptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rx = prescriptions[index];
                      return _PrescriptionCard(
                        prescription: rx,
                        dateLabel: dateFmt.format(rx.createdAt.toLocal()),
                        l10n: l10n,
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.medication_outlined, size: 48, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({
    required this.prescription,
    required this.dateLabel,
    required this.l10n,
  });

  final Prescription prescription;
  final String dateLabel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = prescription.items.isNotEmpty
        ? prescription.items
        : _legacyLines(prescription.medications);

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
            if (prescription.diagnosis.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l10n.diagnosis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              Text(
                prescription.diagnosis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
            if (lines.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l10n.medications,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              for (var i = 0; i < lines.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. '),
                      Expanded(
                        child: Text(
                          lines[i] is PrescriptionLineItem
                              ? (lines[i] as PrescriptionLineItem).formatLine()
                              : lines[i] as String,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (prescription.notes != null &&
                prescription.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.notesOptional}: ${prescription.notes!.trim()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<dynamic> _legacyLines(String medications) {
    if (medications.trim().isEmpty) return const [];
    return medications.split('\n').where((l) => l.trim().isNotEmpty).toList();
  }
}
