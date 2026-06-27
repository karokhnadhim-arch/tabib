import '../../models/user_account.dart';
import '../../domain/repositories/repositories.dart';
import '../../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthService authService}) : _auth = authService;

  final AuthService _auth;

  @override
  UserAccount? get currentUser => _auth.currentUser;

  @override
  bool get isLoggedIn => _auth.isLoggedIn;

  @override
  bool get isPatient => _auth.isPatient;

  @override
  bool get isDoctor => _auth.isDoctor;

  @override
  bool get isSecretary => _auth.isSecretary;

  @override
  String get patientId => _auth.patientId;

  @override
  Future<String?> loginPatient({required String name, required String phone}) =>
      _auth.loginPatient(name: name, phone: phone);

  @override
  Future<String?> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) =>
      _auth.registerPatient(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

  @override
  Future<String?> loginStaff({
    required String identifier,
    required String password,
  }) =>
      _auth.loginStaff(identifier: identifier, password: password);

  @override
  Future<void> logout() => _auth.logout();

  @override
  Future<void> seedDemoData() => _auth.seedDemoData();
}
