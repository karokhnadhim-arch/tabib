import 'package:flutter/foundation.dart';

import '../../../../models/system_monitoring.dart';

/// Narrow slice for Phase 1 — avoids rebuilding live statistics on alert-only ticks.
@immutable
class Phase1MonitoringViewModel {
  const Phase1MonitoringViewModel({
    required this.updatedAt,
    required this.healthLevel,
    required this.phase1Alerts,
    required this.firebaseConnected,
    required this.firebaseConfigured,
    required this.firestoreReads,
    required this.firestoreWrites,
    required this.storageUsageMb,
    required this.imageStorageMb,
    required this.responseTimeMs,
    required this.cacheEnabled,
    required this.lastSync,
    required this.storageUsagePercent,
    required this.cpuUsagePercent,
    required this.memoryUsagePercent,
    required this.avgApiResponseMs,
    required this.backgroundTasks,
    required this.cacheHitRate,
    required this.slowQueries,
    required this.showingCached,
    required this.isOffline,
    required this.isLiveDataAvailable,
    required this.lastSuccessfulSync,
    required this.isRefreshing,
  });

  factory Phase1MonitoringViewModel.from({
    required SystemMonitoringSnapshot snapshot,
    required SystemHealthLevel healthLevel,
    required List<OwnerAlert> phase1Alerts,
    required bool showingCached,
    required bool isOffline,
    required DateTime? lastSuccessfulSync,
    required bool isRefreshing,
  }) {
    return Phase1MonitoringViewModel(
      updatedAt: snapshot.updatedAt,
      healthLevel: healthLevel,
      phase1Alerts: phase1Alerts,
      firebaseConnected: snapshot.firebaseConnected,
      firebaseConfigured: snapshot.firebaseConfigured,
      firestoreReads: snapshot.firestoreReads,
      firestoreWrites: snapshot.firestoreWrites,
      storageUsageMb: snapshot.storageUsageMb,
      imageStorageMb: snapshot.imageStorageMb,
      responseTimeMs: snapshot.responseTimeMs,
      cacheEnabled: snapshot.cacheEnabled,
      lastSync: snapshot.lastSync,
      storageUsagePercent: snapshot.storageUsagePercent,
      cpuUsagePercent: snapshot.cpuUsagePercent,
      memoryUsagePercent: snapshot.memoryUsagePercent,
      avgApiResponseMs: snapshot.avgApiResponseMs,
      backgroundTasks: snapshot.backgroundTasks,
      cacheHitRate: snapshot.cacheHitRate,
      slowQueries: snapshot.slowQueries,
      showingCached: showingCached || snapshot.isFromCache,
      isOffline: isOffline,
      isLiveDataAvailable: snapshot.isLiveDataAvailable,
      lastSuccessfulSync: lastSuccessfulSync,
      isRefreshing: isRefreshing,
    );
  }

  final DateTime updatedAt;
  final SystemHealthLevel healthLevel;
  final List<OwnerAlert> phase1Alerts;
  final bool firebaseConnected;
  final bool firebaseConfigured;
  final int firestoreReads;
  final int firestoreWrites;
  final double storageUsageMb;
  final double imageStorageMb;
  final int responseTimeMs;
  final bool cacheEnabled;
  final DateTime? lastSync;
  final int storageUsagePercent;
  final int cpuUsagePercent;
  final int memoryUsagePercent;
  final int avgApiResponseMs;
  final int backgroundTasks;
  final int cacheHitRate;
  final int slowQueries;
  final bool showingCached;
  final bool isOffline;
  final bool isLiveDataAvailable;
  final DateTime? lastSuccessfulSync;
  final bool isRefreshing;

  @override
  bool operator ==(Object other) {
    return other is Phase1MonitoringViewModel &&
        updatedAt == other.updatedAt &&
        healthLevel == other.healthLevel &&
        listEquals(phase1Alerts, other.phase1Alerts) &&
        firebaseConnected == other.firebaseConnected &&
        firebaseConfigured == other.firebaseConfigured &&
        firestoreReads == other.firestoreReads &&
        firestoreWrites == other.firestoreWrites &&
        storageUsageMb == other.storageUsageMb &&
        imageStorageMb == other.imageStorageMb &&
        responseTimeMs == other.responseTimeMs &&
        cacheEnabled == other.cacheEnabled &&
        lastSync == other.lastSync &&
        storageUsagePercent == other.storageUsagePercent &&
        cpuUsagePercent == other.cpuUsagePercent &&
        memoryUsagePercent == other.memoryUsagePercent &&
        avgApiResponseMs == other.avgApiResponseMs &&
        backgroundTasks == other.backgroundTasks &&
        cacheHitRate == other.cacheHitRate &&
        slowQueries == other.slowQueries &&
        showingCached == other.showingCached &&
        isOffline == other.isOffline &&
        isLiveDataAvailable == other.isLiveDataAvailable &&
        lastSuccessfulSync == other.lastSuccessfulSync &&
        isRefreshing == other.isRefreshing;
  }

  @override
  int get hashCode => Object.hash(
        updatedAt,
        healthLevel,
        Object.hashAll(phase1Alerts),
        firebaseConnected,
        firestoreReads,
        responseTimeMs,
        storageUsagePercent,
        cpuUsagePercent,
        isRefreshing,
      );
}

/// Narrow slice for Phase 2 live statistics — independent from Phase 1 rebuilds.
@immutable
class LiveStatisticsViewModel {
  const LiveStatisticsViewModel({
    required this.updatedAt,
    required this.totalUsers,
    required this.onlineUsers,
    required this.activeToday,
    required this.newRegistrationsToday,
    required this.totalDoctors,
    required this.onlineDoctors,
    required this.activeDoctors,
    required this.suspendedDoctors,
    required this.expiredPackages,
    required this.totalSecretaries,
    required this.onlineSecretaries,
    required this.secretariesWithoutDoctor,
    required this.recentSecretaries,
    required this.totalPatients,
    required this.onlinePatients,
    required this.newPatientsToday,
    required this.totalBusinesses,
    required this.clinics,
    required this.beautyCenters,
    required this.laboratories,
    required this.pharmacies,
    required this.otherHealthcare,
    required this.activeQueues,
    required this.waitingPatients,
    required this.completedQueuesToday,
    required this.cancelledQueuesToday,
    required this.avgWaitingMinutes,
    required this.todaysAppointments,
    required this.upcomingAppointments,
    required this.missedAppointments,
    required this.cancelledAppointments,
    required this.isRefreshing,
  });

  factory LiveStatisticsViewModel.from(SystemMonitoringSnapshot s, {required bool isRefreshing}) {
    return LiveStatisticsViewModel(
      updatedAt: s.updatedAt,
      totalUsers: s.totalUsers,
      onlineUsers: s.onlineUsers,
      activeToday: s.activeToday,
      newRegistrationsToday: s.newRegistrationsToday,
      totalDoctors: s.totalDoctors,
      onlineDoctors: s.onlineDoctors,
      activeDoctors: s.activeDoctors,
      suspendedDoctors: s.suspendedDoctors,
      expiredPackages: s.expiredPackages,
      totalSecretaries: s.totalSecretaries,
      onlineSecretaries: s.onlineSecretaries,
      secretariesWithoutDoctor: s.secretariesWithoutDoctor,
      recentSecretaries: s.recentSecretaries,
      totalPatients: s.totalPatients,
      onlinePatients: s.onlinePatients,
      newPatientsToday: s.newPatientsToday,
      totalBusinesses: s.totalBusinesses,
      clinics: s.clinics,
      beautyCenters: s.beautyCenters,
      laboratories: s.laboratories,
      pharmacies: s.pharmacies,
      otherHealthcare: s.otherHealthcare,
      activeQueues: s.activeQueues,
      waitingPatients: s.waitingPatients,
      completedQueuesToday: s.completedQueuesToday,
      cancelledQueuesToday: s.cancelledQueues,
      avgWaitingMinutes: s.avgWaitingMinutes,
      todaysAppointments: s.todaysAppointments,
      upcomingAppointments: s.upcomingAppointments,
      missedAppointments: s.missedAppointments,
      cancelledAppointments: s.cancelledAppointments,
      isRefreshing: isRefreshing,
    );
  }

  final DateTime updatedAt;
  final int totalUsers;
  final int onlineUsers;
  final int activeToday;
  final int newRegistrationsToday;
  final int totalDoctors;
  final int onlineDoctors;
  final int activeDoctors;
  final int suspendedDoctors;
  final int expiredPackages;
  final int totalSecretaries;
  final int onlineSecretaries;
  final int secretariesWithoutDoctor;
  final int recentSecretaries;
  final int totalPatients;
  final int onlinePatients;
  final int newPatientsToday;
  final int totalBusinesses;
  final int clinics;
  final int beautyCenters;
  final int laboratories;
  final int pharmacies;
  final int otherHealthcare;
  final int activeQueues;
  final int waitingPatients;
  final int completedQueuesToday;
  final int cancelledQueuesToday;
  final int avgWaitingMinutes;
  final int todaysAppointments;
  final int upcomingAppointments;
  final int missedAppointments;
  final int cancelledAppointments;
  final bool isRefreshing;

  @override
  bool operator ==(Object other) {
    return other is LiveStatisticsViewModel &&
        updatedAt == other.updatedAt &&
        totalUsers == other.totalUsers &&
        onlineUsers == other.onlineUsers &&
        activeToday == other.activeToday &&
        newRegistrationsToday == other.newRegistrationsToday &&
        totalDoctors == other.totalDoctors &&
        onlineDoctors == other.onlineDoctors &&
        activeDoctors == other.activeDoctors &&
        suspendedDoctors == other.suspendedDoctors &&
        expiredPackages == other.expiredPackages &&
        totalSecretaries == other.totalSecretaries &&
        onlineSecretaries == other.onlineSecretaries &&
        secretariesWithoutDoctor == other.secretariesWithoutDoctor &&
        recentSecretaries == other.recentSecretaries &&
        totalPatients == other.totalPatients &&
        onlinePatients == other.onlinePatients &&
        newPatientsToday == other.newPatientsToday &&
        totalBusinesses == other.totalBusinesses &&
        clinics == other.clinics &&
        beautyCenters == other.beautyCenters &&
        laboratories == other.laboratories &&
        pharmacies == other.pharmacies &&
        otherHealthcare == other.otherHealthcare &&
        activeQueues == other.activeQueues &&
        waitingPatients == other.waitingPatients &&
        completedQueuesToday == other.completedQueuesToday &&
        cancelledQueuesToday == other.cancelledQueuesToday &&
        avgWaitingMinutes == other.avgWaitingMinutes &&
        todaysAppointments == other.todaysAppointments &&
        upcomingAppointments == other.upcomingAppointments &&
        missedAppointments == other.missedAppointments &&
        cancelledAppointments == other.cancelledAppointments &&
        isRefreshing == other.isRefreshing;
  }

  @override
  int get hashCode => Object.hash(
        updatedAt,
        totalUsers,
        onlineUsers,
        totalDoctors,
        totalPatients,
        activeQueues,
        todaysAppointments,
        isRefreshing,
      );
}
