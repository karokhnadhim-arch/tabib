import '../../models/service_provider_type.dart';

/// Permanent provider account codes (doctors and businesses only).
abstract final class AccountCode {
  AccountCode._();

  static const doctorPrefix = 'DR-';
  static const businessPrefix = 'BZ-';

  static final _pattern = RegExp(r'^(DR|BZ)-(\d{4,6})$', caseSensitive: false);

  static String prefixFor(ServiceProviderAccountType type) =>
      type.isBusiness ? businessPrefix : doctorPrefix;

  static String format(ServiceProviderAccountType type, int sequence) {
    final prefix = prefixFor(type);
    return '$prefix$sequence';
  }

  static String? normalize(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim().toUpperCase();
    if (trimmed.isEmpty) return null;
    final match = _pattern.firstMatch(trimmed);
    if (match == null) return null;
    return '${match.group(1)!.toUpperCase()}-${match.group(2)}';
  }

  static bool looksLikeAccountCode(String query) {
    final q = query.trim();
    if (q.isEmpty) return false;
    return _pattern.hasMatch(q.toUpperCase()) ||
        RegExp(r'^(DR|BZ)-?\d+$', caseSensitive: false).hasMatch(q);
  }

  static bool isAssigned(String? code) =>
      code != null && code.trim().isNotEmpty && normalize(code) != null;
}
