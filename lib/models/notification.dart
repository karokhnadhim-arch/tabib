import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType { appointment, prescription, general, queue }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.type = AppNotificationType.general,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final AppNotificationType type;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'body': body,
        'createdAt': Timestamp.fromDate(createdAt),
        'read': read,
        'type': type.name,
      };

  factory AppNotification.fromFirestore(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: _parseDate(data['createdAt']),
      read: data['read'] as bool? ?? false,
      type: AppNotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => AppNotificationType.general,
      ),
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
