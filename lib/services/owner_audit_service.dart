import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/audit_log_entry.dart';
import '../models/audit_module.dart';
import '../models/user_account.dart';
import 'audit_device_context.dart';
import 'audit_log_exporter.dart';
import 'firebase_bootstrap.dart';

/// Append-only audit trail — immutable, owner-only visibility.
class OwnerAuditService extends ChangeNotifier {
  OwnerAuditService({
    FirebaseFirestore? firestore,
    bool? useFirestore,
  })  : _useFirestore = useFirestore ?? false,
        _db = FirebaseBootstrap.firestoreOrNull(
          enabled: useFirestore ?? false,
          override: firestore,
        ) {
    if (!_useFirestore) _seedDemoEntries();
  }

  final FirebaseFirestore? _db;
  final bool _useFirestore;
  static const _uuid = Uuid();
  static const _collection = 'audit_logs';
  static const _pageSize = 50;

  final List<AuditLogEntry> _entries = [];
  AuditLogFilters _filters = const AuditLogFilters();
  bool _loaded = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;

  List<AuditLogEntry> get entries => List.unmodifiable(_sortedEntries);

  AuditLogFilters get filters => _filters;

  String get searchQuery => _filters.search;
  AuditLogFilter get filter => _filters.legacyFilter ?? AuditLogFilter.all;

  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;

  List<AuditLogEntry> get _sortedEntries {
    final copy = List<AuditLogEntry>.from(_entries);
    copy.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return copy;
  }

  List<AuditLogEntry> get filteredEntries {
    final query = _filters.search.trim().toLowerCase();
    return _sortedEntries.where((entry) {
      if (!_matchesLegacyFilter(entry)) return false;
      if (_filters.role != null && entry.userRole != _filters.role) {
        return false;
      }
      if (_filters.module != null && entry.module != _filters.module) {
        return false;
      }
      if (_filters.clinicId != null &&
          _filters.clinicId!.isNotEmpty &&
          entry.clinicId != _filters.clinicId) {
        return false;
      }
      if (_filters.userId != null &&
          _filters.userId!.isNotEmpty &&
          entry.userId != _filters.userId) {
        return false;
      }
      if (_filters.startDate != null) {
        final start = DateTime(
          _filters.startDate!.year,
          _filters.startDate!.month,
          _filters.startDate!.day,
        );
        if (entry.timestamp.isBefore(start)) return false;
      }
      if (_filters.endDate != null) {
        final end = DateTime(
          _filters.endDate!.year,
          _filters.endDate!.month,
          _filters.endDate!.day,
          23,
          59,
          59,
          999,
        );
        if (entry.timestamp.isAfter(end)) return false;
      }
      if (query.isEmpty) return true;
      return entry.userName.toLowerCase().contains(query) ||
          entry.action.toLowerCase().contains(query) ||
          (entry.description?.toLowerCase().contains(query) ?? false) ||
          (entry.device?.toLowerCase().contains(query) ?? false) ||
          (entry.operatingSystem?.toLowerCase().contains(query) ?? false) ||
          (entry.ipAddress?.toLowerCase().contains(query) ?? false) ||
          (entry.details?.toLowerCase().contains(query) ?? false) ||
          (entry.clinicId?.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);
  }

  /// Activity statistics for the owner dashboard.
  AuditActivityStats get statistics {
    final all = filteredEntries;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));
    final byModule = <AuditModule, int>{};
    final byRole = <UserRole, int>{};
    var today = 0;
    var week = 0;
    for (final e in all) {
      if (e.module != null) {
        byModule[e.module!] = (byModule[e.module!] ?? 0) + 1;
      }
      if (e.userRole != null) {
        byRole[e.userRole!] = (byRole[e.userRole!] ?? 0) + 1;
      }
      if (!e.timestamp.isBefore(todayStart)) today++;
      if (!e.timestamp.isBefore(weekStart)) week++;
    }
    return AuditActivityStats(
      total: all.length,
      today: today,
      lastSevenDays: week,
      byModule: byModule,
      byRole: byRole,
    );
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    if (_useFirestore) {
      await _loadFirestorePage(reset: true);
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_useFirestore || _loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    await _loadFirestorePage(reset: false);
    _loadingMore = false;
    notifyListeners();
  }

  Future<void> _loadFirestorePage({required bool reset}) async {
    if (reset) {
      _entries.clear();
      _lastDoc = null;
      _hasMore = true;
    }
    try {
      Query<Map<String, dynamic>> query = _db!
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .limit(_pageSize);
      if (_lastDoc != null) {
        query = query.startAfterDocument(_lastDoc!);
      }
      final snap = await query.get();
      if (snap.docs.isEmpty) {
        _hasMore = false;
        return;
      }
      _lastDoc = snap.docs.last;
      _hasMore = snap.docs.length >= _pageSize;
      for (final doc in snap.docs) {
        _entries.add(AuditLogEntry.fromMap(doc.id, doc.data()));
      }
    } catch (e) {
      debugPrint('Audit load failed: $e');
      _hasMore = false;
    }
  }

  void setSearchQuery(String query) {
    if (_filters.search == query) return;
    _filters = _filters.copyWith(search: query);
    notifyListeners();
  }

  void setFilter(AuditLogFilter filter) {
    _filters = _filters.copyWith(legacyFilter: filter);
    notifyListeners();
  }

  void updateFilters(AuditLogFilters filters) {
    _filters = filters;
    notifyListeners();
  }

  void clearFilters() {
    _filters = const AuditLogFilters();
    notifyListeners();
  }

  /// Primary append-only logging API.
  void log({
    required String userId,
    required String userName,
    UserRole? userRole,
    required AuditModule module,
    required AuditActionType actionType,
    required String action,
    String? description,
    String? clinicId,
    String? details,
    String? device,
    String? operatingSystem,
    String? ipAddress,
  }) {
    final ctx = AuditDeviceContext.capture(ipAddress: ipAddress);
    final entry = AuditLogEntry(
      id: _uuid.v4(),
      userId: userId,
      userName: userName,
      userRole: userRole,
      module: module,
      actionType: actionType,
      action: action,
      description: description,
      clinicId: clinicId,
      details: details,
      timestamp: DateTime.now(),
      device: device ?? ctx.device,
      operatingSystem: operatingSystem ?? ctx.operatingSystem,
      ipAddress: ipAddress ?? ctx.ipAddress,
    );
    _entries.add(entry);
    notifyListeners();
    if (_useFirestore) {
      _persistEntry(entry);
    }
  }

  Future<void> _persistEntry(AuditLogEntry entry) async {
    try {
      await _db!.collection(_collection).doc(entry.id).set(entry.toMap());
    } catch (e) {
      debugPrint('Audit persist failed: $e');
    }
  }

  /// Backward-compatible logging for existing call sites.
  void record({
    required String userId,
    required String userName,
    required String action,
    String? device,
    String? ipAddress,
    String? details,
  }) {
    log(
      userId: userId,
      userName: userName,
      module: AuditModule.system,
      actionType: AuditActionType.other,
      action: action,
      details: details,
      device: device,
      ipAddress: ipAddress,
    );
  }

  String exportCsv() => AuditLogExporter.exportCsv(filteredEntries);
  String exportExcel() => AuditLogExporter.exportExcel(filteredEntries);

  Future<List<int>> exportPdfBytes(String title) =>
      AuditLogExporter.exportPdfBytes(entries: filteredEntries, title: title);

  bool _matchesLegacyFilter(AuditLogEntry entry) {
    final legacy = _filters.legacyFilter ?? AuditLogFilter.all;
    if (legacy == AuditLogFilter.all) return true;
    final action = entry.action.toLowerCase();
    final type = entry.actionType;
    return switch (legacy) {
      AuditLogFilter.all => true,
      AuditLogFilter.login =>
        type == AuditActionType.login ||
            type == AuditActionType.logout ||
            type == AuditActionType.failedLogin ||
            action.contains('login') ||
            action.contains('logout'),
      AuditLogFilter.userManagement =>
        type == AuditActionType.userCreated ||
            type == AuditActionType.userDeactivated ||
            type == AuditActionType.userActivated ||
            action.contains('user') ||
            action.contains('doctor') ||
            action.contains('secretary'),
      AuditLogFilter.packages =>
        action.contains('subscription') ||
            action.contains('package') ||
            action.contains('renew'),
      AuditLogFilter.ads =>
        action.contains('advertisement') || action.contains('ad '),
      AuditLogFilter.backup => action.contains('backup'),
      AuditLogFilter.settings =>
        type == AuditActionType.settingsChanged || action.contains('setting'),
    };
  }

  void _seedDemoEntries() {
    final now = DateTime.now();
    void seed({
      required String id,
      required String action,
      required AuditActionType type,
      required AuditModule module,
      UserRole role = UserRole.admin,
      Duration ago = Duration.zero,
      String? description,
      String? clinicId,
    }) {
      _entries.add(
        AuditLogEntry(
          id: id,
          userId: 'demo_admin',
          userName: 'System Owner',
          userRole: role,
          module: module,
          actionType: type,
          action: action,
          description: description,
          clinicId: clinicId,
          timestamp: now.subtract(ago),
          device: 'web',
          operatingSystem: 'web',
          ipAddress: '192.168.1.10',
        ),
      );
    }

    seed(
      id: 'audit_seed_1',
      action: 'Login',
      type: AuditActionType.login,
      module: AuditModule.authentication,
      ago: const Duration(minutes: 12),
    );
    seed(
      id: 'audit_seed_2',
      action: 'Doctor created',
      type: AuditActionType.userCreated,
      module: AuditModule.owner,
      description: 'DR-10025',
      ago: const Duration(hours: 1),
    );
    seed(
      id: 'audit_seed_3',
      action: 'Secretary added',
      type: AuditActionType.userCreated,
      module: AuditModule.owner,
      ago: const Duration(hours: 2),
    );
    seed(
      id: 'audit_seed_4',
      action: 'User deactivated',
      type: AuditActionType.userDeactivated,
      module: AuditModule.owner,
      description: 'account_42',
      ago: const Duration(hours: 4),
    );
    seed(
      id: 'audit_seed_5',
      action: 'Queue created',
      type: AuditActionType.queueCreated,
      module: AuditModule.secretary,
      role: UserRole.secretary,
      clinicId: 'clinic_erbil_1',
      ago: const Duration(hours: 5),
    );
    seed(
      id: 'audit_seed_6',
      action: 'Prescription created',
      type: AuditActionType.prescriptionCreated,
      module: AuditModule.doctor,
      role: UserRole.doctor,
      ago: const Duration(hours: 6),
    );
    seed(
      id: 'audit_seed_7',
      action: 'Failed login attempt',
      type: AuditActionType.failedLogin,
      module: AuditModule.authentication,
      description: 'invalid_credentials',
      ago: const Duration(hours: 7),
    );
    seed(
      id: 'audit_seed_8',
      action: 'Medicine database updated',
      type: AuditActionType.medicineChanged,
      module: AuditModule.owner,
      ago: const Duration(hours: 8),
    );
    seed(
      id: 'audit_seed_9',
      action: 'Logout',
      type: AuditActionType.logout,
      module: AuditModule.authentication,
      ago: const Duration(hours: 14),
    );
  }
}

class AuditActivityStats {
  const AuditActivityStats({
    required this.total,
    required this.today,
    required this.lastSevenDays,
    required this.byModule,
    required this.byRole,
  });

  final int total;
  final int today;
  final int lastSevenDays;
  final Map<AuditModule, int> byModule;
  final Map<UserRole, int> byRole;
}
