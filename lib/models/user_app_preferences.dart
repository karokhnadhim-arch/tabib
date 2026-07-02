/// Per-user app preferences stored locally (and optionally synced later).
class UserAppPreferences {
  const UserAppPreferences({
    this.pushNotifications = true,
    this.queueNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showProfileInSearch = true,
    this.shareUsageAnalytics = false,
    this.secretaryQueueAlerts = true,
    this.secretaryAutoRefreshQueue = true,
  });

  final bool pushNotifications;
  final bool queueNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showProfileInSearch;
  final bool shareUsageAnalytics;
  final bool secretaryQueueAlerts;
  final bool secretaryAutoRefreshQueue;

  factory UserAppPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserAppPreferences();
    return UserAppPreferences(
      pushNotifications: _bool(map['pushNotifications'], true),
      queueNotifications: _bool(map['queueNotifications'], true),
      soundEnabled: _bool(map['soundEnabled'], true),
      vibrationEnabled: _bool(map['vibrationEnabled'], true),
      showProfileInSearch: _bool(map['showProfileInSearch'], true),
      shareUsageAnalytics: _bool(map['shareUsageAnalytics'], false),
      secretaryQueueAlerts: _bool(map['secretaryQueueAlerts'], true),
      secretaryAutoRefreshQueue: _bool(map['secretaryAutoRefreshQueue'], true),
    );
  }

  static bool _bool(dynamic value, bool defaultValue) =>
      value is bool ? value : defaultValue;

  Map<String, dynamic> toMap() => {
        'pushNotifications': pushNotifications,
        'queueNotifications': queueNotifications,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'showProfileInSearch': showProfileInSearch,
        'shareUsageAnalytics': shareUsageAnalytics,
        'secretaryQueueAlerts': secretaryQueueAlerts,
        'secretaryAutoRefreshQueue': secretaryAutoRefreshQueue,
      };

  UserAppPreferences copyWith({
    bool? pushNotifications,
    bool? queueNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showProfileInSearch,
    bool? shareUsageAnalytics,
    bool? secretaryQueueAlerts,
    bool? secretaryAutoRefreshQueue,
  }) {
    return UserAppPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      queueNotifications: queueNotifications ?? this.queueNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showProfileInSearch: showProfileInSearch ?? this.showProfileInSearch,
      shareUsageAnalytics: shareUsageAnalytics ?? this.shareUsageAnalytics,
      secretaryQueueAlerts: secretaryQueueAlerts ?? this.secretaryQueueAlerts,
      secretaryAutoRefreshQueue:
          secretaryAutoRefreshQueue ?? this.secretaryAutoRefreshQueue,
    );
  }
}
