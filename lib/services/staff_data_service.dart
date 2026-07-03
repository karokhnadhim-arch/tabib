import 'package:flutter/foundation.dart';

import '../core/utils/subscription_manager.dart';
import '../core/privacy/system_owner_privacy.dart';
import '../models/user_account.dart';
import 'backend/clinic_backend.dart';

/// Single shared staff catalog — one real-time listener for the whole app.
class StaffDataService extends ChangeNotifier {
  StaffDataService({required ClinicBackend backend}) : _backend = backend;

  final ClinicBackend _backend;
  final SubscriptionManager _subscriptions = SubscriptionManager();

  List<UserAccount> _staffRaw = const [];
  bool _realtimeStarted = false;

  /// Staff visible in admin UI, resolvers, and statistics (excludes Super Admin).
  List<UserAccount> get staff =>
      List.unmodifiable(SystemOwnerPrivacy.filterPublic(_staffRaw));

  /// Full staff catalog — internal services only (e.g. owner notifications).
  List<UserAccount> get staffIncludingHidden => List.unmodifiable(_staffRaw);

  List<UserAccount> get platformAdmins =>
      SystemOwnerPrivacy.filterAdminRoster(_staffRaw);

  /// Start one global staff listener (admin + subscription monitor).
  void startRealtime() {
    if (_realtimeStarted) return;
    _realtimeStarted = true;
    _subscriptions.replace(
      'staff',
      _backend.watchStaff(),
      (list) {
        _staffRaw = list;
        notifyListeners();
      },
    );
  }

  /// One-shot fetch for uniqueness checks — no ephemeral stream subscription.
  Future<List<UserAccount>> fetchStaff() => _backend.fetchStaff();

  List<UserAccount> secretariesForDoctor(String doctorId) => staff
      .where(
        (s) =>
            s.role == UserRole.secretary && s.linkedDoctorId == doctorId,
      )
      .toList();

  Future<List<UserAccount>> fetchSecretariesForDoctor(String doctorId) =>
      _backend.fetchSecretariesForDoctor(doctorId);

  UserAccount? accountById(String id) {
    for (final account in staffIncludingHidden) {
      if (account.id != id) continue;
      if (SystemOwnerPrivacy.isInternalPlatformAccount(account)) return null;
      return account;
    }
    return null;
  }

  int secretaryCountFor(String doctorId) =>
      secretariesForDoctor(doctorId).length;

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
  }
}
