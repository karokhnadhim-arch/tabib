import '../../models/doctor.dart';
import '../../models/user_account.dart';

/// Resolves staff accounts and secretaries for admin doctor management.
class AdminDoctorStaffResolver {
  AdminDoctorStaffResolver._();

  static UserAccount? staffAccountFor(
    Doctor doctor,
    List<UserAccount> staff,
  ) {
    return staff
        .where(
          (s) =>
              s.doctorId == doctor.id &&
              (s.role == UserRole.doctor || s.role == UserRole.admin),
        )
        .firstOrNull;
  }

  static String? emailFor(Doctor doctor, List<UserAccount> staff) {
    final contact = doctor.contactEmail?.trim();
    if (contact != null && contact.isNotEmpty) return contact;
    final account = staffAccountFor(doctor, staff);
    final email = account?.email?.trim();
    return email != null && email.isNotEmpty ? email : null;
  }

  static String? phoneFor(Doctor doctor, List<UserAccount> staff) {
    final contact = doctor.contactPhone?.trim();
    if (contact != null && contact.isNotEmpty) return contact;
    final account = staffAccountFor(doctor, staff);
    final phone = account?.phone?.trim();
    return phone != null && phone.isNotEmpty ? phone : null;
  }

  static List<UserAccount> secretariesFor(
    String doctorId,
    List<UserAccount> staff,
  ) {
    return staff
        .where(
          (s) =>
              s.role == UserRole.secretary && s.linkedDoctorId == doctorId,
        )
        .toList();
  }

  static int secretaryCount(String doctorId, List<UserAccount> staff) =>
      secretariesFor(doctorId, staff).length;

  static bool matchesSearch(
    Doctor doctor,
    List<UserAccount> staff,
    String query,
    String Function(String) localize,
  ) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    final fields = <String>[
      localize(doctor.name.ku),
      localize(doctor.name.ar),
      localize(doctor.name.en),
      localize(doctor.specialty.name.ku),
      localize(doctor.specialty.name.ar),
      localize(doctor.specialty.name.en),
      localize(doctor.clinic.name.ku),
      localize(doctor.clinic.name.ar),
      localize(doctor.clinic.name.en),
      emailFor(doctor, staff) ?? '',
      phoneFor(doctor, staff) ?? '',
    ];
    return fields.any((f) => f.toLowerCase().contains(q));
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
