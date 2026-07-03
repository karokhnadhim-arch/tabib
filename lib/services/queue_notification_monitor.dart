import '../models/queue_entry.dart';
import 'clinic_data_service.dart';
import 'queue_service.dart';
import 'smart_notification_service.dart';

/// Watches active queues and sends threshold notifications automatically.
class QueueNotificationMonitor {
  QueueNotificationMonitor({
    required QueueService queueService,
    required SmartNotificationService notifications,
    required ClinicDataService clinicData,
  })  : _queueService = queueService,
        _notifications = notifications,
        _clinicData = clinicData {
    _queueService.addListener(_onQueueChanged);
  }

  final QueueService _queueService;
  final SmartNotificationService _notifications;
  final ClinicDataService _clinicData;

  final Map<String, int> _lastAheadByEntry = {};
  final Map<String, QueueStatus> _lastStatusByEntry = {};

  void dispose() {
    _queueService.removeListener(_onQueueChanged);
  }

  void _onQueueChanged() {
    for (final doctorId in _queueService.watchedDoctorIds) {
      _scanDoctorQueue(doctorId);
    }
  }

  void _scanDoctorQueue(String doctorId) {
    final entries = _queueService.queueForDoctor(doctorId);
    if (entries.isEmpty) return;

    final doctor = _clinicData.doctorById(doctorId);
    final doctorName = doctor?.displayName ?? doctorId;

    for (final entry in entries) {
      if (!entry.isWaitingInLine && entry.status != QueueStatus.inProgress) {
        _lastAheadByEntry.remove(entry.id);
        _lastStatusByEntry.remove(entry.id);
        continue;
      }

      final ahead = _queueService.peopleAhead(entry);
      final lastAhead = _lastAheadByEntry[entry.id];
      final lastStatus = _lastStatusByEntry[entry.id];

      if (entry.status == QueueStatus.inProgress &&
          lastStatus != QueueStatus.inProgress) {
        _notifications.notifyQueueThreshold(
          patientUserId: entry.patientId,
          patientName: entry.patientName,
          patientPhone: entry.patientPhone,
          doctorId: doctorId,
          doctorName: doctorName,
          queueEntryId: entry.id,
          peopleAhead: 0,
        );
      } else if (entry.isWaitingInLine && lastAhead != ahead) {
        for (final threshold in _notifications.config.queueThresholds) {
          if (threshold == 0) continue;
          if (ahead == threshold) {
            _notifications.notifyQueueThreshold(
              patientUserId: entry.patientId,
              patientName: entry.patientName,
              patientPhone: entry.patientPhone,
              doctorId: doctorId,
              doctorName: doctorName,
              queueEntryId: entry.id,
              peopleAhead: threshold,
            );
          }
        }
        if (ahead == 0 && lastAhead != null && lastAhead > 0) {
          _notifications.notifyQueueThreshold(
            patientUserId: entry.patientId,
            patientName: entry.patientName,
            patientPhone: entry.patientPhone,
            doctorId: doctorId,
            doctorName: doctorName,
            queueEntryId: entry.id,
            peopleAhead: 0,
          );
        }
      }

      _lastAheadByEntry[entry.id] = ahead;
      _lastStatusByEntry[entry.id] = entry.status;
    }
  }
}
