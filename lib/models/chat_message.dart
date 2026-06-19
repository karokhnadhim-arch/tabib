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
    this.read = false,
  });

  final String id;
  final String clinicId;
  final String patientId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;
  final bool read;

  bool get isFromPatient => senderRole == 'patient';
  bool get isFromSecretary => senderRole == 'secretary';

  ChatMessage copyWith({bool? read}) => ChatMessage(
        id: id,
        clinicId: clinicId,
        patientId: patientId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        text: text,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}
