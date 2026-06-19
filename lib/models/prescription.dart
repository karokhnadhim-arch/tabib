import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'diagnosis': diagnosis,
        'medications': medications,
        'createdAt': Timestamp.fromDate(createdAt),
        if (notes != null) 'notes': notes,
      };

  factory Prescription.fromFirestore(String id, Map<String, dynamic> data) {
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
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
