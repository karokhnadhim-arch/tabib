import 'package:flutter/foundation.dart';

import '../core/constants/firestore_limits.dart';
import '../core/utils/subscription_manager.dart';
import '../models/clinic.dart';
import '../models/doctor.dart';
import '../models/specialty.dart';
import 'backend/clinic_backend.dart';

/// Cached clinic catalog with lazy loading and paginated doctor fetch.
class ClinicDataService extends ChangeNotifier {
  ClinicDataService({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;
  final SubscriptionManager _subscriptions = SubscriptionManager();
  final Map<String, Doctor> _doctorCache = {};

  List<Specialty> _specialties = [];
  List<Clinic> _clinics = [];
  List<Doctor> _doctors = [];

  bool _catalogLoaded = false;
  bool _catalogLoading = false;
  bool _doctorsLoading = false;
  bool _hasMoreDoctors = true;
  Object? _doctorsCursor;
  String? _doctorsSpecialtyFilter;
  String? _doctorsClinicFilter;

  List<Specialty> get specialties => List.unmodifiable(_specialties);
  List<Clinic> get clinics => List.unmodifiable(_clinics);
  List<Doctor> get doctors => List.unmodifiable(_doctors);
  bool get isDoctorsLoading => _doctorsLoading;
  bool get hasMoreDoctors => _hasMoreDoctors;

  ClinicBackend get backend => _backend;

  /// Load specialties + clinics once (cached in backend for Firestore).
  Future<void> ensureCatalogLoaded() async {
    if (_catalogLoaded || _catalogLoading) return;
    _catalogLoading = true;
    try {
      final results = await Future.wait([
        _backend.fetchSpecialties(),
        _backend.fetchClinics(),
      ]);
      _specialties = results[0] as List<Specialty>;
      _clinics = results[1] as List<Clinic>;
      _catalogLoaded = true;
      notifyListeners();
    } finally {
      _catalogLoading = false;
    }
  }

  /// Paginated doctor list — no real-time listener (reduces Firestore reads).
  Future<void> loadDoctors({
    String? specialtyId,
    String? clinicId,
    bool refresh = false,
  }) async {
    if (_doctorsLoading) return;
    if (refresh ||
        specialtyId != _doctorsSpecialtyFilter ||
        clinicId != _doctorsClinicFilter) {
      _doctors = [];
      _doctorsCursor = null;
      _hasMoreDoctors = true;
      _doctorsSpecialtyFilter = specialtyId;
      _doctorsClinicFilter = clinicId;
    }
    if (!_hasMoreDoctors) return;

    _doctorsLoading = true;
    notifyListeners();
    try {
      await ensureCatalogLoaded();
      final page = await _backend.fetchDoctorsPage(
        specialtyId: specialtyId,
        clinicId: clinicId,
        limit: FirestoreLimits.doctorsPageSize,
        startAfterCursor: _doctorsCursor,
      );
      for (final d in page.doctors) {
        _doctorCache[d.id] = d;
      }
      _doctors = [..._doctors, ...page.doctors];
      _doctorsCursor = page.nextCursor;
      _hasMoreDoctors = page.hasMore;
    } finally {
      _doctorsLoading = false;
      notifyListeners();
    }
  }

  /// Real-time doctor updates only when editing own profile (single document).
  void watchDoctorProfile(String doctorId, void Function(Doctor?) onUpdate) {
    _subscriptions.replace(
      'doctor:$doctorId',
      _backend.watchDoctors().map(
            (list) => list.where((d) => d.id == doctorId).firstOrNull,
          ),
      (doctor) {
        if (doctor != null) {
          _doctorCache[doctor.id] = doctor;
          final index = _doctors.indexWhere((d) => d.id == doctor.id);
          if (index >= 0) {
            _doctors[index] = doctor;
          }
        }
        onUpdate(doctor);
        notifyListeners();
      },
    );
  }

  void stopWatchingDoctorProfile(String doctorId) {
    _subscriptions.cancel('doctor:$doctorId');
  }

  List<Doctor> doctorsBySpecialty(String specialtyId) =>
      _doctors.where((d) => d.specialtyId == specialtyId).toList();

  Doctor? doctorById(String id) {
    if (_doctorCache.containsKey(id)) return _doctorCache[id];
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Fetch single doctor on demand (1 read) when not in cache.
  Future<Doctor?> fetchDoctorById(String id) async {
    final cached = doctorById(id);
    if (cached != null) return cached;
    final loaded = await _backend.getDoctor(id);
    if (loaded != null) _doctorCache[id] = loaded;
    return loaded;
  }

  Clinic? clinicById(String id) {
    try {
      return _clinics.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
  }
}
