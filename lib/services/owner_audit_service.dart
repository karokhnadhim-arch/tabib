import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/audit_log_entry.dart';

/// In-app audit trail for the System Owner dashboard (demo + live logging).
class OwnerAuditService extends ChangeNotifier {
  OwnerAuditService() {
    _seedDemoEntries();
  }

  static const _uuid = Uuid();
  final List<AuditLogEntry> _entries = [];

  List<AuditLogEntry> get entries =>
      List.unmodifiable(_entries..sort((a, b) => b.timestamp.compareTo(a.timestamp)));

  void record({
    required String userId,
    required String userName,
    required String action,
    String? device,
    String? ipAddress,
    String? details,
  }) {
    _entries.add(
      AuditLogEntry(
        id: _uuid.v4(),
        userId: userId,
        userName: userName,
        action: action,
        timestamp: DateTime.now(),
        device: device ?? defaultTargetPlatform.name,
        ipAddress: ipAddress,
        details: details,
      ),
    );
    notifyListeners();
  }

  void _seedDemoEntries() {
    final now = DateTime.now();
    _entries.addAll([
      AuditLogEntry(
        id: 'audit_seed_1',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Signed in to platform console',
        timestamp: now.subtract(const Duration(minutes: 12)),
        device: 'web',
        ipAddress: '—',
      ),
      AuditLogEntry(
        id: 'audit_seed_2',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Viewed subscription management',
        timestamp: now.subtract(const Duration(hours: 2)),
        device: 'web',
      ),
      AuditLogEntry(
        id: 'audit_seed_3',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Updated clinic subscription',
        timestamp: now.subtract(const Duration(hours: 5)),
        device: 'windows',
        details: 'clinic_erbil_1',
      ),
    ]);
  }
}
