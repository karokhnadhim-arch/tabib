import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network reachability — used for offline indicators and deferred sync only.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    _subscription = Connectivity().onConnectivityChanged.listen(_onChanged);
    _refresh();
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  Future<void> _refresh() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _apply(results);
    } catch (_) {
      // Assume online when the plugin is unavailable (e.g. tests).
      _apply([ConnectivityResult.wifi]);
    }
  }

  void _onChanged(List<ConnectivityResult> results) => _apply(results);

  void _apply(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (_isOnline == online) return;
    _isOnline = online;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
