import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/provider_catalog_mode.dart';

/// Tracks recently viewed doctors and businesses for quick re-booking.
class RecentlyVisitedService extends ChangeNotifier {
  static const _doctorsKey = 'recent_doctors_v1';
  static const _businessesKey = 'recent_businesses_v1';
  static const maxItems = 12;

  List<String> _doctorIds = [];
  List<String> _businessIds = [];
  String? _userId;

  List<String> get recentDoctorIds => List.unmodifiable(_doctorIds);
  List<String> get recentBusinessIds => List.unmodifiable(_businessIds);

  Future<void> bindUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _doctorIds = [];
    _businessIds = [];
    if (userId == null || userId.isEmpty) {
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _doctorIds = prefs.getStringList('${_doctorsKey}_$userId') ?? [];
    _businessIds = prefs.getStringList('${_businessesKey}_$userId') ?? [];
    notifyListeners();
  }

  Future<void> recordVisit(String providerId, ProviderCatalogMode mode) async {
    if (_userId == null || providerId.isEmpty) return;
    final list = mode == ProviderCatalogMode.businesses
        ? _businessIds
        : _doctorIds;
    list.remove(providerId);
    list.insert(0, providerId);
    if (list.length > maxItems) {
      list.removeRange(maxItems, list.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      mode == ProviderCatalogMode.businesses
          ? '${_businessesKey}_$_userId'
          : '${_doctorsKey}_$_userId',
      list,
    );
    notifyListeners();
  }
}
