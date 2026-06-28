import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/clinic_subscription.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/utils/doctor_subscription_resolver.dart';
import '../../l10n/app_localizations.dart';
import '../../models/clinic.dart';
import '../../models/doctor.dart';
import '../../services/auth_service.dart';
import '../../services/clinic_data_service.dart';
import '../../utils/localization_utils.dart';
import 'subscription_status_badge.dart';

/// Subscription summary + one-click renew for admin doctor views.
class AdminDoctorSubscriptionCard extends StatelessWidget {
  const AdminDoctorSubscriptionCard({
    super.key,
    required this.doctor,
    this.onRenewed,
  });

  final Doctor doctor;
  final VoidCallback? onRenewed;

  Future<void> _renew(BuildContext context, Clinic clinic) async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    var plan = clinic.subscriptionPlan;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.renewSubscription),
          content: DropdownButtonFormField<SubscriptionPlan>(
            value: plan,
            decoration: InputDecoration(labelText: l10n.subscriptionPlan),
            items: SubscriptionPlan.values
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(subscriptionPlanLabel(l10n, p)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => plan = v ?? plan),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancelQueue),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.renewSubscription),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !context.mounted) return;

    final err = await auth.renewClinicSubscription(
      clinicId: clinic.id,
      plan: plan,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? l10n.subscriptionRenewed : l10n.errorGeneric,
        ),
      ),
    );
    if (err == null) onRenewed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final clinic = DoctorSubscriptionResolver.clinicFor(doctor, data);
    if (clinic == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.errorGeneric),
        ),
      );
    }

    final status = ClinicSubscriptionHelper.statusFor(clinic);
    final days = ClinicSubscriptionHelper.remainingDays(clinic);
    final started = clinic.subscriptionStartedAt;
    final expires = clinic.subscriptionExpiresAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.subscriptionPlan,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                SubscriptionStatusBadge(
                  status: status,
                  remainingDays: days,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Row(label: l10n.subscriptionPlan, value: subscriptionPlanLabel(l10n, clinic.subscriptionPlan)),
            _Row(
              label: l10n.subscriptionStarted,
              value: started != null
                  ? DateFormat.yMMMd().format(started)
                  : l10n.noExpiry,
            ),
            _Row(
              label: l10n.subscriptionExpires,
              value: expires != null
                  ? DateFormat.yMMMd().format(expires)
                  : l10n.noExpiry,
            ),
            _Row(
              label: l10n.subscriptionRemainingDays,
              value: days >= 999
                  ? l10n.noExpiry
                  : days < 0
                      ? l10n.subscriptionExpiredDaysAgo(-days)
                      : l10n.subscriptionDaysRemaining(days),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _renew(context, clinic),
              icon: const Icon(Icons.autorenew),
              label: Text(
                status == ClinicSubscriptionStatus.expired
                    ? l10n.activateSubscription
                    : l10n.renewSubscription,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ResponsiveLabelValueRow(label: label, value: value),
    );
  }
}

/// Compact subscription row for doctor list tiles.
class DoctorSubscriptionListSubtitle extends StatelessWidget {
  const DoctorSubscriptionListSubtitle({
    super.key,
    required this.doctor,
  });

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final clinic = DoctorSubscriptionResolver.clinicFor(doctor, data);
    final plan = clinic?.subscriptionPlan;
    final days = DoctorSubscriptionResolver.remainingDays(doctor, data);
    final status = DoctorSubscriptionResolver.statusFor(doctor, data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(doctor.clinic.name.localized(context)),
        if (plan != null) ...[
          const SizedBox(height: 2),
          Text(
            subscriptionPlanLabel(l10n, plan),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            if (days < 999)
              Expanded(
                child: Text(
                  days < 0
                      ? l10n.subscriptionExpiredDaysAgo(-days)
                      : l10n.subscriptionDaysRemaining(days),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            SubscriptionStatusBadge(
              status: status,
              remainingDays: days,
              compact: true,
            ),
          ],
        ),
      ],
    );
  }
}
