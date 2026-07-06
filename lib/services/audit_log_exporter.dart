import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/audit_log_entry.dart';
import '../models/audit_module.dart';

/// Exports audit logs to PDF and Excel-compatible formats.
class AuditLogExporter {
  AuditLogExporter._();

  static String exportExcel(List<AuditLogEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln(
      [
        'Date',
        'Time',
        'User',
        'Role',
        'Module',
        'Action',
        'Description',
        'Device',
        'OS',
        'IP',
        'Clinic',
      ].join('\t'),
    );
    for (final e in entries) {
      final ts = e.timestamp.toLocal();
      buffer.writeln(
        [
          DateFormat.yMMMd().format(ts),
          DateFormat.Hms().format(ts),
          e.userName,
          e.userRole?.name ?? '',
          e.module?.storageKey ?? '',
          e.action,
          e.description ?? e.details ?? '',
          e.device ?? '',
          e.operatingSystem ?? '',
          e.ipAddress ?? '',
          e.clinicId ?? '',
        ].map(_cell).join('\t'),
      );
    }
    return buffer.toString();
  }

  static String exportCsv(List<AuditLogEntry> entries) {
    final buffer = StringBuffer(
      'Date,Time,User,Role,Module,Action,Description,Device,OS,IP,Clinic\n',
    );
    for (final e in entries) {
      final ts = e.timestamp.toLocal();
      buffer.writeln(
        [
          DateFormat.yMMMd().format(ts),
          DateFormat.Hms().format(ts),
          e.userName,
          e.userRole?.name ?? '',
          e.module?.storageKey ?? '',
          e.action,
          e.description ?? e.details ?? '',
          e.device ?? '',
          e.operatingSystem ?? '',
          e.ipAddress ?? '',
          e.clinicId ?? '',
        ].map(_csv).join(','),
      );
    }
    return buffer.toString();
  }

  static Future<List<int>> exportPdfBytes({
    required List<AuditLogEntry> entries,
    required String title,
  }) async {
    final doc = pw.Document();
    final dateFmt = DateFormat.yMMMd().add_Hms();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Date/Time',
              'User',
              'Role',
              'Module',
              'Action',
              'Description',
            ],
            data: entries
                .map(
                  (e) => [
                    dateFmt.format(e.timestamp.toLocal()),
                    e.userName,
                    e.userRole?.name ?? '—',
                    e.module?.storageKey ?? '—',
                    e.action,
                    e.description ?? e.details ?? '',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static String _csv(String value) => '"${value.replaceAll('"', '""')}"';
  static String _cell(String value) => value.replaceAll('\t', ' ');
}
