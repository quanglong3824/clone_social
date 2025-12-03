class CommentEntity {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String text;
  final DateTime createdAt;
  final Map<String, bool> likes;
  final String? parentCommentId; // For replies
  final int replyCount;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.text,
    required this.createdAt,
    this.likes = const {},
    this.parentCommentId,
    this.replyCount = 0,
  });

  int get likeCount => likes.length;
  
  bool isLikedBy(String userId) => likes.containsKey(userId);
  
  bool get isReply => parentCommentId != null;

  CommentEntity copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? text,
    DateTime? createdAt,
    Map<String, bool>? likes,
    String? parentCommentId,
    int? replyCount,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replyCount: replyCount ?? this.replyCount,
    );
  }
}
