import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_limits.dart';
import '../../models/notification.dart';
import '../../models/prescription.dart';
import '../../domain/repositories/repositories.dart';

class FirestorePrescriptionRepository implements PrescriptionRepository {
  FirestorePrescriptionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<Prescription>> watchPatientPrescriptions(String patientId) {
    return _db
        .collection('prescriptions')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .limit(FirestoreLimits.prescriptionsPageSize)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Prescription.fromFirestore(d.id, d.data()))
            .toList());
  }

  @override
  Stream<List<Prescription>> watchDoctorPrescriptions(String doctorId) {
    return _db
        .collection('prescriptions')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .limit(FirestoreLimits.prescriptionsPageSize)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Prescription.fromFirestore(d.id, d.data()))
            .toList());
  }

  @override
  Future<void> writePrescription({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String diagnosis,
    required String medications,
    String? notes,
  }) async {
    final ref = _db.collection('prescriptions').doc();
    final prescription = Prescription(
      id: ref.id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      diagnosis: diagnosis,
      medications: medications,
      createdAt: DateTime.now(),
      notes: notes,
    );
    await ref.set(prescription.toMap());

    await _db.collection('notifications').add({
      'userId': patientId,
      'title': 'New prescription',
      'body': 'Dr. $doctorName wrote a prescription for you',
      'createdAt': Timestamp.now(),
      'read': false,
      'type': AppNotificationType.prescription.name,
    });
  }
}
