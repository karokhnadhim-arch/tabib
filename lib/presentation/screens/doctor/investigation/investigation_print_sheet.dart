import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/investigation_request_item.dart';
import '../../../../utils/investigation_category_utils.dart';
import '../../../widgets/clinical/clinical_print_builder.dart';

/// Optional A4 investigation request print — never forced.
Future<void> showInvestigationPrintSheet({
  required BuildContext context,
  required String patientName,
  required String doctorName,
  required List<InvestigationRequestItem> items,
  String? clinicName,
  String? clinicAddress,
  String? clinicPhone,
  String? doctorSpecialty,
}) {
  if (items.isEmpty) return Future.value();

  final l10n = AppLocalizations.of(context);
  final body = _formatText(
    l10n: l10n,
    patientName: patientName,
    doctorName: doctorName,
    items: items,
    clinicName: clinicName,
  );

  final builder = ClinicalPrintBuilder(
    clinicName: clinicName?.trim().isNotEmpty == true ? clinicName! : 'TABIB',
    clinicAddress: clinicAddress,
    clinicPhone: clinicPhone,
    doctorName: doctorName,
    doctorSpecialty: doctorSpecialty,
  );

  final isWide = MediaQuery.sizeOf(context).width >= 900;

  final dialog = _InvestigationPrintDialog(
    l10n: l10n,
    body: body,
    builder: builder,
    patientName: patientName,
    items: items,
    patientLabel: l10n.patientName,
    dateLabel: l10n.date,
    investigationsLabel: l10n.requestInvestigation,
    itemLine: (item) =>
        '${item.name} (${item.category.label(l10n)})'
        '${item.note != null && item.note!.trim().isNotEmpty ? ' — ${item.note!.trim()}' : ''}',
  );

  if (isWide) {
    return showDialog<void>(context: context, builder: (_) => dialog);
  }
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: dialog,
      ),
    ),
  );
}

class _InvestigationPrintDialog extends StatelessWidget {
  const _InvestigationPrintDialog({
    required this.l10n,
    required this.body,
    required this.builder,
    required this.patientName,
    required this.items,
    required this.patientLabel,
    required this.dateLabel,
    required this.investigationsLabel,
    required this.itemLine,
  });

  final AppLocalizations l10n;
  final String body;
  final ClinicalPrintBuilder builder;
  final String patientName;
  final List<InvestigationRequestItem> items;
  final String patientLabel;
  final String dateLabel;
  final String investigationsLabel;
  final String Function(InvestigationRequestItem) itemLine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.printInvestigationRequest,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
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
              ),
              child: SelectableText(body),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
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
          ],
        ),
      ],
    );
  }

  Future<void> _printPdf(BuildContext context) async {
    final doc = await builder.buildInvestigationPdf(
      patientName: patientName,
      patientLabel: patientLabel,
      dateLabel: dateLabel,
      investigationsLabel: investigationsLabel,
      items: items,
      itemLine: itemLine,
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }
}

String _formatText({
  required AppLocalizations l10n,
  required String patientName,
  required String doctorName,
  required List<InvestigationRequestItem> items,
  String? clinicName,
}) {
  final dateFmt = DateFormat.yMMMd().add_jm();
  final buffer = StringBuffer();
  if (clinicName != null && clinicName.trim().isNotEmpty) {
    buffer.writeln(clinicName.trim());
    buffer.writeln('────────────────────────');
  }
  buffer
    ..writeln('${l10n.date}: ${dateFmt.format(DateTime.now())}')
    ..writeln('${l10n.patientName}: $patientName')
    ..writeln('${l10n.doctor}: $doctorName')
    ..writeln()
    ..writeln('${l10n.requestInvestigation}:');
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    buffer.writeln(
      '${i + 1}. ${item.name} (${item.category.label(l10n)})'
      '${item.note != null && item.note!.trim().isNotEmpty ? ' — ${item.note!.trim()}' : ''}',
    );
  }
  return buffer.toString();
}
