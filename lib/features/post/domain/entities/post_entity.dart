class PostEntity {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String content;
  final List<String> images;
  final String? videoUrl;
  final Map<String, bool> likes;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.content,
    this.images = const [],
    this.videoUrl,
    this.likes = const {},
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  int get likeCount => likes.length;
  
  bool isLikedBy(String userId) => likes.containsKey(userId);

  PostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? content,
    List<String>? images,
    String? videoUrl,
    Map<String, bool>? likes,
    int? commentCount,
    int? shareCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      content: content ?? this.content,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
