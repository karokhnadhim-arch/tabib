import '../../models/clinic.dart';
import '../../models/doctor.dart';
import '../../models/doctor_page.dart';
import '../../models/queue_entry.dart';
import '../../models/service_provider_type.dart';
import '../../models/specialty.dart';
import '../../models/user_account.dart';

/// Abstract backend for clinic data — implemented by Firestore.
abstract class ClinicBackend {
  Stream<List<Specialty>> watchSpecialties();
  Stream<List<Clinic>> watchClinics();
  Stream<List<Doctor>> watchDoctors({String? specialtyId, String? clinicId});

  /// One-time fetch — prefer over watch for static catalog data.
  Future<List<Specialty>> fetchSpecialties();
  Future<List<Clinic>> fetchClinics();
  Future<DoctorPage> fetchDoctorsPage({
    String? specialtyId,
    String? clinicId,
    ServiceProviderAccountType? accountType,
    int limit = 24,
    Object? startAfterCursor,
  });
  Stream<List<QueueEntry>> watchQueue(String doctorId);
  Stream<List<QueueEntry>> watchSecretaryQueue(String doctorId);
  Stream<QueueEntry?> watchPatientActiveQueue(String patientId);

  Future<Doctor?> getDoctor(String doctorId);
  Future<Clinic?> getClinic(String clinicId);

  /// One-shot staff fetch — prefer over [watchStaff].first for uniqueness checks.
  Future<List<UserAccount>> fetchStaff();

  /// Secretaries assigned to exactly one doctor (scoped query).
  Future<List<UserAccount>> fetchSecretariesForDoctor(String doctorId);

  /// Real-time updates for a single doctor document (1 read stream).
  Stream<Doctor?> watchDoctor(String doctorId);

  Future<QueueEntry?> bookQueue({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String queueDate,
    required String slotStart,
    required String slotEnd,
  });

  Future<void> cancelEntry(String entryId, String doctorId);
  Future<void> moveUp(String entryId, String doctorId);
  Future<void> moveDown(String entryId, String doctorId);
  Future<void> callNext(String doctorId);
  Future<void> completeCurrent(String doctorId);
  Future<void> updateEntryStatus(
    String entryId,
    String doctorId,
    QueueStatus status,
  );
  Future<void> enterDoctorRoom(String entryId, String doctorId);
  Future<void> sendToExamination(String entryId, String doctorId);
  Future<void> returnToReview(String entryId, String doctorId);

  Future<void> upsertSpecialty(Specialty specialty);
  Future<void> deleteSpecialty(String id);
  Future<void> upsertClinic(Clinic clinic);
  Future<void> deleteClinic(String id);
  Future<void> upsertDoctor(Doctor doctor);
  Future<void> deleteDoctor(String id);
  Future<void> upsertStaff(UserAccount account, {String? password, String? authEmail});
  Future<void> deleteStaff(String id);
  Stream<List<UserAccount>> watchStaff();
  Future<UserAccount?> lookupStaffCredentials(
    String identifier,
    String password,
  );

  Future<void> seedDemoData();
}
