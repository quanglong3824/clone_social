/// Entity representing a Story in the social app.
/// Stories are temporary content that expires after 24 hours.
class StoryEntity {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String mediaUrl;
  final String mediaType; // 'image' | 'video'
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewerIds;

  const StoryEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiresAt,
    this.viewerIds = const [],
  });

  /// Check if the story has expired (older than 24 hours)
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if a specific user has viewed this story
  bool isViewedBy(String viewerId) => viewerIds.contains(viewerId);

  /// Get the number of viewers
  int get viewCount => viewerIds.length;

  StoryEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? mediaUrl,
    String? mediaType,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewerIds,
  }) {
    return StoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewerIds: viewerIds ?? this.viewerIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
