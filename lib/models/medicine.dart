/// Entry in the Tabib medicine catalog (generic + brands + strength).
class Medicine {
  const Medicine({
    required this.id,
    required this.genericName,
    required this.brandNames,
    required this.strength,
    required this.form,
    this.category,
    this.archived = false,
    this.isCustom = false,
  });

  final String id;
  final String genericName;
  final List<String> brandNames;
  final String strength;
  final String form;
  final String? category;
  final bool archived;
  final bool isCustom;

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

  Medicine copyWith({
    String? genericName,
    List<String>? brandNames,
    String? strength,
    String? form,
    String? category,
    bool? archived,
  }) {
    return Medicine(
      id: id,
      genericName: genericName ?? this.genericName,
      brandNames: brandNames ?? this.brandNames,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      category: category ?? this.category,
      archived: archived ?? this.archived,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toMap() => {
        'genericName': genericName,
        'brandNames': brandNames,
        'strength': strength,
        'form': form,
        if (category != null) 'category': category,
        'archived': archived,
        'isCustom': isCustom,
      };

  factory Medicine.fromMap(String id, Map<String, dynamic> data) {
    final brands = data['brandNames'];
    return Medicine(
      id: id,
      genericName: data['genericName'] as String? ?? '',
      brandNames: brands is List
          ? brands.map((e) => e.toString()).toList()
          : const [],
      strength: data['strength'] as String? ?? '',
      form: data['form'] as String? ?? '',
      category: data['category'] as String?,
      archived: data['archived'] as bool? ?? false,
      isCustom: data['isCustom'] as bool? ?? true,
    );
  }
}
