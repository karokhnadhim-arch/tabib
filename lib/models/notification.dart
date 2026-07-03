import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_channel.dart';

enum AppNotificationType {
  appointment,
  prescription,
  general,
  queue,
  subscription,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.type = AppNotificationType.general,
    this.eventType,
    this.deliveryChannel,
    this.deliveryStatus = NotificationDeliveryStatus.sent,
    this.sentByUserId,
    this.sentByName,
    this.localeCode,
    this.doctorId,
    this.queueEntryId,
    this.openedAt,
    this.metadata = const {},
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final AppNotificationType type;
  final NotificationEventType? eventType;
  final NotificationChannel? deliveryChannel;
  final NotificationDeliveryStatus deliveryStatus;
  final String? sentByUserId;
  final String? sentByName;
  final String? localeCode;
  final String? doctorId;
  final String? queueEntryId;
  final DateTime? openedAt;
  final Map<String, String> metadata;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'body': body,
        'createdAt': Timestamp.fromDate(createdAt),
        'read': read,
        'type': type.name,
        if (eventType != null) 'eventType': eventType!.storageKey,
        if (deliveryChannel != null)
          'deliveryChannel': deliveryChannel!.storageKey,
        'deliveryStatus': deliveryStatus.name,
        if (sentByUserId != null) 'sentByUserId': sentByUserId,
        if (sentByName != null) 'sentByName': sentByName,
        if (localeCode != null) 'localeCode': localeCode,
        if (doctorId != null) 'doctorId': doctorId,
        if (queueEntryId != null) 'queueEntryId': queueEntryId,
        if (openedAt != null) 'openedAt': Timestamp.fromDate(openedAt!),
        if (metadata.isNotEmpty) 'metadata': metadata,
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
      eventType: _parseEventType(data['eventType']),
      deliveryChannel: _parseChannel(data['deliveryChannel']),
      deliveryStatus: NotificationDeliveryStatus.values.firstWhere(
        (s) => s.name == data['deliveryStatus'],
        orElse: () => NotificationDeliveryStatus.sent,
      ),
      sentByUserId: data['sentByUserId'] as String?,
      sentByName: data['sentByName'] as String?,
      localeCode: data['localeCode'] as String?,
      doctorId: data['doctorId'] as String?,
      queueEntryId: data['queueEntryId'] as String?,
      openedAt: data['openedAt'] != null ? _parseDate(data['openedAt']) : null,
      metadata: _parseMetadata(data['metadata']),
    );
  }

  AppNotification copyWith({
    bool? read,
    DateTime? openedAt,
    NotificationDeliveryStatus? deliveryStatus,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
      type: type,
      eventType: eventType,
      deliveryChannel: deliveryChannel,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      sentByUserId: sentByUserId,
      sentByName: sentByName,
      localeCode: localeCode,
      doctorId: doctorId,
      queueEntryId: queueEntryId,
      openedAt: openedAt ?? this.openedAt,
      metadata: metadata,
    );
  }

  static NotificationEventType? _parseEventType(dynamic raw) {
    if (raw is! String) return null;
    return NotificationEventType.values.cast<NotificationEventType?>().firstWhere(
          (t) => t?.storageKey == raw,
          orElse: () => null,
        );
  }

  static NotificationChannel? _parseChannel(dynamic raw) {
    if (raw is! String) return null;
    return NotificationChannel.values.cast<NotificationChannel?>().firstWhere(
          (c) => c?.storageKey == raw,
          orElse: () => null,
        );
  }

  static Map<String, String> _parseMetadata(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
