import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/owner_monitoring_phase4.dart';
import '../models/system_monitoring.dart';

/// Intelligent owner notifications — monitoring layer only (not push notifications).
class SmartOwnerNotificationService extends ChangeNotifier {
  static const _uuid = Uuid();
  final List<SmartOwnerNotification> _items = [];
  SystemHealthLevel? _lastHealth;

  List<SmartOwnerNotification> get activeItems => _items
      .where((n) => !n.isArchived)
      .toList(growable: false);

  List<SmartOwnerNotification> get inboxItems => _items
      .where((n) => !n.isArchived)
      .toList(growable: false)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  void syncFromMonitoring({
    required SystemMonitoringSnapshot? snapshot,
    required List<OwnerAlert> alerts,
    required SystemHealthLevel healthLevel,
  }) {
    if (snapshot == null) return;
    final now = DateTime.now();

    _upsert(
      id: 'storage_80',
      type: SmartNotificationType.storageWarning,
      title: 'Storage at 80%',
      message: 'Firebase storage usage reached ${snapshot.storageUsagePercent}%.',
      active: snapshot.storageUsagePercent >= 80 && snapshot.storageUsagePercent < 90,
      timestamp: now,
    );
    _upsert(
      id: 'storage_90',
      type: SmartNotificationType.storageCritical,
      title: 'Storage at 90%',
      message: 'Critical storage threshold — ${snapshot.storageUsagePercent}% used.',
      active: snapshot.storageUsagePercent >= 90 && snapshot.storageUsagePercent < 100,
      timestamp: now,
    );
    _upsert(
      id: 'storage_100',
      type: SmartNotificationType.storageFull,
      title: 'Storage full',
      message: 'Storage capacity reached. Immediate action required.',
      active: snapshot.storageUsagePercent >= 100,
      timestamp: now,
    );

    final backupFailed = alerts.any((a) => a.type == OwnerAlertType.backupFailed);
    _upsert(
      id: 'backup_failed',
      type: SmartNotificationType.backupFailed,
      title: 'Backup failed',
      message: 'Last platform backup did not complete successfully.',
      active: backupFailed,
      timestamp: now,
    );

    final firebaseDown = alerts.any((a) => a.type == OwnerAlertType.firebaseDisconnected);
    _upsert(
      id: 'firebase_down',
      type: SmartNotificationType.firebaseDisconnected,
      title: 'Firebase disconnected',
      message: 'Platform lost connection to Firebase services.',
      active: firebaseDown,
      timestamp: now,
    );

    final highErrors = alerts.any((a) => a.type == OwnerAlertType.highErrorRate);
    _upsert(
      id: 'high_errors',
      type: SmartNotificationType.highErrorRate,
      title: 'High error rate',
      message: 'Application error rate is ${snapshot.errorRatePercent.toStringAsFixed(1)}%.',
      active: highErrors,
      timestamp: now,
    );

    final slow = alerts.any((a) => a.type == OwnerAlertType.slowPerformance);
    _upsert(
      id: 'slow_response',
      type: SmartNotificationType.slowResponse,
      title: 'Slow response time',
      message: 'Average API response is ${snapshot.avgApiResponseMs}ms.',
      active: slow,
      timestamp: now,
    );

    _upsert(
      id: 'package_expires',
      type: SmartNotificationType.packageExpiresToday,
      title: 'Package expires today',
      message: '${snapshot.packagesExpiringSoon} subscription(s) need renewal today.',
      active: snapshot.packagesExpiringSoon > 0,
      timestamp: now,
    );

    _upsert(
      id: 'login_failures',
      type: SmartNotificationType.loginFailures,
      title: 'Login failures spike',
      message: '${snapshot.failedLoginAttempts} failed login attempts detected.',
      active: snapshot.failedLoginAttempts >= 8,
      timestamp: now,
    );

    _upsert(
      id: 'queue_wait',
      type: SmartNotificationType.queueWaitAbnormal,
      title: 'Abnormal queue wait',
      message:
          'Average wait ${snapshot.avgWaitingMinutes} min with ${snapshot.waitingPatients} patients waiting.',
      active: snapshot.avgWaitingMinutes >= 30 && snapshot.waitingPatients > 3,
      timestamp: now,
    );

    if (_lastHealth != null && _lastHealth != healthLevel) {
      _items.insert(
        0,
        SmartOwnerNotification(
          id: _uuid.v4(),
          type: SmartNotificationType.healthChange,
          title: 'System health changed',
          message: 'Health level moved from ${_lastHealth!.name} to ${healthLevel.name}.',
          timestamp: now,
        ),
      );
    }
    _lastHealth = healthLevel;

    notifyListeners();
  }

  void markRead(String id) => _update(id, (n) => n.copyWith(isRead: true));

  void archive(String id) => _update(id, (n) => n.copyWith(isArchived: true));

  void delete(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void _update(String id, SmartOwnerNotification Function(SmartOwnerNotification) fn) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _items[i] = fn(_items[i]);
    notifyListeners();
  }

  void _upsert({
    required String id,
    required SmartNotificationType type,
    required String title,
    required String message,
    required bool active,
    required DateTime timestamp,
  }) {
    final existing = _items.indexWhere((n) => n.id == id);
    if (!active) {
      if (existing != -1) _items.removeAt(existing);
      return;
    }
    final notification = SmartOwnerNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      timestamp: timestamp,
    );
    if (existing == -1) {
      _items.insert(0, notification);
    } else {
      _items[existing] = SmartOwnerNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        timestamp: timestamp,
        isRead: _items[existing].isRead,
        isArchived: _items[existing].isArchived,
      );
    }
  }
}
