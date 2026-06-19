enum QueueStatus { waiting, inProgress, completed, cancelled }

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

  bool get isActive =>
      status == QueueStatus.waiting || status == QueueStatus.inProgress;

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'patientPhone': patientPhone,
        'doctorId': doctorId,
        'position': position,
        'status': status.name,
        'bookedAt': bookedAt.toUtc().millisecondsSinceEpoch,
        'estimatedWaitMinutes': estimatedWaitMinutes,
      };

  factory QueueEntry.fromFirestore(String id, Map<String, dynamic> data) {
    return QueueEntry(
      id: id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      patientPhone: data['patientPhone'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      position: (data['position'] as num?)?.toInt() ?? 0,
      status: QueueStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => QueueStatus.waiting,
      ),
      bookedAt: DateTime.fromMillisecondsSinceEpoch(
        (data['bookedAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      estimatedWaitMinutes: (data['estimatedWaitMinutes'] as num?)?.toInt(),
    );
  }
}
