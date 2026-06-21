import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/notification.dart';
import '../models/queue_entry.dart';
import '../presentation/providers/app_providers.dart';

/// Sends in-app queue alerts and device feedback when thresholds are crossed.
class QueueAlertService {
  int? _lastAheadCount;
  QueueStatus? _lastStatus;

  Future<void> handleQueueUpdate({
    required QueueEntry entry,
    required int peopleAhead,
    required AppLocalizations l10n,
    required NotificationProvider notifications,
    required String patientUserId,
  }) async {
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

    if (peopleAhead == 4) {
      await _send(
        notifications: notifications,
        userId: patientUserId,
        title: l10n.queueNotifyFourRemaining,
        body: l10n.queueNotifyFourRemainingBody,
      );
    } else if (peopleAhead == 2) {
      await _send(
        notifications: notifications,
        userId: patientUserId,
        title: l10n.queueNotifyTwoRemaining,
        body: l10n.queueNotifyTwoRemainingBody,
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
    await _send(
      notifications: notifications,
      userId: userId,
      title: l10n.queueNotifyYourTurn,
      body: l10n.queueNotifyYourTurnBody,
    );
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);
  }

  Future<void> _send({
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
