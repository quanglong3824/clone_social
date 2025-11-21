class NotificationEntity {
  final String id;
  final String userId;
  final String type; // like, comment, share, friend_request, friend_accept, message
  final String fromUserId;
  final String fromUserName;
  final String? fromUserProfileImage;
  final String? postId;
  final String? message;
  final bool read;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserProfileImage,
    this.postId,
    this.message,
    this.read = false,
    required this.createdAt,
  });

  String get title {
    switch (type) {
      case 'like':
        return '$fromUserName liked your post';
      case 'comment':
        return '$fromUserName commented on your post';
      case 'share':
        return '$fromUserName shared your post';
      case 'friend_request':
        return '$fromUserName sent you a friend request';
      case 'friend_accept':
        return '$fromUserName accepted your friend request';
      case 'message':
        return '$fromUserName sent you a message';
      default:
        return 'New notification';
    }
  }

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? type,
    String? fromUserId,
    String? fromUserName,
    String? fromUserProfileImage,
    String? postId,
    String? message,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserProfileImage: fromUserProfileImage ?? this.fromUserProfileImage,
      postId: postId ?? this.postId,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
