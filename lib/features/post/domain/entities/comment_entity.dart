class CommentEntity {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String text;
  final DateTime createdAt;
  final Map<String, bool> likes;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.text,
    required this.createdAt,
    this.likes = const {},
  });

  int get likeCount => likes.length;
  
  bool isLikedBy(String userId) => likes.containsKey(userId);

  CommentEntity copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? text,
    DateTime? createdAt,
    Map<String, bool>? likes,
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
    );
  }
}
