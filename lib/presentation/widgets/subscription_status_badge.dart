import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/clinic_subscription.dart';
import '../../l10n/app_localizations.dart';

class SubscriptionStatusBadge extends StatelessWidget {
  const SubscriptionStatusBadge({
    super.key,
    required this.status,
    required this.remainingDays,
    this.compact = false,
  });

  final ClinicSubscriptionStatus status;
  final int remainingDays;
  final bool compact;

  Color get _color => switch (status) {
        ClinicSubscriptionStatus.active => AppTheme.medicalGreen,
        ClinicSubscriptionStatus.expiringSoon => const Color(0xFFF9A825),
        ClinicSubscriptionStatus.expired => Colors.red.shade700,
      };

  String _label(AppLocalizations l10n) => switch (status) {
        ClinicSubscriptionStatus.active => l10n.subscriptionStatusActive,
        ClinicSubscriptionStatus.expiringSoon =>
          l10n.subscriptionStatusExpiringSoon,
        ClinicSubscriptionStatus.expired => l10n.subscriptionStatusExpired,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countdown = remainingDays >= 999
        ? l10n.noExpiry
        : remainingDays < 0
            ? l10n.subscriptionExpiredDaysAgo(-remainingDays)
            : l10n.subscriptionDaysRemaining(remainingDays);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: _color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              compact ? _label(l10n) : '${_label(l10n)} · $countdown',
              style: TextStyle(
                color: _color,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 12 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String subscriptionPlanLabel(AppLocalizations l10n, SubscriptionPlan plan) {
  return switch (plan) {
    SubscriptionPlan.oneMonth => l10n.subscriptionPlan1Month,
    SubscriptionPlan.twoMonths => l10n.subscriptionPlan2Months,
    SubscriptionPlan.threeMonths => l10n.subscriptionPlan3Months,
    SubscriptionPlan.sixMonths => l10n.subscriptionPlan6Months,
    SubscriptionPlan.twelveMonths => l10n.subscriptionPlan12Months,
  };
}
