/// Backup classification.
enum BackupType {
  daily('daily'),
  weekly('weekly'),
  manual('manual');

  const BackupType(this.storageKey);
  final String storageKey;

  static BackupType fromStorage(String? raw) {
    for (final t in BackupType.values) {
      if (t.storageKey == raw) return t;
    }
    return BackupType.manual;
  }
}

/// Lifecycle state of a backup or restore job.
enum BackupJobStatus {
  pending('pending'),
  running('running'),
  completed('completed'),
  failed('failed'),
  corrupted('corrupted');

  const BackupJobStatus(this.storageKey);
  final String storageKey;

  static BackupJobStatus fromStorage(String? raw) {
    for (final s in BackupJobStatus.values) {
      if (s.storageKey == raw) return s;
    }
    return BackupJobStatus.pending;
  }

  bool get isHealthy => this == BackupJobStatus.completed;
}

/// Immutable backup record — metadata only in history lists.
class PlatformBackupRecord {
  const PlatformBackupRecord({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
    required this.type,
    required this.status,
    required this.createdById,
    required this.createdByName,
    required this.checksum,
    this.formatVersion = currentFormatVersion,
    this.failureReason,
  });

  static const currentFormatVersion = 1;

  final String id;
  final DateTime createdAt;
  final int sizeBytes;
  final BackupType type;
  final BackupJobStatus status;
  final String createdById;
  final String createdByName;
  final String checksum;
  final int formatVersion;
  final String? failureReason;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isRestorable =>
      status.isHealthy && formatVersion == currentFormatVersion;

  PlatformBackupRecord copyWith({
    BackupJobStatus? status,
    String? failureReason,
    int? sizeBytes,
    String? checksum,
  }) {
    return PlatformBackupRecord(
      id: id,
      createdAt: createdAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      type: type,
      status: status ?? this.status,
      createdById: createdById,
      createdByName: createdByName,
      checksum: checksum ?? this.checksum,
      formatVersion: formatVersion,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  Map<String, dynamic> toMap() => {
        'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
        'sizeBytes': sizeBytes,
        'type': type.storageKey,
        'status': status.storageKey,
        'createdById': _encodeMeta(createdById),
        'createdByName': _encodeMeta(createdByName),
        'checksum': checksum,
        'formatVersion': formatVersion,
        if (failureReason != null) 'failureReason': failureReason,
      };

  factory PlatformBackupRecord.fromMap(String id, Map<String, dynamic> data) {
    return PlatformBackupRecord(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (data['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
        isUtc: true,
      ).toLocal(),
      sizeBytes: (data['sizeBytes'] as num?)?.toInt() ?? 0,
      type: BackupType.fromStorage(data['type'] as String?),
      status: BackupJobStatus.fromStorage(data['status'] as String?),
      createdById: _decodeMeta(data['createdById'] as String? ?? ''),
      createdByName: _decodeMeta(data['createdByName'] as String? ?? ''),
      checksum: data['checksum'] as String? ?? '',
      formatVersion: (data['formatVersion'] as num?)?.toInt() ?? 1,
      failureReason: data['failureReason'] as String?,
    );
  }

  static String _encodeMeta(String value) =>
      value.isEmpty ? '' : String.fromCharCodes(value.codeUnits.map((c) => c ^ 0x5A));

  static String _decodeMeta(String value) =>
      value.isEmpty ? '' : String.fromCharCodes(value.codeUnits.map((c) => c ^ 0x5A));
}

/// Owner-configurable backup schedule.
class BackupScheduleConfig {
  const BackupScheduleConfig({
    this.dailyEnabled = true,
    this.weeklyEnabled = true,
    this.dailyHour = 2,
    this.weeklyWeekday = DateTime.sunday,
    this.weeklyHour = 3,
  });

  final bool dailyEnabled;
  final bool weeklyEnabled;
  final int dailyHour;
  final int weeklyWeekday;
  final int weeklyHour;

  BackupScheduleConfig copyWith({
    bool? dailyEnabled,
    bool? weeklyEnabled,
    int? dailyHour,
    int? weeklyWeekday,
    int? weeklyHour,
  }) {
    return BackupScheduleConfig(
      dailyEnabled: dailyEnabled ?? this.dailyEnabled,
      weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
      dailyHour: dailyHour ?? this.dailyHour,
      weeklyWeekday: weeklyWeekday ?? this.weeklyWeekday,
      weeklyHour: weeklyHour ?? this.weeklyHour,
    );
  }

  Map<String, dynamic> toMap() => {
        'dailyEnabled': dailyEnabled,
        'weeklyEnabled': weeklyEnabled,
        'dailyHour': dailyHour,
        'weeklyWeekday': weeklyWeekday,
        'weeklyHour': weeklyHour,
      };

  factory BackupScheduleConfig.fromMap(Map<String, dynamic> data) {
    return BackupScheduleConfig(
      dailyEnabled: data['dailyEnabled'] as bool? ?? true,
      weeklyEnabled: data['weeklyEnabled'] as bool? ?? true,
      dailyHour: (data['dailyHour'] as num?)?.toInt() ?? 2,
      weeklyWeekday: (data['weeklyWeekday'] as num?)?.toInt() ?? DateTime.sunday,
      weeklyHour: (data['weeklyHour'] as num?)?.toInt() ?? 3,
    );
  }

  static const defaults = BackupScheduleConfig();
}

/// Dashboard summary metrics.
class BackupDashboardMetrics {
  const BackupDashboardMetrics({
    required this.lastBackup,
    required this.nextScheduledBackup,
    required this.statusLabel,
    required this.totalBackups,
    required this.storageUsageBytes,
    required this.latestRestoreDate,
    required this.healthyBackupCount,
  });

  final DateTime? lastBackup;
  final DateTime? nextScheduledBackup;
  final String statusLabel;
  final int totalBackups;
  final int storageUsageBytes;
  final DateTime? latestRestoreDate;
  final int healthyBackupCount;

  String get storageUsageLabel {
    if (storageUsageBytes < 1024 * 1024) {
      return '${(storageUsageBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(storageUsageBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
