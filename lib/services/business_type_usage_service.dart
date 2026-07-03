import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/specialty.dart';

/// Persists the 10 most recently selected business types for quick pick.
class BusinessTypeUsageService extends ChangeNotifier {
  static const _storageKey = 'business_type_recent_usage_v1';
  static const maxRecent = 10;

  List<String> _recentIds = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<String> get recentIds => List.unmodifiable(_recentIds);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _recentIds = prefs.getStringList(_storageKey) ?? [];
    _loaded = true;
    notifyListeners();
  }

  Future<void> recordUsage(String specialtyId) async {
    if (specialtyId.isEmpty) return;
    _recentIds.remove(specialtyId);
    _recentIds.insert(0, specialtyId);
    if (_recentIds.length > maxRecent) {
      _recentIds = _recentIds.sublist(0, maxRecent);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _recentIds);
    notifyListeners();
  }

  List<Specialty> resolveRecent(Iterable<Specialty> catalog) {
    if (_recentIds.isEmpty) return const [];
    final byId = {for (final item in catalog) item.id: item};
    return [
      for (final id in _recentIds)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }
}
