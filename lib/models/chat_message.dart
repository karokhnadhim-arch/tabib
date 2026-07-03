enum ChatMessageType { text, image }

/// Outbound lifecycle for chat bubbles (sent → delivered → read).
enum ChatDeliveryStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.createdAt,
    this.type = ChatMessageType.text,
    this.imageUrl,
    this.imageThumbnailUrl,
    this.delivered = false,
    this.read = false,
    this.localOnly = false,
  });

  final String id;
  final String clinicId;
  final String patientId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;
  final ChatMessageType type;
  final String? imageUrl;
  final String? imageThumbnailUrl;
  final bool delivered;
  final bool read;
  /// Optimistic placeholder before Firestore confirms the write.
  final bool localOnly;

  bool get isFromPatient => senderRole == 'patient';
  bool get isFromSecretary => senderRole == 'secretary';
  bool get isImage => type == ChatMessageType.image;

  ChatDeliveryStatus get deliveryStatus {
    if (localOnly) return ChatDeliveryStatus.sending;
    if (read) return ChatDeliveryStatus.read;
    if (delivered) return ChatDeliveryStatus.delivered;
    return ChatDeliveryStatus.sent;
  }

  ChatMessage copyWith({
    bool? delivered,
    bool? read,
    bool? localOnly,
    String? id,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        clinicId: clinicId,
        patientId: patientId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        text: text,
        createdAt: createdAt,
        type: type,
        imageUrl: imageUrl,
        imageThumbnailUrl: imageThumbnailUrl,
        delivered: delivered ?? this.delivered,
        read: read ?? this.read,
        localOnly: localOnly ?? this.localOnly,
      );
}

class ChatTypingState {
  const ChatTypingState({
    required this.userId,
    required this.userName,
    required this.role,
    required this.updatedAt,
  });

  final String userId;
  final String userName;
  final String role;
  final DateTime updatedAt;

  bool isActive({required String currentUserId, DateTime? now}) {
    if (userId.isEmpty || userId == currentUserId) return false;
    final at = now ?? DateTime.now();
    return at.difference(updatedAt) < const Duration(seconds: 5);
  }
}
