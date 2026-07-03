import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_limits.dart';
import '../../models/chat_message.dart';
import '../../domain/repositories/repositories.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static String _typingDocId(String clinicId, String patientId) =>
      '${clinicId}_$patientId';

  CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('chat_messages');

  DocumentReference<Map<String, dynamic>> _typingRef(
    String clinicId,
    String patientId,
  ) =>
      _db.collection('chat_typing').doc(_typingDocId(clinicId, patientId));

  @override
  Stream<List<ChatMessage>> watchConversation({
    required String clinicId,
    required String patientId,
  }) {
    return _messages
        .where('clinicId', isEqualTo: clinicId)
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .limit(FirestoreLimits.chatMessagesPageSize)
        .snapshots()
        .map((snap) {
          final messages =
              snap.docs.map((d) => _fromDoc(d.id, d.data())).toList();
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return messages;
        });
  }

  @override
  Stream<ChatTypingState?> watchTyping({
    required String clinicId,
    required String patientId,
  }) {
    return _typingRef(clinicId, patientId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final data = snap.data()!;
      if (data['isTyping'] != true) return null;
      return ChatTypingState(
        userId: data['userId'] as String? ?? '',
        userName: data['userName'] as String? ?? '',
        role: data['role'] as String? ?? '',
        updatedAt: _parseDate(data['updatedAt']),
      );
    });
  }

  @override
  Future<List<ChatMessage>> loadOlderMessages({
    required String clinicId,
    required String patientId,
    required DateTime before,
    int limit = 30,
  }) async {
    final snap = await _messages
        .where('clinicId', isEqualTo: clinicId)
        .where('patientId', isEqualTo: patientId)
        .where('createdAt', isLessThan: Timestamp.fromDate(before))
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    final messages =
        snap.docs.map((d) => _fromDoc(d.id, d.data())).toList();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  @override
  Future<String> sendMessage({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    final ref = await _messages.add({
      'clinicId': clinicId,
      'patientId': patientId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'type': ChatMessageType.text.name,
      'createdAt': FieldValue.serverTimestamp(),
      'delivered': false,
      'read': false,
    });
    return ref.id;
  }

  @override
  Future<String> sendImageMessage({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String imageUrl,
    required String imageThumbnailUrl,
    String caption = '',
  }) async {
    final ref = await _messages.add({
      'clinicId': clinicId,
      'patientId': patientId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': caption,
      'type': ChatMessageType.image.name,
      'imageUrl': imageUrl,
      'imageThumbnailUrl': imageThumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'delivered': false,
      'read': false,
    });
    return ref.id;
  }

  @override
  Future<void> setTyping({
    required String clinicId,
    required String patientId,
    required String userId,
    required String userName,
    required String role,
    required bool isTyping,
  }) async {
    await _typingRef(clinicId, patientId).set({
      'clinicId': clinicId,
      'patientId': patientId,
      'userId': userId,
      'userName': userName,
      'role': role,
      'isTyping': isTyping,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markDelivered({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) async {
    final snap = await _messages
        .where('clinicId', isEqualTo: clinicId)
        .where('patientId', isEqualTo: patientId)
        .where('delivered', isEqualTo: false)
        .limit(FirestoreLimits.chatMessagesPageSize)
        .get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    var count = 0;
    for (final doc in snap.docs) {
      final role = doc.data()['senderRole'] as String?;
      if (role == readerRole) continue;
      batch.update(doc.reference, {'delivered': true});
      count++;
      if (count >= 450) break;
    }
    if (count > 0) await batch.commit();
  }

  @override
  Future<void> markConversationRead({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) async {
    final snap = await _messages
        .where('clinicId', isEqualTo: clinicId)
        .where('patientId', isEqualTo: patientId)
        .where('read', isEqualTo: false)
        .limit(FirestoreLimits.chatMessagesPageSize)
        .get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    var count = 0;
    for (final doc in snap.docs) {
      final role = doc.data()['senderRole'] as String?;
      if (role == readerRole) continue;
      batch.update(doc.reference, {'read': true, 'delivered': true});
      count++;
      if (count >= 450) break;
    }
    if (count > 0) await batch.commit();
  }

  ChatMessage _fromDoc(String id, Map<String, dynamic> data) {
    final typeName = data['type'] as String? ?? ChatMessageType.text.name;
    final type = ChatMessageType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => ChatMessageType.text,
    );
    return ChatMessage(
      id: id,
      clinicId: data['clinicId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: _parseDate(data['createdAt']),
      type: type,
      imageUrl: data['imageUrl'] as String?,
      imageThumbnailUrl: data['imageThumbnailUrl'] as String?,
      delivered: data['delivered'] as bool? ?? false,
      read: data['read'] as bool? ?? false,
    );
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    return DateTime.now();
  }
}
