class ChatEntity {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final int unreadCount;
  final Map<String, Map<String, dynamic>> participantInfo;

  const ChatEntity({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    required this.lastMessageTime,
    this.lastMessageSenderId = '',
    this.unreadCount = 0,
    this.participantInfo = const {},
  });

  String getOtherParticipantName(String currentUserId) {
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    if (otherUserId.isEmpty) return 'Unknown';
    return participantInfo[otherUserId]?['name'] ?? 'Unknown';
  }

  String? getOtherParticipantImage(String currentUserId) {
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    if (otherUserId.isEmpty) return null;
    return participantInfo[otherUserId]?['profileImage'];
  }

  ChatEntity copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    int? unreadCount,
    Map<String, Map<String, dynamic>>? participantInfo,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      participantInfo: participantInfo ?? this.participantInfo,
    );
  }
}
