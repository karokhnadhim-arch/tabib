import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_limits.dart';
import '../../models/notification.dart';
import '../../models/notification_channel.dart';
import '../../domain/repositories/repositories.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<AppNotification>> watchUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(FirestoreLimits.notificationsPageSize)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppNotification.fromFirestore(d.id, d.data()))
            .toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'read': true,
      'openedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
  }) async {
    await sendSmartNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
    );
  }

  @override
  Future<void> sendSmartNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    NotificationEventType? eventType,
    NotificationChannel? deliveryChannel,
    NotificationDeliveryStatus deliveryStatus =
        NotificationDeliveryStatus.sent,
    String? sentByUserId,
    String? sentByName,
    String? localeCode,
    String? doctorId,
    String? queueEntryId,
    Map<String, String> metadata = const {},
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'createdAt': Timestamp.now(),
      'read': false,
      'type': type ?? AppNotificationType.general.name,
      if (eventType != null) 'eventType': eventType.storageKey,
      if (deliveryChannel != null)
        'deliveryChannel': deliveryChannel.storageKey,
      'deliveryStatus': deliveryStatus.name,
      if (sentByUserId != null) 'sentByUserId': sentByUserId,
      if (sentByName != null) 'sentByName': sentByName,
      if (localeCode != null) 'localeCode': localeCode,
      if (doctorId != null) 'doctorId': doctorId,
      if (queueEntryId != null) 'queueEntryId': queueEntryId,
      if (metadata.isNotEmpty) 'metadata': metadata,
    });
  }
}
