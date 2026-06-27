import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/clinic.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';

class OwnerSubscriptionsScreen extends StatelessWidget {
  const OwnerSubscriptionsScreen({super.key});

  String _planLabel(AppLocalizations l10n, SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return l10n.subscriptionPlanFree;
      case SubscriptionPlan.basic:
        return l10n.subscriptionPlanBasic;
      case SubscriptionPlan.premium:
        return l10n.subscriptionPlanPremium;
    }
  }

  Future<void> _editSubscription(
    BuildContext context,
    Clinic clinic,
  ) async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    var plan = clinic.subscriptionPlan;
    var active = clinic.subscriptionActive;
    var expiresAt = clinic.subscriptionExpiresAt;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.manageSubscriptions),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<SubscriptionPlan>(
                value: plan,
                decoration: InputDecoration(labelText: l10n.subscriptionPlan),
                items: SubscriptionPlan.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(_planLabel(l10n, p)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => plan = v ?? plan),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.subscriptionActive),
                value: active,
                onChanged: (v) => setState(() => active = v),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.subscriptionExpires),
                subtitle: Text(
                  expiresAt != null
                      ? DateFormat.yMMMd().format(expiresAt!)
                      : l10n.noExpiry,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: expiresAt ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() => expiresAt = picked);
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancelQueue),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !context.mounted) return;

    final err = await auth.updateClinicSubscription(
      clinicId: clinic.id,
      plan: plan,
      active: active,
      expiresAt: expiresAt,
    );
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canManageSubscriptions(auth)) {
      return const SizedBox.shrink();
    }

    final clinics = context.watch<ClinicDataService>().clinics;

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.manageSubscriptions),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: clinics.isEmpty
            ? Center(child: Text(l10n.manageClinics))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: clinics.length,
                itemBuilder: (context, i) {
                  final clinic = clinics[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        clinic.subscriptionActive
                            ? Icons.verified_outlined
                            : Icons.block_outlined,
                        color: clinic.subscriptionActive
                            ? AppTheme.medicalGreen
                            : Colors.red,
                      ),
                      title: Text(clinic.name.localized(context)),
                      subtitle: Text(
                        [
                          _planLabel(l10n, clinic.subscriptionPlan),
                          clinic.subscriptionActive
                              ? l10n.accountActive
                              : l10n.accountInactive,
                          if (clinic.subscriptionExpiresAt != null)
                            DateFormat.yMMMd()
                                .format(clinic.subscriptionExpiresAt!),
                        ].join(' · '),
                      ),
                      isThreeLine: clinic.subscriptionExpiresAt != null,
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editSubscription(context, clinic),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
