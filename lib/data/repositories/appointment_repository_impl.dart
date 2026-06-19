import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/appointment.dart';
import '../../models/visit_status.dart';
import '../../models/notification.dart';
import '../../domain/repositories/repositories.dart';

class FirestoreAppointmentRepository implements AppointmentRepository {
  FirestoreAppointmentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const _collection = 'appointments';

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection(_collection);

  @override
  Stream<List<Appointment>> watchPatientAppointments(String patientId) {
    return _appointments
        .where('patientId', isEqualTo: patientId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<Appointment>> watchDoctorAppointments(String doctorId) {
    return _appointments
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('dateTime')
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<Appointment>> watchClinicAppointments(String clinicId) {
    return _appointments
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('dateTime')
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<Appointment>> watchDailySchedule(String clinicId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _appointments
        .where('clinicId', isEqualTo: clinicId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dateTime', isLessThan: Timestamp.fromDate(end))
        .orderBy('dateTime')
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Future<String?> bookAppointment({
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String doctorId,
    required String doctorName,
    required String specialty,
    required String clinicName,
    required String clinicId,
    required DateTime dateTime,
    String? notes,
  }) async {
    try {
      final ref = _appointments.doc();
      final appointment = Appointment(
        id: ref.id,
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        doctorId: doctorId,
        doctorName: doctorName,
        specialty: specialty,
        clinicName: clinicName,
        clinicId: clinicId,
        dateTime: dateTime,
        status: AppointmentStatus.pending,
        notes: notes,
      );
      await ref.set(appointment.toMap());

      await _db.collection('notifications').add({
        'userId': doctorId,
        'title': 'New appointment request',
        'body': '$patientName requested an appointment',
        'createdAt': Timestamp.now(),
        'read': false,
        'type': AppNotificationType.appointment.name,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    await _appointments.doc(appointmentId).update({'status': status.name});
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }

  @override
  Future<void> updateVisitStatus(
    String appointmentId,
    VisitStatus visitStatus,
  ) async {
    await _appointments
        .doc(appointmentId)
        .update({'visitStatus': visitStatus.name});
  }

  @override
  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime dateTime,
  ) async {
    await _appointments.doc(appointmentId).update({
      'dateTime': Timestamp.fromDate(dateTime),
    });
  }

  @override
  Future<void> moveAppointment(String appointmentId, int direction) async {
    final doc = await _appointments.doc(appointmentId).get();
    if (!doc.exists) return;
    final current = Appointment.fromFirestore(doc.id, doc.data()!);
    final start = DateTime(
      current.dateTime.year,
      current.dateTime.month,
      current.dateTime.day,
    );
    final end = start.add(const Duration(days: 1));
    final snap = await _appointments
        .where('clinicId', isEqualTo: current.clinicId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dateTime', isLessThan: Timestamp.fromDate(end))
        .orderBy('dateTime')
        .get();
    final list = snap.docs
        .map((d) => Appointment.fromFirestore(d.id, d.data()))
        .toList();
    final index = list.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= list.length) return;
    final other = list[newIndex];
    final batch = _db.batch();
    batch.update(_appointments.doc(appointmentId), {
      'dateTime': Timestamp.fromDate(other.dateTime),
    });
    batch.update(_appointments.doc(other.id), {
      'dateTime': Timestamp.fromDate(current.dateTime),
    });
    await batch.commit();
  }

  List<Appointment> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => Appointment.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
