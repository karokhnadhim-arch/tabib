import 'package:flutter/foundation.dart';

import '../core/utils/subscription_manager.dart';
import '../models/advertisement.dart';
import 'backend/clinic_backend.dart';

/// City-targeted patient advertisements with national fallback.
class AdvertisementService extends ChangeNotifier {
  AdvertisementService({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;
  final SubscriptionManager _subscriptions = SubscriptionManager();
  List<Advertisement> _ads = [];
  String? _city;

  List<Advertisement> get advertisements => List.unmodifiable(_ads);

  void watchForCity(String? city) {
    final normalized = city?.trim();
    if (_city == normalized) return;
    _city = normalized;
    _subscriptions.replace(
      'ads',
      _backend.watchAdvertisements(city: normalized),
      (list) {
        _ads = list;
        notifyListeners();
      },
    );
  }

  void stopWatching() {
    _subscriptions.cancel('ads');
    _ads = [];
    _city = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
  }
}
