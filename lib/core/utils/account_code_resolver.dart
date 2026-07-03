import '../../models/doctor.dart';
import '../../models/user_account.dart';
import '../../services/clinic_data_service.dart';
import 'account_code.dart';

/// Resolves inherited provider account codes for staff accounts.
abstract final class AccountCodeResolver {
  AccountCodeResolver._();

  static String? forDoctor(Doctor? doctor) {
    final code = doctor?.accountCode;
    if (!AccountCode.isAssigned(code)) return null;
    return AccountCode.normalize(code);
  }

  static String? forDoctorId(String? doctorId, ClinicDataService data) {
    if (doctorId == null || doctorId.isEmpty) return null;
    return forDoctor(data.doctorById(doctorId));
  }

  /// Secretaries inherit the linked doctor's code — never their own.
  static String? forSecretary(
    UserAccount account,
    ClinicDataService data,
  ) {
    if (account.role != UserRole.secretary) return null;
    return forDoctorId(account.linkedDoctorId, data);
  }

  static String? forClinicalUser(
    UserAccount? account,
    ClinicDataService data,
  ) {
    if (account == null) return null;
    if (account.role == UserRole.secretary) {
      return forSecretary(account, data);
    }
    if (account.role == UserRole.doctor && account.doctorId != null) {
      return forDoctorId(account.doctorId, data);
    }
    return null;
  }
}
