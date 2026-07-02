import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../models/user_account.dart';
import '../../utils/provider_labels.dart';

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
    AppLocalizations l10n,
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
      ...ProviderLabels.searchableCategoryTerms(l10n, doctor),
      localize(doctor.clinic.name.ku),
      localize(doctor.clinic.name.ar),
      localize(doctor.clinic.name.en),
      emailFor(doctor, staff) ?? '',
      phoneFor(doctor, staff) ?? '',
    ];
    appendSecretarySearchFields(fields, doctor.id, staff, localize);
    return fields.any((f) => f.toLowerCase().contains(q));
  }

  static void appendSecretarySearchFields(
    List<String> fields,
    String doctorId,
    List<UserAccount> staff,
    String Function(String) localize,
  ) {
    for (final secretary in secretariesFor(doctorId, staff)) {
      fields.addAll([
        localize(secretary.name.ku),
        localize(secretary.name.ar),
        localize(secretary.name.en),
        secretary.email ?? '',
        secretary.phone ?? '',
      ]);
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
