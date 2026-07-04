/// Super Owner accounts — platform-level control above Organization Owners.
class SuperOwnerConfig {
  SuperOwnerConfig._();

  static const ownerEmails = <String>{
    'super@tabib.demo',
    'platform@tabib.app',
  };

  static bool isSuperOwnerEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return ownerEmails.contains(email.trim().toLowerCase());
  }
}
