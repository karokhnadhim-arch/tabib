import '../../models/appointment.dart';
import '../../models/chat_message.dart';
import '../../models/visit_status.dart';
import '../../models/doctor.dart';
import '../../models/notification.dart';
import '../../models/prescription.dart';
import '../../models/queue_entry.dart';
import '../../models/specialty.dart';
import '../../models/user_account.dart';

abstract class AuthRepository {
  UserAccount? get currentUser;
  bool get isLoggedIn;
  bool get isPatient;
  bool get isDoctor;
  bool get isSecretary;
  String get patientId;

  Future<String?> loginPatient({required String name, required String phone});
  Future<String?> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  Future<String?> loginStaff({
    required String identifier,
    required String password,
  });
  Future<void> logout();
  Future<void> seedDemoData();
}

abstract class DoctorRepository {
  Stream<List<Specialty>> watchSpecialties();
  Stream<List<Doctor>> watchDoctors({String? specialtyId});
  Future<Doctor?> getDoctor(String doctorId);
}

abstract class AppointmentRepository {
  Stream<List<Appointment>> watchPatientAppointments(String patientId);
  Stream<List<Appointment>> watchDoctorAppointments(String doctorId);
  Stream<List<Appointment>> watchClinicAppointments(String clinicId);
  Stream<List<Appointment>> watchDailySchedule(String clinicId, DateTime date);

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
  });

  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status);
  Future<void> updateVisitStatus(String appointmentId, VisitStatus visitStatus);
  Future<void> rescheduleAppointment(String appointmentId, DateTime dateTime);
  Future<void> moveAppointment(String appointmentId, int direction);
  Future<void> cancelAppointment(String appointmentId);
}

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchConversation({
    required String clinicId,
    required String patientId,
  });

  Future<void> sendMessage({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  });

  Future<void> markConversationRead({
    required String clinicId,
    required String patientId,
    required String readerRole,
  });
}

abstract class PrescriptionRepository {
  Stream<List<Prescription>> watchPatientPrescriptions(String patientId);
  Stream<List<Prescription>> watchDoctorPrescriptions(String doctorId);

  Future<void> writePrescription({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String diagnosis,
    required String medications,
    String? notes,
  });
}

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
  });
}

abstract class QueueRepository {
  Stream<List<QueueEntry>> watchDoctorQueue(String doctorId);
  Stream<QueueEntry?> watchPatientActiveQueue(String patientId);
  Future<QueueEntry?> bookQueue({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
  });
}
