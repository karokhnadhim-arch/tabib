import 'user_account.dart';
import 'audit_module.dart';

/// Immutable platform audit record — append-only, owner-visible only.
class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.timestamp,
    this.userRole,
    this.module,
    this.actionType,
    this.description,
    this.device,
    this.operatingSystem,
    this.ipAddress,
    this.clinicId,
    this.details,
  });

  final String id;
  final String userId;
  final String userName;
  /// Human-readable action label (legacy + display).
  final String action;
  final DateTime timestamp;
  final UserRole? userRole;
  final AuditModule? module;
  final AuditActionType? actionType;
  final String? description;
  final String? device;
  final String? operatingSystem;
  final String? ipAddress;
  final String? clinicId;
  final String? details;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'action': action,
        'timestamp': timestamp.toUtc().millisecondsSinceEpoch,
        if (userRole != null) 'userRole': userRole!.name,
        if (module != null) 'module': module!.storageKey,
        if (actionType != null) 'actionType': actionType!.storageKey,
        if (description != null) 'description': description,
        if (device != null) 'device': device,
        if (operatingSystem != null) 'operatingSystem': operatingSystem,
        if (ipAddress != null) 'ipAddress': ipAddress,
        if (clinicId != null) 'clinicId': clinicId,
        if (details != null) 'details': details,
      };

  factory AuditLogEntry.fromMap(String id, Map<String, dynamic> data) {
    UserRole? role;
    final roleRaw = data['userRole'] as String?;
    if (roleRaw != null) {
      for (final r in UserRole.values) {
        if (r.name == roleRaw) {
          role = r;
          break;
        }
      }
    }
    final ts = data['timestamp'];
    DateTime timestamp;
    if (ts is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true).toLocal();
    } else {
      timestamp = DateTime.now();
    }
    return AuditLogEntry(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      action: data['action'] as String? ?? '',
      timestamp: timestamp,
      userRole: role,
      module: AuditModule.fromStorage(data['module'] as String?),
      actionType: AuditActionType.fromStorage(data['actionType'] as String?),
      description: data['description'] as String?,
      device: data['device'] as String?,
      operatingSystem: data['operatingSystem'] as String?,
      ipAddress: data['ipAddress'] as String?,
      clinicId: data['clinicId'] as String?,
      details: data['details'] as String?,
    );
  }
}

/// Owner audit list filters.
class AuditLogFilters {
  const AuditLogFilters({
    this.search = '',
    this.role,
    this.module,
    this.clinicId,
    this.userId,
    this.startDate,
    this.endDate,
    this.legacyFilter,
  });

  final String search;
  final UserRole? role;
  final AuditModule? module;
  final String? clinicId;
  final String? userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final AuditLogFilter? legacyFilter;

  AuditLogFilters copyWith({
    String? search,
    UserRole? role,
    AuditModule? module,
    String? clinicId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    AuditLogFilter? legacyFilter,
    bool clearRole = false,
    bool clearModule = false,
    bool clearClinic = false,
    bool clearUser = false,
    bool clearDates = false,
  }) {
    return AuditLogFilters(
      search: search ?? this.search,
      role: clearRole ? null : (role ?? this.role),
      module: clearModule ? null : (module ?? this.module),
      clinicId: clearClinic ? null : (clinicId ?? this.clinicId),
      userId: clearUser ? null : (userId ?? this.userId),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      legacyFilter: legacyFilter ?? this.legacyFilter,
    );
  }
}

/// Legacy filter chips — kept for monitoring dashboard compatibility.
enum AuditLogFilter { all, login, userManagement, packages, ads, backup, settings }
