import 'package:cloud_firestore/cloud_firestore.dart';

import 'prescription_line_item.dart';

class Prescription {
  const Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.diagnosis,
    required this.medications,
    required this.createdAt,
    this.notes,
    this.items = const [],
  });

  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String diagnosis;
  final String medications;
  final DateTime createdAt;
  final String? notes;
  final List<PrescriptionLineItem> items;

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'diagnosis': diagnosis,
        'medications': medications,
        'createdAt': Timestamp.fromDate(createdAt),
        if (notes != null) 'notes': notes,
        if (items.isNotEmpty) 'items': items.map((e) => e.toMap()).toList(),
      };

  factory Prescription.fromFirestore(String id, Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) =>
                PrescriptionLineItem.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : const <PrescriptionLineItem>[];

    return Prescription(
      id: id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      diagnosis: data['diagnosis'] as String? ?? '',
      medications: data['medications'] as String? ?? '',
      createdAt: _parseDate(data['createdAt']),
      notes: data['notes'] as String?,
      items: items,
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
