import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/organization.dart';
import '../../../presentation/widgets/system_owner_guard.dart';
import '../../../services/organization_billing_service.dart';
import '../../../services/tenant_context_service.dart';

/// Organization subscription and usage — presentation layer only (no payment processor).
class OrganizationBillingScreen extends StatefulWidget {
  const OrganizationBillingScreen({super.key});

  @override
  State<OrganizationBillingScreen> createState() =>
      _OrganizationBillingScreenState();
}

class _OrganizationBillingScreenState extends State<OrganizationBillingScreen> {
  OrganizationBillingSnapshot? _billing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final orgId = context.read<TenantContextService>().activeOrganizationId;
    final billing =
        await context.read<OrganizationBillingService>().fetchBilling(orgId);
    if (!mounted) return;
    setState(() {
      _billing = billing;
      _loading = false;
    });
  }

  String _planLabel(AppLocalizations l10n, OrganizationBillingPlan plan) =>
      switch (plan) {
        OrganizationBillingPlan.trial => l10n.planTrial,
        OrganizationBillingPlan.monthly => l10n.planMonthly,
        OrganizationBillingPlan.annual => l10n.planAnnual,
        OrganizationBillingPlan.enterprise => l10n.planEnterprise,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final billing = _billing;
    final dateFormat = DateFormat.yMMMd();

    return SystemOwnerGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          title: Text(l10n.organizationBilling),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : billing == null
                ? Center(child: Text(l10n.noDataAvailable))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(l10n.organizationBillingHint,
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _row(l10n.currentPlan,
                                  _planLabel(l10n, billing.currentPlan)),
                              _row(
                                l10n.expirationDate,
                                billing.expiresAt != null
                                    ? dateFormat.format(billing.expiresAt!)
                                    : '—',
                              ),
                              _row(l10n.usageLimits, billing.usageLimitsLabel),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.comingSoon)),
                                  );
                                },
                                icon: const Icon(Icons.upgrade_outlined),
                                label: Text(l10n.upgradePlan),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.paymentHistory,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            for (final payment in billing.paymentHistory) ...[
                              ListTile(
                                leading: const Icon(Icons.receipt_long_outlined),
                                title: Text(payment.amountLabel),
                                subtitle: Text(
                                  '${_planLabel(l10n, payment.plan)} · ${dateFormat.format(payment.paidAt)}',
                                ),
                              ),
                              if (payment != billing.paymentHistory.last)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
