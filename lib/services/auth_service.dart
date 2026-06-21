import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/localized_text.dart';
import '../models/doctor.dart';
import '../models/user_account.dart';
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
  static const demoDoctorEmail = 'doctor@tabib.demo';
  static const demoSecretaryEmail = 'secretary@tabib.demo';
  static const demoPassword = 'demo123';
  bool get isPatient => _currentUser?.role == UserRole.patient;
  bool get isDoctor => _currentUser?.role == UserRole.doctor;
  bool get isSecretary => _currentUser?.role == UserRole.secretary;
  bool get isStaff => isDoctor || isSecretary;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

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

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserAccount.fromFirestore(doc.id, doc.data()!);
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
    notifyListeners();
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
      return null;
    }

    try {
      final cred = await _firebaseAuth!.signInAnonymously();
      final uid = cred.user!.uid;
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
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } on FirebaseException catch (e) {
      return e.message ?? e.code;
    }
  }

  Future<String?> loginStaff({
    required String email,
    required String password,
  }) async {
    if (_useDemoAuth) {
      final err = await _demoStaffLogin(email.trim(), password);
      if (err != null) return err;
      notifyListeners();
      return null;
    }

    try {
      await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException {
      if (_isKnownDemoCredential(email.trim(), password)) {
        final err = await _demoStaffLogin(email.trim(), password);
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
      return null;
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

  Future<String?> loginAdmin({
    required String email,
    required String password,
  }) async {
    if (_useDemoAuth) {
      final err = await _demoStaffLogin(email.trim(), password);
      if (err != null) return err;
      if (_currentUser?.role != UserRole.admin) {
        _currentUser = null;
        return 'invalid_credentials';
      }
      notifyListeners();
      return null;
    }

    try {
      final cred = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();
      if (!doc.exists) {
        await logout();
        return 'invalid_credentials';
      }
      final account = UserAccount.fromFirestore(doc.id, doc.data()!);
      if (account.role != UserRole.admin) {
        await logout();
        return 'invalid_credentials';
      }
      _currentUser = account;
      notifyListeners();
      return null;
    } on FirebaseAuthException {
      if (_isKnownDemoCredential(email.trim(), password) &&
          email.trim().toLowerCase() == demoAdminEmail) {
        final err = await _demoStaffLogin(email.trim(), password);
        if (err != null) return err;
        if (_currentUser?.role != UserRole.admin) {
          _currentUser = null;
          return 'invalid_credentials';
        }
        notifyListeners();
        return null;
      }
      return 'invalid_credentials';
    } on FirebaseException catch (e) {
      return e.message ?? 'invalid_credentials';
    }
  }

  Future<void> logout() async {
    if (!_demoMode) {
      await _firebaseAuth!.signOut();
    }
    _currentUser = null;
    notifyListeners();
  }

  /// Admin-only: create a doctor account and profile.
  Future<String?> createDoctorAccount({
    required String name,
    required String email,
    required String password,
    required String specialtyId,
    required String clinicId,
    String? phone,
  }) async {
    if (!isAdmin) return 'unauthorized';
    if (password.length < 6) return 'weak_password';
    if (email.trim().isEmpty) return 'invalid_email';

    final doctorId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    final accountId = 'user_$doctorId';
    final nameText = LocalizedText(ku: name, ar: name, en: name);

    if (_demoMode) {
      final staff = await _backend.watchStaff().first;
      if (staff.any((s) => s.email?.toLowerCase() == email.trim().toLowerCase())) {
        return 'email_in_use';
      }
      final existingDoctor = await _backend.getDoctor(doctorId);
      if (existingDoctor != null) return 'error';
      final clinics = await _backend.fetchClinics();
      final specialties = await _backend.fetchSpecialties();
      final clinic = clinics.where((c) => c.id == clinicId).firstOrNull;
      final specialty =
          specialties.where((s) => s.id == specialtyId).firstOrNull;
      if (clinic == null || specialty == null) return 'error';

      await _backend.upsertDoctor(
        Doctor(
          id: doctorId,
          name: nameText,
          specialtyId: specialtyId,
          specialty: specialty,
          clinicId: clinicId,
          clinic: clinic,
          rating: 0,
          experienceYears: 0,
          bio: const LocalizedText(ku: '', ar: '', en: ''),
          isAvailableToday: true,
        ),
      );
      await _backend.upsertStaff(
        UserAccount(
          id: accountId,
          name: nameText,
          role: UserRole.doctor,
          email: email.trim(),
          phone: phone,
          doctorId: doctorId,
          clinicId: clinicId,
        ),
        password: password,
      );
      return null;
    }

    try {
      final cred = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      await _backend.upsertStaff(
        UserAccount(
          id: uid,
          name: nameText,
          role: UserRole.doctor,
          email: email.trim(),
          phone: phone,
          doctorId: doctorId,
          clinicId: clinicId,
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
    required String email,
    required String password,
    required String linkedDoctorId,
    String? clinicId,
  }) async {
    if (!isAdmin) return 'unauthorized';
    if (password.length < 6) return 'weak_password';
    if (linkedDoctorId.isEmpty) return 'linked_doctor_required';

    final doctor = await _backend.getDoctor(linkedDoctorId);
    if (doctor == null) return 'linked_doctor_required';

    final nameText = LocalizedText(ku: name, ar: name, en: name);
    final resolvedClinicId = clinicId ?? doctor.clinicId;

    if (_demoMode) {
      final staff = await _backend.watchStaff().first;
      if (staff.any((s) => s.email?.toLowerCase() == email.trim().toLowerCase())) {
        return 'email_in_use';
      }

      await _backend.upsertStaff(
        UserAccount(
          id: 'sec_${DateTime.now().millisecondsSinceEpoch}',
          name: nameText,
          role: UserRole.secretary,
          email: email.trim(),
          clinicId: resolvedClinicId,
          linkedDoctorId: linkedDoctorId,
        ),
        password: password,
      );
      return null;
    }

    try {
      final cred = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _backend.upsertStaff(
        UserAccount(
          id: cred.user!.uid,
          name: nameText,
          role: UserRole.secretary,
          email: email.trim(),
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

  bool _isKnownDemoCredential(String email, String password) {
    if (password != demoPassword) return false;
    final normalizedEmail = email.trim().toLowerCase();
    return normalizedEmail == demoAdminEmail ||
        normalizedEmail == demoDoctorEmail ||
        normalizedEmail == demoSecretaryEmail;
  }

  Future<String?> _demoStaffLogin(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (password != demoPassword) {
      final dynamic = await _backend.lookupStaffCredentials(
        normalizedEmail,
        password,
      );
      if (dynamic != null) {
        _currentUser = dynamic;
        return null;
      }
      return 'invalid_credentials';
    }

    if (normalizedEmail == demoAdminEmail) {
      _currentUser = UserAccount(
        id: 'demo_admin',
        name: const LocalizedText(
          ku: 'بەڕێوەبەر',
          ar: 'مدير',
          en: 'Admin',
        ),
        role: UserRole.admin,
        email: email,
      );
      return null;
    }

    if (normalizedEmail == demoDoctorEmail) {
      _currentUser = UserAccount(
        id: 'demo_doctor',
        name: const LocalizedText(
          ku: 'د. ئاراس محەمەد',
          ar: 'د. أراس محمد',
          en: 'Dr. Aras Mohammed',
        ),
        role: UserRole.doctor,
        email: email,
        doctorId: 'doc_1',
        clinicId: 'clinic_erbil_1',
      );
      return null;
    }

    if (normalizedEmail == demoSecretaryEmail) {
      _currentUser = UserAccount(
        id: 'demo_secretary',
        name: const LocalizedText(
          ku: 'سکرتێر',
          ar: 'سكرتير',
          en: 'Secretary',
        ),
        role: UserRole.secretary,
        email: email,
        clinicId: 'clinic_erbil_1',
        linkedDoctorId: 'doc_1',
      );
      return null;
    }

    return 'invalid_credentials';
  }

  Future<void> seedDemoData() => _backend.seedDemoData();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
