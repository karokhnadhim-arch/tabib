import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/architecture/platform_api_contract.dart';
import '../core/architecture/tenant_constants.dart';
import '../models/organization.dart';

/// Organization lifecycle + global stats — monitoring/admin layer only.
class OrganizationService extends ChangeNotifier implements PlatformOrganizationApi {
  OrganizationService() {
    _seedDefaultOrganization();
  }

  static const _uuid = Uuid();
  static const _settingsCachePrefix = 'org_settings_v1_';

  final List<Organization> _organizations = [];

  List<Organization> get organizations =>
      List.unmodifiable(_organizations.where((o) => o.status != OrganizationStatus.deleted));

  Organization? get defaultOrganization => _organizations
      .where((o) => o.id == TenantConstants.defaultOrganizationId)
      .cast<Organization?>()
      .firstOrNull;

  Organization? byId(String id) {
    try {
      return _organizations.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Organization>> listOrganizations() async =>
      List.unmodifiable(organizations);

  @override
  Future<Organization?> getOrganization(String id) async => byId(id);

  @override
  Future<Organization> createOrganization({required String name}) async {
    final org = Organization(
      id: 'org_${_uuid.v4()}',
      name: name.trim(),
      status: OrganizationStatus.active,
      createdAt: DateTime.now(),
      billingPlan: OrganizationBillingPlan.trial,
      billingExpiresAt: DateTime.now().add(const Duration(days: 14)),
    );
    _organizations.add(org);
    notifyListeners();
    return org;
  }

  @override
  Future<Organization> suspendOrganization(String id) async {
    if (id == TenantConstants.defaultOrganizationId) {
      throw StateError('Default organization cannot be suspended');
    }
    final index = _organizations.indexWhere((o) => o.id == id);
    if (index == -1) throw StateError('Organization not found');
    _organizations[index] = _organizations[index].copyWith(
      status: OrganizationStatus.suspended,
      suspendedAt: DateTime.now(),
    );
    notifyListeners();
    return _organizations[index];
  }

  Future<Organization> activateOrganization(String id) async {
    final index = _organizations.indexWhere((o) => o.id == id);
    if (index == -1) throw StateError('Organization not found');
    _organizations[index] = _organizations[index].copyWith(
      status: OrganizationStatus.active,
      suspendedAt: null,
    );
    notifyListeners();
    return _organizations[index];
  }

  @override
  Future<void> deleteOrganization(String id) async {
    if (id == TenantConstants.defaultOrganizationId) {
      throw StateError('Default organization cannot be deleted');
    }
    final index = _organizations.indexWhere((o) => o.id == id);
    if (index == -1) return;
    _organizations[index] = _organizations[index].copyWith(
      status: OrganizationStatus.deleted,
      suspendedAt: DateTime.now(),
    );
    notifyListeners();
  }

  Future<OrganizationSettings> loadSettings(String organizationId) async {
    final org = byId(organizationId);
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_settingsCachePrefix$organizationId');
    if (cached != null && org != null) {
      return OrganizationSettings(
        organizationId: organizationId,
        logoUrl: org.logoUrl,
        displayName: org.name,
        primaryColorHex: org.primaryColorHex,
        defaultLanguage: org.defaultLanguage,
        workingHoursLabel: '09:00 – 21:00',
        queueRulesSummary: 'Real-time queue (unchanged)',
        appointmentRulesSummary: 'Standard booking windows',
        notificationSettingsSummary: 'Push + SMS enabled',
      );
    }
    return OrganizationSettings(
      organizationId: organizationId,
      logoUrl: org?.logoUrl,
      displayName: org?.name ?? organizationId,
      primaryColorHex: org?.primaryColorHex ?? '1E88E5',
      defaultLanguage: org?.defaultLanguage ?? 'ku',
      workingHoursLabel: '09:00 – 21:00',
      queueRulesSummary: 'Real-time queue (unchanged)',
      appointmentRulesSummary: 'Standard booking windows',
      notificationSettingsSummary: 'Push + SMS enabled',
    );
  }

  Future<void> saveSettings(OrganizationSettings settings) async {
    final index = _organizations.indexWhere((o) => o.id == settings.organizationId);
    if (index != -1) {
      _organizations[index] = _organizations[index].copyWith(
        name: settings.displayName,
        logoUrl: settings.logoUrl,
        primaryColorHex: settings.primaryColorHex,
        defaultLanguage: settings.defaultLanguage,
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_settingsCachePrefix${settings.organizationId}', '1');
    notifyListeners();
  }

  Future<Organization> updateOrganizationPlan({
    required String organizationId,
    required OrganizationBillingPlan plan,
    DateTime? expiresAt,
  }) async {
    final index = _organizations.indexWhere((o) => o.id == organizationId);
    if (index == -1) throw StateError('Organization not found');
    _organizations[index] = Organization(
      id: _organizations[index].id,
      name: _organizations[index].name,
      status: _organizations[index].status,
      createdAt: _organizations[index].createdAt,
      logoUrl: _organizations[index].logoUrl,
      primaryColorHex: _organizations[index].primaryColorHex,
      defaultLanguage: _organizations[index].defaultLanguage,
      billingPlan: plan,
      billingExpiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      suspendedAt: _organizations[index].suspendedAt,
      whiteLabelAppName: _organizations[index].whiteLabelAppName,
      whiteLabelBundleId: _organizations[index].whiteLabelBundleId,
    );
    notifyListeners();
    return _organizations[index];
  }

  @override
  Future<PlatformGlobalStats> fetchGlobalStats() async {
    if (_cachedGlobalStats != null) return _cachedGlobalStats!;
    final active = organizations.where((o) => o.isActive).length;
    final suspended =
        organizations.where((o) => o.status == OrganizationStatus.suspended).length;
    return PlatformGlobalStats(
      totalOrganizations: organizations.length,
      activeOrganizations: active,
      suspendedOrganizations: suspended,
      totalDoctors: 0,
      totalPatients: 0,
      totalRevenueLabel: '—',
      firebaseUsageLabel: '—',
    );
  }

  void updateGlobalStats({
    required int totalDoctors,
    required int totalPatients,
    required String totalRevenueLabel,
    required String firebaseUsageLabel,
  }) {
    _cachedGlobalStats = PlatformGlobalStats(
      totalOrganizations: organizations.length,
      activeOrganizations: organizations.where((o) => o.isActive).length,
      suspendedOrganizations:
          organizations.where((o) => o.status == OrganizationStatus.suspended).length,
      totalDoctors: totalDoctors,
      totalPatients: totalPatients,
      totalRevenueLabel: totalRevenueLabel,
      firebaseUsageLabel: firebaseUsageLabel,
    );
    notifyListeners();
  }

  PlatformGlobalStats? _cachedGlobalStats;
  PlatformGlobalStats? get cachedGlobalStats => _cachedGlobalStats;

  void _seedDefaultOrganization() {
    _organizations.add(
      Organization(
        id: TenantConstants.defaultOrganizationId,
        name: 'Tabib Platform (Default)',
        status: OrganizationStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        billingPlan: OrganizationBillingPlan.enterprise,
        billingExpiresAt: DateTime.now().add(const Duration(days: 365)),
        whiteLabelAppName: 'Tabib',
        whiteLabelBundleId: 'com.tabib.app',
      ),
    );
    _organizations.add(
      Organization(
        id: 'org_demo_hospital_group',
        name: 'Demo Hospital Group',
        status: OrganizationStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        billingPlan: OrganizationBillingPlan.annual,
        billingExpiresAt: DateTime.now().add(const Duration(days: 200)),
      ),
    );
    _organizations.add(
      Organization(
        id: 'org_demo_franchise',
        name: 'Demo Franchise Network',
        status: OrganizationStatus.suspended,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        billingPlan: OrganizationBillingPlan.monthly,
        billingExpiresAt: DateTime.now().subtract(const Duration(days: 5)),
        suspendedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
