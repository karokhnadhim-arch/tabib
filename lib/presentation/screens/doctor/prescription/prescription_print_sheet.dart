import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/prescription_line_item.dart';

/// Optional print / copy preview — never forced.
Future<void> showPrescriptionPrintSheet({
  required BuildContext context,
  required String patientName,
  required String doctorName,
  required String diagnosis,
  required List<PrescriptionLineItem> items,
  String? notes,
}) {
  final l10n = AppLocalizations.of(context);
  final body = _formatPrescriptionText(
    patientName: patientName,
    doctorName: doctorName,
    diagnosis: diagnosis,
    items: items,
    notes: notes,
    medicationsLabel: l10n.medications,
    diagnosisLabel: l10n.diagnosis,
    notesLabel: l10n.notesOptional,
    doctorLabel: l10n.doctor,
    patientLabel: l10n.patientName,
    dateLabel: l10n.date,
  );

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.printPrescription,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.printPrescriptionHint,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: SelectableText(
                      body,
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: body));
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(l10n.copiedToClipboard)),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded),
                label: Text(l10n.copyPrescription),
              ),
            ],
          ),
        ),
      );
    },
  );
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
  String? notes,
}) {
  final dateFmt = DateFormat.yMMMd().add_jm();
  final buffer = StringBuffer()
    ..writeln('TABIB')
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
  return buffer.toString();
}
