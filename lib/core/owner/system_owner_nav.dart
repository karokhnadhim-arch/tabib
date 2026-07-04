import 'package:flutter/material.dart';

import '../auth/admin_routes.dart';

/// Primary navigation destinations for the System Owner console.
enum SystemOwnerNavSection {
  overview,
  doctors,
  businesses,
  secretaries,
  patients,
  admins,
  subscriptions,
  payments,
  feedback,
  notifications,
  reports,
  systemHealth,
  auditLog,
  security,
  backup,
  organizationSettings,
  organizationBilling,
  settings;

  String get routePath => switch (this) {
        SystemOwnerNavSection.overview => AdminRoutes.ownerHome,
        SystemOwnerNavSection.doctors => '${AdminRoutes.platformPrefix}/doctors',
        SystemOwnerNavSection.businesses =>
          '${AdminRoutes.platformPrefix}/business-management',
        SystemOwnerNavSection.secretaries =>
          '${AdminRoutes.platformPrefix}/secretaries',
        SystemOwnerNavSection.patients =>
          '${AdminRoutes.platformPrefix}/patients',
        SystemOwnerNavSection.admins => '${AdminRoutes.platformPrefix}/admins',
        SystemOwnerNavSection.subscriptions =>
          '${AdminRoutes.platformPrefix}/subscriptions-packages',
        SystemOwnerNavSection.payments =>
          '${AdminRoutes.platformPrefix}/payments',
        SystemOwnerNavSection.feedback =>
          '${AdminRoutes.platformPrefix}/feedback',
        SystemOwnerNavSection.notifications =>
          '${AdminRoutes.platformPrefix}/notifications-admin',
        SystemOwnerNavSection.reports =>
          '${AdminRoutes.platformPrefix}/reports',
        SystemOwnerNavSection.systemHealth =>
          '${AdminRoutes.platformPrefix}/system-health',
        SystemOwnerNavSection.auditLog =>
          '${AdminRoutes.platformPrefix}/audit-log',
        SystemOwnerNavSection.security =>
          '${AdminRoutes.platformPrefix}/security',
        SystemOwnerNavSection.backup =>
          '${AdminRoutes.platformPrefix}/backup',
        SystemOwnerNavSection.organizationSettings =>
          '${AdminRoutes.platformPrefix}/organization-settings',
        SystemOwnerNavSection.organizationBilling =>
          '${AdminRoutes.platformPrefix}/organization-billing',
        SystemOwnerNavSection.settings =>
          '${AdminRoutes.platformPrefix}/system-settings',
      };

  IconData get icon => switch (this) {
        SystemOwnerNavSection.overview => Icons.dashboard_outlined,
        SystemOwnerNavSection.doctors => Icons.medical_services_outlined,
        SystemOwnerNavSection.businesses => Icons.storefront_outlined,
        SystemOwnerNavSection.secretaries => Icons.support_agent_outlined,
        SystemOwnerNavSection.patients => Icons.people_alt_outlined,
        SystemOwnerNavSection.admins => Icons.security_outlined,
        SystemOwnerNavSection.subscriptions => Icons.card_membership_outlined,
        SystemOwnerNavSection.payments => Icons.payments_outlined,
        SystemOwnerNavSection.feedback => Icons.feedback_outlined,
        SystemOwnerNavSection.notifications => Icons.notifications_outlined,
        SystemOwnerNavSection.reports => Icons.analytics_outlined,
        SystemOwnerNavSection.systemHealth => Icons.monitor_heart_outlined,
        SystemOwnerNavSection.auditLog => Icons.history_outlined,
        SystemOwnerNavSection.security => Icons.shield_outlined,
        SystemOwnerNavSection.backup => Icons.backup_outlined,
        SystemOwnerNavSection.organizationSettings => Icons.business_outlined,
        SystemOwnerNavSection.organizationBilling => Icons.receipt_long_outlined,
        SystemOwnerNavSection.settings => Icons.tune_outlined,
      };

  static SystemOwnerNavSection? fromPath(String path) {
    if (path == AdminRoutes.ownerHome) return SystemOwnerNavSection.overview;
    if (path.startsWith('${AdminRoutes.platformPrefix}/doctors')) {
      return SystemOwnerNavSection.doctors;
    }
    if (path.startsWith('${AdminRoutes.platformPrefix}/businesses') ||
        path.startsWith('${AdminRoutes.platformPrefix}/business-management') ||
        path.startsWith('${AdminRoutes.platformPrefix}/business-types')) {
      return SystemOwnerNavSection.businesses;
    }
    if (path.startsWith('${AdminRoutes.platformPrefix}/subscriptions') ||
        path.startsWith('${AdminRoutes.platformPrefix}/packages') ||
        path == '${AdminRoutes.platformPrefix}/subscriptions-packages') {
      return SystemOwnerNavSection.subscriptions;
    }
    if (path.startsWith('${AdminRoutes.platformPrefix}/analytics')) {
      return SystemOwnerNavSection.reports;
    }
    for (final section in SystemOwnerNavSection.values) {
      if (section == SystemOwnerNavSection.overview) continue;
      final sectionPath = section.routePath;
      if (path == sectionPath || path.startsWith('$sectionPath/')) {
        return section;
      }
    }
    if (path.startsWith('${AdminRoutes.platformPrefix}/clinics')) {
      return SystemOwnerNavSection.settings;
    }
    return null;
  }
}
