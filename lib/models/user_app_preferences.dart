import 'notification_channel.dart';

/// Per-user app preferences stored locally (and optionally synced later).
class UserAppPreferences {
  const UserAppPreferences({
    this.pushNotifications = true,
    this.queueNotifications = true,
    this.reminderNotifications = true,
    this.preferredLanguageCode = '',
    this.preferredNotificationMethod = PatientNotificationMethod.automatic,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showProfileInSearch = true,
    this.shareUsageAnalytics = false,
    this.secretaryQueueAlerts = true,
    this.secretaryAutoRefreshQueue = true,
  });

  final bool pushNotifications;
  final bool queueNotifications;
  final bool reminderNotifications;
  /// Empty means follow app locale.
  final String preferredLanguageCode;
  final PatientNotificationMethod preferredNotificationMethod;
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
      reminderNotifications: _bool(map['reminderNotifications'], true),
      preferredLanguageCode: map['preferredLanguageCode'] as String? ?? '',
      preferredNotificationMethod: _parseMethod(
        map['preferredNotificationMethod'] as String?,
      ),
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

  static PatientNotificationMethod _parseMethod(String? raw) {
    if (raw == null || raw.isEmpty) {
      return PatientNotificationMethod.automatic;
    }
    return PatientNotificationMethod.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => PatientNotificationMethod.automatic,
    );
  }

  Map<String, dynamic> toMap() => {
        'pushNotifications': pushNotifications,
        'queueNotifications': queueNotifications,
        'reminderNotifications': reminderNotifications,
        'preferredLanguageCode': preferredLanguageCode,
        'preferredNotificationMethod': preferredNotificationMethod.name,
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
    bool? reminderNotifications,
    String? preferredLanguageCode,
    PatientNotificationMethod? preferredNotificationMethod,
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
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      preferredLanguageCode:
          preferredLanguageCode ?? this.preferredLanguageCode,
      preferredNotificationMethod: preferredNotificationMethod ??
          this.preferredNotificationMethod,
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
