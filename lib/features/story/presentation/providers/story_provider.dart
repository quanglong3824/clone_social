import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clone_social/features/story/domain/entities/story_entity.dart';
import 'package:clone_social/features/story/domain/repositories/story_repository.dart';
import 'package:clone_social/features/story/data/repositories/story_repository_impl.dart';

class StoryProvider extends ChangeNotifier {
  final StoryRepository _storyRepository;
  
  List<StoryEntity> _stories = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _storiesSubscription;

  /// Timer for periodic cleanup of expired stories
  Timer? _cleanupTimer;

  StoryProvider({StoryRepository? storyRepository}) 
      : _storyRepository = storyRepository ?? StoryRepositoryImpl();

  List<StoryEntity> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get stories grouped by user
  Map<String, List<StoryEntity>> get storiesByUser {
    final Map<String, List<StoryEntity>> grouped = {};
    for (var story in _stories) {
      if (!grouped.containsKey(story.userId)) {
        grouped[story.userId] = [];
      }
      grouped[story.userId]!.add(story);
    }
    return grouped;
  }

  /// Initialize the provider and start listening to stories
  void init(String userId) {
    _setLoading(true);
    _storiesSubscription?.cancel();
    _storiesSubscription = _storyRepository.getStories(userId).listen(
      (stories) {
        _stories = stories;
        _setLoading(false);
      },
      onError: (e) {
        _setError(e.toString());
      },
    );

    // Start periodic cleanup of expired stories (every 5 minutes)
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => deleteExpiredStories(),
    );
  }


  /// Create a new story with media
  Future<bool> createStory(String userId, File media, String mediaType) async {
    _setLoading(true);
    try {
      await _storyRepository.createStory(userId, media, mediaType);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Mark a story as viewed by the current user
  Future<void> markAsViewed(String storyId, String viewerId) async {
    try {
      await _storyRepository.markStoryAsViewed(storyId, viewerId);
    } catch (e) {
      // Silent fail for view tracking
      debugPrint('Error marking story as viewed: $e');
    }
  }

  /// Delete a story
  Future<bool> deleteStory(String storyId) async {
    try {
      await _storyRepository.deleteStory(storyId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete all expired stories
  Future<void> deleteExpiredStories() async {
    try {
      await _storyRepository.deleteExpiredStories();
    } catch (e) {
      debugPrint('Error deleting expired stories: $e');
    }
  }

  /// Check if a user has any unviewed stories
  bool hasUnviewedStories(String userId, String currentUserId) {
    final userStories = storiesByUser[userId] ?? [];
    return userStories.any((story) => !story.isViewedBy(currentUserId));
  }

  /// Get stories for a specific user
  List<StoryEntity> getStoriesForUser(String userId) {
    return storiesByUser[userId] ?? [];
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

  @override
  void dispose() {
    _storiesSubscription?.cancel();
    _cleanupTimer?.cancel();
    super.dispose();
  }
}
