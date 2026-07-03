import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clinic_subscription.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/clinic.dart';
import '../../../models/doctor.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../presentation/widgets/subscription_status_badge.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';

class OwnerSubscriptionsScreen extends StatefulWidget {
  const OwnerSubscriptionsScreen({super.key});

  @override
  State<OwnerSubscriptionsScreen> createState() =>
      _OwnerSubscriptionsScreenState();
}

class _OwnerSubscriptionsScreenState extends State<OwnerSubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = context.read<ClinicDataService>();
      await data.ensureCatalogLoaded();
      await data.loadDoctors(refresh: true);
    });
  }

  Future<void> _editSubscription(
    BuildContext context,
    Clinic clinic,
  ) async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    var plan = clinic.subscriptionPlan;
    var active = clinic.subscriptionActive;
    var startedAt = clinic.subscriptionStartedAt ?? DateTime.now();
    var expiresAt = clinic.subscriptionExpiresAt ??
        ClinicSubscriptionHelper.expiryForPlan(plan, startedAt);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.manageSubscriptions),
          content: SingleChildScrollView(
            child: Column(
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
                          child: Text(subscriptionPlanLabel(l10n, p)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      plan = v;
                      expiresAt =
                          ClinicSubscriptionHelper.expiryForPlan(plan, startedAt);
                    });
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.subscriptionActive,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  value: active,
                  onChanged: (v) => setState(() => active = v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.subscriptionStarted),
                  subtitle: Text(DateFormat.yMMMd().format(startedAt)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: startedAt,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          startedAt = picked;
                          expiresAt = ClinicSubscriptionHelper.expiryForPlan(
                            plan,
                            startedAt,
                          );
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.subscriptionExpires),
                  subtitle: Text(DateFormat.yMMMd().format(expiresAt)),
                  trailing: IconButton(
                    icon: const Icon(Icons.event_outlined),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: expiresAt,
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancelQueue),
            ),
            FilledButton(
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
      startedAt: startedAt,
      expiresAt: expiresAt,
    );
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  Future<void> _quickRenew(BuildContext context, Clinic clinic) async {
    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final err = await auth.renewClinicSubscription(
      clinicId: clinic.id,
      plan: clinic.subscriptionPlan,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? l10n.subscriptionRenewed : l10n.errorGeneric,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canManageSubscriptions(auth)) {
      return const SizedBox.shrink();
    }

    final data = context.watch<ClinicDataService>();
    final clinics = data.clinics;

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(context, title: l10n.manageSubscriptions),
        body: clinics.isEmpty
            ? Center(child: Text(l10n.manageClinics))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: clinics.length,
                itemBuilder: (context, i) {
                  final clinic = clinics[i];
                  final doctors = data.doctors.where((d) => d.clinicId == clinic.id);
                  return _ClinicSubscriptionCard(
                    clinic: clinic,
                    doctors: doctors.toList(),
                    onEdit: () => _editSubscription(context, clinic),
                    onRenew: () => _quickRenew(context, clinic),
                  );
                },
              ),
      ),
    );
  }
}

class _ClinicSubscriptionCard extends StatelessWidget {
  const _ClinicSubscriptionCard({
    required this.clinic,
    required this.doctors,
    required this.onEdit,
    required this.onRenew,
  });

  final Clinic clinic;
  final List<Doctor> doctors;
  final VoidCallback onEdit;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ClinicSubscriptionHelper.statusFor(clinic);
    final days = ClinicSubscriptionHelper.remainingDays(clinic);
    final started = clinic.subscriptionStartedAt;
    final expires = clinic.subscriptionExpiresAt;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name.localized(context),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subscriptionPlanLabel(l10n, clinic.subscriptionPlan),
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SubscriptionStatusBadge(
                    status: status,
                    remainingDays: days,
                    compact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.play_circle_outline,
              label: l10n.subscriptionStarted,
              value: started != null
                  ? DateFormat.yMMMd().format(started)
                  : l10n.noExpiry,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.event_outlined,
              label: l10n.subscriptionExpires,
              value: expires != null
                  ? DateFormat.yMMMd().format(expires)
                  : l10n.noExpiry,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.timelapse_outlined,
              label: l10n.subscriptionRemainingDays,
              value: days >= 999
                  ? l10n.noExpiry
                  : days < 0
                      ? l10n.subscriptionExpiredDaysAgo(-days)
                      : l10n.subscriptionDaysRemaining(days),
            ),
            if (doctors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.assignedDoctors,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              ...doctors.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_services_outlined, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(d.name.localized(context))),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            ResponsiveActionButtons(
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l10n.edit),
                ),
                FilledButton.icon(
                  onPressed: onRenew,
                  icon: const Icon(Icons.autorenew, size: 18),
                  label: Text(l10n.renewSubscription),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLabelValueRow(
      icon: icon,
      label: '$label:',
      value: value,
    );
  }
}
