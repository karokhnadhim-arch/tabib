import 'dart:async';

import '../../domain/repositories/repositories.dart';
import '../../models/chat_message.dart';
import '../../services/offline/connectivity_service.dart';
import '../../services/offline/offline_chat_cache_service.dart';

/// Chat repository decorator — caches messages and queues outbound text when offline.
class OfflineChatRepository implements ChatRepository {
  OfflineChatRepository({
    required ChatRepository inner,
    required OfflineChatCacheService cache,
    required ConnectivityService connectivity,
  })  : _inner = inner,
        _cache = cache,
        _connectivity = connectivity;

  final ChatRepository _inner;
  final OfflineChatCacheService _cache;
  final ConnectivityService _connectivity;
  final StreamController<String> _conversationUpdates =
      StreamController<String>.broadcast();

  void _notifyConversation(String clinicId, String patientId) {
    if (_conversationUpdates.isClosed) return;
    _conversationUpdates.add(_cache.conversationKey(clinicId, patientId));
  }

  @override
  Stream<List<ChatMessage>> watchConversation({
    required String clinicId,
    required String patientId,
  }) {
    final key = _cache.conversationKey(clinicId, patientId);
    late StreamSubscription<List<ChatMessage>> liveSub;
    late StreamSubscription<String> localSub;

    return Stream<List<ChatMessage>>.multi((emitter) async {
      Future<void> emitMerged(List<ChatMessage> live) async {
        final pending = await _cache.pendingForConversation(
          clinicId: clinicId,
          patientId: patientId,
        );
        final merged = _cache.mergeWithPending(live: live, pending: pending);
        if (!emitter.isClosed) emitter.add(merged);
      }

      final cached = await _cache.loadMessages(
        clinicId: clinicId,
        patientId: patientId,
      );
      await emitMerged(cached);

      liveSub = _inner
          .watchConversation(clinicId: clinicId, patientId: patientId)
          .listen(
        (live) async {
          await _cache.saveMessages(
            clinicId: clinicId,
            patientId: patientId,
            messages: live,
          );
          await emitMerged(live);
        },
        onError: (_) async {
          await emitMerged(cached);
        },
      );

      localSub = _conversationUpdates.stream
          .where((updatedKey) => updatedKey == key)
          .listen((_) async {
        final live = await _cache.loadMessages(
          clinicId: clinicId,
          patientId: patientId,
        );
        await emitMerged(live);
      });

      emitter.onCancel = () async {
        await liveSub.cancel();
        await localSub.cancel();
      };
    });
  }

  @override
  Stream<ChatTypingState?> watchTyping({
    required String clinicId,
    required String patientId,
  }) =>
      _inner.watchTyping(clinicId: clinicId, patientId: patientId);

  @override
  Future<List<ChatMessage>> loadOlderMessages({
    required String clinicId,
    required String patientId,
    required DateTime before,
    int limit = 30,
  }) =>
      _inner.loadOlderMessages(
        clinicId: clinicId,
        patientId: patientId,
        before: before,
        limit: limit,
      );

  @override
  Future<String> sendMessage({
    required String clinicId,
    required String patientId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    if (_connectivity.isOnline) {
      try {
        final id = await _inner.sendMessage(
          clinicId: clinicId,
          patientId: patientId,
          senderId: senderId,
          senderName: senderName,
          senderRole: senderRole,
          text: text,
        );
        return id;
      } catch (_) {
        if (_connectivity.isOnline) rethrow;
      }
    }
    final pending = await _cache.enqueueText(
      clinicId: clinicId,
      patientId: patientId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
    );
    _notifyConversation(clinicId, patientId);
    return pending.clientId;
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
  }) {
    if (!_connectivity.isOnline) {
      throw StateError('offline_image_send');
    }
    return _inner.sendImageMessage(
      clinicId: clinicId,
      patientId: patientId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      imageUrl: imageUrl,
      imageThumbnailUrl: imageThumbnailUrl,
      caption: caption,
    );
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
    if (!_connectivity.isOnline) return;
    await _inner.setTyping(
      clinicId: clinicId,
      patientId: patientId,
      userId: userId,
      userName: userName,
      role: role,
      isTyping: isTyping,
    );
  }

  @override
  Future<void> markDelivered({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) async {
    if (!_connectivity.isOnline) return;
    await _inner.markDelivered(
      clinicId: clinicId,
      patientId: patientId,
      readerRole: readerRole,
    );
  }

  @override
  Future<void> markConversationRead({
    required String clinicId,
    required String patientId,
    required String readerRole,
  }) async {
    if (!_connectivity.isOnline) return;
    await _inner.markConversationRead(
      clinicId: clinicId,
      patientId: patientId,
      readerRole: readerRole,
    );
  }

  /// Sends queued text messages when connectivity returns (server is source of truth).
  Future<void> flushPendingMessages() async {
    if (!_connectivity.isOnline) return;
    final pending = await _cache.loadPending();
    for (final item in List<PendingChatOutbound>.from(pending)) {
      if (!_connectivity.isOnline) break;
      try {
        await _inner.sendMessage(
          clinicId: item.clinicId,
          patientId: item.patientId,
          senderId: item.senderId,
          senderName: item.senderName,
          senderRole: item.senderRole,
          text: item.text,
        );
        await _cache.removePending(item.clientId);
        _notifyConversation(item.clinicId, item.patientId);
      } catch (_) {
        break;
      }
    }
  }

  void dispose() {
    _conversationUpdates.close();
  }
}
