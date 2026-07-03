import '../l10n/app_localizations.dart';
import '../models/notification.dart';
import '../models/queue_entry.dart';
import '../presentation/providers/app_providers.dart';
import 'smart_notification_service.dart';

/// Sends in-app queue alerts and device feedback when thresholds are crossed.
class QueueAlertService {
  QueueAlertService({SmartNotificationService? smartNotifications})
      : _smartNotifications = smartNotifications;

  final SmartNotificationService? _smartNotifications;
  int? _lastAheadCount;
  QueueStatus? _lastStatus;

  static const _thresholds = [10, 5, 3];

  Future<void> handleQueueUpdate({
    required QueueEntry entry,
    required int peopleAhead,
    required AppLocalizations l10n,
    required NotificationProvider notifications,
    required String patientUserId,
    String? doctorName,
  }) async {
    if (_smartNotifications != null && doctorName != null) {
      if (_lastStatus != entry.status) {
        _lastStatus = entry.status;
        if (entry.status == QueueStatus.inProgress) {
          await _smartNotifications!.notifyQueueThreshold(
            patientUserId: patientUserId,
            patientName: entry.patientName,
            patientPhone: entry.patientPhone,
            doctorId: entry.doctorId,
            doctorName: doctorName,
            queueEntryId: entry.id,
            peopleAhead: 0,
          );
        }
      }

      if (entry.isWaitingInLine && _lastAheadCount != peopleAhead) {
        for (final threshold in _thresholds) {
          if (peopleAhead == threshold) {
            await _smartNotifications!.notifyQueueThreshold(
              patientUserId: patientUserId,
              patientName: entry.patientName,
              patientPhone: entry.patientPhone,
              doctorId: entry.doctorId,
              doctorName: doctorName,
              queueEntryId: entry.id,
              peopleAhead: threshold,
            );
          }
        }
        if (peopleAhead == 0 &&
            _lastAheadCount != null &&
            _lastAheadCount! > 0) {
          await _smartNotifications!.notifyQueueThreshold(
            patientUserId: patientUserId,
            patientName: entry.patientName,
            patientPhone: entry.patientPhone,
            doctorId: entry.doctorId,
            doctorName: doctorName,
            queueEntryId: entry.id,
            peopleAhead: 0,
          );
        }
      }
      _lastAheadCount = peopleAhead;
      _lastStatus = entry.status;
      return;
    }

    if (_lastStatus != entry.status) {
      _lastStatus = entry.status;
      if (entry.status == QueueStatus.inProgress) {
        await _notifyTurn(l10n, notifications, patientUserId);
      }
    }

    if (!entry.isWaitingInLine) {
      _lastAheadCount = peopleAhead;
      return;
    }

    if (_lastAheadCount == peopleAhead) return;

    if (peopleAhead == 10) {
      await _sendLegacy(
        notifications: notifications,
        userId: patientUserId,
        title: l10n.queueNotifyTenRemaining,
        body: l10n.queueNotifyTenRemainingBody,
      );
    } else if (peopleAhead == 5) {
      await _sendLegacy(
        notifications: notifications,
        userId: patientUserId,
        title: l10n.queueNotifyFiveRemaining,
        body: l10n.queueNotifyFiveRemainingBody,
      );
    } else if (peopleAhead == 3) {
      await _sendLegacy(
        notifications: notifications,
        userId: patientUserId,
        title: l10n.queueNotifyThreeRemaining,
        body: l10n.queueNotifyThreeRemainingBody,
      );
    } else if (peopleAhead == 0 &&
        _lastAheadCount != null &&
        _lastAheadCount! > 0) {
      await _notifyTurn(l10n, notifications, patientUserId);
    }

    _lastAheadCount = peopleAhead;
  }

  Future<void> _notifyTurn(
    AppLocalizations l10n,
    NotificationProvider notifications,
    String userId,
  ) async {
    await _sendLegacy(
      notifications: notifications,
      userId: userId,
      title: l10n.queueNotifyYourTurn,
      body: l10n.queueNotifyYourTurnBody,
    );
  }

  Future<void> _sendLegacy({
    required NotificationProvider notifications,
    required String userId,
    required String title,
    required String body,
  }) =>
      notifications.send(
        userId: userId,
        title: title,
        body: body,
        type: AppNotificationType.queue.name,
      );

  void reset() {
    _lastAheadCount = null;
    _lastStatus = null;
  }
}
