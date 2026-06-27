/// Helpers for staff login via email or mobile number + password.
class StaffAuthIdentifiers {
  StaffAuthIdentifiers._();

  static const phoneAuthDomain = 'staff.tabib.local';

  static bool looksLikeEmail(String value) {
    final trimmed = value.trim();
    return trimmed.contains('@') && trimmed.contains('.');
  }

  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  static bool isValidPhone(String phone) {
    return normalizePhone(phone).length >= 10;
  }

  static String phoneToAuthEmail(String phone) {
    return '${normalizePhone(phone)}@$phoneAuthDomain';
  }

  static StaffLoginKind detectLoginKind(String identifier) {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) return StaffLoginKind.unknown;
    if (looksLikeEmail(trimmed)) return StaffLoginKind.email;
    if (isValidPhone(trimmed)) return StaffLoginKind.phone;
    return StaffLoginKind.unknown;
  }

  /// Firebase Auth email used for sign-in (real email or phone-derived alias).
  static String resolveAuthEmail(String identifier) {
    final trimmed = identifier.trim();
    if (looksLikeEmail(trimmed)) return trimmed.toLowerCase();
    return phoneToAuthEmail(trimmed);
  }

  static String? resolveAuthEmailForAccount({
    required StaffLoginMethod loginMethod,
    String? email,
    String? phone,
  }) {
    switch (loginMethod) {
      case StaffLoginMethod.email:
        final value = email?.trim();
        if (value == null || value.isEmpty || !looksLikeEmail(value)) {
          return null;
        }
        return value.toLowerCase();
      case StaffLoginMethod.phone:
        final value = phone?.trim();
        if (value == null || value.isEmpty || !isValidPhone(value)) {
          return null;
        }
        return phoneToAuthEmail(value);
    }
  }
}

enum StaffLoginKind { email, phone, unknown }

enum StaffLoginMethod { phone, email }
