import '../../models/organization.dart';

/// Future REST/GraphQL boundary — business services stay unchanged behind this contract.
abstract class PlatformOrganizationApi {
  Future<List<Organization>> listOrganizations();
  Future<Organization?> getOrganization(String id);
  Future<Organization> createOrganization({required String name});
  Future<Organization> suspendOrganization(String id);
  Future<void> deleteOrganization(String id);
  Future<PlatformGlobalStats> fetchGlobalStats();
}

abstract class PlatformBillingApi {
  Future<OrganizationBillingSnapshot> fetchBilling(String organizationId);
}

abstract class PlatformTenantApi {
  Future<OrganizationSettings> fetchSettings(String organizationId);
  Future<OrganizationSettings> updateSettings(OrganizationSettings settings);
}
