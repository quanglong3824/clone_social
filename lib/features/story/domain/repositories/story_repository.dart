import 'dart:io';
import '../entities/story_entity.dart';

/// Abstract repository interface for Story operations.
/// Defines the contract for story data access.
abstract class StoryRepository {
  /// Get all active (non-expired) stories for the current user and their friends.
  /// Returns a stream that updates when stories change.
  Stream<List<StoryEntity>> getStories(String userId);

  /// Get stories for a specific user.
  Stream<List<StoryEntity>> getUserStories(String userId);

  /// Create a new story with media (image or video).
  /// [userId] - The ID of the user creating the story
  /// [media] - The media file (image or video)
  /// [mediaType] - Either 'image' or 'video'
  Future<void> createStory(String userId, File media, String mediaType);

  /// Mark a story as viewed by a user.
  /// [storyId] - The ID of the story being viewed
  /// [viewerId] - The ID of the user viewing the story
  Future<void> markStoryAsViewed(String storyId, String viewerId);

  /// Delete expired stories (older than 24 hours).
  /// This should be called periodically to clean up old stories.
  Future<void> deleteExpiredStories();

  /// Delete a specific story by ID.
  /// Only the owner of the story can delete it.
  Future<void> deleteStory(String storyId);

  /// Get a single story by ID.
  Future<StoryEntity?> getStoryById(String storyId);
}
