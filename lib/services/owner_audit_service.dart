import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/audit_log_entry.dart';

enum AuditLogFilter { all, login, userManagement, packages, ads, backup, settings }

/// In-app audit trail for the System Owner dashboard (demo + live logging).
class OwnerAuditService extends ChangeNotifier {
  OwnerAuditService() {
    _seedDemoEntries();
  }

  static const _uuid = Uuid();
  final List<AuditLogEntry> _entries = [];
  String _searchQuery = '';
  AuditLogFilter _filter = AuditLogFilter.all;

  List<AuditLogEntry> get entries =>
      List.unmodifiable(_entries..sort((a, b) => b.timestamp.compareTo(a.timestamp)));

  String get searchQuery => _searchQuery;
  AuditLogFilter get filter => _filter;

  List<AuditLogEntry> get filteredEntries {
    final query = _searchQuery.trim().toLowerCase();
    return entries.where((entry) {
      if (!_matchesFilter(entry)) return false;
      if (query.isEmpty) return true;
      return entry.userName.toLowerCase().contains(query) ||
          entry.action.toLowerCase().contains(query) ||
          (entry.device?.toLowerCase().contains(query) ?? false) ||
          (entry.ipAddress?.toLowerCase().contains(query) ?? false) ||
          (entry.details?.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(AuditLogFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

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

  bool _matchesFilter(AuditLogEntry entry) {
    final action = entry.action.toLowerCase();
    return switch (_filter) {
      AuditLogFilter.all => true,
      AuditLogFilter.login =>
        action.contains('sign') ||
            action.contains('login') ||
            action.contains('logout'),
      AuditLogFilter.userManagement =>
        action.contains('user') ||
            action.contains('doctor') ||
            action.contains('secretary') ||
            action.contains('suspension') ||
            action.contains('suspend'),
      AuditLogFilter.packages =>
        action.contains('subscription') ||
            action.contains('package') ||
            action.contains('renew'),
      AuditLogFilter.ads =>
        action.contains('advertisement') || action.contains('ad '),
      AuditLogFilter.backup => action.contains('backup'),
      AuditLogFilter.settings => action.contains('setting'),
    };
  }

  void _seedDemoEntries() {
    final now = DateTime.now();
    _entries.addAll([
      AuditLogEntry(
        id: 'audit_seed_1',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Login — signed in to platform console',
        timestamp: now.subtract(const Duration(minutes: 12)),
        device: 'web',
        ipAddress: '192.168.1.10',
      ),
      AuditLogEntry(
        id: 'audit_seed_2',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Doctor created — DR-10025',
        timestamp: now.subtract(const Duration(hours: 1)),
        device: 'web',
        ipAddress: '192.168.1.10',
      ),
      AuditLogEntry(
        id: 'audit_seed_3',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Secretary added to clinic roster',
        timestamp: now.subtract(const Duration(hours: 2)),
        device: 'windows',
      ),
      AuditLogEntry(
        id: 'audit_seed_4',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'User suspension applied',
        timestamp: now.subtract(const Duration(hours: 4)),
        device: 'web',
        details: 'account_42',
      ),
      AuditLogEntry(
        id: 'audit_seed_5',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Package activated — 12 month plan',
        timestamp: now.subtract(const Duration(hours: 6)),
        device: 'web',
      ),
      AuditLogEntry(
        id: 'audit_seed_6',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Advertisement created',
        timestamp: now.subtract(const Duration(hours: 8)),
        device: 'android',
      ),
      AuditLogEntry(
        id: 'audit_seed_7',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Backup created — manual snapshot',
        timestamp: now.subtract(const Duration(hours: 10)),
        device: 'web',
      ),
      AuditLogEntry(
        id: 'audit_seed_8',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Settings changed — maintenance message updated',
        timestamp: now.subtract(const Duration(hours: 12)),
        device: 'web',
      ),
      AuditLogEntry(
        id: 'audit_seed_9',
        userId: 'demo_admin',
        userName: 'System Owner',
        action: 'Logout — console session ended',
        timestamp: now.subtract(const Duration(hours: 14)),
        device: 'web',
      ),
    ]);
  }
}
