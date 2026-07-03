/// Pre-aggregated platform metrics — one document read instead of collection scans.
class PlatformDashboardSummary {
  const PlatformDashboardSummary({
    required this.updatedAt,
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
    required this.queueWaiting,
    required this.queueInProgress,
    required this.completedQueuesToday,
    required this.cancelledQueues,
    required this.avgWaitingMinutes,
    required this.todaysAppointments,
    required this.upcomingAppointments,
    required this.missedAppointments,
    required this.cancelledAppointments,
    required this.firestoreReads,
    required this.firestoreWrites,
    required this.storageUsageMb,
    required this.imageStorageMb,
    required this.storageUsagePercent,
    required this.activeSubscriptions,
    required this.expiringSoonSubscriptions,
    required this.monthlyRevenueLabel,
    required this.annualRevenueLabel,
    required this.activeAds,
    required this.scheduledAds,
    required this.expiredAds,
    required this.adViews,
    required this.adClicks,
    required this.pushSent,
    required this.whatsappSent,
    required this.smsSent,
    required this.failedNotifications,
    required this.pendingNotifications,
    required this.failedLoginAttempts,
    required this.lockedAccounts,
    required this.activeSessionsCount,
  });

  final DateTime updatedAt;
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
  final int queueWaiting;
  final int queueInProgress;
  final int completedQueuesToday;
  final int cancelledQueues;
  final int avgWaitingMinutes;
  final int todaysAppointments;
  final int upcomingAppointments;
  final int missedAppointments;
  final int cancelledAppointments;
  final int firestoreReads;
  final int firestoreWrites;
  final double storageUsageMb;
  final double imageStorageMb;
  final int storageUsagePercent;
  final int activeSubscriptions;
  final int expiringSoonSubscriptions;
  final String monthlyRevenueLabel;
  final String annualRevenueLabel;
  final int activeAds;
  final int scheduledAds;
  final int expiredAds;
  final int adViews;
  final int adClicks;
  final int pushSent;
  final int whatsappSent;
  final int smsSent;
  final int failedNotifications;
  final int pendingNotifications;
  final int failedLoginAttempts;
  final int lockedAccounts;
  final int activeSessionsCount;

  double get adClickRate =>
      adViews == 0 ? 0 : (adClicks / adViews) * 100;

  Map<String, dynamic> toJson() => {
        'updatedAt': updatedAt.toIso8601String(),
        'totalUsers': totalUsers,
        'onlineUsers': onlineUsers,
        'activeToday': activeToday,
        'newRegistrationsToday': newRegistrationsToday,
        'totalDoctors': totalDoctors,
        'activeDoctors': activeDoctors,
        'suspendedDoctors': suspendedDoctors,
        'expiredPackages': expiredPackages,
        'onlineDoctors': onlineDoctors,
        'totalSecretaries': totalSecretaries,
        'onlineSecretaries': onlineSecretaries,
        'secretariesWithoutDoctor': secretariesWithoutDoctor,
        'recentSecretaries': recentSecretaries,
        'totalBusinesses': totalBusinesses,
        'clinics': clinics,
        'beautyCenters': beautyCenters,
        'laboratories': laboratories,
        'pharmacies': pharmacies,
        'otherHealthcare': otherHealthcare,
        'totalPatients': totalPatients,
        'onlinePatients': onlinePatients,
        'newPatientsToday': newPatientsToday,
        'queueWaiting': queueWaiting,
        'queueInProgress': queueInProgress,
        'completedQueuesToday': completedQueuesToday,
        'cancelledQueues': cancelledQueues,
        'avgWaitingMinutes': avgWaitingMinutes,
        'todaysAppointments': todaysAppointments,
        'upcomingAppointments': upcomingAppointments,
        'missedAppointments': missedAppointments,
        'cancelledAppointments': cancelledAppointments,
        'firestoreReads': firestoreReads,
        'firestoreWrites': firestoreWrites,
        'storageUsageMb': storageUsageMb,
        'imageStorageMb': imageStorageMb,
        'storageUsagePercent': storageUsagePercent,
        'activeSubscriptions': activeSubscriptions,
        'expiringSoonSubscriptions': expiringSoonSubscriptions,
        'monthlyRevenueLabel': monthlyRevenueLabel,
        'annualRevenueLabel': annualRevenueLabel,
        'activeAds': activeAds,
        'scheduledAds': scheduledAds,
        'expiredAds': expiredAds,
        'adViews': adViews,
        'adClicks': adClicks,
        'pushSent': pushSent,
        'whatsappSent': whatsappSent,
        'smsSent': smsSent,
        'failedNotifications': failedNotifications,
        'pendingNotifications': pendingNotifications,
        'failedLoginAttempts': failedLoginAttempts,
        'lockedAccounts': lockedAccounts,
        'activeSessionsCount': activeSessionsCount,
      };

  factory PlatformDashboardSummary.fromJson(Map<String, dynamic> json) {
    return PlatformDashboardSummary(
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      totalUsers: _int(json['totalUsers']),
      onlineUsers: _int(json['onlineUsers']),
      activeToday: _int(json['activeToday']),
      newRegistrationsToday: _int(json['newRegistrationsToday']),
      totalDoctors: _int(json['totalDoctors']),
      activeDoctors: _int(json['activeDoctors']),
      suspendedDoctors: _int(json['suspendedDoctors']),
      expiredPackages: _int(json['expiredPackages']),
      onlineDoctors: _int(json['onlineDoctors']),
      totalSecretaries: _int(json['totalSecretaries']),
      onlineSecretaries: _int(json['onlineSecretaries']),
      secretariesWithoutDoctor: _int(json['secretariesWithoutDoctor']),
      recentSecretaries: _int(json['recentSecretaries']),
      totalBusinesses: _int(json['totalBusinesses']),
      clinics: _int(json['clinics']),
      beautyCenters: _int(json['beautyCenters']),
      laboratories: _int(json['laboratories']),
      pharmacies: _int(json['pharmacies']),
      otherHealthcare: _int(json['otherHealthcare']),
      totalPatients: _int(json['totalPatients']),
      onlinePatients: _int(json['onlinePatients']),
      newPatientsToday: _int(json['newPatientsToday']),
      queueWaiting: _int(json['queueWaiting']),
      queueInProgress: _int(json['queueInProgress']),
      completedQueuesToday: _int(json['completedQueuesToday']),
      cancelledQueues: _int(json['cancelledQueues']),
      avgWaitingMinutes: _int(json['avgWaitingMinutes']),
      todaysAppointments: _int(json['todaysAppointments']),
      upcomingAppointments: _int(json['upcomingAppointments']),
      missedAppointments: _int(json['missedAppointments']),
      cancelledAppointments: _int(json['cancelledAppointments']),
      firestoreReads: _int(json['firestoreReads']),
      firestoreWrites: _int(json['firestoreWrites']),
      storageUsageMb: _double(json['storageUsageMb']),
      imageStorageMb: _double(json['imageStorageMb']),
      storageUsagePercent: _int(json['storageUsagePercent']),
      activeSubscriptions: _int(json['activeSubscriptions']),
      expiringSoonSubscriptions: _int(json['expiringSoonSubscriptions']),
      monthlyRevenueLabel: json['monthlyRevenueLabel'] as String? ?? '—',
      annualRevenueLabel: json['annualRevenueLabel'] as String? ?? '—',
      activeAds: _int(json['activeAds']),
      scheduledAds: _int(json['scheduledAds']),
      expiredAds: _int(json['expiredAds']),
      adViews: _int(json['adViews']),
      adClicks: _int(json['adClicks']),
      pushSent: _int(json['pushSent']),
      whatsappSent: _int(json['whatsappSent']),
      smsSent: _int(json['smsSent']),
      failedNotifications: _int(json['failedNotifications']),
      pendingNotifications: _int(json['pendingNotifications']),
      failedLoginAttempts: _int(json['failedLoginAttempts']),
      lockedAccounts: _int(json['lockedAccounts']),
      activeSessionsCount: _int(json['activeSessionsCount']),
    );
  }

  factory PlatformDashboardSummary.fromFirestore(Map<String, dynamic> data) =>
      PlatformDashboardSummary.fromJson(data);

  static int _int(Object? v) => (v as num?)?.toInt() ?? 0;

  static double _double(Object? v) => (v as num?)?.toDouble() ?? 0;
}

/// Optional chart bundle — loaded lazily (separate read when charts are viewed).
class DashboardChartsBundle {
  const DashboardChartsBundle({
    required this.range,
    required this.registrations,
    required this.queues,
    required this.appointments,
    required this.revenue,
    required this.adPerformance,
    required this.userGrowth,
    required this.activeUsers,
    required this.businessGrowth,
  });

  final String range;
  final List<double> registrations;
  final List<double> queues;
  final List<double> appointments;
  final List<double> revenue;
  final List<double> adPerformance;
  final List<double> userGrowth;
  final List<double> activeUsers;
  final List<double> businessGrowth;

  Map<String, dynamic> toJson() => {
        'range': range,
        'registrations': registrations,
        'queues': queues,
        'appointments': appointments,
        'revenue': revenue,
        'adPerformance': adPerformance,
        'userGrowth': userGrowth,
        'activeUsers': activeUsers,
        'businessGrowth': businessGrowth,
      };

  factory DashboardChartsBundle.fromJson(Map<String, dynamic> json) {
    List<double> series(Object? raw) =>
        (raw as List?)?.map((e) => (e as num).toDouble()).toList() ??
        const [];

    return DashboardChartsBundle(
      range: json['range'] as String? ?? 'today',
      registrations: series(json['registrations']),
      queues: series(json['queues']),
      appointments: series(json['appointments']),
      revenue: series(json['revenue']),
      adPerformance: series(json['adPerformance']),
      userGrowth: series(json['userGrowth']),
      activeUsers: series(json['activeUsers']),
      businessGrowth: series(json['businessGrowth']),
    );
  }
}
