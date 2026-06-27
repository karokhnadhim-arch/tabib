import '../../models/clinic.dart';

enum ClinicSubscriptionStatus { active, expiringSoon, expired }

/// Subscription duration plans (months).
enum SubscriptionPlan {
  oneMonth,
  twoMonths,
  threeMonths,
  sixMonths,
  twelveMonths,
}

extension SubscriptionPlanX on SubscriptionPlan {
  String get storageKey => name;

  int get monthCount => switch (this) {
        SubscriptionPlan.oneMonth => 1,
        SubscriptionPlan.twoMonths => 2,
        SubscriptionPlan.threeMonths => 3,
        SubscriptionPlan.sixMonths => 6,
        SubscriptionPlan.twelveMonths => 12,
      };

  static SubscriptionPlan fromKey(String? key) {
    if (key == null || key.isEmpty) return SubscriptionPlan.oneMonth;
    return SubscriptionPlan.values.firstWhere(
      (p) => p.name == key,
      orElse: () => switch (key) {
        'free' || 'basic' => SubscriptionPlan.oneMonth,
        'premium' => SubscriptionPlan.twelveMonths,
        _ => SubscriptionPlan.oneMonth,
      },
    );
  }
}

class ClinicSubscriptionHelper {
  ClinicSubscriptionHelper._();

  static const expiringSoonDays = 7;

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int remainingDays(Clinic clinic) {
    final expiresAt = clinic.subscriptionExpiresAt;
    if (expiresAt == null) return 999;
    return dateOnly(expiresAt).difference(dateOnly(DateTime.now())).inDays;
  }

  static ClinicSubscriptionStatus statusFor(Clinic clinic) {
    if (!clinic.subscriptionActive) return ClinicSubscriptionStatus.expired;
    final expiresAt = clinic.subscriptionExpiresAt;
    if (expiresAt == null) return ClinicSubscriptionStatus.active;
    final days = remainingDays(clinic);
    if (days < 0) return ClinicSubscriptionStatus.expired;
    if (days <= expiringSoonDays) return ClinicSubscriptionStatus.expiringSoon;
    return ClinicSubscriptionStatus.active;
  }

  static bool allowsNewAppointments(Clinic clinic) =>
      statusFor(clinic) != ClinicSubscriptionStatus.expired;

  static bool isExpired(Clinic clinic) =>
      statusFor(clinic) == ClinicSubscriptionStatus.expired;

  static DateTime addMonths(DateTime from, int months) {
    final totalMonths = from.month - 1 + months;
    final year = from.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = from.day > lastDay ? lastDay : from.day;
    return DateTime(year, month, day, from.hour, from.minute, from.second);
  }

  static DateTime expiryForPlan(SubscriptionPlan plan, DateTime start) =>
      addMonths(dateOnly(start), plan.monthCount);

  static Clinic renew({
    required Clinic clinic,
    required SubscriptionPlan plan,
    DateTime? startDate,
  }) {
    final start = dateOnly(startDate ?? DateTime.now());
    return clinic.copyWith(
      subscriptionPlan: plan,
      subscriptionActive: true,
      subscriptionStartedAt: start,
      subscriptionExpiresAt: expiryForPlan(plan, start),
      subscriptionWarned7Days: false,
      subscriptionExpiredNotified: false,
    );
  }
}
