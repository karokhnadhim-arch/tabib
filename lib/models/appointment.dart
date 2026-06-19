import 'package:cloud_firestore/cloud_firestore.dart';

import 'visit_status.dart';

enum AppointmentStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
  available,
  booked,
}

class Appointment {
  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.clinicName,
    required this.dateTime,
    required this.status,
    this.patientId,
    this.patientName,
    this.patientPhone,
    this.doctorId,
    this.clinicId,
    this.notes,
    this.visitStatus = VisitStatus.scheduled,
  });

  final String id;
  final String? patientId;
  final String? patientName;
  final String? patientPhone;
  final String doctorName;
  final String specialty;
  final String clinicName;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String? doctorId;
  final String? clinicId;
  final String? notes;
  final VisitStatus visitStatus;

  bool get isPending => status == AppointmentStatus.pending;
  bool get isAccepted => status == AppointmentStatus.accepted;
  bool get isAvailable => status == AppointmentStatus.available;

  Appointment copyWith({
    AppointmentStatus? status,
    DateTime? dateTime,
    VisitStatus? visitStatus,
    String? notes,
  }) =>
      Appointment(
        id: id,
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        doctorName: doctorName,
        specialty: specialty,
        clinicName: clinicName,
        dateTime: dateTime ?? this.dateTime,
        status: status ?? this.status,
        doctorId: doctorId,
        clinicId: clinicId,
        notes: notes ?? this.notes,
        visitStatus: visitStatus ?? this.visitStatus,
      );

  Map<String, dynamic> toMap() => {
        'doctorName': doctorName,
        'specialty': specialty,
        'clinicName': clinicName,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': status.name,
        'visitStatus': visitStatus.name,
        if (patientId != null) 'patientId': patientId,
        if (patientName != null) 'patientName': patientName,
        if (patientPhone != null) 'patientPhone': patientPhone,
        if (doctorId != null) 'doctorId': doctorId,
        if (clinicId != null) 'clinicId': clinicId,
        if (notes != null) 'notes': notes,
      };

  factory Appointment.fromFirestore(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      patientId: data['patientId'] as String?,
      patientName: data['patientName'] as String?,
      patientPhone: data['patientPhone'] as String?,
      doctorName: data['doctorName'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      clinicName: data['clinicName'] as String? ?? '',
      dateTime: _parseDateTime(data['dateTime']),
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      doctorId: data['doctorId'] as String?,
      clinicId: data['clinicId'] as String?,
      notes: data['notes'] as String?,
      visitStatus: VisitStatus.values.firstWhere(
        (s) => s.name == data['visitStatus'],
        orElse: () => VisitStatus.scheduled,
      ),
    );
  }

  static DateTime _parseDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
