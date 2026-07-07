import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  static pw.Font? _regular;
  static pw.Font? _bold;

  static Future<void> _ensureFonts() async {
    _regular ??= await PdfGoogleFonts.notoSansArabicRegular();
    _bold ??= await PdfGoogleFonts.notoSansArabicBold();
  }

  pw.TextStyle _textStyle({
    double fontSize = 11,
    bool bold = false,
  }) {
    return pw.TextStyle(
      fontSize: fontSize,
      font: bold ? _bold : _regular,
    );
  }

  pw.Widget _header(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          clinicName,
          style: _textStyle(fontSize: 18, bold: true),
        ),
        if (doctorName != null && doctorName!.isNotEmpty)
          pw.Text(doctorName!, style: _textStyle(fontSize: 12)),
        if (doctorSpecialty != null && doctorSpecialty!.isNotEmpty)
          pw.Text(doctorSpecialty!, style: _textStyle(fontSize: 10)),
        if (clinicAddress != null && clinicAddress!.isNotEmpty)
          pw.Text(clinicAddress!, style: _textStyle(fontSize: 9)),
        if (clinicPhone != null && clinicPhone!.isNotEmpty)
          pw.Text(clinicPhone!, style: _textStyle(fontSize: 9)),
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
    String? copyTitle,
    String? notesLabel,
    String? notes,
  }) async {
    await _ensureFonts();
    final doc = pw.Document();
    final dateFmt = DateFormat.yMMMd().add_jm();
    final formattedDate = dateFmt.format(DateTime.now());

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _header(context),
              if (copyTitle != null && copyTitle.trim().isNotEmpty) ...[
                pw.Text(
                  copyTitle.trim(),
                  style: _textStyle(fontSize: 14, bold: true),
                ),
                pw.SizedBox(height: 12),
              ],
              pw.Text(dateLabel, style: _textStyle(fontSize: 10)),
              pw.Text(formattedDate, style: _textStyle(fontSize: 10)),
              pw.SizedBox(height: 12),
              pw.Text(
                '$patientLabel: $patientName',
                style: _textStyle(fontSize: 12, bold: true),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                diagnosisLabel,
                style: _textStyle(fontSize: 11, bold: true),
              ),
              pw.Text(diagnosis, style: _textStyle(fontSize: 11)),
              pw.SizedBox(height: 16),
              pw.Text(
                medicationsLabel,
                style: _textStyle(fontSize: 11, bold: true),
              ),
              pw.SizedBox(height: 6),
              for (var i = 0; i < items.length; i++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '${i + 1}. ${items[i].formatLine()}',
                    style: _textStyle(fontSize: 11),
                  ),
                ),
              if (notes != null && notes.trim().isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  notesLabel ?? 'Notes',
                  style: _textStyle(fontSize: 11, bold: true),
                ),
                pw.Text(notes.trim(), style: _textStyle(fontSize: 10)),
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
    await _ensureFonts();
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
              pw.Text(dateLabel, style: _textStyle(fontSize: 10)),
              pw.Text(
                dateFmt.format(DateTime.now()),
                style: _textStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                '$patientLabel: $patientName',
                style: _textStyle(fontSize: 12, bold: true),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                investigationsLabel,
                style: _textStyle(fontSize: 11, bold: true),
              ),
              pw.SizedBox(height: 6),
              for (var i = 0; i < items.length; i++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '${i + 1}. ${itemLine(items[i])}',
                    style: _textStyle(fontSize: 11),
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
