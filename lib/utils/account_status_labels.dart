import '../../l10n/app_localizations.dart';
import '../../models/account_status.dart';

abstract final class AccountStatusLabels {
  static String label(AppLocalizations l10n, AccountStatus status) =>
      switch (status) {
        AccountStatus.active => l10n.accountStatusActive,
        AccountStatus.suspended => l10n.accountStatusSuspended,
        AccountStatus.disabled => l10n.accountStatusDisabled,
        AccountStatus.expiredSubscription =>
          l10n.accountStatusExpiredSubscription,
      };

  static String loginBlockMessage(AppLocalizations l10n, String code) =>
      switch (code) {
        'account_suspended' => l10n.accountSuspendedMessage,
        'account_disabled' => l10n.accountDisabledMessage,
        'account_subscription_expired' =>
          l10n.accountSubscriptionExpiredLoginMessage,
        'account_deactivated' => l10n.accountDeactivated,
        _ => l10n.invalidCredentials,
      };
}
