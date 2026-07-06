import '../models/audit_module.dart';
import '../models/localized_text.dart';
import '../models/user_account.dart';
import 'owner_audit_service.dart';

/// Shared helpers for structured audit logging across services.
class AuditLogger {
  AuditLogger(this._audit);

  final OwnerAuditService? _audit;

  void log({
    UserAccount? actor,
    String? userId,
    String? userName,
    UserRole? userRole,
    required AuditModule module,
    required AuditActionType actionType,
    required String action,
    String? description,
    String? clinicId,
    String? details,
  }) {
    _audit?.log(
      userId: userId ?? actor?.id ?? 'system',
      userName: userName ?? displayName(actor),
      userRole: userRole ?? actor?.role,
      module: module,
      actionType: actionType,
      action: action,
      description: description,
      clinicId: clinicId ?? actor?.clinicId,
      details: details,
    );
  }

  static String displayName(UserAccount? user) {
    if (user == null) return 'System';
    return _localizedDisplay(user.name);
  }

  static String _localizedDisplay(LocalizedText name) {
    if (name.en.trim().isNotEmpty) return name.en.trim();
    if (name.ar.trim().isNotEmpty) return name.ar.trim();
    if (name.ku.trim().isNotEmpty) return name.ku.trim();
    return 'User';
  }
}
