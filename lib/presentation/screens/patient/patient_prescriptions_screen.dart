import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/prescription.dart';
import '../../../models/prescription_line_item.dart';
import '../../../services/auth_service.dart';
import '../../providers/app_providers.dart';
import '../doctor/prescription/prescription_print_sheet.dart';

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
                        isCurrent: index == 0,
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
    this.isCurrent = false,
  });

  final Prescription prescription;
  final String dateLabel;
  final AppLocalizations l10n;
  final bool isCurrent;

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
        side: BorderSide(
          color: isCurrent
              ? AppTheme.medicalGreen.withOpacity(0.5)
              : scheme.outlineVariant.withOpacity(0.5),
          width: isCurrent ? 1.5 : 1,
        ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.medicalGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.currentPrescription,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.medicalGreen,
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
              const SizedBox(height: 12),
              Text(
                l10n.diagnosis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              Text(
                prescription.diagnosis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
            if (lines.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.medications,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < lines.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lines[i] is PrescriptionLineItem
                              ? (lines[i] as PrescriptionLineItem).formatLine()
                              : lines[i] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.35,
                          ),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openPrintSheet(context),
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: Text(l10n.printPrescription),
                ),
                if (prescription.pdfUrl != null &&
                    prescription.pdfUrl!.trim().isNotEmpty)
                  FilledButton.tonalIcon(
                    onPressed: () => _openPdf(prescription.pdfUrl!),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: Text(l10n.downloadPdf),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openPrintSheet(BuildContext context) {
    final items = prescription.items.isNotEmpty
        ? prescription.items
        : _legacyLines(prescription.medications)
            .map(
              (s) => PrescriptionLineItem(
                medicineId: '',
                genericName: s as String,
                brandName: '',
                strength: '',
                form: '',
                dosage: '',
                frequency: '',
                duration: '',
              ),
            )
            .toList();

    showPrescriptionPrintSheet(
      context: context,
      patientName: prescription.patientName,
      doctorName: prescription.doctorName,
      diagnosis: prescription.diagnosis,
      items: items,
      notes: prescription.notes,
    );
  }

  List<dynamic> _legacyLines(String medications) {
    if (medications.trim().isEmpty) return const [];
    return medications.split('\n').where((l) => l.trim().isNotEmpty).toList();
  }
}
