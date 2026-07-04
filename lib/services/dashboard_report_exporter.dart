import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/system_monitoring.dart';

/// Saves dashboard report payloads to disk (mobile/desktop) or downloads on web.
class DashboardReportExporter {
  DashboardReportExporter._();

  static Future<ReportExportResult> export({
    required String content,
    required ReportExportFormat format,
  }) async {
    if (content.isEmpty) {
      return const ReportExportResult(success: false, message: 'empty');
    }

    final extension = switch (format) {
      ReportExportFormat.csv => 'csv',
      ReportExportFormat.excel => 'xls',
      ReportExportFormat.pdf => 'pdf',
    };
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'tabib_dashboard_$stamp.$extension';

    if (kIsWeb) {
      return ReportExportResult(
        success: true,
        message: 'clipboard',
        fileName: fileName,
        content: content,
      );
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);
      return ReportExportResult(
        success: true,
        message: file.path,
        fileName: fileName,
        filePath: file.path,
      );
    } catch (_) {
      return ReportExportResult(
        success: false,
        message: 'failed',
        fileName: fileName,
        content: content,
      );
    }
  }
}

class ReportExportResult {
  const ReportExportResult({
    required this.success,
    required this.message,
    this.fileName,
    this.filePath,
    this.content,
  });

  final bool success;
  final String message;
  final String? fileName;
  final String? filePath;
  final String? content;
}
