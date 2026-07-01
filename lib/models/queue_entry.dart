enum QueueStatus {
  waiting,
  inProgress,
  examination,
  review,
  /// Legacy — migrated to [examination] when read from storage.
  sentForTests,
  /// Legacy — migrated to [review] when read from storage.
  followUp,
  completed,
  absent,
  cancelled,
}

QueueStatus parseQueueStatus(String? raw) {
  switch (raw) {
    case 'inProgress':
      return QueueStatus.inProgress;
    case 'examination':
    case 'sentForTests':
      return QueueStatus.examination;
    case 'review':
    case 'followUp':
      return QueueStatus.review;
    case 'completed':
      return QueueStatus.completed;
    case 'absent':
      return QueueStatus.absent;
    case 'cancelled':
      return QueueStatus.cancelled;
    case 'waiting':
    default:
      return QueueStatus.waiting;
  }
}

class QueueEntry {
  QueueEntry({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.position,
    required this.status,
    required this.bookedAt,
    this.estimatedWaitMinutes,
    this.queueDate = '',
    this.slotStart = '',
    this.slotEnd = '',
  });

  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  int position;
  QueueStatus status;
  final DateTime bookedAt;
  int? estimatedWaitMinutes;
  /// Calendar day for this queue (YYYY-MM-DD).
  final String queueDate;
  /// Slot start/end in 24h HH:mm — positions are scoped per day + slot.
  final String slotStart;
  final String slotEnd;

  static String dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  String get effectiveQueueDate =>
      queueDate.isNotEmpty ? queueDate : dateKey(bookedAt);

  String get effectiveSlotStart =>
      slotStart.isNotEmpty ? slotStart : '09:00';

  String get effectiveSlotEnd => slotEnd.isNotEmpty ? slotEnd : '17:00';

  bool isSameSlotAs(QueueEntry other) =>
      doctorId == other.doctorId &&
      effectiveQueueDate == other.effectiveQueueDate &&
      effectiveSlotStart == other.effectiveSlotStart;

  bool get isActive =>
      status == QueueStatus.waiting ||
      status == QueueStatus.inProgress ||
      status == QueueStatus.review;

  bool get isInExamination =>
      status == QueueStatus.examination ||
      status == QueueStatus.sentForTests;

  bool get isWaitingInLine =>
      status == QueueStatus.waiting || status == QueueStatus.review;

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'patientPhone': patientPhone,
        'doctorId': doctorId,
        'position': position,
        'status': _persistedStatusName(status),
        'bookedAt': bookedAt.toUtc().millisecondsSinceEpoch,
        'estimatedWaitMinutes': estimatedWaitMinutes,
        if (queueDate.isNotEmpty) 'queueDate': queueDate,
        if (slotStart.isNotEmpty) 'slotStart': slotStart,
        if (slotEnd.isNotEmpty) 'slotEnd': slotEnd,
      };

  static String _persistedStatusName(QueueStatus status) {
    switch (status) {
      case QueueStatus.examination:
      case QueueStatus.sentForTests:
        return 'examination';
      case QueueStatus.review:
      case QueueStatus.followUp:
        return 'review';
      default:
        return status.name;
    }
  }

  factory QueueEntry.fromFirestore(String id, Map<String, dynamic> data) {
    return QueueEntry(
      id: id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      patientPhone: data['patientPhone'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      position: (data['position'] as num?)?.toInt() ?? 0,
      status: parseQueueStatus(data['status'] as String?),
      bookedAt: DateTime.fromMillisecondsSinceEpoch(
        (data['bookedAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      estimatedWaitMinutes: (data['estimatedWaitMinutes'] as num?)?.toInt(),
      queueDate: data['queueDate'] as String? ?? '',
      slotStart: data['slotStart'] as String? ?? '',
      slotEnd: data['slotEnd'] as String? ?? '',
    );
  }
}

const activeQueueStatuses = [
  QueueStatus.waiting,
  QueueStatus.inProgress,
  QueueStatus.review,
];

const activeQueueStatusNames = [
  'waiting',
  'inProgress',
  'review',
  'followUp', // legacy
];

/// Secretary dashboard — active queue plus patients in examination.
const secretaryQueueStatusNames = [
  'waiting',
  'inProgress',
  'review',
  'followUp', // legacy
  'examination',
  'sentForTests', // legacy
];

/// Patient-facing stream — includes examination (off active queue but visible).
const patientVisibleQueueStatusNames = [
  'waiting',
  'inProgress',
  'review',
  'followUp', // legacy
  'examination',
  'sentForTests', // legacy
];
