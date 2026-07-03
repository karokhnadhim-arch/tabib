import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clinic_subscription.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/clinic.dart';
import '../../../services/auth_service.dart';
import '../../../utils/localization_utils.dart';
import '../../widgets/subscription_status_badge.dart';

class SubscriptionExpiredScreen extends StatelessWidget {
  const SubscriptionExpiredScreen({
    super.key,
    required this.clinic,
    this.onViewRecords,
    this.onRenewed,
  });

  final Clinic clinic;
  final VoidCallback? onViewRecords;
  final VoidCallback? onRenewed;

  Future<void> _renew(BuildContext context) async {
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
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionRenewed)),
      );
      onRenewed?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final expiresAt = clinic.subscriptionExpiresAt;

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 72,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.subscriptionExpiredTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medicalBlueDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.subscriptionExpiredMessage,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    clinic.name.localized(context),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (expiresAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.subscriptionExpires}: ${DateFormat.yMMMd().format(expiresAt)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SubscriptionStatusBadge(
                    status: ClinicSubscriptionStatus.expired,
                    remainingDays: ClinicSubscriptionHelper.remainingDays(clinic),
                  ),
                  const SizedBox(height: 28),
                  if (onViewRecords != null)
                    OutlinedButton.icon(
                      onPressed: onViewRecords,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: Text(l10n.viewPatientRecords),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  if (auth.canAccessAdminPanel) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _renew(context),
                      icon: const Icon(Icons.autorenew),
                      label: Text(l10n.renewSubscription),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
