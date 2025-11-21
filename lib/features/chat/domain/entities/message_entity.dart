class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderProfileImage;
  final String text;
  final String type; // text, image, video
  final String? mediaUrl;
  final DateTime createdAt;
  final bool read;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderProfileImage,
    required this.text,
    this.type = 'text',
    this.mediaUrl,
    required this.createdAt,
    this.read = false,
  });

  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderProfileImage,
    String? text,
    String? type,
    String? mediaUrl,
    DateTime? createdAt,
    bool? read,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      text: text ?? this.text,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}
