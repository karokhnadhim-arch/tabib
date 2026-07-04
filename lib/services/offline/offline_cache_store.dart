import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight JSON cache in SharedPreferences — single source for offline blobs.
class OfflineCacheStore {
  OfflineCacheStore._();
  static final instance = OfflineCacheStore._();

  Future<void> putJson(String key, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode({
        'savedAt': DateTime.now().toUtc().toIso8601String(),
        ...payload,
      }),
    );
  }

  Future<Map<String, dynamic>?> getJson(
    String key, {
    Duration? maxAge,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (maxAge != null) {
        final savedAt = DateTime.tryParse(map['savedAt'] as String? ?? '');
        if (savedAt == null ||
            DateTime.now().difference(savedAt.toLocal()) > maxAge) {
          return null;
        }
      }
      return map;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
