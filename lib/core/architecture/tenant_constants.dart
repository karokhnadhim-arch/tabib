/// Platform-wide tenant constants — single default org keeps legacy behavior unchanged.
abstract final class TenantConstants {
  static const defaultOrganizationId = 'org_tabib_default';

  /// Firestore root for organization metadata (future nested collections).
  static const organizationsCollection = 'organizations';

  /// Optional organizationId field name on existing flat collections.
  static const organizationIdField = 'organizationId';

  /// Platform-level metrics for Super Owner (cross-tenant aggregates).
  static const platformMetricsCollection = 'platformMetrics';

  /// Per-organization metrics document path prefix.
  static String orgMetricsDoc(String organizationId) =>
      'orgMetrics/$organizationId';
}
