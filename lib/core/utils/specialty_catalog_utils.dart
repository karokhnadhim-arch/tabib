import '../../models/localized_text.dart';
import '../../models/specialty.dart';

/// Helpers for localized specialty / business-type catalog management.
abstract final class SpecialtyCatalogUtils {
  SpecialtyCatalogUtils._();

  static String normalizeToken(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static bool namesMatch(LocalizedText a, LocalizedText b) {
    final pairs = [
      (normalizeToken(a.ku), normalizeToken(b.ku)),
      (normalizeToken(a.ar), normalizeToken(b.ar)),
      (normalizeToken(a.en), normalizeToken(b.en)),
    ];
    for (final (left, right) in pairs) {
      if (left.isNotEmpty && right.isNotEmpty && left == right) return true;
    }
    return false;
  }

  static Specialty? findDuplicate(
    List<Specialty> catalog,
    LocalizedText name, {
    required bool forBusiness,
  }) {
    for (final specialty in catalog) {
      if (specialty.isBusinessType != forBusiness) continue;
      if (namesMatch(specialty.name, name)) return specialty;
    }
    return null;
  }

  static String slugFromName(LocalizedText name) {
    final source = name.en.trim().isNotEmpty
        ? name.en
        : name.ku.trim().isNotEmpty
            ? name.ku
            : name.ar;
    final slug = source
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return slug.isEmpty ? 'type' : slug;
  }

  static String uniqueId(
    List<Specialty> catalog,
    LocalizedText name, {
    required bool forBusiness,
  }) {
    final prefix = forBusiness ? 'biz_' : '';
    var base = '$prefix${slugFromName(name)}';
    if (base == prefix) base = '${prefix}type';
    var candidate = base;
    var i = 2;
    while (catalog.any((s) => s.id == candidate)) {
      candidate = '${base}_$i';
      i++;
    }
    return candidate;
  }

  static List<Specialty> forAccountType(
    List<Specialty> catalog,
    bool forBusiness,
  ) =>
      catalog.where((s) => s.isBusinessType == forBusiness).toList();

  static List<Specialty> filterQuery(
    List<Specialty> catalog,
    String query,
  ) {
    final q = normalizeToken(query);
    if (q.isEmpty) return catalog;
    return catalog.where((s) {
      final n = s.name;
      return normalizeToken(n.ku).contains(q) ||
          normalizeToken(n.ar).contains(q) ||
          normalizeToken(n.en).contains(q);
    }).toList();
  }
}
