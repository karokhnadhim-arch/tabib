import '../../models/user_account.dart';

/// Client-side data access rules — mirror [firestore.rules] for UI gating.
abstract final class DataAccessPolicy {
  static bool isSystemOwner(UserAccount? user) =>
      user?.isSystemOwner == true;

  static bool canAccessAdminPanel(UserAccount? user) => isSystemOwner(user);

  static bool canAccessDoctorData(UserAccount? user, String doctorId) {
    if (user == null || doctorId.isEmpty) return false;
    if (isSystemOwner(user)) return true;
    if (user.role == UserRole.doctor && user.doctorId == doctorId) {
      return true;
    }
    if (user.role == UserRole.secretary &&
        user.linkedDoctorId == doctorId) {
      return true;
    }
    return false;
  }

  static bool canAccessClinicData(UserAccount? user, String clinicId) {
    if (user == null || clinicId.isEmpty) return false;
    if (isSystemOwner(user)) return true;
    if (user.clinicId == clinicId) return true;
    return false;
  }

  static bool canAccessPatientQueue(
    UserAccount? user,
    String patientId,
    String doctorId,
  ) {
    if (user == null) return false;
    if (isSystemOwner(user)) return true;
    if (user.role == UserRole.patient && user.id == patientId) return true;
    return canAccessDoctorData(user, doctorId);
  }

  static bool canManageSecretariesForDoctor(
    UserAccount? user,
    String doctorId,
  ) =>
      isSystemOwner(user);

  static String? doctorScopeFor(UserAccount? user) {
    if (user == null) return null;
    if (user.role == UserRole.doctor) return user.doctorId;
    if (user.role == UserRole.secretary) return user.linkedDoctorId;
    return null;
  }

  static String? clinicScopeFor(UserAccount? user) => user?.clinicId;
}
