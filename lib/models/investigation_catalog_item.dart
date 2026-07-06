import 'investigation_category.dart';

/// Entry in the Tabib investigation catalog.
class InvestigationCatalogItem {
  const InvestigationCatalogItem({
    required this.id,
    required this.name,
    required this.category,
  });

  final String id;
  final String name;
  final InvestigationCategory category;

  bool containsQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q);
  }
}
