import 'package:cloud_firestore/cloud_firestore.dart';

import 'investigation_request_item.dart';

/// Investigation request batch for a single queue visit.
class InvestigationRequest {
  const InvestigationRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.queueEntryId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String queueEntryId;
  final List<InvestigationRequestItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  List<InvestigationRequestItem> get pendingItems =>
      items.where((i) => i.isPending).toList();

  bool get hasPending => pendingItems.isNotEmpty;

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'queueEntryId': queueEntryId,
        'items': items.map((e) => e.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory InvestigationRequest.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawItems = data['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) =>
                InvestigationRequestItem.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : const <InvestigationRequestItem>[];

    return InvestigationRequest(
      id: id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      queueEntryId: data['queueEntryId'] as String? ?? '',
      items: items,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt'] ?? data['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
