enum SystemHealthLevel { healthy, warning, critical }

enum AnalyticsRange { today, week, month, year, custom }

enum AppErrorSeverity { low, medium, high, critical }

enum AppErrorStatus { open, fixed, ignored }

enum ActivityEventType {
  doctorCreated,
  doctorUpdated,
  secretaryAdded,
  patientRegistered,
  businessCreated,
  queueJoined,
  queueCancelled,
  appointmentBooked,
  appointmentCancelled,
  advertisementCreated,
  packageActivated,
  packageRenewed,
  login,
  logout,
}

enum ActivityFeedFilter { today, lastHour, all }

enum OwnerAlertType {
  firebaseDisconnected,
  backupFailed,
  storageWarning,
  storageCritical,
  packageExpiresToday,
  loginFailures,
  slowPerformance,
  highErrorRate,
  pushServiceFailed,
}

/// Phase 1 monitoring alerts shown on the owner infrastructure dashboard.
extension OwnerAlertPhase on OwnerAlertType {
  bool get isPhase1 => switch (this) {
        OwnerAlertType.firebaseDisconnected ||
        OwnerAlertType.backupFailed ||
        OwnerAlertType.storageWarning ||
        OwnerAlertType.storageCritical ||
        OwnerAlertType.slowPerformance ||
        OwnerAlertType.highErrorRate =>
          true,
        _ => false,
      };
}

class OwnerAlert {
  const OwnerAlert({
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  final OwnerAlertType type;
  final String message;
  final SystemHealthLevel severity;
  final DateTime timestamp;
}

class SystemMonitoringSnapshot {
  const SystemMonitoringSnapshot({
    required this.updatedAt,
    required this.healthLevel,
    required this.totalUsers,
    required this.onlineUsers,
    required this.activeToday,
    required this.newRegistrationsToday,
    required this.totalDoctors,
    required this.activeDoctors,
    required this.suspendedDoctors,
    required this.expiredPackages,
    required this.onlineDoctors,
    required this.totalSecretaries,
    required this.onlineSecretaries,
    required this.secretariesWithoutDoctor,
    required this.recentSecretaries,
    required this.totalBusinesses,
    required this.clinics,
    required this.beautyCenters,
    required this.laboratories,
    required this.pharmacies,
    required this.otherHealthcare,
    required this.totalPatients,
    required this.onlinePatients,
    required this.newPatientsToday,
    required this.activeQueues,
    required this.waitingPatients,
    required this.completedQueuesToday,
    required this.cancelledQueues,
    required this.avgWaitingMinutes,
    required this.todaysAppointments,
    required this.upcomingAppointments,
    required this.missedAppointments,
    required this.cancelledAppointments,
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
    required this.slowQueries,
    required this.backgroundTasks,
    required this.cacheHitRate,
    required this.errorRatePercent,
    required this.pushSent,
    required this.whatsappSent,
    required this.smsSent,
    required this.failedNotifications,
    required this.pendingNotifications,
    required this.activeAds,
    required this.scheduledAds,
    required this.expiredAds,
    required this.adViews,
    required this.adClicks,
    required this.adClickRate,
    required this.monthlyRevenue,
    required this.annualRevenue,
    required this.activePackages,
    required this.packagesExpiringSoon,
    required this.renewalsToday,
    required this.failedLoginAttempts,
    required this.lockedAccounts,
    required this.suspiciousLogins,
    required this.activeSessions,
    required this.alerts,
    required this.chartRegistrations,
    required this.chartQueues,
    required this.chartAppointments,
    required this.chartRevenue,
    required this.chartAdPerformance,
    required this.chartUserGrowth,
    required this.chartActiveUsers,
    required this.chartBusinessGrowth,
    this.isFromCache = false,
    this.isLiveDataAvailable = true,
  });

  final DateTime updatedAt;
  final SystemHealthLevel healthLevel;
  final int totalUsers;
  final int onlineUsers;
  final int activeToday;
  final int newRegistrationsToday;
  final int totalDoctors;
  final int activeDoctors;
  final int suspendedDoctors;
  final int expiredPackages;
  final int onlineDoctors;
  final int totalSecretaries;
  final int onlineSecretaries;
  final int secretariesWithoutDoctor;
  final int recentSecretaries;
  final int totalBusinesses;
  final int clinics;
  final int beautyCenters;
  final int laboratories;
  final int pharmacies;
  final int otherHealthcare;
  final int totalPatients;
  final int onlinePatients;
  final int newPatientsToday;
  final int activeQueues;
  final int waitingPatients;
  final int completedQueuesToday;
  final int cancelledQueues;
  final int avgWaitingMinutes;
  final int todaysAppointments;
  final int upcomingAppointments;
  final int missedAppointments;
  final int cancelledAppointments;
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
  final int slowQueries;
  final int backgroundTasks;
  final int cacheHitRate;
  final double errorRatePercent;
  final int pushSent;
  final int whatsappSent;
  final int smsSent;
  final int failedNotifications;
  final int pendingNotifications;
  final int activeAds;
  final int scheduledAds;
  final int expiredAds;
  final int adViews;
  final int adClicks;
  final double adClickRate;
  final String monthlyRevenue;
  final String annualRevenue;
  final int activePackages;
  final int packagesExpiringSoon;
  final int renewalsToday;
  final int failedLoginAttempts;
  final int lockedAccounts;
  final int suspiciousLogins;
  final int activeSessions;
  final List<OwnerAlert> alerts;
  final List<double> chartRegistrations;
  final List<double> chartQueues;
  final List<double> chartAppointments;
  final List<double> chartRevenue;
  final List<double> chartAdPerformance;
  final List<double> chartUserGrowth;
  final List<double> chartActiveUsers;
  final List<double> chartBusinessGrowth;
  final bool isFromCache;
  final bool isLiveDataAvailable;
}

class AppErrorEntry {
  const AppErrorEntry({
    required this.id,
    required this.timestamp,
    required this.module,
    required this.errorType,
    required this.severity,
    required this.device,
    required this.platform,
    required this.status,
    required this.message,
  });

  final String id;
  final DateTime timestamp;
  final String module;
  final String errorType;
  final AppErrorSeverity severity;
  final String device;
  final String platform;
  final AppErrorStatus status;
  final String message;

  AppErrorEntry copyWith({AppErrorStatus? status}) => AppErrorEntry(
        id: id,
        timestamp: timestamp,
        module: module,
        errorType: errorType,
        severity: severity,
        device: device,
        platform: platform,
        status: status ?? this.status,
        message: message,
      );
}

class ActivityFeedEntry {
  const ActivityFeedEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.timestamp,
    this.actorName,
  });

  final String id;
  final ActivityEventType type;
  final String title;
  final DateTime timestamp;
  final String? actorName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'timestamp': timestamp.toIso8601String(),
        if (actorName != null) 'actorName': actorName,
      };

  factory ActivityFeedEntry.fromJson(Map<String, dynamic> json) {
    return ActivityFeedEntry(
      id: json['id'] as String,
      type: ActivityEventType.values.byName(json['type'] as String),
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorName: json['actorName'] as String?,
    );
  }
}

class ActiveSessionEntry {
  const ActiveSessionEntry({
    required this.id,
    required this.userName,
    required this.role,
    required this.device,
    required this.platform,
    required this.lastActive,
    this.suspicious = false,
  });

  final String id;
  final String userName;
  final String role;
  final String device;
  final String platform;
  final DateTime lastActive;
  final bool suspicious;
}

class BackupSnapshot {
  const BackupSnapshot({
    required this.lastBackup,
    required this.sizeLabel,
    required this.status,
    required this.nextScheduled,
  });

  final DateTime? lastBackup;
  final String sizeLabel;
  final String status;
  final DateTime? nextScheduled;
}
