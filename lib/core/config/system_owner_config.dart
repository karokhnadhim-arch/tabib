/// Hidden system owner accounts — full admin access via the doctor login UI.
///
/// Add your email here to receive automatic admin privileges on staff login.
/// These accounts are never shown as a separate "Admin" role in the UI.
///
/// Owner detection also checks Firebase Auth email and Firestore `isSystemOwner`.
class SystemOwnerConfig {
  SystemOwnerConfig._();

  static const ownerEmails = <String>{
    'admin@tabib.demo',
    'admin@clinic.app',
  };

  static bool isOwnerEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return ownerEmails.contains(email.trim().toLowerCase());
  }
}
