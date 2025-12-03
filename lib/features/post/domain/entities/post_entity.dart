/// Enum representing the different reaction types available for posts
enum ReactionType {
  like,
  love,
  haha,
  wow,
  sad,
  angry;

  String get emoji {
    switch (this) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.haha:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😠';
    }
  }

  String get label {
    switch (this) {
      case ReactionType.like:
        return 'Like';
      case ReactionType.love:
        return 'Love';
      case ReactionType.haha:
        return 'Haha';
      case ReactionType.wow:
        return 'Wow';
      case ReactionType.sad:
        return 'Sad';
      case ReactionType.angry:
        return 'Angry';
    }
  }

  static ReactionType? fromString(String? value) {
    if (value == null) return null;
    return ReactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReactionType.like,
    );
  }
}

class PostEntity {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String content;
  final List<String> images;
  final String? videoUrl;
  /// Map of userId to their reaction type (e.g., {'user1': 'like', 'user2': 'love'})
  final Map<String, String> reactions;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Shared post fields
  final String? sharedPostId;
  final String? sharedPostUserId;
  final String? sharedPostUserName;
  final String? sharedPostUserProfileImage;
  final String? sharedPostContent;
  final List<String>? sharedPostImages;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.content,
    this.images = const [],
    this.videoUrl,
    this.reactions = const {},
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.sharedPostId,
    this.sharedPostUserId,
    this.sharedPostUserName,
    this.sharedPostUserProfileImage,
    this.sharedPostContent,
    this.sharedPostImages,
  });
  
  /// Check if this is a shared post
  bool get isSharedPost => sharedPostId != null;

  /// Total count of all reactions
  int get reactionCount => reactions.length;
  
  /// For backward compatibility - returns total reaction count
  int get likeCount => reactionCount;
  
  /// Check if a user has reacted to this post
  bool hasReactionFrom(String userId) => reactions.containsKey(userId);
  
  /// For backward compatibility
  bool isLikedBy(String userId) => hasReactionFrom(userId);
  
  /// Get the reaction type for a specific user
  ReactionType? getReactionBy(String userId) {
    final reactionStr = reactions[userId];
    return ReactionType.fromString(reactionStr);
  }

  /// Get count of reactions by type
  Map<ReactionType, int> get reactionCounts {
    final counts = <ReactionType, int>{};
    for (final reaction in reactions.values) {
      final type = ReactionType.fromString(reaction);
      if (type != null) {
        counts[type] = (counts[type] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Get the top 3 reaction types by count
  List<ReactionType> get topReactions {
    final counts = reactionCounts;
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  PostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? content,
    List<String>? images,
    String? videoUrl,
    Map<String, String>? reactions,
    int? commentCount,
    int? shareCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sharedPostId,
    String? sharedPostUserId,
    String? sharedPostUserName,
    String? sharedPostUserProfileImage,
    String? sharedPostContent,
    List<String>? sharedPostImages,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      content: content ?? this.content,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      reactions: reactions ?? this.reactions,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sharedPostId: sharedPostId ?? this.sharedPostId,
      sharedPostUserId: sharedPostUserId ?? this.sharedPostUserId,
      sharedPostUserName: sharedPostUserName ?? this.sharedPostUserName,
      sharedPostUserProfileImage: sharedPostUserProfileImage ?? this.sharedPostUserProfileImage,
      sharedPostContent: sharedPostContent ?? this.sharedPostContent,
      sharedPostImages: sharedPostImages ?? this.sharedPostImages,
    );
  }
}
