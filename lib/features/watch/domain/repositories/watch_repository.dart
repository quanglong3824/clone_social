import '../entities/video_entity.dart';

abstract class WatchRepository {
  /// Lấy danh sách video theo category
  Future<List<VideoEntity>> getVideos({String? category, int page = 1, int perPage = 10});
  
  /// Lấy video theo ID
  Future<VideoEntity?> getVideoById(String videoId);
  
  /// Tìm kiếm video
  Future<List<VideoEntity>> searchVideos(String query, {int page = 1, int perPage = 10});
  
  /// Lấy video đã lưu của user
  Stream<List<VideoEntity>> getSavedVideos(String userId);
  
  /// Lấy video đang theo dõi (từ các channel đã follow)
  Stream<List<VideoEntity>> getFollowingVideos(String userId);
  
  /// Like video
  Future<void> likeVideo(String videoId, String userId);
  
  /// Unlike video
  Future<void> unlikeVideo(String videoId, String userId);
  
  /// Lưu video
  Future<void> saveVideo(String videoId, String userId);
  
  /// Bỏ lưu video
  Future<void> unsaveVideo(String videoId, String userId);
  
  /// Tăng view count
  Future<void> incrementViewCount(String videoId);
  
  /// Follow channel
  Future<void> followChannel(String channelId, String userId);
  
  /// Unfollow channel
  Future<void> unfollowChannel(String channelId, String userId);
  
  /// Kiểm tra đã follow channel chưa
  Future<bool> isFollowingChannel(String channelId, String userId);
  
  /// Lấy danh sách categories
  List<String> getCategories();
}
