import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FavoriteKind { doctor, business }

/// Patient favorites for doctors and businesses (provider document ids).
class FavoritesService extends ChangeNotifier {
  final Set<String> _doctorIds = {};
  final Set<String> _businessIds = {};
  String? _userId;

  List<String> get favoriteDoctorIds => List.unmodifiable(_doctorIds);
  List<String> get favoriteBusinessIds => List.unmodifiable(_businessIds);

  Future<void> bindUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _doctorIds.clear();
    _businessIds.clear();
    if (userId == null || userId.isEmpty) {
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _doctorIds.addAll(prefs.getStringList(_key(userId, FavoriteKind.doctor)) ?? []);
    _businessIds
        .addAll(prefs.getStringList(_key(userId, FavoriteKind.business)) ?? []);
    notifyListeners();
  }

  bool isFavorite(String providerId, FavoriteKind kind) {
    return kind == FavoriteKind.doctor
        ? _doctorIds.contains(providerId)
        : _businessIds.contains(providerId);
  }

  Future<void> toggle(String providerId, FavoriteKind kind) async {
    final set = kind == FavoriteKind.doctor ? _doctorIds : _businessIds;
    if (set.contains(providerId)) {
      set.remove(providerId);
    } else {
      set.add(providerId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String providerId, FavoriteKind kind) async {
    final set = kind == FavoriteKind.doctor ? _doctorIds : _businessIds;
    if (!set.remove(providerId)) return;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key(userId, FavoriteKind.doctor),
      _doctorIds.toList(),
    );
    await prefs.setStringList(
      _key(userId, FavoriteKind.business),
      _businessIds.toList(),
    );
  }

  String _key(String userId, FavoriteKind kind) =>
      'favorites_${kind.name}_$userId';
}
