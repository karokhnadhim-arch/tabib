import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/investigation_request_item.dart';
import '../../../models/prescription_line_item.dart';

/// Clinic header + A4 document builders for optional clinical printing.
class ClinicalPrintBuilder {
  ClinicalPrintBuilder({
    required this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    this.doctorName,
    this.doctorSpecialty,
  });

  final String clinicName;
  final String? clinicAddress;
  final String? clinicPhone;
  final String? doctorName;
  final String? doctorSpecialty;

  pw.Widget _header(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          clinicName,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (doctorName != null && doctorName!.isNotEmpty)
          pw.Text(
            doctorName!,
            style: const pw.TextStyle(fontSize: 12),
          ),
        if (doctorSpecialty != null && doctorSpecialty!.isNotEmpty)
          pw.Text(
            doctorSpecialty!,
            style: const pw.TextStyle(fontSize: 10),
          ),
        if (clinicAddress != null && clinicAddress!.isNotEmpty)
          pw.Text(clinicAddress!, style: const pw.TextStyle(fontSize: 9)),
        if (clinicPhone != null && clinicPhone!.isNotEmpty)
          pw.Text(clinicPhone!, style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
      ],
    );
  }

  Future<pw.Document> buildPrescriptionPdf({
    required String patientName,
    required String diagnosisLabel,
    required String diagnosis,
    required String medicationsLabel,
    required List<PrescriptionLineItem> items,
    required String patientLabel,
    required String dateLabel,
    String? notesLabel,
    String? notes,
    String? investigationsLabel,
    List<InvestigationRequestItem>? investigations,
    String Function(InvestigationRequestItem)? investigationLine,
  }) async {
    final doc = pw.Document();
    final dateFmt = DateFormat.yMMMd().add_jm();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _header(context),
              pw.Text(
                dateLabel,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                dateFmt.format(DateTime.now()),
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                '$patientLabel: $patientName',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                diagnosisLabel,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(diagnosis, style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 16),
              pw.Text(
                medicationsLabel,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              for (var i = 0; i < items.length; i++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '${i + 1}. ${items[i].formatLine()}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              if (notes != null && notes.trim().isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  notesLabel ?? 'Notes',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(notes.trim(), style: const pw.TextStyle(fontSize: 10)),
              ],
              if (investigations != null &&
                  investigations.isNotEmpty &&
                  investigationsLabel != null &&
                  investigationLine != null) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  investigationsLabel,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                for (var i = 0; i < investigations.length; i++)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '${i + 1}. ${investigationLine(investigations[i])}',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
    return doc;
  }

  Future<pw.Document> buildInvestigationPdf({
    required String patientName,
    required String patientLabel,
    required String dateLabel,
    required String investigationsLabel,
    required List<InvestigationRequestItem> items,
    required String Function(InvestigationRequestItem) itemLine,
  }) async {
    final doc = pw.Document();
    final dateFmt = DateFormat.yMMMd().add_jm();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _header(context),
              pw.Text(dateLabel, style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                dateFmt.format(DateTime.now()),
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                '$patientLabel: $patientName',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                investigationsLabel,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              for (var i = 0; i < items.length; i++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '${i + 1}. ${itemLine(items[i])}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
            ],
          );
        },
      ),
    );
    return doc;
  }
}
