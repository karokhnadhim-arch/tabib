import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/utils/clinic_subscription.dart';
import '../domain/repositories/repositories.dart';
import '../models/clinic.dart';
import '../models/notification.dart';
import '../models/user_account.dart';
import 'backend/clinic_backend.dart';
import 'clinic_data_service.dart';
import 'staff_data_service.dart';

/// Watches clinic subscriptions in real time, sends alerts, and auto-deactivates.
///
/// Uses [ClinicDataService] and [StaffDataService] instead of duplicate
/// Firestore listeners.
class SubscriptionMonitorService extends ChangeNotifier {
  SubscriptionMonitorService({
    required ClinicBackend backend,
    required ClinicDataService catalog,
    required StaffDataService staffData,
    required NotificationRepository notifications,
  })  : _backend = backend,
        _catalog = catalog,
        _staffData = staffData,
        _notifications = notifications;

  final ClinicBackend _backend;
  final ClinicDataService _catalog;
  final StaffDataService _staffData;
  final NotificationRepository _notifications;

  VoidCallback? _catalogListener;
  VoidCallback? _staffListener;

  List<Clinic> get clinics => _catalog.clinics;

  void start() {
    _catalogListener ??= () {
      notifyListeners();
      unawaited(_evaluateAll(_catalog.clinics));
    };
    _staffListener ??= () {
      unawaited(_evaluateAll(_catalog.clinics));
    };

    _catalog.addListener(_catalogListener!);
    _staffData.addListener(_staffListener!);

    if (_catalog.isCatalogLoaded) {
      unawaited(_evaluateAll(_catalog.clinics));
    }
  }

  Future<void> _evaluateAll(List<Clinic> clinics) async {
    for (final clinic in clinics) {
      await _evaluateClinic(clinic);
    }
  }

  Future<void> _evaluateClinic(Clinic clinic) async {
    final days = ClinicSubscriptionHelper.remainingDays(clinic);
    final status = ClinicSubscriptionHelper.statusFor(clinic);
    var updated = clinic;

    if (status == ClinicSubscriptionStatus.expired &&
        clinic.subscriptionActive) {
      updated = updated.copyWith(subscriptionActive: false);
      await _backend.upsertClinic(updated);
    }

    if (days == ClinicSubscriptionHelper.expiringSoonDays &&
        !updated.subscriptionWarned7Days &&
        status != ClinicSubscriptionStatus.expired) {
      await _notifyStakeholders(
        updated,
        titleKey: 'warn7',
        bodyKey: 'warn7',
      );
      updated = updated.copyWith(subscriptionWarned7Days: true);
      await _backend.upsertClinic(updated);
    }

    if (days == 0 &&
        !updated.subscriptionExpiredNotified &&
        updated.subscriptionExpiresAt != null) {
      await _notifyStakeholders(
        updated,
        titleKey: 'expired',
        bodyKey: 'expired',
      );
      updated = updated.copyWith(subscriptionExpiredNotified: true);
      await _backend.upsertClinic(updated);
    }
  }

  Future<void> _notifyStakeholders(
    Clinic clinic, {
    required String titleKey,
    required String bodyKey,
  }) async {
    final recipients = _recipientsForClinic(clinic);
    for (final userId in recipients) {
      await _notifications.sendNotification(
        userId: userId,
        title: titleKey == 'warn7'
            ? 'Subscription expiring soon'
            : 'Subscription expired',
        body: titleKey == 'warn7'
            ? 'Your subscription will expire in 7 days.'
            : 'Your subscription has expired. Please renew to restore access.',
        type: AppNotificationType.subscription.name,
      );
    }
  }

  Set<String> _recipientsForClinic(Clinic clinic) {
    final staff = _staffData.staff;
    final ids = <String>{};
    for (final account in staff) {
      if (account.isSystemOwner) {
        ids.add(account.id);
        continue;
      }
      if (account.role == UserRole.doctor &&
          account.clinicId == clinic.id) {
        ids.add(account.id);
        continue;
      }
      if (account.role == UserRole.secretary) {
        if (account.clinicId == clinic.id) {
          ids.add(account.id);
          continue;
        }
        final linkedDoctor = staff
            .where((s) => s.doctorId == account.linkedDoctorId)
            .firstOrNull;
        if (linkedDoctor?.clinicId == clinic.id) {
          ids.add(account.id);
        }
      }
    }
    return ids;
  }

  @override
  void dispose() {
    if (_catalogListener != null) {
      _catalog.removeListener(_catalogListener!);
    }
    if (_staffListener != null) {
      _staffData.removeListener(_staffListener!);
    }
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
