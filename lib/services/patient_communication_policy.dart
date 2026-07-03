import '../models/admin_capability.dart';
import '../models/user_account.dart';
import 'auth_service.dart';

/// Access control for patient-facing communications.
abstract final class PatientCommunicationPolicy {
  PatientCommunicationPolicy._();

  static bool canSendToPatient(AuthService auth, {String? doctorId}) {
    final user = auth.currentUser;
    if (user == null) return false;
    if (user.isSystemOwner) return true;
    if (user.role == UserRole.admin &&
        auth.hasCapability(AdminCapability.sendNotifications)) {
      return true;
    }
    if (user.role == UserRole.doctor) {
      if (doctorId == null) return true;
      return user.doctorId == doctorId || user.id == doctorId;
    }
    if (user.role == UserRole.secretary) {
      if (doctorId == null) return user.linkedDoctorId != null;
      return user.linkedDoctorId == doctorId;
    }
    return false;
  }

  static bool canViewPatientCommunications(
    AuthService auth, {
    required String patientUserId,
    String? doctorId,
  }) {
    if (auth.patientId == patientUserId) return true;
    return canSendToPatient(auth, doctorId: doctorId);
  }
}
