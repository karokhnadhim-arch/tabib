import 'package:flutter/foundation.dart';

import '../core/architecture/platform_api_contract.dart';
import '../models/organization.dart';
import 'organization_service.dart';

/// Organization billing presentation layer — no payment processor integration yet.
class OrganizationBillingService extends ChangeNotifier implements PlatformBillingApi {
  OrganizationBillingService({required OrganizationService organizations})
      : _organizations = organizations;

  final OrganizationService _organizations;

  @override
  Future<OrganizationBillingSnapshot> fetchBilling(String organizationId) async {
    final org = await _organizations.getOrganization(organizationId);
    if (org == null) {
      throw StateError('Organization not found');
    }
    return OrganizationBillingSnapshot(
      organizationId: organizationId,
      currentPlan: org.billingPlan,
      expiresAt: org.billingExpiresAt,
      usageLimitsLabel: _limitsFor(org.billingPlan),
      paymentHistory: _demoHistory(org),
    );
  }

  String _limitsFor(OrganizationBillingPlan plan) => switch (plan) {
        OrganizationBillingPlan.trial => 'Up to 5 doctors · 500 patients · 1 GB storage',
        OrganizationBillingPlan.monthly => 'Up to 25 doctors · 5,000 patients · 10 GB storage',
        OrganizationBillingPlan.annual => 'Up to 100 doctors · 25,000 patients · 50 GB storage',
        OrganizationBillingPlan.enterprise => 'Unlimited doctors · custom storage · SLA support',
      };

  List<OrganizationPaymentRecord> _demoHistory(Organization org) {
    return [
      OrganizationPaymentRecord(
        id: 'pay_${org.id}_1',
        amountLabel: _priceLabel(org.billingPlan),
        paidAt: DateTime.now().subtract(const Duration(days: 30)),
        plan: org.billingPlan,
      ),
    ];
  }

  String _priceLabel(OrganizationBillingPlan plan) => switch (plan) {
        OrganizationBillingPlan.trial => '0 IQD',
        OrganizationBillingPlan.monthly => '120,000 IQD',
        OrganizationBillingPlan.annual => '1,200,000 IQD',
        OrganizationBillingPlan.enterprise => 'Custom',
      };
}
