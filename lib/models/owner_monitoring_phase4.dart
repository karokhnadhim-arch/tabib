import 'package:flutter/material.dart';

enum InsightPriority { high, medium, low }

enum InsightCategory {
  patients,
  doctors,
  queues,
  revenue,
  packages,
  advertisements,
  security,
  firebase,
  performance,
}

class OwnerInsight {
  const OwnerInsight({
    required this.id,
    required this.priority,
    required this.category,
    required this.title,
    required this.description,
    required this.recommendation,
    required this.generatedAt,
  });

  final String id;
  final InsightPriority priority;
  final InsightCategory category;
  final String title;
  final String description;
  final String recommendation;
  final DateTime generatedAt;
}

enum ForecastHorizon { next7Days, nextMonth, nextYear }

class ForecastSeries {
  const ForecastSeries({
    required this.horizon,
    required this.registrations,
    required this.queueGrowth,
    required this.appointmentGrowth,
    required this.revenue,
    required this.storageUsage,
    required this.firebaseUsage,
    required this.adRevenue,
  });

  final ForecastHorizon horizon;
  final List<double> registrations;
  final List<double> queueGrowth;
  final List<double> appointmentGrowth;
  final List<double> revenue;
  final List<double> storageUsage;
  final List<double> firebaseUsage;
  final List<double> adRevenue;
}

enum SmartNotificationType {
  storageWarning,
  storageCritical,
  storageFull,
  backupFailed,
  firebaseDisconnected,
  highErrorRate,
  slowResponse,
  packageExpiresToday,
  loginFailures,
  queueWaitAbnormal,
  healthChange,
}

class SmartOwnerNotification {
  const SmartOwnerNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isArchived = false,
  });

  final String id;
  final SmartNotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isArchived;

  SmartOwnerNotification copyWith({
    bool? isRead,
    bool? isArchived,
  }) =>
      SmartOwnerNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        isArchived: isArchived ?? this.isArchived,
      );
}

enum DashboardSearchCategory {
  doctor,
  patient,
  secretary,
  business,
  advertisement,
  package,
  queue,
  appointment,
  auditLog,
}

class DashboardSearchResult {
  const DashboardSearchResult({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final DashboardSearchCategory category;
  final String title;
  final String subtitle;
}

enum DashboardStatusFilter { all, active, suspended }

class OwnerDashboardFilter {
  const OwnerDashboardFilter({
    this.city,
    this.businessId,
    this.doctorId,
    this.dateRange,
    this.status = DashboardStatusFilter.all,
  });

  final String? city;
  final String? businessId;
  final String? doctorId;
  final DateTimeRange? dateRange;
  final DashboardStatusFilter status;

  bool get isActive =>
      city != null ||
      businessId != null ||
      doctorId != null ||
      dateRange != null ||
      status != DashboardStatusFilter.all;

  OwnerDashboardFilter copyWith({
    String? city,
    String? businessId,
    String? doctorId,
    DateTimeRange? dateRange,
    DashboardStatusFilter? status,
    bool clearCity = false,
    bool clearBusiness = false,
    bool clearDoctor = false,
    bool clearDateRange = false,
  }) {
    return OwnerDashboardFilter(
      city: clearCity ? null : (city ?? this.city),
      businessId: clearBusiness ? null : (businessId ?? this.businessId),
      doctorId: clearDoctor ? null : (doctorId ?? this.doctorId),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      status: status ?? this.status,
    );
  }
}

enum DashboardAccent { blue, green, teal, purple, orange }

enum DashboardDensity { compact, comfortable }

enum DashboardLayout { standard, wide, focused }

class FirebaseCostAnalysis {
  const FirebaseCostAnalysis({
    required this.estimatedMonthlyUsd,
    required this.readOperations,
    required this.writeOperations,
    required this.storageMb,
    required this.imageStorageMb,
    required this.bandwidthMb,
    required this.cacheHitRate,
    required this.suggestions,
    required this.expensiveOperationWarnings,
  });

  final double estimatedMonthlyUsd;
  final int readOperations;
  final int writeOperations;
  final double storageMb;
  final double imageStorageMb;
  final double bandwidthMb;
  final int cacheHitRate;
  final List<String> suggestions;
  final List<String> expensiveOperationWarnings;
}

enum MonitoringSettingsSection {
  firebase,
  queue,
  advertisements,
  packages,
  notifications,
  backup,
  maintenance,
}
