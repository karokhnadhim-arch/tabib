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

/// Doctor-facing arrival indicator derived from queue status + ready flag.
enum PatientArrivalStatus {
  notArrived,
  readyForConsultation,
  insideDoctorRoom,
  completed,
}

extension QueueEntryArrival on QueueEntry {
  PatientArrivalStatus get arrivalStatus {
    switch (status) {
      case QueueStatus.completed:
        return PatientArrivalStatus.completed;
      case QueueStatus.inProgress:
      case QueueStatus.examination:
      case QueueStatus.sentForTests:
        return PatientArrivalStatus.insideDoctorRoom;
      default:
        break;
    }
    if (patientReady &&
        (status == QueueStatus.waiting || status == QueueStatus.review)) {
      return PatientArrivalStatus.readyForConsultation;
    }
    return PatientArrivalStatus.notArrived;
  }
}

extension PatientArrivalStatusUi on PatientArrivalStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PatientArrivalStatus.notArrived:
        return l10n.patientNotArrived;
      case PatientArrivalStatus.readyForConsultation:
        return l10n.patientReadyForConsultation;
      case PatientArrivalStatus.insideDoctorRoom:
        return l10n.patientInsideDoctorRoom;
      case PatientArrivalStatus.completed:
        return l10n.queueStatusCompleted;
    }
  }

  Color color() {
    switch (this) {
      case PatientArrivalStatus.notArrived:
        return Colors.grey.shade500;
      case PatientArrivalStatus.readyForConsultation:
        return AppTheme.medicalGreen;
      case PatientArrivalStatus.insideDoctorRoom:
        return AppTheme.medicalBlue;
      case PatientArrivalStatus.completed:
        return AppTheme.medicalGreenLight;
    }
  }

  IconData icon() {
    switch (this) {
      case PatientArrivalStatus.notArrived:
        return Icons.circle_outlined;
      case PatientArrivalStatus.readyForConsultation:
        return Icons.waving_hand_rounded;
      case PatientArrivalStatus.insideDoctorRoom:
        return Icons.circle;
      case PatientArrivalStatus.completed:
        return Icons.check_circle_rounded;
    }
  }
}