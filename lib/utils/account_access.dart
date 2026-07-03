import '../models/account_status.dart';
import '../models/clinic.dart';
import '../models/user_account.dart';
import '../core/utils/clinic_subscription.dart';

/// Login access rules for user accounts.
abstract final class AccountAccess {
  static String? loginBlockCode({
    required UserAccount user,
    Clinic? clinic,
  }) {
    if (user.isSystemOwner) return null;
    if (user.role == UserRole.admin) return null;

    switch (user.accountStatus) {
      case AccountStatus.suspended:
        return 'account_suspended';
      case AccountStatus.disabled:
        return 'account_disabled';
      case AccountStatus.expiredSubscription:
        return 'account_subscription_expired';
      case AccountStatus.active:
        break;
    }

    if (_staffRole(user) && clinic != null && ClinicSubscriptionHelper.isExpired(clinic)) {
      return 'account_subscription_expired';
    }

    return null;
  }

  static bool _staffRole(UserAccount user) =>
      user.role == UserRole.doctor ||
      user.role == UserRole.secretary ||
      user.role == UserRole.admin;
}
