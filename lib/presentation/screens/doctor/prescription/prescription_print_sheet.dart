import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/investigation_request_item.dart';
import '../../../../models/prescription_line_item.dart';
import '../../../../utils/investigation_category_utils.dart';
import '../../../widgets/clinical/clinical_print_builder.dart';

/// Prints the prescription directly (system print dialog). Shows feedback only on failure.
Future<void> printPrescriptionDocument({
  required BuildContext context,
  required String patientName,
  required String doctorName,
  required String diagnosis,
  required List<PrescriptionLineItem> items,
  String? notes,
  String? clinicName,
  String? clinicAddress,
  String? clinicPhone,
  String? doctorSpecialty,
  List<InvestigationRequestItem> investigations = const [],
}) async {
  final l10n = AppLocalizations.of(context);
  final builder = ClinicalPrintBuilder(
    clinicName: clinicName?.trim().isNotEmpty == true ? clinicName! : 'TABIB',
    clinicAddress: clinicAddress,
    clinicPhone: clinicPhone,
    doctorName: doctorName,
    doctorSpecialty: doctorSpecialty,
  );

  try {
    final doc = await builder.buildPrescriptionPdf(
      patientName: patientName,
      diagnosisLabel: l10n.diagnosis,
      diagnosis: diagnosis,
      medicationsLabel: l10n.medications,
      items: items,
      patientLabel: l10n.patientName,
      dateLabel: l10n.date,
      notesLabel: l10n.notesOptional,
      notes: notes,
      investigationsLabel: investigations.isEmpty ? null : l10n.requestedInvestigations,
      investigations: investigations.isEmpty ? null : investigations,
      investigationLine: investigations.isEmpty
          ? null
          : (item) =>
              '${item.name} (${item.category.label(l10n)})'
              '${item.note != null && item.note!.trim().isNotEmpty ? ' — ${item.note!.trim()}' : ''}',
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.errorGeneric)),
    );
  }
}

/// Optional A4 prescription print / copy — never forced.
Future<void> showPrescriptionPrintSheet({
  required BuildContext context,
  required String patientName,
  required String doctorName,
  required String diagnosis,
  required List<PrescriptionLineItem> items,
  String? notes,
  String? clinicName,
  String? clinicAddress,
  String? clinicPhone,
  String? doctorSpecialty,
  List<InvestigationRequestItem> investigations = const [],
}) {
  final l10n = AppLocalizations.of(context);
  final body = _formatPrescriptionText(
    patientName: patientName,
    doctorName: doctorName,
    diagnosis: diagnosis,
    items: items,
    notes: notes,
    clinicName: clinicName,
    medicationsLabel: l10n.medications,
    diagnosisLabel: l10n.diagnosis,
    notesLabel: l10n.notesOptional,
    doctorLabel: l10n.doctor,
    patientLabel: l10n.patientName,
    dateLabel: l10n.date,
    investigations: investigations,
    investigationsLabel: investigations.isEmpty ? null : l10n.requestedInvestigations,
    investigationLine: investigations.isEmpty
        ? null
        : (item) =>
            '${item.name} (${item.category.label(l10n)})'
            '${item.note != null && item.note!.trim().isNotEmpty ? ' — ${item.note!.trim()}' : ''}',
  );

  final builder = ClinicalPrintBuilder(
    clinicName: clinicName?.trim().isNotEmpty == true ? clinicName! : 'TABIB',
    clinicAddress: clinicAddress,
    clinicPhone: clinicPhone,
    doctorName: doctorName,
    doctorSpecialty: doctorSpecialty,
  );

  final isWide = MediaQuery.sizeOf(context).width >= 900;

  if (isWide) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _PrescriptionPrintDialog(
        l10n: l10n,
        body: body,
        builder: builder,
        patientName: patientName,
        diagnosis: diagnosis,
        items: items,
        notes: notes,
        patientLabel: l10n.patientName,
        diagnosisLabel: l10n.diagnosis,
        medicationsLabel: l10n.medications,
        dateLabel: l10n.date,
        notesLabel: l10n.notesOptional,
        investigations: investigations,
        investigationsLabel:
            investigations.isEmpty ? null : l10n.requestedInvestigations,
        investigationLine: investigations.isEmpty
            ? null
            : (item) =>
                '${item.name} (${item.category.label(l10n)})'
                '${item.note != null && item.note!.trim().isNotEmpty ? ' — ${item.note!.trim()}' : ''}',
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _PrescriptionPrintDialog(
      l10n: l10n,
      body: body,
      builder: builder,
      patientName: patientName,
      diagnosis: diagnosis,
      items: items,
      notes: notes,
      patientLabel: l10n.patientName,
      diagnosisLabel: l10n.diagnosis,
      medicationsLabel: l10n.medications,
      dateLabel: l10n.date,
      notesLabel: l10n.notesOptional,
      investigations: investigations,
      investigationsLabel:
          investigations.isEmpty ? null : l10n.requestedInvestigations,
      investigationLine: investigations.isEmpty
          ? null
          : (item) =>
              '${item.name} (${item.category.label(l10n)})'
              '${item.note != null && item.note!.trim().isNotEmpty ? ' — ${item.note!.trim()}' : ''}',
      compact: true,
    ),
  );
}

class _PrescriptionPrintDialog extends StatelessWidget {
  const _PrescriptionPrintDialog({
    required this.l10n,
    required this.body,
    required this.builder,
    required this.patientName,
    required this.diagnosis,
    required this.items,
    required this.notes,
    required this.patientLabel,
    required this.diagnosisLabel,
    required this.medicationsLabel,
    required this.dateLabel,
    required this.notesLabel,
    this.investigations = const [],
    this.investigationsLabel,
    this.investigationLine,
    this.compact = false,
  });

  final AppLocalizations l10n;
  final String body;
  final ClinicalPrintBuilder builder;
  final String patientName;
  final String diagnosis;
  final List<PrescriptionLineItem> items;
  final String? notes;
  final String patientLabel;
  final String diagnosisLabel;
  final String medicationsLabel;
  final String dateLabel;
  final String? notesLabel;
  final List<InvestigationRequestItem> investigations;
  final String? investigationsLabel;
  final String Function(InvestigationRequestItem)? investigationLine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.printPrescription,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.printPrescriptionHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 595),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: scheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SelectableText(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: Colors.black87,
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _printPdf(context),
              icon: const Icon(Icons.print_outlined),
              label: Text(l10n.printDocument),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: body));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.copiedToClipboard)),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(l10n.copyPrescription),
            ),
            if (!compact)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.notNow),
              ),
          ],
        ),
      ],
    );

    if (compact) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: content,
        ),
      );
    }

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      content: SizedBox(
        width: 640,
        height: 520,
        child: content,
      ),
    );
  }

  Future<void> _printPdf(BuildContext context) async {
    final doc = await builder.buildPrescriptionPdf(
      patientName: patientName,
      diagnosisLabel: diagnosisLabel,
      diagnosis: diagnosis,
      medicationsLabel: medicationsLabel,
      items: items,
      patientLabel: patientLabel,
      dateLabel: dateLabel,
      notesLabel: notesLabel,
      notes: notes,
      investigationsLabel: investigationsLabel,
      investigations: investigations,
      investigationLine: investigationLine,
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }
}

String _formatPrescriptionText({
  required String patientName,
  required String doctorName,
  required String diagnosis,
  required List<PrescriptionLineItem> items,
  required String medicationsLabel,
  required String diagnosisLabel,
  required String notesLabel,
  required String doctorLabel,
  required String patientLabel,
  required String dateLabel,
  String? clinicName,
  String? notes,
  List<InvestigationRequestItem> investigations = const [],
  String? investigationsLabel,
  String Function(InvestigationRequestItem)? investigationLine,
}) {
  final dateFmt = DateFormat.yMMMd().add_jm();
  final buffer = StringBuffer();
  if (clinicName != null && clinicName.trim().isNotEmpty) {
    buffer.writeln(clinicName.trim());
    buffer.writeln('────────────────────────');
  } else {
    buffer.writeln('TABIB');
  }
  buffer
    ..writeln('$dateLabel: ${dateFmt.format(DateTime.now())}')
    ..writeln('$patientLabel: $patientName')
    ..writeln('$doctorLabel: $doctorName')
    ..writeln()
    ..writeln('$diagnosisLabel: $diagnosis')
    ..writeln()
    ..writeln('$medicationsLabel:');
  for (var i = 0; i < items.length; i++) {
    buffer.writeln('${i + 1}. ${items[i].formatLine()}');
  }
  if (notes != null && notes.trim().isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('$notesLabel: ${notes.trim()}');
  }
  if (investigations.isNotEmpty &&
      investigationsLabel != null &&
      investigationLine != null) {
    buffer
      ..writeln()
      ..writeln('$investigationsLabel:');
    for (var i = 0; i < investigations.length; i++) {
      buffer.writeln('${i + 1}. ${investigationLine(investigations[i])}');
    }
  }
  return buffer.toString();
}
