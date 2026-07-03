import '../../models/queue_entry.dart';
import '../../services/queue_service.dart';

/// How active patient queues are ordered on the home screen.
enum PatientQueueSort {
  nearestAppointment,
  queueProgress,
  recentlyJoined,
}

List<QueueEntry> sortPatientQueues({
  required List<QueueEntry> entries,
  required PatientQueueSort sort,
  required QueueService queueService,
}) {
  final list = List<QueueEntry>.from(entries);
  switch (sort) {
    case PatientQueueSort.nearestAppointment:
      list.sort((a, b) {
        final ad = '${a.effectiveQueueDate} ${a.effectiveSlotStart}';
        final bd = '${b.effectiveQueueDate} ${b.effectiveSlotStart}';
        return ad.compareTo(bd);
      });
    case PatientQueueSort.queueProgress:
      list.sort((a, b) {
        final pa = queueProgressRatio(
          queueService.currentServingNumber(a) ?? 0,
          a.position,
        );
        final pb = queueProgressRatio(
          queueService.currentServingNumber(b) ?? 0,
          b.position,
        );
        final cmp = pb.compareTo(pa);
        if (cmp != 0) return cmp;
        return a.position.compareTo(b.position);
      });
    case PatientQueueSort.recentlyJoined:
      list.sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
  }
  return list;
}

/// 0.0 = just joined the line, 1.0 = your turn or already serving.
double queueProgressRatio(int currentServing, int myNumber) {
  if (myNumber <= 0) return 0;
  if (currentServing >= myNumber) return 1;
  if (currentServing <= 0) return 0.04;
  return (currentServing / myNumber).clamp(0.04, 0.98);
}

bool canCancelPatientQueue(QueueEntry entry) =>
    entry.status == QueueStatus.waiting ||
    entry.status == QueueStatus.review ||
    entry.status == QueueStatus.followUp;
