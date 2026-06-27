import 'package:flutter/foundation.dart';

import '../core/utils/subscription_manager.dart';
import '../models/user_account.dart';
import 'backend/clinic_backend.dart';

/// Single shared staff catalog — one real-time listener for the whole app.
class StaffDataService extends ChangeNotifier {
  StaffDataService({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;
  final SubscriptionManager _subscriptions = SubscriptionManager();

  List<UserAccount> _staff = const [];
  bool _realtimeStarted = false;

  List<UserAccount> get staff => List.unmodifiable(_staff);

  /// Start one global staff listener (admin + subscription monitor).
  void startRealtime() {
    if (_realtimeStarted) return;
    _realtimeStarted = true;
    _subscriptions.replace(
      'staff',
      _backend.watchStaff(),
      (list) {
        _staff = list;
        notifyListeners();
      },
    );
  }

  /// One-shot fetch for uniqueness checks — no ephemeral stream subscription.
  Future<List<UserAccount>> fetchStaff() => _backend.fetchStaff();

  List<UserAccount> secretariesForDoctor(String doctorId) => _staff
      .where(
        (s) =>
            s.role == UserRole.secretary && s.linkedDoctorId == doctorId,
      )
      .toList();

  Future<List<UserAccount>> fetchSecretariesForDoctor(String doctorId) =>
      _backend.fetchSecretariesForDoctor(doctorId);

  UserAccount? accountById(String id) {
    try {
      return _staff.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  int secretaryCountFor(String doctorId) =>
      secretariesForDoctor(doctorId).length;

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
  }
}
