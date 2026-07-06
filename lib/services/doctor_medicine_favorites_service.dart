import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-doctor favorite medicine IDs — local only, instant access.
class DoctorMedicineFavoritesService extends ChangeNotifier {
  static const _prefix = 'doctor_med_favorites_v1_';

  final Map<String, List<String>> _cache = {};

  List<String> favoritesFor(String doctorId) =>
      List.unmodifiable(_cache[doctorId] ?? const []);

  Future<void> load(String doctorId) async {
    if (_cache.containsKey(doctorId)) return;
    final prefs = await SharedPreferences.getInstance();
    _cache[doctorId] = prefs.getStringList('$_prefix$doctorId') ?? [];
    notifyListeners();
  }

  Future<void> toggleFavorite(String doctorId, String medicineId) async {
    await load(doctorId);
    final list = List<String>.from(_cache[doctorId] ?? []);
    if (list.contains(medicineId)) {
      list.remove(medicineId);
    } else {
      list.insert(0, medicineId);
    }
    _cache[doctorId] = list;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('$_prefix$doctorId', list);
    notifyListeners();
  }

  bool isFavorite(String doctorId, String medicineId) {
    return (_cache[doctorId] ?? []).contains(medicineId);
  }
}
