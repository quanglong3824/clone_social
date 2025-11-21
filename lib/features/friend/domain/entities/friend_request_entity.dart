class FriendRequestEntity {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserProfileImage;
  final String toUserId;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  const FriendRequestEntity({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserProfileImage,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  FriendRequestEntity copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? fromUserProfileImage,
    String? toUserId,
    String? status,
    DateTime? createdAt,
  }) {
    return FriendRequestEntity(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserProfileImage: fromUserProfileImage ?? this.fromUserProfileImage,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
