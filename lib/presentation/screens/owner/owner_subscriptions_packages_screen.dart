import 'package:flutter/material.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../core/utils/clinic_subscription.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/admin_guard.dart';
import 'owner_module_hub_screen.dart';

/// Subscriptions and package duration management hub.
class OwnerSubscriptionsPackagesScreen extends StatelessWidget {
  const OwnerSubscriptionsPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.ownerNavSubscriptionsPackages,
        header: l10n.subscriptionPackagesHint,
        items: [
          OwnerHubItem(
            icon: Icons.card_membership_outlined,
            title: l10n.manageSubscriptions,
            subtitle: l10n.manageSubscriptionsHint,
            route: '${AdminRoutes.platformPrefix}/subscriptions',
          ),
          OwnerHubItem(
            icon: Icons.inventory_2_outlined,
            title: l10n.createPackages,
            subtitle: l10n.createPackagesHint,
            comingSoon: true,
          ),
          for (final plan in SubscriptionPlan.values)
            OwnerHubItem(
              icon: Icons.calendar_month_outlined,
              title: _planLabel(l10n, plan),
              subtitle: l10n.subscriptionPlanHint,
              route: '${AdminRoutes.platformPrefix}/subscriptions',
            ),
          OwnerHubItem(
            icon: Icons.play_circle_outline,
            title: l10n.activateSubscription,
            subtitle: l10n.activateSubscriptionHint,
            route: '${AdminRoutes.platformPrefix}/subscriptions',
          ),
          OwnerHubItem(
            icon: Icons.autorenew,
            title: l10n.renewSubscription,
            subtitle: l10n.renewSubscriptionHint,
            route: '${AdminRoutes.platformPrefix}/subscriptions',
          ),
          OwnerHubItem(
            icon: Icons.pause_circle_outline,
            title: l10n.suspendSubscription,
            subtitle: l10n.suspendSubscriptionHint,
            route: '${AdminRoutes.platformPrefix}/subscriptions',
          ),
          OwnerHubItem(
            icon: Icons.timer_outlined,
            title: l10n.remainingDays,
            subtitle: l10n.remainingDaysHint,
            route: '${AdminRoutes.platformPrefix}/subscriptions',
          ),
          OwnerHubItem(
            icon: Icons.notification_important_outlined,
            title: l10n.expirationAlerts,
            subtitle: l10n.expirationAlertsHint,
            route: '${AdminRoutes.platformPrefix}/subscriptions',
          ),
        ],
      ),
    );
  }

  static String _planLabel(AppLocalizations l10n, SubscriptionPlan plan) =>
      switch (plan) {
        SubscriptionPlan.oneMonth => l10n.plan1Month,
        SubscriptionPlan.twoMonths => l10n.plan2Months,
        SubscriptionPlan.threeMonths => l10n.plan3Months,
        SubscriptionPlan.sixMonths => l10n.plan6Months,
        SubscriptionPlan.twelveMonths => l10n.plan12Months,
      };
}
