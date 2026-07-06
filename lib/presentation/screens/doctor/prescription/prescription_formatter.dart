import '../../../../models/prescription_line_item.dart';

/// Formats structured prescription lines for storage and display.
class PrescriptionFormatter {
  PrescriptionFormatter._();

  static String formatItems(List<PrescriptionLineItem> items) {
    if (items.isEmpty) return '';
    return items.map((e) => e.formatLine()).join('\n');
  }

  static List<PrescriptionLineItem> parseItems(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => PrescriptionLineItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
