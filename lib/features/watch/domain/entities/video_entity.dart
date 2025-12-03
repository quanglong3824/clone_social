/// Entity đại diện cho một video trong Watch
class VideoEntity {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String channelId;
  final String channelName;
  final String? channelAvatar;
  final int duration; // in seconds
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final Map<String, bool> likes; // userId -> liked
  final Map<String, bool> saved; // userId -> saved
  final DateTime createdAt;
  final String category;
  final bool isLive;

  const VideoEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.channelId,
    required this.channelName,
    this.channelAvatar,
    required this.duration,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.likes = const {},
    this.saved = const {},
    required this.createdAt,
    this.category = 'Dành cho bạn',
    this.isLive = false,
  });

  bool isLikedBy(String userId) => likes[userId] == true;
  bool isSavedBy(String userId) => saved[userId] == true;

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedViews {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    
    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365} năm trước';
    } else if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30} tháng trước';
    } else if (diff.inDays > 7) {
      return '${diff.inDays ~/ 7} tuần trước';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phút trước';
    }
    return 'Vừa xong';
  }

  VideoEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    String? channelId,
    String? channelName,
    String? channelAvatar,
    int? duration,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    Map<String, bool>? likes,
    Map<String, bool>? saved,
    DateTime? createdAt,
    String? category,
    bool? isLive,
  }) {
    return VideoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelAvatar: channelAvatar ?? this.channelAvatar,
      duration: duration ?? this.duration,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      likes: likes ?? this.likes,
      saved: saved ?? this.saved,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      isLive: isLive ?? this.isLive,
    );
  }
}
