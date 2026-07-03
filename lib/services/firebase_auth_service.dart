import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// Low-level Firebase Authentication operations.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  FirebaseApp? _secondaryApp;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  /// Creates a staff Firebase user without switching the primary signed-in session.
  Future<UserCredential> createStaffUserWithoutSessionSwitch({
    required String email,
    required String password,
  }) async {
    final secondaryApp = await _ensureSecondaryApp();
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    try {
      return await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      await secondaryAuth.signOut();
    }
  }

  Future<FirebaseApp> _ensureSecondaryApp() async {
    if (_secondaryApp != null) return _secondaryApp!;
    const secondaryName = 'TabibStaffProvisioner';
    try {
      _secondaryApp = Firebase.app(secondaryName);
    } catch (_) {
      _secondaryApp = await Firebase.initializeApp(
        name: secondaryName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return _secondaryApp!;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updatePassword(String newPassword) =>
      _auth.currentUser!.updatePassword(newPassword);

  Future<void> sendPasswordResetEmail({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await _auth.currentUser!.reauthenticateWithCredential(credential);
  }
}
