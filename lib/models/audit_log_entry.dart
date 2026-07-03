/// Platform audit record — visible only to the System Owner.
class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.timestamp,
    this.device,
    this.ipAddress,
    this.details,
  });

  final String id;
  final String userId;
  final String userName;
  final String action;
  final DateTime timestamp;
  final String? device;
  final String? ipAddress;
  final String? details;
}
