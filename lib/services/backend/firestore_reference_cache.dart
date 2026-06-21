import '../../models/clinic.dart';
import '../../models/specialty.dart';

/// In-memory cache for small reference collections (clinics, specialties).
/// Avoids re-fetching entire collections on every doctor query.
class FirestoreReferenceCache {
  Map<String, Clinic> _clinics = {};
  Map<String, Specialty> _specialties = {};
  DateTime? _clinicsLoadedAt;
  DateTime? _specialtiesLoadedAt;

  static const _ttl = Duration(minutes: 10);

  Map<String, Clinic> get clinics => _clinics;
  Map<String, Specialty> get specialties => _specialties;

  bool get hasFreshClinics =>
      _clinicsLoadedAt != null &&
      DateTime.now().difference(_clinicsLoadedAt!) < _ttl;

  bool get hasFreshSpecialties =>
      _specialtiesLoadedAt != null &&
      DateTime.now().difference(_specialtiesLoadedAt!) < _ttl;

  void setClinics(Map<String, Clinic> clinics) {
    _clinics = clinics;
    _clinicsLoadedAt = DateTime.now();
  }

  void setSpecialties(Map<String, Specialty> specialties) {
    _specialties = specialties;
    _specialtiesLoadedAt = DateTime.now();
  }

  void upsertClinic(Clinic clinic) => _clinics[clinic.id] = clinic;
  void upsertSpecialty(Specialty specialty) =>
      _specialties[specialty.id] = specialty;

  void clear() {
    _clinics = {};
    _specialties = {};
    _clinicsLoadedAt = null;
    _specialtiesLoadedAt = null;
  }
}
