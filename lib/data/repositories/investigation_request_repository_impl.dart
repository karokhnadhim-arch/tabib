import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_limits.dart';
import '../../models/investigation_request.dart';
import '../../models/investigation_request_item.dart';
import '../../models/notification.dart';
import '../../domain/repositories/repositories.dart';

class FirestoreInvestigationRequestRepository
    implements InvestigationRequestRepository {
  FirestoreInvestigationRequestRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('investigation_requests');

  @override
  Stream<List<InvestigationRequest>> watchPatientRequests(String patientId) {
    return _collection
        .where('patientId', isEqualTo: patientId)
        .orderBy('updatedAt', descending: true)
        .limit(FirestoreLimits.investigationRequestsPageSize)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InvestigationRequest.fromFirestore(d.id, d.data()))
            .toList());
  }

  @override
  Stream<List<InvestigationRequest>> watchDoctorRequests(String doctorId) {
    return _collection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('updatedAt', descending: true)
        .limit(FirestoreLimits.investigationRequestsPageSize)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InvestigationRequest.fromFirestore(d.id, d.data()))
            .toList());
  }

  @override
  Future<void> upsertVisitRequest({
    required String queueEntryId,
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required List<InvestigationRequestItem> items,
  }) async {
    final ref = _collection.doc(queueEntryId);
    final existing = await ref.get();
    final now = DateTime.now();

    if (items.isEmpty) {
      if (existing.exists) {
        await ref.update({
          'items': [],
          'updatedAt': Timestamp.fromDate(now),
        });
      }
      return;
    }

    final data = {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'queueEntryId': queueEntryId,
      'items': items.map((e) => e.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(now),
      if (!existing.exists) 'createdAt': Timestamp.fromDate(now),
    };

    if (existing.exists) {
      final existingData = existing.data();
      final hadPending = _countPending(existingData);
      await ref.set(data, SetOptions(merge: true));
      final hasPending = items.where((i) => i.isPending).length;
      if (hadPending > 0 && hasPending < hadPending) {
        await _db.collection('notifications').add({
          'userId': patientId,
          'title': 'Investigation result available',
          'body': 'Dr. $doctorName — your investigation results are ready',
          'createdAt': Timestamp.now(),
          'read': false,
          'type': AppNotificationType.general.name,
        });
      }
    } else {
      await ref.set({
        ...data,
        'createdAt': Timestamp.fromDate(now),
      });
      await _db.collection('notifications').add({
        'userId': patientId,
        'title': 'Investigation requested',
        'body': 'Dr. $doctorName requested investigations for you',
        'createdAt': Timestamp.now(),
        'read': false,
        'type': AppNotificationType.general.name,
      });
    }
  }

  int _countPending(Map<String, dynamic>? data) {
    if (data == null) return 0;
    final rawItems = data['items'];
    if (rawItems is! List) return 0;
    var count = 0;
    for (final raw in rawItems) {
      if (raw is Map && (raw['status'] as String? ?? 'pending') == 'pending') {
        count++;
      }
    }
    return count;
  }
}
