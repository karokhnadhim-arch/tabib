import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/queue_entry.dart';

extension QueueStatusUi on QueueStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case QueueStatus.waiting:
        return l10n.queueStatusWaiting;
      case QueueStatus.inProgress:
        return l10n.queueStatusWithDoctor;
      case QueueStatus.examination:
      case QueueStatus.sentForTests:
        return l10n.queueStatusExamination;
      case QueueStatus.review:
      case QueueStatus.followUp:
        return l10n.queueStatusReview;
      case QueueStatus.completed:
        return l10n.queueStatusCompleted;
      case QueueStatus.absent:
        return l10n.queueStatusAbsent;
      case QueueStatus.cancelled:
        return l10n.queueStatusCancelled;
    }
  }

  Color color() {
    switch (this) {
      case QueueStatus.waiting:
        return AppTheme.medicalBlue;
      case QueueStatus.inProgress:
        return AppTheme.medicalGreen;
      case QueueStatus.examination:
      case QueueStatus.sentForTests:
        return const Color(0xFF7B1FA2);
      case QueueStatus.review:
      case QueueStatus.followUp:
        return Colors.orange.shade700;
      case QueueStatus.completed:
        return AppTheme.medicalGreenLight;
      case QueueStatus.absent:
        return Colors.red.shade600;
      case QueueStatus.cancelled:
        return Colors.grey;
    }
  }
}
