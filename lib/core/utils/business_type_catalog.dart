import '../../models/account_status.dart';
import '../../models/doctor.dart';
import '../../models/specialty.dart';
import 'specialty_catalog_utils.dart';

/// Centralized business-type catalog rules for admin and patient surfaces.
abstract final class BusinessTypeCatalog {
  BusinessTypeCatalog._();

  static List<Specialty> allBusinessTypes(List<Specialty> catalog) =>
      SpecialtyCatalogUtils.forAccountType(catalog, true);

  static List<Specialty> activeBusinessTypes(List<Specialty> catalog) =>
      allBusinessTypes(catalog).where((s) => s.isActive).toList();

  static List<Specialty> doctorSpecialties(List<Specialty> catalog) =>
      SpecialtyCatalogUtils.forAccountType(catalog, false);

  static List<Specialty> activeDoctorSpecialties(List<Specialty> catalog) =>
      doctorSpecialties(catalog).where((s) => s.isActive).toList();

  static bool isProviderAccountActive(
    Doctor provider,
    Map<String, AccountStatus> loginStatusByDoctorId,
  ) {
    final status = loginStatusByDoctorId[provider.id];
    if (status == null) return true;
    return status.isActive;
  }

  static Set<String> specialtyIdsInUse({
    required Iterable<Doctor> providers,
    required Map<String, AccountStatus> loginStatusByDoctorId,
    required bool businessesOnly,
  }) {
    return providers
        .where((d) {
          if (!isProviderAccountActive(d, loginStatusByDoctorId)) return false;
          return businessesOnly ? d.isBusiness : d.isDoctorAccount;
        })
        .map((d) => d.specialtyId)
        .toSet();
  }

  /// Active business types with at least one active business account assigned.
  static List<Specialty> patientVisibleBusinessTypes({
    required List<Specialty> catalog,
    required Iterable<Doctor> providers,
    required Map<String, AccountStatus> loginStatusByDoctorId,
  }) {
    final inUse = specialtyIdsInUse(
      providers: providers,
      loginStatusByDoctorId: loginStatusByDoctorId,
      businessesOnly: true,
    );
    return activeBusinessTypes(catalog)
        .where((type) => inUse.contains(type.id))
        .toList();
  }

  /// Active doctor specialties with at least one active doctor assigned.
  static List<Specialty> patientVisibleDoctorSpecialties({
    required List<Specialty> catalog,
    required Iterable<Doctor> providers,
    required Map<String, AccountStatus> loginStatusByDoctorId,
  }) {
    final inUse = specialtyIdsInUse(
      providers: providers,
      loginStatusByDoctorId: loginStatusByDoctorId,
      businessesOnly: false,
    );
    return activeDoctorSpecialties(catalog)
        .where((s) => inUse.contains(s.id))
        .toList();
  }

  static Specialty? byId(List<Specialty> catalog, String id) {
    for (final item in catalog) {
      if (item.id == id) return item;
    }
    return null;
  }
}
