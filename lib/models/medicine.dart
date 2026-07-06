/// Entry in the Tabib medicine catalog (generic + brands + strength).
class Medicine {
  const Medicine({
    required this.id,
    required this.genericName,
    required this.brandNames,
    required this.strength,
    required this.form,
  });

  final String id;
  final String genericName;
  final List<String> brandNames;
  final String strength;
  final String form;

  String get displayLabel => '$genericName — $strength ($form)';

  String get primaryBrand => brandNames.isNotEmpty ? brandNames.first : genericName;

  String matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return '';
    final blob =
        '${genericName.toLowerCase()} ${brandNames.join(' ').toLowerCase()} '
        '${strength.toLowerCase()} ${form.toLowerCase()}';
    return blob.contains(q) ? genericName : '';
  }

  bool containsQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final blob =
        '${genericName.toLowerCase()} ${brandNames.join(' ').toLowerCase()} '
        '${strength.toLowerCase()} ${form.toLowerCase()}';
    return blob.contains(q);
  }
}
