import '../../models/doctor.dart';
import '../../models/queue_entry.dart';
import '../../models/specialty.dart';
import '../../domain/repositories/repositories.dart';
import '../../services/backend/clinic_backend.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;

  @override
  Stream<List<Specialty>> watchSpecialties() => _backend.watchSpecialties();

  @override
  Stream<List<Doctor>> watchDoctors({String? specialtyId}) =>
      _backend.watchDoctors(specialtyId: specialtyId);

  @override
  Future<Doctor?> getDoctor(String doctorId) => _backend.getDoctor(doctorId);
}

class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;

  @override
  Stream<List<QueueEntry>> watchDoctorQueue(String doctorId) =>
      _backend.watchQueue(doctorId);

  @override
  Stream<QueueEntry?> watchPatientActiveQueue(String patientId) =>
      _backend.watchPatientActiveQueue(patientId);

  @override
  Future<QueueEntry?> bookQueue({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String queueDate,
    required String slotStart,
    required String slotEnd,
  }) =>
      _backend.bookQueue(
        doctorId: doctorId,
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        queueDate: queueDate,
        slotStart: slotStart,
        slotEnd: slotEnd,
      );
}
