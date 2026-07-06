import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/queue_entry.dart';

/// Merges secretary/active queue entries with today's completed patients (read-only).
class DoctorTodayQueueAggregator {
  DoctorTodayQueueAggregator({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  Stream<List<QueueEntry>> watchTodayQueue({
    required Stream<List<QueueEntry>> secretaryStream,
    required String doctorId,
  }) {
    if (_firestore == null) {
      return secretaryStream.map(
        (secretary) => mergeLists(
          secretary: secretary,
          completed: const [],
          forDate: DateTime.now(),
        ),
      );
    }

    final today = QueueEntry.dateKey(DateTime.now());

    Stream<List<QueueEntry>> completedStream() {
      return _firestore!
          .collection('queue_entries')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: QueueStatus.completed.name)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => QueueEntry.fromFirestore(d.id, d.data()))
                .where((e) => e.effectiveQueueDate == today)
                .toList(),
          );
    }

    return Stream<List<QueueEntry>>.multi((multi) {
      var secretary = <QueueEntry>[];
      var completed = <QueueEntry>[];

      void emit() {
        multi.add(
          mergeLists(
            secretary: secretary,
            completed: completed,
            forDate: DateTime.now(),
          ),
        );
      }

      final sub1 = secretaryStream.listen(
        (value) {
          secretary = value;
          emit();
        },
        onError: multi.addError,
      );
      final sub2 = completedStream().listen(
        (value) {
          completed = value;
          emit();
        },
        onError: multi.addError,
      );

      multi.onCancel = () {
        sub1.cancel();
        sub2.cancel();
      };
    });
  }

  static List<QueueEntry> mergeLists({
    required List<QueueEntry> secretary,
    required List<QueueEntry> completed,
    DateTime? forDate,
  }) {
    final today = QueueEntry.dateKey(forDate ?? DateTime.now());
    final map = <String, QueueEntry>{};
    for (final entry in [...secretary, ...completed]) {
      if (entry.effectiveQueueDate != today) continue;
      if (entry.status == QueueStatus.cancelled) continue;
      map[entry.id] = entry;
    }
    final list = map.values.toList()
      ..sort((a, b) {
        final pos = a.position.compareTo(b.position);
        if (pos != 0) return pos;
        return a.bookedAt.compareTo(b.bookedAt);
      });
    return list;
  }
}

List<QueueEntry> doctorTodayQueueFromService({
  required List<QueueEntry> secretaryQueue,
  required List<QueueEntry> activeQueue,
}) {
  return DoctorTodayQueueAggregator.mergeLists(
    secretary: secretaryQueue.isNotEmpty ? secretaryQueue : activeQueue,
    completed: const [],
  );
}
