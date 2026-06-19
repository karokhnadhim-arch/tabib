import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chat_message.dart';
import '../../domain/repositories/repositories.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<ChatMessage>> watchConversation({
    required String clinicId,
    required String patientId,
  }) {
    return _db
        .collection('chat_messages')
        .where('clinicId', isEqualTo: clinicId)
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => _fromDoc(d.id, d.data()))
            .toList());
  }

  @override
  Future<void> sendMessage({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    await _db.collection('chat_messages').add({
      'clinicId': clinicId,
      'patientId': patientId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'createdAt': Timestamp.now(),
      'read': false,
    });
  }

  @override
  Future<void> markConversationRead({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) async {
    final snap = await _db
        .collection('chat_messages')
        .where('clinicId', isEqualTo: clinicId)
        .where('patientId', isEqualTo: patientId)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      final role = doc.data()['senderRole'] as String?;
      if (role != readerRole) {
        batch.update(doc.reference, {'read': true});
      }
    }
    await batch.commit();
  }

  ChatMessage _fromDoc(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      clinicId: data['clinicId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: _parseDate(data['createdAt']),
      read: data['read'] as bool? ?? false,
    );
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    return DateTime.now();
  }
}
