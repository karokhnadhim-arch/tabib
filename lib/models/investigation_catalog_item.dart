import 'investigation_category.dart';

/// Entry in the Tabib investigation catalog.
class InvestigationCatalogItem {
  const InvestigationCatalogItem({
    required this.id,
    required this.name,
    required this.category,
    this.archived = false,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final InvestigationCategory category;
  final bool archived;
  final bool isCustom;

  bool containsQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q);
  }

  InvestigationCatalogItem copyWith({
    String? name,
    InvestigationCategory? category,
    bool? archived,
  }) {
    return InvestigationCatalogItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      archived: archived ?? this.archived,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category.storageKey,
        'archived': archived,
        'isCustom': isCustom,
      };

  factory InvestigationCatalogItem.fromMap(String id, Map<String, dynamic> data) {
    return InvestigationCatalogItem(
      id: id,
      name: data['name'] as String? ?? '',
      category: parseInvestigationCategory(data['category'] as String?),
      archived: data['archived'] as bool? ?? false,
      isCustom: data['isCustom'] as bool? ?? true,
    );
  }
}
