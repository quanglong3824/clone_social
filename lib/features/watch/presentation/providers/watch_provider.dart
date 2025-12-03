import 'package:flutter/material.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/watch_repository.dart';
import '../../data/repositories/watch_repository_impl.dart';

class WatchProvider extends ChangeNotifier {
  final WatchRepository _repository;
  
  List<VideoEntity> _videos = [];
  List<VideoEntity> _savedVideos = [];
  List<VideoEntity> _searchResults = [];
  String _selectedCategory = 'Dành cho bạn';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  // Statistics
  int _totalWatchTime = 0; // in seconds
  int _videosWatched = 0;
  Map<String, int> _categoryWatchTime = {};

  WatchProvider({WatchRepository? repository})
      : _repository = repository ?? WatchRepositoryImpl();

  // Getters
  List<VideoEntity> get videos => _videos;
  List<VideoEntity> get savedVideos => _savedVideos;
  List<VideoEntity> get searchResults => _searchResults;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  List<String> get categories => _repository.getCategories();
  String get searchQuery => _searchQuery;

  // Statistics getters
  int get totalWatchTime => _totalWatchTime;
  int get videosWatched => _videosWatched;
  Map<String, int> get categoryWatchTime => _categoryWatchTime;
  
  String get formattedTotalWatchTime {
    final hours = _totalWatchTime ~/ 3600;
    final minutes = (_totalWatchTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Load videos cho category hiện tại
  Future<void> loadVideos({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _setLoading(true);
    
    try {
      final newVideos = await _repository.getVideos(
        category: _selectedCategory,
        page: _currentPage,
      );
      
      if (refresh) {
        _videos = newVideos;
      } else {
        _videos.addAll(newVideos);
      }
      
      _hasMore = newVideos.length >= 10;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Load thêm videos (pagination)
  Future<void> loadMoreVideos() async {
    if (_isLoadingMore || !_hasMore) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      _currentPage++;
      final newVideos = await _repository.getVideos(
        category: _selectedCategory,
        page: _currentPage,
      );
      
      _videos.addAll(newVideos);
      _hasMore = newVideos.length >= 10;
    } catch (e) {
      _currentPage--;
      debugPrint('Error loading more videos: $e');
    }
    
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Đổi category
  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;
    
    _selectedCategory = category;
    _videos = [];
    notifyListeners();
    
    if (category == 'Đã lưu') {
      // Load saved videos
      // This would need userId from auth
    } else if (category == 'Theo dõi') {
      // Load following videos
    } else {
      await loadVideos(refresh: true);
    }
  }

  /// Tìm kiếm video
  Future<void> searchVideos(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _setLoading(true);
    
    try {
      _searchResults = await _repository.searchVideos(query);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Clear search
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  /// Like video
  Future<void> likeVideo(String videoId, String userId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      final updatedLikes = Map<String, bool>.from(video.likes);
      updatedLikes[userId] = true;
      _videos[index] = video.copyWith(
        likes: updatedLikes,
        likeCount: video.likeCount + 1,
      );
      notifyListeners();
    }

    try {
      await _repository.likeVideo(videoId, userId);
    } catch (e) {
      // Rollback
      if (index != -1) {
        final video = _videos[index];
        final updatedLikes = Map<String, bool>.from(video.likes);
        updatedLikes.remove(userId);
        _videos[index] = video.copyWith(
          likes: updatedLikes,
          likeCount: video.likeCount - 1,
        );
        notifyListeners();
      }
    }
  }

  /// Unlike video
  Future<void> unlikeVideo(String videoId, String userId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      final updatedLikes = Map<String, bool>.from(video.likes);
      updatedLikes.remove(userId);
      _videos[index] = video.copyWith(
        likes: updatedLikes,
        likeCount: video.likeCount - 1,
      );
      notifyListeners();
    }

    try {
      await _repository.unlikeVideo(videoId, userId);
    } catch (e) {
      // Rollback
      if (index != -1) {
        final video = _videos[index];
        final updatedLikes = Map<String, bool>.from(video.likes);
        updatedLikes[userId] = true;
        _videos[index] = video.copyWith(
          likes: updatedLikes,
          likeCount: video.likeCount + 1,
        );
        notifyListeners();
      }
    }
  }

  /// Toggle like
  Future<void> toggleLike(String videoId, String userId) async {
    final video = _videos.firstWhere((v) => v.id == videoId);
    if (video.isLikedBy(userId)) {
      await unlikeVideo(videoId, userId);
    } else {
      await likeVideo(videoId, userId);
    }
  }

  /// Save video
  Future<void> saveVideo(String videoId, String userId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      final updatedSaved = Map<String, bool>.from(video.saved);
      updatedSaved[userId] = true;
      _videos[index] = video.copyWith(saved: updatedSaved);
      notifyListeners();
    }

    try {
      await _repository.saveVideo(videoId, userId);
    } catch (e) {
      debugPrint('Error saving video: $e');
    }
  }

  /// Unsave video
  Future<void> unsaveVideo(String videoId, String userId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      final updatedSaved = Map<String, bool>.from(video.saved);
      updatedSaved.remove(userId);
      _videos[index] = video.copyWith(saved: updatedSaved);
      notifyListeners();
    }

    try {
      await _repository.unsaveVideo(videoId, userId);
    } catch (e) {
      debugPrint('Error unsaving video: $e');
    }
  }

  /// Toggle save
  Future<void> toggleSave(String videoId, String userId) async {
    final video = _videos.firstWhere((v) => v.id == videoId);
    if (video.isSavedBy(userId)) {
      await unsaveVideo(videoId, userId);
    } else {
      await saveVideo(videoId, userId);
    }
  }

  /// Record video view
  Future<void> recordView(String videoId) async {
    try {
      await _repository.incrementViewCount(videoId);
    } catch (e) {
      debugPrint('Error recording view: $e');
    }
  }

  /// Update watch statistics
  void updateWatchStats(int watchedSeconds, String category) {
    _totalWatchTime += watchedSeconds;
    _videosWatched++;
    _categoryWatchTime[category] = 
        (_categoryWatchTime[category] ?? 0) + watchedSeconds;
    notifyListeners();
  }

  /// Follow channel
  Future<void> followChannel(String channelId, String userId) async {
    try {
      await _repository.followChannel(channelId, userId);
    } catch (e) {
      debugPrint('Error following channel: $e');
    }
  }

  /// Unfollow channel
  Future<void> unfollowChannel(String channelId, String userId) async {
    try {
      await _repository.unfollowChannel(channelId, userId);
    } catch (e) {
      debugPrint('Error unfollowing channel: $e');
    }
  }

  /// Check if following channel
  Future<bool> isFollowingChannel(String channelId, String userId) async {
    return await _repository.isFollowingChannel(channelId, userId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _isLoading = false;
    _error = error;
    notifyListeners();
  }
}
