import 'package:flutter/foundation.dart';

import '../core/constants/firestore_limits.dart';
import '../core/utils/async_request_cache.dart';
import '../core/utils/business_type_catalog.dart';
import '../core/utils/clinic_subscription.dart';
import '../core/utils/localized_name_utils.dart';
import '../core/utils/specialty_catalog_utils.dart';
import '../core/utils/subscription_manager.dart';
import '../models/account_status.dart';
import '../models/clinic.dart';
import '../models/doctor.dart';
import '../models/localized_text.dart';
import '../models/provider_catalog_mode.dart';
import '../models/service_provider_type.dart';
import '../models/specialty.dart';
import '../models/user_account.dart';
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
  Map<String, AccountStatus> _providerLoginStatus = {};

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

  List<Specialty> get businessTypes =>
      BusinessTypeCatalog.allBusinessTypes(_specialties);

  List<Specialty> get activeBusinessTypes =>
      BusinessTypeCatalog.activeBusinessTypes(_specialties);

  List<Specialty> get doctorSpecialties =>
      BusinessTypeCatalog.doctorSpecialties(_specialties);

  List<Specialty> get patientVisibleBusinessTypes =>
      BusinessTypeCatalog.patientVisibleBusinessTypes(
        catalog: _specialties,
        providers: _doctors,
        loginStatusByDoctorId: _providerLoginStatus,
      );

  List<Specialty> get patientVisibleDoctorSpecialties =>
      BusinessTypeCatalog.patientVisibleDoctorSpecialties(
        catalog: _specialties,
        providers: _doctors,
        loginStatusByDoctorId: _providerLoginStatus,
      );

  Specialty? specialtyById(String id) =>
      BusinessTypeCatalog.byId(_specialties, id);

  /// Resolves the latest catalog specialty/clinic onto a provider snapshot.
  Doctor hydrateProvider(Doctor doctor) {
    final specialty = specialtyById(doctor.specialtyId) ?? doctor.specialty;
    final clinic = clinicById(doctor.clinicId) ?? doctor.clinic;
    if (specialty == doctor.specialty && clinic == doctor.clinic) {
      return doctor;
    }
    return doctor.copyWith(specialty: specialty, clinic: clinic);
  }

  void _rehydrateProvidersForSpecialty(String specialtyId) {
    _doctors = _doctors
        .map(
          (d) => d.specialtyId == specialtyId ? hydrateProvider(d) : d,
        )
        .toList();
    for (final entry in _doctorCache.entries.toList()) {
      if (entry.value.specialtyId == specialtyId) {
        _doctorCache[entry.key] = hydrateProvider(entry.value);
      }
    }
  }

  void _rehydrateAllProviders() {
    _doctors = _doctors.map(hydrateProvider).toList();
    _doctorCache.updateAll((_, doctor) => hydrateProvider(doctor));
  }

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
      await refreshProviderLoginIndex();
      if (_doctors.isNotEmpty) {
        _rehydrateAllProviders();
      }
      _catalogLoaded = true;
      notifyListeners();
    } finally {
      _catalogLoadFuture = null;
    }
  }

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
      await refreshProviderLoginIndex();
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
        _doctorCache[d.id] = hydrateProvider(d);
      }
      _doctors = [..._doctors, ...loaded.map(hydrateProvider)];
      _doctorsCursor = page.nextCursor;
      _hasMoreDoctors = page.hasMore;
    } finally {
      _doctorsLoading = false;
      notifyListeners();
    }
  }

  /// Load every provider page — used to compute patient-visible business types.
  Future<void> ensureFullProviderCatalog(ProviderCatalogMode mode) async {
    await loadDoctors(catalogMode: mode, refresh: true);
    while (_hasMoreDoctors) {
      await loadDoctors(catalogMode: mode);
    }
    await refreshProviderLoginIndex();
  }

  /// Real-time updates for a single doctor profile (1 document listener).
  void watchDoctorProfile(String doctorId, void Function(Doctor?) onUpdate) {
    _subscriptions.replace(
      'doctor:$doctorId',
      _backend.watchDoctor(doctorId),
      (doctor) {
        if (doctor != null) {
          final hydrated = hydrateProvider(doctor);
          _doctorCache[hydrated.id] = hydrated;
          final index = _doctors.indexWhere((d) => d.id == hydrated.id);
          if (index >= 0) {
            _doctors[index] = hydrated;
          }
          _doctorFetchCache.invalidate(hydrated.id);
          onUpdate(hydrated);
        } else {
          onUpdate(null);
        }
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
    Doctor? doctor;
    if (_doctorCache.containsKey(id)) {
      doctor = _doctorCache[id];
    } else {
      try {
        doctor = _doctors.firstWhere((d) => d.id == id);
      } catch (_) {
        return null;
      }
    }
    return doctor == null ? null : hydrateProvider(doctor);
  }

  void putDoctorInCache(Doctor doctor) {
    final hydrated = hydrateProvider(doctor);
    _doctorCache[hydrated.id] = hydrated;
    final index = _doctors.indexWhere((d) => d.id == hydrated.id);
    if (index >= 0) {
      _doctors[index] = hydrated;
    }
    _doctorFetchCache.invalidate(hydrated.id);
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

  /// Real-time clinic + specialty catalog for dashboards and patient browse.
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
    _subscriptions.replace(
      'specialties',
      _backend.watchSpecialties(),
      (list) {
        _specialties = list;
        _catalogLoaded = true;
        _rehydrateAllProviders();
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

  /// Reload specialty catalog after admin creates or edits a business type.
  Future<void> reloadSpecialties() async {
    _specialties = await _backend.fetchSpecialties();
    _rehydrateAllProviders();
    notifyListeners();
  }

  /// Index provider login accounts for patient catalog visibility.
  Future<void> refreshProviderLoginIndex() async {
    final staff = await _backend.fetchStaff();
    syncProviderLoginIndex(staff);
  }

  void syncProviderLoginIndex(Iterable<UserAccount> staff) {
    _providerLoginStatus = {
      for (final account in staff)
        if (account.doctorId != null && account.doctorId!.isNotEmpty)
          account.doctorId!: account.accountStatus,
    };
    notifyListeners();
  }

  bool isCatalogVisibleProvider(Doctor provider) =>
      BusinessTypeCatalog.isProviderAccountActive(
        provider,
        _providerLoginStatus,
      );

  /// Providers visible in the patient catalog (active login + optional filters).
  List<Doctor> patientCatalogProviders({
    ProviderCatalogMode? catalogMode,
    String? businessTypeId,
    String? specialtyId,
  }) {
    var list = _doctors.where(isCatalogVisibleProvider);
    if (catalogMode == ProviderCatalogMode.doctors) {
      list = list.where((d) => d.isDoctorAccount);
      if (specialtyId != null) {
        list = list.where((d) => d.specialtyId == specialtyId);
      }
    } else if (catalogMode == ProviderCatalogMode.businesses) {
      list = list.where((d) => d.isBusiness);
      if (businessTypeId != null) {
        list = list.where((d) => d.specialtyId == businessTypeId);
      }
    }
    return list.toList();
  }

  Future<void> saveSpecialty(Specialty specialty) async {
    await _backend.upsertSpecialty(specialty);
    final index = _specialties.indexWhere((s) => s.id == specialty.id);
    if (index >= 0) {
      _specialties = [..._specialties]..[index] = specialty;
    } else {
      _specialties = [..._specialties, specialty];
    }
    _rehydrateProvidersForSpecialty(specialty.id);
    notifyListeners();
  }

  Future<void> deleteSpecialty(String id) async {
    await _backend.deleteSpecialty(id);
    _specialties = _specialties.where((s) => s.id != id).toList();
    notifyListeners();
  }

  /// Find an existing localized type or persist a new one (deduplicated).
  Future<Specialty> findOrCreateSpecialty({
    required LocalizedText name,
    required bool forBusiness,
    bool isActive = true,
  }) async {
    await ensureCatalogLoaded();

    if (forBusiness && !LocalizedNameUtils.isComplete(name)) {
      throw ArgumentError('Business types require Kurdish, Arabic, and English names');
    }

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
      isActive: isActive,
    );
    await saveSpecialty(specialty);
    return specialty;
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();
    _doctorFetchCache.clear();
    super.dispose();
  }
}
