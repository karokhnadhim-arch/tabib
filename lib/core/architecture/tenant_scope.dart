import '../../models/user_account.dart';

/// Tenant identifiers for clinic-isolated data paths.
///
/// Designed for future expansion: payments, video consults, branches, analytics.
abstract final class TenantScope {
  static const String clinicsCollection = 'clinics';
  static const String doctorsCollection = 'doctors';
  static const String queueCollection = 'queue_entries';
  static const String appointmentsCollection = 'appointments';
  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';
  static const String prescriptionsCollection = 'prescriptions';
  static const String chatCollection = 'chat_messages';

  /// Clinic partition key — every doctor/secretary belongs to one clinic.
  static String clinicIdFor(UserAccount account) =>
      account.clinicId ?? '';

  /// Doctor partition key — secretaries are scoped to exactly one doctor.
  static String? doctorIdFor(UserAccount account) => switch (account.role) {
        UserRole.doctor => account.doctorId,
        UserRole.secretary => account.linkedDoctorId,
        _ => null,
      };

  /// Future: branch within a clinic (multi-branch support).
  static String? branchIdFor(UserAccount account) =>
      null; // reserved — add account.branchId when needed
}
