import 'package:flutter/foundation.dart';

import '../core/constants/firestore_limits.dart';
import '../core/utils/async_request_cache.dart';
import '../core/utils/clinic_subscription.dart';
import '../core/utils/specialty_catalog_utils.dart';
import '../core/utils/subscription_manager.dart';
import '../models/clinic.dart';
import '../models/doctor.dart';
import '../models/localized_text.dart';
import '../models/provider_catalog_mode.dart';
import '../models/service_provider_type.dart';
import '../models/specialty.dart';
import 'backend/clinic_backend.dart';

/// Cached clinic catalog with lazy loading and paginated doctor fetch.
class ClinicDataService extends ChangeNotifier {
  ClinicDataService({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;
  final SubscriptionManager _subscriptions = SubscriptionManager();
  final Map<String, Doctor> _doctorCache = {};
  final AsyncRequestCache<String, Doctor?> _doctorFetchCache =
      AsyncRequestCache(ttl: FirestoreLimits.doctorCacheTtl);

  List<Specialty> _specialties = [];
  List<Clinic> _clinics = [];
  List<Doctor> _doctors = [];

  bool _catalogLoaded = false;
  Future<void>? _catalogLoadFuture;
  bool _doctorsLoading = false;
  bool _hasMoreDoctors = true;
  Object? _doctorsCursor;
  String? _doctorsSpecialtyFilter;
  String? _doctorsClinicFilter;
  ServiceProviderAccountType? _doctorsAccountTypeFilter;

  List<Specialty> get specialties => List.unmodifiable(_specialties);
  List<Clinic> get clinics => List.unmodifiable(_clinics);
  List<Doctor> get doctors => List.unmodifiable(_doctors);
  bool get isDoctorsLoading => _doctorsLoading;
  bool get hasMoreDoctors => _hasMoreDoctors;
  bool get isCatalogLoaded => _catalogLoaded;

  ClinicBackend get backend => _backend;

  /// Load specialties + clinics once (cached in backend for Firestore).
  Future<void> ensureCatalogLoaded() {
    if (_catalogLoaded) return Future.value();
    if (_catalogLoadFuture != null) return _catalogLoadFuture!;
    _catalogLoadFuture = _loadCatalog();
    return _catalogLoadFuture!;
  }

  Future<void> _loadCatalog() async {
    try {
      final results = await Future.wait([
        _backend.fetchSpecialties(),
        _backend.fetchClinics(),
      ]);
      _specialties = results[0] as List<Specialty>;
      _clinics = results[1] as List<Clinic>;
      await _backend.ensureProviderAccountCodes();
      _catalogLoaded = true;
      notifyListeners();
    } finally {
      _catalogLoadFuture = null;
    }
  }

  /// Paginated doctor list — no real-time listener (reduces Firestore reads).
  Future<void> loadDoctors({
    String? specialtyId,
    String? clinicId,
    ProviderCatalogMode? catalogMode,
    bool refresh = false,
  }) async {
    final accountType = catalogMode == null
        ? null
        : catalogMode == ProviderCatalogMode.businesses
            ? ServiceProviderAccountType.business
            : ServiceProviderAccountType.doctor;

    if (_doctorsLoading) return;
    if (refresh ||
        specialtyId != _doctorsSpecialtyFilter ||
        clinicId != _doctorsClinicFilter ||
        accountType != _doctorsAccountTypeFilter) {
      _doctors = [];
      _doctorsCursor = null;
      _hasMoreDoctors = true;
      _doctorsSpecialtyFilter = specialtyId;
      _doctorsClinicFilter = clinicId;
      _doctorsAccountTypeFilter = accountType;
    }
    if (!_hasMoreDoctors) return;

    _doctorsLoading = true;
    notifyListeners();
    try {
      await ensureCatalogLoaded();
      final page = await _backend.fetchDoctorsPage(
        specialtyId: specialtyId,
        clinicId: clinicId,
        accountType: accountType,
        limit: FirestoreLimits.doctorsPageSize,
        startAfterCursor: _doctorsCursor,
      );
      var loaded = page.doctors;
      if (catalogMode == ProviderCatalogMode.doctors) {
        loaded = loaded.where((d) => d.isDoctorAccount).toList();
      } else if (catalogMode == ProviderCatalogMode.businesses) {
        loaded = loaded.where((d) => d.isBusiness).toList();
      }
      for (final d in loaded) {
        _doctorCache[d.id] = d;
      }
      _doctors = [..._doctors, ...loaded];
      _doctorsCursor = page.nextCursor;
      _hasMoreDoctors = page.hasMore;
    } finally {
      _doctorsLoading = false;
      notifyListeners();
    }
  }

  /// Real-time updates for a single doctor profile (1 document listener).
  void watchDoctorProfile(String doctorId, void Function(Doctor?) onUpdate) {
    _subscriptions.replace(
      'doctor:$doctorId',
      _backend.watchDoctor(doctorId),
      (doctor) {
        if (doctor != null) {
          _doctorCache[doctor.id] = doctor;
          final index = _doctors.indexWhere((d) => d.id == doctor.id);
          if (index >= 0) {
            _doctors[index] = doctor;
          }
          _doctorFetchCache.invalidate(doctor.id);
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

  void putDoctorInCache(Doctor doctor) {
    _doctorCache[doctor.id] = doctor;
    final index = _doctors.indexWhere((d) => d.id == doctor.id);
    if (index >= 0) {
      _doctors[index] = doctor;
    }
    _doctorFetchCache.invalidate(doctor.id);
    notifyListeners();
  }

  Future<void> saveDoctor(Doctor doctor) async {
    await _backend.upsertDoctor(doctor);
    putDoctorInCache(doctor);
  }

  /// Fetch single doctor on demand (1 read) when not in cache — deduped.
  Future<Doctor?> fetchDoctorById(String id, {bool forceRefresh = false}) {
    if (!forceRefresh) {
      final cached = doctorById(id);
      if (cached != null) return Future.value(cached);
    } else {
      _doctorFetchCache.invalidate(id);
    }
    return _doctorFetchCache.run(
      id,
      () async {
        final loaded = await _backend.getDoctor(id);
        if (loaded != null) putDoctorInCache(loaded);
        return loaded;
      },
      forceRefresh: forceRefresh,
    );
  }

  Clinic? clinicById(String id) {
    try {
      return _clinics.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool clinicAllowsAppointments(String clinicId) {
    final clinic = clinicById(clinicId);
    if (clinic == null) return true;
    return ClinicSubscriptionHelper.allowsNewAppointments(clinic);
  }

  bool clinicAllowsQueue(String clinicId) => clinicAllowsAppointments(clinicId);

  /// Real-time clinic catalog for subscription dashboards and gates.
  void startRealtimeCatalog() {
    if (_realtimeStarted) return;
    _realtimeStarted = true;
    _subscriptions.replace(
      'clinics',
      _backend.watchClinics(),
      (list) {
        _clinics = list;
        _catalogLoaded = true;
        notifyListeners();
      },
    );
  }

  bool _realtimeStarted = false;

  List<Doctor> doctorsForClinic(String clinicId) =>
      _doctors.where((d) => d.clinicId == clinicId).toList();

  /// Default clinic for new provider accounts when none is chosen at signup.
  String? get defaultClinicId =>
      _clinics.isNotEmpty ? _clinics.first.id : null;

  /// Reload specialty catalog after admin creates a new business type / specialty.
  Future<void> reloadSpecialties() async {
    _specialties = await _backend.fetchSpecialties();
    notifyListeners();
  }

  /// Find an existing localized type or persist a new one (deduplicated).
  Future<Specialty> findOrCreateSpecialty({
    required LocalizedText name,
    required bool forBusiness,
  }) async {
    await ensureCatalogLoaded();

    final duplicate = SpecialtyCatalogUtils.findDuplicate(
      _specialties,
      name,
      forBusiness: forBusiness,
    );
    if (duplicate != null) return duplicate;

    final specialty = Specialty(
      id: SpecialtyCatalogUtils.uniqueId(
        _specialties,
        name,
        forBusiness: forBusiness,
      ),
      name: name,
      iconName: forBusiness ? 'storefront' : 'medical',
      isBusinessType: forBusiness,
    );
    await _backend.upsertSpecialty(specialty);
    _specialties = [..._specialties, specialty];
    notifyListeners();
    return specialty;
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();
    _doctorFetchCache.clear();
    super.dispose();
  }
}
