import '../data/investigation_catalog.dart';
import '../models/investigation_catalog_item.dart';
import '../models/investigation_category.dart';

/// Fast in-memory investigation search — results grouped by category.
class InvestigationSearchService {
  InvestigationSearchService({
    InvestigationCatalog? catalog,
    Iterable<InvestigationCatalogItem>? additionalItems,
  })  : _catalog = catalog ?? InvestigationCatalog.instance,
        _additional = List<InvestigationCatalogItem>.unmodifiable(
          additionalItems ?? const <InvestigationCatalogItem>[],
        );

  final InvestigationCatalog _catalog;
  final List<InvestigationCatalogItem> _additional;

  List<InvestigationCatalogItem> get _allItems {
    final builtIn = _catalog.all;
    final ids = builtIn.map((i) => i.id).toSet();
    return [
      ...builtIn,
      ..._additional.where((i) => !i.archived && !ids.contains(i.id)),
    ];
  }

  List<InvestigationCatalogItem> search({
    required String query,
    int limit = 24,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _allItems.take(limit).toList();

    final results = <InvestigationCatalogItem>[];
    for (final item in _allItems) {
      if (item.containsQuery(q)) results.add(item);
      if (results.length >= limit) break;
    }
    return results;
  }

  Map<InvestigationCategory, List<InvestigationCatalogItem>> grouped({
    required String query,
    int perCategory = 8,
  }) {
    final items = search(query: query, limit: 200);
    final map = <InvestigationCategory, List<InvestigationCatalogItem>>{};
    for (final category in InvestigationCategory.values) {
      final group = items.where((i) => i.category == category).take(perCategory).toList();
      if (group.isNotEmpty) map[category] = group;
    }
    return map;
  }
}
