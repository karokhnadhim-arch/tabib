import 'package:flutter/material.dart';

/// Enterprise organization — future multi-tenant partition root.
class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.logoUrl,
    this.primaryColorHex = '1E88E5',
    this.defaultLanguage = 'ku',
    this.billingPlan = OrganizationBillingPlan.trial,
    this.billingExpiresAt,
    this.suspendedAt,
    this.whiteLabelAppName,
    this.whiteLabelBundleId,
  });

  final String id;
  final String name;
  final OrganizationStatus status;
  final DateTime createdAt;
  final String? logoUrl;
  final String primaryColorHex;
  final String defaultLanguage;
  final OrganizationBillingPlan billingPlan;
  final DateTime? billingExpiresAt;
  final DateTime? suspendedAt;
  final String? whiteLabelAppName;
  final String? whiteLabelBundleId;

  bool get isActive => status == OrganizationStatus.active;

  Color get primaryColor {
    final hex = primaryColorHex.replaceAll('#', '');
    final value = int.tryParse(hex, radix: 16) ?? 0x1E88E5;
    return Color(0xFF000000 | value);
  }

  Organization copyWith({
    String? name,
    OrganizationStatus? status,
    String? logoUrl,
    String? primaryColorHex,
    String? defaultLanguage,
    OrganizationBillingPlan? billingPlan,
    DateTime? billingExpiresAt,
    DateTime? suspendedAt,
    String? whiteLabelAppName,
    String? whiteLabelBundleId,
  }) {
    return Organization(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      billingPlan: billingPlan ?? this.billingPlan,
      billingExpiresAt: billingExpiresAt ?? this.billingExpiresAt,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      whiteLabelAppName: whiteLabelAppName ?? this.whiteLabelAppName,
      whiteLabelBundleId: whiteLabelBundleId ?? this.whiteLabelBundleId,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        if (logoUrl != null) 'logoUrl': logoUrl,
        'primaryColorHex': primaryColorHex,
        'defaultLanguage': defaultLanguage,
        'billingPlan': billingPlan.name,
        if (billingExpiresAt != null)
          'billingExpiresAt': billingExpiresAt!.toIso8601String(),
        if (suspendedAt != null) 'suspendedAt': suspendedAt!.toIso8601String(),
        if (whiteLabelAppName != null) 'whiteLabelAppName': whiteLabelAppName,
        if (whiteLabelBundleId != null) 'whiteLabelBundleId': whiteLabelBundleId,
      };

  factory Organization.fromMap(String id, Map<String, dynamic> data) {
    return Organization(
      id: id,
      name: data['name'] as String? ?? id,
      status: OrganizationStatus.values.byName(
        data['status'] as String? ?? OrganizationStatus.active.name,
      ),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
      logoUrl: data['logoUrl'] as String?,
      primaryColorHex: data['primaryColorHex'] as String? ?? '1E88E5',
      defaultLanguage: data['defaultLanguage'] as String? ?? 'ku',
      billingPlan: OrganizationBillingPlan.values.byName(
        data['billingPlan'] as String? ?? OrganizationBillingPlan.trial.name,
      ),
      billingExpiresAt: _parseDate(data['billingExpiresAt']),
      suspendedAt: _parseDate(data['suspendedAt']),
      whiteLabelAppName: data['whiteLabelAppName'] as String?,
      whiteLabelBundleId: data['whiteLabelBundleId'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return null;
  }
}

enum OrganizationStatus { active, suspended, deleted }

enum OrganizationBillingPlan { trial, monthly, annual, enterprise }

class OrganizationBillingSnapshot {
  const OrganizationBillingSnapshot({
    required this.organizationId,
    required this.currentPlan,
    required this.expiresAt,
    required this.usageLimitsLabel,
    required this.paymentHistory,
  });

  final String organizationId;
  final OrganizationBillingPlan currentPlan;
  final DateTime? expiresAt;
  final String usageLimitsLabel;
  final List<OrganizationPaymentRecord> paymentHistory;
}

class OrganizationPaymentRecord {
  const OrganizationPaymentRecord({
    required this.id,
    required this.amountLabel,
    required this.paidAt,
    required this.plan,
  });

  final String id;
  final String amountLabel;
  final DateTime paidAt;
  final OrganizationBillingPlan plan;
}

class OrganizationSettings {
  const OrganizationSettings({
    required this.organizationId,
    required this.logoUrl,
    required this.displayName,
    required this.primaryColorHex,
    required this.defaultLanguage,
    required this.workingHoursLabel,
    required this.queueRulesSummary,
    required this.appointmentRulesSummary,
    required this.notificationSettingsSummary,
  });

  final String organizationId;
  final String? logoUrl;
  final String displayName;
  final String primaryColorHex;
  final String defaultLanguage;
  final String workingHoursLabel;
  final String queueRulesSummary;
  final String appointmentRulesSummary;
  final String notificationSettingsSummary;
}

class PlatformGlobalStats {
  const PlatformGlobalStats({
    required this.totalOrganizations,
    required this.activeOrganizations,
    required this.suspendedOrganizations,
    required this.totalDoctors,
    required this.totalPatients,
    required this.totalRevenueLabel,
    required this.firebaseUsageLabel,
  });

  final int totalOrganizations;
  final int activeOrganizations;
  final int suspendedOrganizations;
  final int totalDoctors;
  final int totalPatients;
  final String totalRevenueLabel;
  final String firebaseUsageLabel;
}
