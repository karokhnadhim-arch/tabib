import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../models/chat_message.dart';

/// Local chat message cache + outbound queue (reliability layer only).
class OfflineChatCacheService {
  static const _messagesPrefix = 'offline_chat_msgs_v1_';
  static const _pendingKey = 'offline_chat_pending_v1';
  static const _maxMessagesPerConversation = 50;
  static const _uuid = Uuid();

  String conversationKey(String clinicId, String patientId) =>
      '${clinicId}_$patientId';

  Future<List<ChatMessage>> loadMessages({
    required String clinicId,
    required String patientId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_messagesPrefix${conversationKey(clinicId, patientId)}');
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _messageFromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveMessages({
    required String clinicId,
    required String patientId,
    required List<ChatMessage> messages,
  }) async {
    if (messages.isEmpty) return;
    final trimmed = messages.length > _maxMessagesPerConversation
        ? messages.sublist(messages.length - _maxMessagesPerConversation)
        : messages;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_messagesPrefix${conversationKey(clinicId, patientId)}',
      jsonEncode(trimmed.map(_messageToMap).toList()),
    );
  }

  Future<List<PendingChatOutbound>> loadPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PendingChatOutbound.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<List<PendingChatOutbound>> pendingForConversation({
    required String clinicId,
    required String patientId,
  }) async {
    final key = conversationKey(clinicId, patientId);
    return (await loadPending())
        .where((p) => p.conversationKey == key)
        .toList(growable: false);
  }

  Future<PendingChatOutbound> enqueueText({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    final pending = PendingChatOutbound(
      clientId: 'pending_${_uuid.v4()}',
      clinicId: clinicId,
      patientId: patientId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
      createdAt: DateTime.now(),
    );
    final all = await loadPending()..add(pending);
    await _savePending(all);
    return pending;
  }

  Future<void> removePending(String clientId) async {
    final all = await loadPending();
    all.removeWhere((p) => p.clientId == clientId);
    await _savePending(all);
  }

  Future<void> _savePending(List<PendingChatOutbound> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  List<ChatMessage> mergeWithPending({
    required List<ChatMessage> live,
    required List<PendingChatOutbound> pending,
  }) {
    if (pending.isEmpty) return live;
    final liveIds = live.map((m) => m.id).toSet();
    final optimistic = pending
        .where((p) => !liveIds.contains(p.clientId))
        .map((p) => p.toLocalMessage())
        .toList();
    if (optimistic.isEmpty) return live;
    return [...live, ...optimistic]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Map<String, dynamic> _messageToMap(ChatMessage m) => {
        'id': m.id,
        'clinicId': m.clinicId,
        'patientId': m.patientId,
        'senderId': m.senderId,
        'senderName': m.senderName,
        'senderRole': m.senderRole,
        'text': m.text,
        'type': m.type.name,
        'createdAt': m.createdAt.toUtc().millisecondsSinceEpoch,
        'imageUrl': m.imageUrl,
        'imageThumbnailUrl': m.imageThumbnailUrl,
        'delivered': m.delivered,
        'read': m.read,
        'localOnly': m.localOnly,
      };

  ChatMessage _messageFromMap(Map<String, dynamic> data) {
    final typeName = data['type'] as String? ?? ChatMessageType.text.name;
    final type = ChatMessageType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => ChatMessageType.text,
    );
    return ChatMessage(
      id: data['id'] as String? ?? '',
      clinicId: data['clinicId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (data['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      type: type,
      imageUrl: data['imageUrl'] as String?,
      imageThumbnailUrl: data['imageThumbnailUrl'] as String?,
      delivered: data['delivered'] as bool? ?? false,
      read: data['read'] as bool? ?? false,
      localOnly: data['localOnly'] as bool? ?? false,
    );
  }
}

class PendingChatOutbound {
  const PendingChatOutbound({
    required this.clientId,
    required this.clinicId,
    required this.patientId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });

  final String clientId;
  final String clinicId;
  final String patientId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;

  String get conversationKey => '${clinicId}_$patientId';

  ChatMessage toLocalMessage() => ChatMessage(
        id: clientId,
        clinicId: clinicId,
        patientId: patientId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        text: text,
        createdAt: createdAt,
        localOnly: true,
      );

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'clinicId': clinicId,
        'patientId': patientId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'text': text,
        'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
      };

  factory PendingChatOutbound.fromMap(Map<String, dynamic> data) {
    return PendingChatOutbound(
      clientId: data['clientId'] as String? ?? '',
      clinicId: data['clinicId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (data['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
