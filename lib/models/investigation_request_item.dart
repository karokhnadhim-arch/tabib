import 'investigation_category.dart';

enum InvestigationItemStatus {
  pending,
  completed,
}

/// Single investigation line on a visit request.
class InvestigationRequestItem {
  const InvestigationRequestItem({
    required this.investigationId,
    required this.name,
    required this.category,
    this.note,
    this.status = InvestigationItemStatus.pending,
  });

  final String investigationId;
  final String name;
  final InvestigationCategory category;
  final String? note;
  final InvestigationItemStatus status;

  bool get isPending => status == InvestigationItemStatus.pending;

  Map<String, dynamic> toMap() => {
        'investigationId': investigationId,
        'name': name,
        'category': category.storageKey,
        if (note != null && note!.isNotEmpty) 'note': note,
        'status': status.name,
      };

  factory InvestigationRequestItem.fromMap(Map<String, dynamic> data) {
    return InvestigationRequestItem(
      investigationId: data['investigationId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: parseInvestigationCategory(data['category'] as String?),
      note: data['note'] as String?,
      status: InvestigationItemStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => InvestigationItemStatus.pending,
      ),
    );
  }

  InvestigationRequestItem copyWith({
    String? note,
    InvestigationItemStatus? status,
  }) {
    return InvestigationRequestItem(
      investigationId: investigationId,
      name: name,
      category: category,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }
}
