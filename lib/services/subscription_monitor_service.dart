import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/utils/clinic_subscription.dart';
import '../core/utils/subscription_manager.dart';
import '../domain/repositories/repositories.dart';
import '../models/clinic.dart';
import '../models/notification.dart';
import '../models/user_account.dart';
import 'backend/clinic_backend.dart';

/// Watches clinic subscriptions in real time, sends alerts, and auto-deactivates.
class SubscriptionMonitorService extends ChangeNotifier {
  SubscriptionMonitorService({
    required ClinicBackend backend,
    required NotificationRepository notifications,
  })  : _backend = backend,
        _notifications = notifications;

  final ClinicBackend _backend;
  final NotificationRepository _notifications;
  final SubscriptionManager _subscriptions = SubscriptionManager();

  List<Clinic> _clinics = const [];
  List<UserAccount> _staff = const [];

  List<Clinic> get clinics => List.unmodifiable(_clinics);

  void start() {
    _subscriptions.replace(
      'clinics',
      _backend.watchClinics(),
      (clinics) {
        _clinics = clinics;
        notifyListeners();
        unawaited(_evaluateAll(clinics));
      },
    );
    _subscriptions.replace(
      'staff',
      _backend.watchStaff(),
      (staff) {
        _staff = staff;
        unawaited(_evaluateAll(_clinics));
      },
    );
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
            ? 'Your subscription will expire in 7 days. Please renew to avoid service interruption.'
            : 'Your subscription has expired today. Please renew to restore full access.',
        type: AppNotificationType.subscription.name,
      );
    }
  }

  Set<String> _recipientsForClinic(Clinic clinic) {
    final ids = <String>{};
    for (final account in _staff) {
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
        final linkedDoctor = _staff
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
    _subscriptions.cancelAll();
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
