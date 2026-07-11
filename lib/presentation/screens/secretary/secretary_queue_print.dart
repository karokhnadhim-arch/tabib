import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../utils/queue_status_utils.dart';

/// Prints the secretary queue list using Flutter's text engine (same shaping
/// and system fonts as the on-screen UI), then embeds that into a PDF page.
Future<void> printSecretaryQueueList({
  required BuildContext context,
  required List<QueueEntry> entries,
  required String doctorName,
  String? clinicName,
  String? clinicPhone,
}) async {
  final l10n = AppLocalizations.of(context);
  if (entries.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.noPatientsInQueue)),
    );
    return;
  }

  final locale = Localizations.localeOf(context);
  final rtl = locale.languageCode == 'ku' || locale.languageCode == 'ar';
  final direction = rtl ? TextDirection.rtl : TextDirection.ltr;

  try {
    final rendered = await _renderQueueListPng(
      l10n: l10n,
      entries: entries,
      doctorName: doctorName,
      clinicName: clinicName?.trim().isNotEmpty == true
          ? clinicName!.trim()
          : 'TABIB',
      clinicPhone: clinicPhone,
      textDirection: direction,
    );

    final doc = pw.Document();
    final image = pw.MemoryImage(rendered.bytes);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Image(
          image,
          fit: pw.BoxFit.fitWidth,
          // Critical: Image defaults to center (blank on top). Top leaves
          // unused A4 space at the bottom.
          alignment: pw.Alignment.topCenter,
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.errorGeneric)),
    );
  }
}

Future<({Uint8List bytes, int width, int height})> _renderQueueListPng({
  required AppLocalizations l10n,
  required List<QueueEntry> entries,
  required String doctorName,
  required String clinicName,
  String? clinicPhone,
  required TextDirection textDirection,
}) async {
  const pageWidth = 794.0; // ~A4 @ 96dpi
  const margin = 28.0;
  const contentWidth = pageWidth - margin * 2;
  final now = DateFormat('yyyy/MM/dd  HH:mm').format(DateTime.now());

  final lines = <_PaintLine>[
    _PaintLine(clinicName, 22, FontWeight.w700),
    if (doctorName.trim().isNotEmpty)
      _PaintLine(doctorName.trim(), 14, FontWeight.w500),
    if (clinicPhone != null && clinicPhone.trim().isNotEmpty)
      _PaintLine(clinicPhone.trim(), 12, FontWeight.w400),
    const _PaintLine('', 8, FontWeight.w400),
    _PaintLine(l10n.printQueueListTitle, 16, FontWeight.w700),
    _PaintLine(now, 12, FontWeight.w400),
    _PaintLine(l10n.patientsInQueue(entries.length), 12, FontWeight.w400),
  ];

  final headers = [
    '#',
    l10n.patientName,
    l10n.phoneNumber,
    l10n.status,
    l10n.patientReady,
  ];
  final rows = entries
      .map(
        (e) => [
          '${e.position}',
          e.patientName,
          e.patientPhone,
          e.status.label(l10n),
          e.patientReady ? l10n.patientReady : '—',
        ],
      )
      .toList();

  // Measure height
  double y = margin;
  for (final line in lines) {
    if (line.text.isEmpty) {
      y += line.size;
      continue;
    }
    final tp = _painter(line.text, line.size, line.weight, textDirection)
      ..layout(maxWidth: contentWidth);
    y += tp.height + 4;
  }
  y += 16; // divider gap
  const colFlex = [0.7, 2.6, 2.0, 1.8, 1.6];
  final colWidths = colFlex.map((f) => contentWidth * f / 8.7).toList();
  final headerH = _measureRow(headers, colWidths, textDirection, bold: true);
  y += headerH;
  for (final row in rows) {
    y += _measureRow(row, colWidths, textDirection, bold: false);
  }
  y += margin;
  // Exact content height — no forced minimum blank band.
  final pageHeight = y.clamp(120.0, 3500.0);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, pageWidth, pageHeight),
    Paint()..color = Colors.white,
  );

  var cursorY = margin;
  for (final line in lines) {
    if (line.text.isEmpty) {
      cursorY += line.size;
      continue;
    }
    final tp = _painter(line.text, line.size, line.weight, textDirection)
      ..layout(maxWidth: contentWidth);
    final dx = textDirection == TextDirection.rtl
        ? margin + (contentWidth - tp.width)
        : margin;
    tp.paint(canvas, Offset(dx, cursorY));
    cursorY += tp.height + 4;
  }

  cursorY += 8;
  canvas.drawLine(
    Offset(margin, cursorY),
    Offset(pageWidth - margin, cursorY),
    Paint()
      ..color = Colors.black87
      ..strokeWidth = 1,
  );
  cursorY += 12;

  cursorY = _paintTableRow(
    canvas: canvas,
    cells: headers,
    colWidths: colWidths,
    x: margin,
    y: cursorY,
    textDirection: textDirection,
    bold: true,
    background: const Color(0xFFE0E0E0),
  );

  for (final row in rows) {
    cursorY = _paintTableRow(
      canvas: canvas,
      cells: row,
      colWidths: colWidths,
      x: margin,
      y: cursorY,
      textDirection: textDirection,
      bold: false,
      background: Colors.white,
    );
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(pageWidth.ceil(), pageHeight.ceil());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return (
    bytes: bytes!.buffer.asUint8List(),
    width: image.width,
    height: image.height,
  );
}

class _PaintLine {
  const _PaintLine(this.text, this.size, this.weight);
  final String text;
  final double size;
  final FontWeight weight;
}

TextPainter _painter(
  String text,
  double size,
  FontWeight weight,
  TextDirection direction,
) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: Colors.black,
        height: 1.35,
      ),
    ),
    textDirection: direction,
    textAlign:
        direction == TextDirection.rtl ? TextAlign.right : TextAlign.left,
  );
}

double _measureRow(
  List<String> cells,
  List<double> colWidths,
  TextDirection direction, {
  required bool bold,
}) {
  var maxH = 28.0;
  for (var i = 0; i < cells.length; i++) {
    final tp = _painter(
      cells[i],
      bold ? 11 : 12,
      bold ? FontWeight.w700 : FontWeight.w400,
      direction,
    )..layout(maxWidth: colWidths[i] - 12);
    maxH = maxH < tp.height + 14 ? tp.height + 14 : maxH;
  }
  return maxH;
}

double _paintTableRow({
  required Canvas canvas,
  required List<String> cells,
  required List<double> colWidths,
  required double x,
  required double y,
  required TextDirection textDirection,
  required bool bold,
  required Color background,
}) {
  final height = _measureRow(cells, colWidths, textDirection, bold: bold);
  final totalW = colWidths.fold<double>(0, (a, b) => a + b);

  canvas.drawRect(
    Rect.fromLTWH(x, y, totalW, height),
    Paint()..color = background,
  );
  canvas.drawRect(
    Rect.fromLTWH(x, y, totalW, height),
    Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8,
  );

  // Paint columns from the start side matching text direction.
  if (textDirection == TextDirection.rtl) {
    var cx = x + totalW;
    for (var i = 0; i < cells.length; i++) {
      final w = colWidths[i];
      cx -= w;
      canvas.drawLine(
        Offset(cx, y),
        Offset(cx, y + height),
        Paint()
          ..color = const Color(0xFFBDBDBD)
          ..strokeWidth = 0.6,
      );
      final tp = _painter(
        cells[i],
        bold ? 11 : 12,
        bold ? FontWeight.w700 : FontWeight.w400,
        textDirection,
      )..layout(maxWidth: w - 12);
      tp.paint(canvas, Offset(cx + w - 6 - tp.width, y + (height - tp.height) / 2));
    }
  } else {
    var cx = x;
    for (var i = 0; i < cells.length; i++) {
      final w = colWidths[i];
      canvas.drawLine(
        Offset(cx + w, y),
        Offset(cx + w, y + height),
        Paint()
          ..color = const Color(0xFFBDBDBD)
          ..strokeWidth = 0.6,
      );
      final tp = _painter(
        cells[i],
        bold ? 11 : 12,
        bold ? FontWeight.w700 : FontWeight.w400,
        textDirection,
      )..layout(maxWidth: w - 12);
      tp.paint(canvas, Offset(cx + 6, y + (height - tp.height) / 2));
      cx += w;
    }
  }
  return y + height;
}
