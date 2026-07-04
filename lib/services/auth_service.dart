import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/account_status.dart';
import '../core/utils/account_code.dart';
import '../models/admin_capability.dart';
import '../models/localized_text.dart';
import '../models/doctor.dart';
import '../models/service_provider_type.dart';
import '../models/clinic.dart';
import '../models/user_account.dart';
import '../core/config/super_owner_config.dart';
import '../core/config/system_owner_config.dart';
import '../core/auth/permission_policy.dart';
import '../core/utils/clinic_subscription.dart';
import '../core/utils/staff_auth_identifiers.dart';
import '../utils/account_access.dart';
import '../firebase_options.dart';
import 'backend/clinic_backend.dart';
import 'firebase_auth_service.dart';
import 'firebase_bootstrap.dart';

class AuthService extends ChangeNotifier {
  AuthService({
    required ClinicBackend backend,
    bool demoMode = false,
    FirebaseAuthService? firebaseAuth,
  })  : _backend = backend,
        _demoMode = demoMode,
        _firebaseAuth = demoMode ? null : (firebaseAuth ?? FirebaseAuthService());

  final ClinicBackend _backend;
  final FirebaseAuthService? _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;
  UserAccount? _currentUser;
  bool _firebaseReady = false;
  final bool _demoMode;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get firebaseReady => _firebaseReady;
  bool get demoMode => _demoMode;

  /// Demo staff accounts when Firebase is not configured.
  static const demoAdminEmail = 'admin@tabib.demo';
  static const demoSuperOwnerEmail = 'super@tabib.demo';
  static const demoDoctorEmail = 'doctor@tabib.demo';
  static const demoSecretaryEmail = 'secretary@tabib.demo';
  static const demoPassword = 'demo123';
  bool get isPatient => _currentUser?.role == UserRole.patient;
  bool get isSecretary => _currentUser?.role == UserRole.secretary;
  /// System owner — unrestricted platform access; hidden from all other users.
  bool get isSystemOwner => _currentUser?.isSystemOwner == true;

  /// Super Owner — platform-level multi-tenant control above Organization Owners.
  bool get isSuperOwner => _currentUser?.isSuperOwner == true;

  /// Delegated Admin or System Owner with panel access.
  bool get canAccessAdminPanel =>
      PermissionPolicy.canAccessAdminPanel(_currentUser);

  bool get isDelegatedAdmin =>
      PermissionPolicy.isDelegatedAdmin(_currentUser);

  bool hasCapability(AdminCapability capability) =>
      PermissionPolicy.hasCapability(_currentUser, capability);

  bool get isDoctor =>
      !isSystemOwner && !isSuperOwner && _currentUser?.role == UserRole.doctor;

  /// Doctor or business provider with clinical dashboard (never System Owner).
  bool get isClinicalProvider => isDoctor;

  bool get isStaff => isDoctor || isSecretary || isDelegatedAdmin;

  /// Platform operator (System Owner or delegated Admin).
  bool get isPlatformAdmin => canAccessAdminPanel;

  /// Legacy alias — use [isSystemOwner] or [canAccessAdminPanel].
  bool get isAdmin => isSystemOwner;

  /// Demo auth when explicitly in demo mode, Firebase is unavailable, or options
  /// are placeholders (guards against partial Firebase setup).
  bool get _useDemoAuth =>
      _demoMode ||
      !FirebaseBootstrap.initialized ||
      !DefaultFirebaseOptions.isConfigured;

  String get patientId => _currentUser?.id ?? '';

  void setFirebaseReady(bool ready) {
    if (_firebaseReady == ready) return;
    _firebaseReady = ready;

    if (ready && _firebaseAuth != null) {
      _authSubscription ??=
          _firebaseAuth!.authStateChanges.listen(_onAuthChanged);
    } else {
      _authSubscription?.cancel();
      _authSubscription = null;
      if (!ready) _currentUser = null;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    await _loadUserFromFirebase(user);
    final blockCode = await _rejectBlockedAccount();
    if (blockCode != null) {
      _currentUser = null;
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  Future<void> _loadUserFromFirebase(User user) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserAccount.fromFirestore(doc.id, doc.data()!);
        await _applySuperOwnerPrivileges(
          persist: true,
          authEmail: user.email,
        );
        await _applySystemOwnerPrivileges(
          persist: true,
          authEmail: user.email,
        );
      } else if (user.isAnonymous) {
        _currentUser = UserAccount(
          id: user.uid,
          name: const LocalizedText(ku: 'نەخۆش', ar: 'مريض', en: 'Patient'),
          role: UserRole.patient,
          phone: user.phoneNumber,
        );
      }
    } catch (_) {
      _currentUser = null;
    }
  }

  Future<void> _applySuperOwnerPrivileges({
    bool persist = false,
    String? authEmail,
  }) async {
    final user = _currentUser;
    if (user == null) return;

    final shouldSuper = user.isSuperOwner ||
        SuperOwnerConfig.isSuperOwnerEmail(user.email) ||
        SuperOwnerConfig.isSuperOwnerEmail(authEmail);
    if (!shouldSuper) return;

    final needsUpdate = !user.isSuperOwner ||
        user.role != UserRole.admin ||
        user.doctorId != null ||
        user.linkedDoctorId != null;
    if (!needsUpdate) return;

    _currentUser = user.copyWith(
      isSuperOwner: true,
      role: UserRole.admin,
      email: user.email ?? authEmail,
      doctorId: null,
      linkedDoctorId: null,
    );
    if (persist && !_demoMode) {
      await _backend.upsertStaff(_currentUser!);
    }
    notifyListeners();
  }

  Future<void> _applySystemOwnerPrivileges({
    bool persist = false,
    String? authEmail,
  }) async {
    final user = _currentUser;
    if (user == null) return;
    if (user.isSuperOwner &&
        !SystemOwnerConfig.isOwnerEmail(user.email) &&
        !SystemOwnerConfig.isOwnerEmail(authEmail)) {
      return;
    }

    final shouldOwn = user.isSystemOwner ||
        SystemOwnerConfig.isOwnerEmail(user.email) ||
        SystemOwnerConfig.isOwnerEmail(authEmail);
    if (!shouldOwn) return;

    final needsUpdate = !user.isSystemOwner ||
        user.role != UserRole.admin ||
        user.doctorId != null ||
        user.linkedDoctorId != null ||
        (user.email == null && authEmail != null && authEmail.isNotEmpty);
    if (!needsUpdate) return;

    _currentUser = user.copyWith(
      isSystemOwner: true,
      role: UserRole.admin,
      email: user.email ?? authEmail,
      doctorId: null,
      linkedDoctorId: null,
    );
    if (persist && !_demoMode) {
      await _backend.upsertStaff(_currentUser!);
    }
    notifyListeners();
  }

  Future<String?> _rejectBlockedAccount() async {
    final user = _currentUser;
    if (user == null) return 'invalid_credentials';
    if (user.isSystemOwner || user.isSuperOwner) return null;

    Clinic? clinic;
    if (user.clinicId != null && user.clinicId!.isNotEmpty) {
      clinic = await _backend.getClinic(user.clinicId!);
    }

    final blockCode = AccountAccess.loginBlockCode(user: user, clinic: clinic);
    if (blockCode != null) {
      await logout();
      return blockCode;
    }
    return null;
  }

  Future<String?> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (phone.length < 10) return 'invalid_phone';
    if (password.length < 6) return 'weak_password';

    if (_demoMode) {
      _currentUser = UserAccount(
        id: 'demo_patient_${phone.hashCode}',
        name: LocalizedText(ku: name, ar: name, en: name),
        role: UserRole.patient,
        email: email.trim(),
        phone: phone,
      );
      notifyListeners();
      return null;
    }

    try {
      final cred = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final account = UserAccount(
        id: uid,
        name: LocalizedText(ku: name, ar: name, en: name),
        role: UserRole.patient,
        email: email.trim(),
        phone: phone,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(account.toMap());
      _currentUser = account;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'email_in_use';
      if (e.code == 'weak-password') return 'weak_password';
      return e.message ?? e.code;
    } on FirebaseException catch (e) {
      return e.message ?? e.code;
    }
  }

  Future<String?> loginPatient({
    required String name,
    required String phone,
  }) async {
    if (phone.length < 10) return 'invalid_phone';

    if (_demoMode) {
      _currentUser = UserAccount(
        id: 'demo_patient_${phone.hashCode}',
        name: LocalizedText(ku: name, ar: name, en: name),
        role: UserRole.patient,
        phone: phone,
      );
      notifyListeners();
      return await _rejectBlockedAccount();
    }

    try {
      final cred = await _firebaseAuth!.signInAnonymously();
      final uid = cred.user!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserAccount.fromFirestore(doc.id, doc.data()!);
      } else {
        final account = UserAccount(
          id: uid,
          name: LocalizedText(ku: name, ar: name, en: name),
          role: UserRole.patient,
          phone: phone,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(account.toMap(), SetOptions(merge: true));
        _currentUser = account;
      }
      notifyListeners();
      return await _rejectBlockedAccount();
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } on FirebaseException catch (e) {
      return e.message ?? e.code;
    }
  }

  Future<String?> loginStaff({
    required String identifier,
    required String password,
  }) async {
    final trimmed = identifier.trim();
    final loginKind = StaffAuthIdentifiers.detectLoginKind(trimmed);
    if (loginKind == StaffLoginKind.unknown) return 'invalid_credentials';

    if (_useDemoAuth) {
      final err = await _demoStaffLogin(trimmed, password);
      if (err != null) return err;
      notifyListeners();
      return null;
    }

    final authEmail = StaffAuthIdentifiers.resolveAuthEmail(trimmed);

    try {
      await _firebaseAuth!.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
      final fbUser = _firebaseAuth!.currentUser;
      if (fbUser != null) {
        await _loadUserFromFirebase(fbUser);
      }
      if (_currentUser == null) return 'invalid_credentials';
      await _applySuperOwnerPrivileges(
        persist: true,
        authEmail: fbUser?.email ?? authEmail,
      );
      await _applySystemOwnerPrivileges(
        persist: true,
        authEmail: fbUser?.email ?? authEmail,
      );
      return await _rejectBlockedAccount();
    } on FirebaseAuthException {
      if (_isKnownDemoCredential(trimmed, password)) {
        final err = await _demoStaffLogin(trimmed, password);
        if (err != null) return err;
        notifyListeners();
        return null;
      }
      return 'invalid_credentials';
    } on FirebaseException catch (e) {
      return e.message ?? 'invalid_credentials';
    }
  }

  Future<String?> loginPatientWithEmail({
    required String email,
    required String password,
  }) async {
    if (_demoMode) {
      if (password != demoPassword) return 'invalid_credentials';
      _currentUser = UserAccount(
        id: 'demo_patient_${email.hashCode}',
        name: const LocalizedText(ku: 'نەخۆش', ar: 'مريض', en: 'Patient'),
        role: UserRole.patient,
        email: email.trim(),
      );
      notifyListeners();
      return null;
    }

    try {
      await _firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = _firebaseAuth!.currentUser;
      if (fbUser != null) {
        await _loadUserFromFirebase(fbUser);
      }
      return await _rejectBlockedAccount();
    } on FirebaseAuthException {
      return 'invalid_credentials';
    } on FirebaseException catch (e) {
      return e.message ?? 'invalid_credentials';
    }
  }

  Future<String?> registerPatientBySecretary({
    required String name,
    required String phone,
    required String clinicId,
  }) async {
    if (phone.length < 10) return 'invalid_phone';

    if (_demoMode) return null;

    try {
      final cred = await _firebaseAuth!.signInAnonymously();
      final uid = cred.user!.uid;
      final account = UserAccount(
        id: uid,
        name: LocalizedText(ku: name, ar: name, en: name),
        role: UserRole.patient,
        phone: phone,
        clinicId: clinicId,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(account.toMap());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } on FirebaseException catch (e) {
      return e.message ?? e.code;
    }
  }

  /// Backend-only: system owner signs in via the doctor login UI.
  Future<String?> loginAdmin({
    required String email,
    required String password,
  }) async {
    final err = await loginStaff(identifier: email, password: password);
    if (err != null) return err;
    if (!canAccessAdminPanel) {
      await logout();
      return 'invalid_credentials';
    }
    return null;
  }

  Future<void> logout() async {
    if (!_demoMode) {
      await _firebaseAuth!.signOut();
    }
    _currentUser = null;
    notifyListeners();
  }

  /// Admin-only: create a doctor or business account and catalog profile.
  Future<String?> createDoctorAccount({
    required String name,
    required StaffLoginMethod loginMethod,
    String? email,
    String? phone,
    required String password,
    required String specialtyId,
    String? clinicId,
    ServiceProviderAccountType accountType = ServiceProviderAccountType.doctor,
    BusinessCategory? businessCategory,
  }) async {
    final cap = accountType.isBusiness
        ? AdminCapability.manageBusinesses
        : AdminCapability.manageDoctors;
    if (!hasCapability(cap)) return 'unauthorized';
    if (password.length < 6) return 'weak_password';

    final trimmedEmail = email?.trim();
    final trimmedPhone = phone?.trim();
    final authEmail = StaffAuthIdentifiers.resolveAuthEmailForAccount(
      loginMethod: loginMethod,
      email: trimmedEmail,
      phone: trimmedPhone,
    );
    if (authEmail == null) {
      return loginMethod == StaffLoginMethod.phone
          ? 'invalid_phone'
          : 'invalid_email';
    }

    final doctorId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    final accountId = 'user_$doctorId';
    final nameText = LocalizedText(ku: name, ar: name, en: name);
    final contactEmail = trimmedEmail;
    final contactPhone = trimmedPhone;

    if (_demoMode) {
      final staff = await _backend.fetchStaff();
      if (staff.any((s) =>
          s.email != null &&
          trimmedEmail != null &&
          trimmedEmail.isNotEmpty &&
          s.email!.toLowerCase() == trimmedEmail.toLowerCase())) {
        return 'email_in_use';
      }
      if (trimmedPhone != null &&
          trimmedPhone.isNotEmpty &&
          staff.any((s) =>
              s.phone != null &&
              StaffAuthIdentifiers.normalizePhone(s.phone!) ==
                  StaffAuthIdentifiers.normalizePhone(trimmedPhone))) {
        return 'phone_in_use';
      }
      final existingDoctor = await _backend.getDoctor(doctorId);
      if (existingDoctor != null) return 'error';
      final clinics = await _backend.fetchClinics();
      final specialties = await _backend.fetchSpecialties();
      final resolvedClinicId =
          clinicId ?? clinics.firstOrNull?.id;
      if (resolvedClinicId == null) return 'error';
      final clinic =
          clinics.where((c) => c.id == resolvedClinicId).firstOrNull;
      final specialty =
          specialties.where((s) => s.id == specialtyId).firstOrNull;
      if (clinic == null || specialty == null) return 'error';
      if (accountType.isBusiness && !specialty.isBusinessType) return 'error';
      if (accountType.isDoctor && specialty.isBusinessType) return 'error';

      final accountCode =
          await _backend.allocateAccountCode(accountType);
      await _backend.upsertDoctor(
        Doctor(
          id: doctorId,
          name: nameText,
          specialtyId: specialtyId,
          specialty: specialty,
          clinicId: resolvedClinicId,
          clinic: clinic,
          rating: 0,
          experienceYears: 0,
          bio: const LocalizedText(ku: '', ar: '', en: ''),
          isAvailableToday: true,
          accountType: accountType,
          businessCategory: businessCategory,
          accountCode: accountCode,
        ),
      );
      await _backend.upsertStaff(
        UserAccount(
          id: accountId,
          name: nameText,
          role: UserRole.doctor,
          email: contactEmail?.isNotEmpty == true ? contactEmail : null,
          phone: contactPhone?.isNotEmpty == true ? contactPhone : null,
          doctorId: doctorId,
          clinicId: resolvedClinicId,
        ),
        password: password,
        authEmail: authEmail,
      );
      return null;
    }

    try {
      final staff = await _backend.fetchStaff();
      if (staff.any((s) =>
          s.email != null &&
          trimmedEmail != null &&
          trimmedEmail.isNotEmpty &&
          s.email!.toLowerCase() == trimmedEmail.toLowerCase())) {
        return 'email_in_use';
      }
      if (trimmedPhone != null &&
          trimmedPhone.isNotEmpty &&
          staff.any((s) =>
              s.phone != null &&
              StaffAuthIdentifiers.normalizePhone(s.phone!) ==
                  StaffAuthIdentifiers.normalizePhone(trimmedPhone))) {
        return 'phone_in_use';
      }

      final clinics = await _backend.fetchClinics();
      final specialties = await _backend.fetchSpecialties();
      final resolvedClinicId =
          clinicId ?? clinics.firstOrNull?.id;
      if (resolvedClinicId == null) return 'error';
      final clinic =
          clinics.where((c) => c.id == resolvedClinicId).firstOrNull;
      final specialty =
          specialties.where((s) => s.id == specialtyId).firstOrNull;
      if (clinic == null || specialty == null) return 'error';
      if (accountType.isBusiness && !specialty.isBusinessType) return 'error';
      if (accountType.isDoctor && specialty.isBusinessType) return 'error';

      final cred = await _firebaseAuth!.createStaffUserWithoutSessionSwitch(
        email: authEmail,
        password: password,
      );
      final uid = cred.user!.uid;
      final accountCode =
          await _backend.allocateAccountCode(accountType);
      await _backend.upsertDoctor(
        Doctor(
          id: doctorId,
          name: nameText,
          specialtyId: specialtyId,
          specialty: specialty,
          clinicId: resolvedClinicId,
          clinic: clinic,
          rating: 0,
          experienceYears: 0,
          bio: const LocalizedText(ku: '', ar: '', en: ''),
          isAvailableToday: true,
          accountType: accountType,
          businessCategory: businessCategory,
          accountCode: accountCode,
        ),
      );
      await _backend.upsertStaff(
        UserAccount(
          id: uid,
          name: nameText,
          role: UserRole.doctor,
          email: contactEmail?.isNotEmpty == true ? contactEmail : null,
          phone: contactPhone?.isNotEmpty == true ? contactPhone : null,
          doctorId: doctorId,
          clinicId: resolvedClinicId,
        ),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'email_in_use';
      if (e.code == 'weak-password') return 'weak_password';
      return e.message ?? e.code;
    }
  }

  /// Admin-only: create a secretary linked to a doctor.
  Future<String?> createSecretaryAccount({
    required String name,
    required StaffLoginMethod loginMethod,
    String? email,
    String? phone,
    required String password,
    required String linkedDoctorId,
    String? clinicId,
  }) async {
    if (!hasCapability(AdminCapability.manageSecretaries)) return 'unauthorized';
    if (password.length < 6) return 'weak_password';
    if (linkedDoctorId.isEmpty) return 'linked_doctor_required';

    final trimmedEmail = email?.trim();
    final trimmedPhone = phone?.trim();
    final authEmail = StaffAuthIdentifiers.resolveAuthEmailForAccount(
      loginMethod: loginMethod,
      email: trimmedEmail,
      phone: trimmedPhone,
    );
    if (authEmail == null) {
      return loginMethod == StaffLoginMethod.phone
          ? 'invalid_phone'
          : 'invalid_email';
    }

    final doctor = await _backend.getDoctor(linkedDoctorId);
    if (doctor == null) return 'linked_doctor_required';

    final nameText = LocalizedText(ku: name, ar: name, en: name);
    final resolvedClinicId = clinicId ?? doctor.clinicId;
    final contactEmail = trimmedEmail;
    final contactPhone = trimmedPhone;

    if (_demoMode) {
      final staff = await _backend.fetchStaff();
      if (staff.any((s) =>
          s.email != null &&
          trimmedEmail != null &&
          trimmedEmail.isNotEmpty &&
          s.email!.toLowerCase() == trimmedEmail.toLowerCase())) {
        return 'email_in_use';
      }
      if (trimmedPhone != null &&
          trimmedPhone.isNotEmpty &&
          staff.any((s) =>
              s.phone != null &&
              StaffAuthIdentifiers.normalizePhone(s.phone!) ==
                  StaffAuthIdentifiers.normalizePhone(trimmedPhone))) {
        return 'phone_in_use';
      }

      await _backend.upsertStaff(
        UserAccount(
          id: 'sec_${DateTime.now().millisecondsSinceEpoch}',
          name: nameText,
          role: UserRole.secretary,
          email: contactEmail?.isNotEmpty == true ? contactEmail : null,
          phone: contactPhone?.isNotEmpty == true ? contactPhone : null,
          clinicId: resolvedClinicId,
          linkedDoctorId: linkedDoctorId,
        ),
        password: password,
        authEmail: authEmail,
      );
      return null;
    }

    try {
      final staff = await _backend.fetchStaff();
      if (staff.any((s) =>
          s.email != null &&
          trimmedEmail != null &&
          trimmedEmail.isNotEmpty &&
          s.email!.toLowerCase() == trimmedEmail.toLowerCase())) {
        return 'email_in_use';
      }
      if (trimmedPhone != null &&
          trimmedPhone.isNotEmpty &&
          staff.any((s) =>
              s.phone != null &&
              StaffAuthIdentifiers.normalizePhone(s.phone!) ==
                  StaffAuthIdentifiers.normalizePhone(trimmedPhone))) {
        return 'phone_in_use';
      }

      final cred = await _firebaseAuth!.createStaffUserWithoutSessionSwitch(
        email: authEmail,
        password: password,
      );
      await _backend.upsertStaff(
        UserAccount(
          id: cred.user!.uid,
          name: nameText,
          role: UserRole.secretary,
          email: contactEmail?.isNotEmpty == true ? contactEmail : null,
          phone: contactPhone?.isNotEmpty == true ? contactPhone : null,
          clinicId: resolvedClinicId,
          linkedDoctorId: linkedDoctorId,
        ),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'email_in_use';
      if (e.code == 'weak-password') return 'weak_password';
      return e.message ?? e.code;
    }
  }

  bool _isKnownDemoCredential(String identifier, String password) {
    if (password != demoPassword) return false;
    if (!StaffAuthIdentifiers.looksLikeEmail(identifier)) return false;
    final normalizedEmail = identifier.trim().toLowerCase();
    return normalizedEmail == demoAdminEmail ||
        normalizedEmail == demoSuperOwnerEmail ||
        normalizedEmail == demoDoctorEmail ||
        normalizedEmail == demoSecretaryEmail;
  }

  Future<String?> _demoStaffLogin(String identifier, String password) async {
    if (StaffAuthIdentifiers.looksLikeEmail(identifier) &&
        password == demoPassword) {
      final normalizedEmail = identifier.trim().toLowerCase();

      if (normalizedEmail == demoSuperOwnerEmail) {
        _currentUser = const UserAccount(
          id: 'demo_super_owner',
          name: LocalizedText(
            ku: 'سوپەر خاوەن',
            ar: 'المالك الأعلى',
            en: 'Super Owner',
          ),
          role: UserRole.admin,
          email: demoSuperOwnerEmail,
          isSuperOwner: true,
        );
        return await _rejectBlockedAccount();
      }

      if (normalizedEmail == demoAdminEmail) {
        _currentUser = const UserAccount(
          id: 'demo_admin',
          name: LocalizedText(
            ku: 'بەڕێوەبەری سیستەم',
            ar: 'مدير النظام',
            en: 'System Owner',
          ),
          role: UserRole.admin,
          email: demoAdminEmail,
          isSystemOwner: true,
        );
        return await _rejectBlockedAccount();
      }

      if (normalizedEmail == demoDoctorEmail) {
        _currentUser = const UserAccount(
          id: 'demo_doctor',
          name: LocalizedText(
            ku: 'د. ئاراس محەمەد',
            ar: 'د. أراس محمد',
            en: 'Dr. Aras Mohammed',
          ),
          role: UserRole.doctor,
          email: demoDoctorEmail,
          doctorId: 'doc_1',
          clinicId: 'clinic_erbil_1',
        );
        return await _rejectBlockedAccount();
      }

      if (normalizedEmail == demoSecretaryEmail) {
        _currentUser = const UserAccount(
          id: 'demo_secretary',
          name: LocalizedText(
            ku: 'سکرتێر',
            ar: 'سكرتير',
            en: 'Secretary',
          ),
          role: UserRole.secretary,
          email: demoSecretaryEmail,
          clinicId: 'clinic_erbil_1',
          linkedDoctorId: 'doc_1',
        );
        return await _rejectBlockedAccount();
      }
    }

    final dynamic = await _backend.lookupStaffCredentials(identifier, password);
    if (dynamic != null) {
      _currentUser = dynamic;
      await _applySuperOwnerPrivileges();
      await _applySystemOwnerPrivileges();
      return await _rejectBlockedAccount();
    }
    return 'invalid_credentials';
  }

  Future<void> seedDemoData() => _backend.seedDemoData();

  /// Admin-only: create or update a clinic.
  Future<String?> saveClinic(Clinic clinic) async {
    if (!hasCapability(AdminCapability.manageCategories) &&
        !hasCapability(AdminCapability.manageDoctors)) {
      return 'unauthorized';
    }
    await _backend.upsertClinic(clinic);
    return null;
  }

  /// Admin-only: set account status (suspend, disable, reactivate, etc.).
  Future<String?> setAccountStatus(
    String accountId,
    AccountStatus status,
  ) async {
    if (!hasCapability(AdminCapability.suspendAccounts)) return 'unauthorized';

    final accounts = await _backend.fetchAllAccounts();
    final account = accounts.where((s) => s.id == accountId).firstOrNull;
    if (account == null) return 'error';
    if (!PermissionPolicy.canModifyAccount(_currentUser, account)) {
      return 'unauthorized';
    }

    await _backend.upsertStaff(account.copyWith(accountStatus: status));
    return null;
  }

  /// Admin-only: activate or deactivate a staff account.
  Future<String?> setStaffActive(String staffId, bool active) async {
    return setAccountStatus(
      staffId,
      active ? AccountStatus.active : AccountStatus.disabled,
    );
  }

  /// Admin-only: update clinic subscription settings.
  Future<String?> updateClinicSubscription({
    required String clinicId,
    required SubscriptionPlan plan,
    required bool active,
    DateTime? startedAt,
    DateTime? expiresAt,
  }) async {
    if (!hasCapability(AdminCapability.manageSubscriptions)) {
      return 'unauthorized';
    }

    final clinic = await _backend.getClinic(clinicId);
    if (clinic == null) return 'error';

    await _backend.upsertClinic(
      clinic.copyWith(
        subscriptionPlan: plan,
        subscriptionActive: active,
        subscriptionStartedAt: startedAt ?? clinic.subscriptionStartedAt,
        subscriptionExpiresAt: expiresAt,
        subscriptionWarned7Days: false,
        subscriptionExpiredNotified: false,
      ),
    );
    return null;
  }

  /// Admin-only: instantly renew a clinic subscription from today.
  Future<String?> renewClinicSubscription({
    required String clinicId,
    required SubscriptionPlan plan,
    DateTime? startDate,
  }) async {
    if (!hasCapability(AdminCapability.manageSubscriptions)) {
      return 'unauthorized';
    }

    final clinic = await _backend.getClinic(clinicId);
    if (clinic == null) return 'error';

    await _backend.upsertClinic(
      ClinicSubscriptionHelper.renew(
        clinic: clinic,
        plan: plan,
        startDate: startDate,
      ),
    );
    return null;
  }

  /// Admin-only: update a secretary assigned to a single doctor.
  Future<String?> updateSecretaryAccount({
    required String secretaryId,
    required String name,
    String? email,
    String? phone,
    bool? isActive,
    AccountStatus? accountStatus,
  }) async {
    if (!hasCapability(AdminCapability.manageSecretaries)) return 'unauthorized';

    final staff = await _backend.fetchStaff();
    final account = staff.where((s) => s.id == secretaryId).firstOrNull;
    if (account == null || account.role != UserRole.secretary) return 'error';
    if (!PermissionPolicy.canModifyAccount(_currentUser, account)) {
      return 'unauthorized';
    }

    final trimmedEmail = email?.trim();
    final trimmedPhone = phone?.trim();

    if (trimmedEmail != null &&
        trimmedEmail.isNotEmpty &&
        staff.any((s) =>
            s.id != secretaryId &&
            s.email != null &&
            s.email!.toLowerCase() == trimmedEmail.toLowerCase())) {
      return 'email_in_use';
    }
    if (trimmedPhone != null &&
        trimmedPhone.isNotEmpty &&
        staff.any((s) =>
            s.id != secretaryId &&
            s.phone != null &&
            StaffAuthIdentifiers.normalizePhone(s.phone!) ==
                StaffAuthIdentifiers.normalizePhone(trimmedPhone))) {
      return 'phone_in_use';
    }

    final nameText = LocalizedText(ku: name, ar: name, en: name);
    final resolvedStatus = accountStatus ??
        (isActive == null
            ? account.accountStatus
            : (isActive ? AccountStatus.active : AccountStatus.disabled));
    await _backend.upsertStaff(
      account.copyWith(
        name: nameText,
        email: trimmedEmail?.isNotEmpty == true ? trimmedEmail : null,
        phone: trimmedPhone?.isNotEmpty == true ? trimmedPhone : null,
        accountStatus: resolvedStatus,
      ),
    );
    return null;
  }

  /// Demo mode sets [newPassword] directly. Firebase mode sends a reset email
  /// to the secretary's auth address (client SDK cannot set another user's password).
  Future<String?> resetSecretaryPassword({
    required String secretaryId,
    String? newPassword,
  }) async {
    if (!hasCapability(AdminCapability.resetPasswords)) return 'unauthorized';

    final staff = await _backend.fetchStaff();
    final account = staff.where((s) => s.id == secretaryId).firstOrNull;
    if (account == null || account.role != UserRole.secretary) return 'error';
    if (!PermissionPolicy.canModifyAccount(_currentUser, account)) {
      return 'unauthorized';
    }

    final loginMethod = account.email != null && account.email!.trim().isNotEmpty
        ? StaffLoginMethod.email
        : StaffLoginMethod.phone;
    final authEmail = StaffAuthIdentifiers.resolveAuthEmailForAccount(
      loginMethod: loginMethod,
      email: account.email,
      phone: account.phone,
    );
    if (authEmail == null) return 'invalid_credentials';

    if (_demoMode) {
      if (newPassword == null || newPassword.length < 6) return 'weak_password';
      await _backend.upsertStaff(
        account,
        password: newPassword,
        authEmail: authEmail,
      );
      return null;
    }

    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: authEmail);
      return 'password_reset_email_sent';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'invalid_credentials';
      return e.message ?? e.code;
    }
  }

  /// Admin-only: delete a secretary account.
  Future<String?> deleteSecretaryAccount(String secretaryId) async {
    if (!hasCapability(AdminCapability.deleteAccounts)) return 'unauthorized';

    final staff = await _backend.fetchStaff();
    final account = staff.where((s) => s.id == secretaryId).firstOrNull;
    if (account == null || account.role != UserRole.secretary) return 'error';
    if (!PermissionPolicy.canModifyAccount(_currentUser, account)) {
      return 'unauthorized';
    }

    await _backend.deleteStaff(secretaryId);
    return null;
  }

  /// Admin-only: move a secretary to another doctor.
  Future<String?> transferSecretaryAccount({
    required String secretaryId,
    required String newLinkedDoctorId,
  }) async {
    if (!hasCapability(AdminCapability.manageSecretaries)) return 'unauthorized';
    if (newLinkedDoctorId.isEmpty) return 'linked_doctor_required';

    final staff = await _backend.fetchStaff();
    final account = staff.where((s) => s.id == secretaryId).firstOrNull;
    if (account == null || account.role != UserRole.secretary) return 'error';
    if (!PermissionPolicy.canModifyAccount(_currentUser, account)) {
      return 'unauthorized';
    }
    if (account.linkedDoctorId == newLinkedDoctorId) return null;

    final doctor = await _backend.getDoctor(newLinkedDoctorId);
    if (doctor == null) return 'linked_doctor_required';

    await _backend.upsertStaff(
      account.copyWith(
        linkedDoctorId: newLinkedDoctorId,
        clinicId: doctor.clinicId,
      ),
    );
    return null;
  }

  /// System Owner only: create a delegated Admin account.
  Future<String?> createAdminAccount({
    required String name,
    required StaffLoginMethod loginMethod,
    String? email,
    String? phone,
    required String password,
    required AdminPermissionSet permissions,
  }) async {
    if (!PermissionPolicy.canManageAdminAccounts(_currentUser)) {
      return 'unauthorized';
    }
    if (password.length < 6) return 'weak_password';

    final trimmedEmail = email?.trim();
    final trimmedPhone = phone?.trim();
    final authEmail = StaffAuthIdentifiers.resolveAuthEmailForAccount(
      loginMethod: loginMethod,
      email: trimmedEmail,
      phone: trimmedPhone,
    );
    if (authEmail == null) {
      return loginMethod == StaffLoginMethod.phone
          ? 'invalid_phone'
          : 'invalid_email';
    }

    final safePermissions = PermissionPolicy.sanitizeGrantedPermissions(
      _currentUser,
      permissions,
    );
    if (safePermissions.isEmpty) return 'error';

    final nameText = LocalizedText(ku: name, ar: name, en: name);
    final staff = await _backend.fetchStaff();
    if (_emailInUse(staff, trimmedEmail)) return 'email_in_use';
    if (_phoneInUse(staff, trimmedPhone)) return 'phone_in_use';

    if (_demoMode) {
      await _backend.upsertStaff(
        UserAccount(
          id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
          name: nameText,
          role: UserRole.admin,
          email: trimmedEmail?.isNotEmpty == true ? trimmedEmail : null,
          phone: trimmedPhone?.isNotEmpty == true ? trimmedPhone : null,
          adminPermissions: safePermissions,
        ),
        password: password,
        authEmail: authEmail,
      );
      return null;
    }

    try {
      final cred = await _firebaseAuth!.createStaffUserWithoutSessionSwitch(
        email: authEmail,
        password: password,
      );
      await _backend.upsertStaff(
        UserAccount(
          id: cred.user!.uid,
          name: nameText,
          role: UserRole.admin,
          email: trimmedEmail?.isNotEmpty == true ? trimmedEmail : null,
          phone: trimmedPhone?.isNotEmpty == true ? trimmedPhone : null,
          adminPermissions: safePermissions,
        ),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'email_in_use';
      if (e.code == 'weak-password') return 'weak_password';
      return e.message ?? e.code;
    }
  }

  /// System Owner only: update delegated Admin profile and permissions.
  Future<String?> updateAdminAccount({
    required String adminId,
    required String name,
    String? email,
    String? phone,
    AdminPermissionSet? permissions,
    AccountStatus? accountStatus,
  }) async {
    if (!PermissionPolicy.canManageAdminAccounts(_currentUser)) {
      return 'unauthorized';
    }

    final staff = await _backend.fetchStaff();
    final account = staff.where((s) => s.id == adminId).firstOrNull;
    if (account == null ||
        account.role != UserRole.admin ||
        account.isSystemOwner) {
      return 'error';
    }

    final trimmedEmail = email?.trim();
    final trimmedPhone = phone?.trim();
    if (_emailInUse(staff, trimmedEmail, exceptId: adminId) ||
        _phoneInUse(staff, trimmedPhone, exceptId: adminId)) {
      return 'email_in_use';
    }

    final nameText = LocalizedText(ku: name, ar: name, en: name);
    final nextPermissions = permissions == null
        ? account.adminPermissions
        : PermissionPolicy.sanitizeGrantedPermissions(_currentUser, permissions);

    await _backend.upsertStaff(
      account.copyWith(
        name: nameText,
        email: trimmedEmail?.isNotEmpty == true ? trimmedEmail : null,
        phone: trimmedPhone?.isNotEmpty == true ? trimmedPhone : null,
        adminPermissions: nextPermissions,
        accountStatus: accountStatus ?? account.accountStatus,
      ),
    );
    return null;
  }

  /// System Owner only: delete a delegated Admin account.
  Future<String?> deleteAdminAccount(String adminId) async {
    if (!PermissionPolicy.canManageAdminAccounts(_currentUser)) {
      return 'unauthorized';
    }

    final staff = await _backend.fetchStaff();
    final account = staff.where((s) => s.id == adminId).firstOrNull;
    if (account == null ||
        account.role != UserRole.admin ||
        account.isSystemOwner) {
      return 'error';
    }

    await _backend.deleteStaff(adminId);
    return null;
  }

  bool _emailInUse(
    List<UserAccount> staff,
    String? email, {
    String? exceptId,
  }) {
    final trimmed = email?.trim();
    if (trimmed == null || trimmed.isEmpty) return false;
    return staff.any((s) =>
        s.id != exceptId &&
        s.email != null &&
        s.email!.toLowerCase() == trimmed.toLowerCase());
  }

  bool _phoneInUse(
    List<UserAccount> staff,
    String? phone, {
    String? exceptId,
  }) {
    final trimmed = phone?.trim();
    if (trimmed == null || trimmed.isEmpty) return false;
    final normalized = StaffAuthIdentifiers.normalizePhone(trimmed);
    return staff.any((s) =>
        s.id != exceptId &&
        s.phone != null &&
        StaffAuthIdentifiers.normalizePhone(s.phone!) == normalized);
  }

  /// Updates the signed-in patient's name, email, and phone.
  Future<String?> updatePatientAccount({
    required String name,
    String? email,
    String? phone,
  }) async {
    final user = _currentUser;
    if (user == null || user.role != UserRole.patient) {
      return 'unauthorized';
    }
    if (name.trim().length < 2) return 'invalid_name';
    if (phone != null && phone.length < 10) return 'invalid_phone';

    final localized = LocalizedText(ku: name, ar: name, en: name);
    final updated = user.copyWith(
      name: localized,
      email: email?.trim().isEmpty == true ? null : email?.trim(),
      phone: phone,
    );

    if (_useDemoAuth) {
      _currentUser = updated;
      notifyListeners();
      return null;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).set(
        {
          'name': localized.toMap(),
          'email': updated.email,
          'phone': updated.phone,
        },
        SetOptions(merge: true),
      );
      _currentUser = updated;
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? e.code;
    }
  }

  /// Whether the signed-in user can change their own password (email auth only).
  bool get canChangePassword {
    final user = _currentUser;
    if (user == null) return false;
    if (_useDemoAuth) {
      return user.role != UserRole.patient || user.email?.isNotEmpty == true;
    }
    final fb = _firebaseAuth?.currentUser;
    if (fb == null) return false;
    if (fb.isAnonymous) return false;
    return fb.email != null && fb.email!.isNotEmpty;
  }

  /// Changes only the current user's password. Does not affect admin permissions.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!canChangePassword) return 'password_change_unavailable';
    if (newPassword.length < 6) return 'weak_password';
    if (currentPassword == newPassword) return 'password_same';

    if (_useDemoAuth) {
      if (!_validateDemoCurrentPassword(currentPassword)) {
        return 'invalid_credentials';
      }
      return null;
    }

    final fb = _firebaseAuth?.currentUser;
    final email = fb?.email;
    if (fb == null || email == null || email.isEmpty) {
      return 'password_change_unavailable';
    }

    try {
      await _firebaseAuth!.reauthenticateWithPassword(
        email: email,
        password: currentPassword,
      );
      await _firebaseAuth!.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'invalid_credentials';
      }
      if (e.code == 'weak-password') return 'weak_password';
      return e.message ?? e.code;
    }
  }

  bool _validateDemoCurrentPassword(String currentPassword) {
    return currentPassword == demoPassword;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
