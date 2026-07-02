import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_app_preferences.dart';

/// Stores notification, privacy, and role-specific preferences per user.
class UserPreferencesService extends ChangeNotifier {
  UserAppPreferences _prefs = const UserAppPreferences();
  String? _userId;

  UserAppPreferences get preferences => _prefs;

  Future<void> bindUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    if (userId == null || userId.isEmpty) {
      _prefs = const UserAppPreferences();
      notifyListeners();
      return;
    }
    final stored = await SharedPreferences.getInstance();
    final raw = stored.getString(_storageKey(userId));
    _prefs = UserAppPreferences.fromMap(
      raw == null ? null : jsonDecode(raw) as Map<String, dynamic>,
    );
    notifyListeners();
  }

  Future<void> update(UserAppPreferences prefs) async {
    _prefs = prefs;
    notifyListeners();
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;
    final stored = await SharedPreferences.getInstance();
    await stored.setString(_storageKey(userId), jsonEncode(prefs.toMap()));
  }

  Future<void> updateField(
    UserAppPreferences Function(UserAppPreferences current) transform,
  ) async {
    await update(transform(_prefs));
  }

  String _storageKey(String userId) => 'user_prefs_$userId';
}
