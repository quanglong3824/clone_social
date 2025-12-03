import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/post/domain/entities/post_entity.dart';

abstract class ProfileRepository {
  /// Get user profile by ID
  Future<UserEntity?> getUserProfile(String userId);
  
  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
  });
  
  /// Get user's posts stream
  Stream<List<PostEntity>> getUserPosts(String userId);
  
  /// Get user's friends list stream
  Stream<List<String>> getUserFriends(String userId);
  
  /// Get user's photos stream
  Stream<List<String>> getUserPhotos(String userId);
  
  /// Get friends with full profile info
  Future<List<UserEntity>> getFriendsWithProfile(String userId);
  
  /// Check if two users are friends
  Future<bool> areFriends(String userId1, String userId2);
  
  /// Get friend status between two users
  Future<FriendStatus> getFriendStatus(String currentUserId, String targetUserId);
  
  /// Unfriend a user
  Future<void> unfriend(String userId, String friendId);
  
  /// Block a user
  Future<void> blockUser(String userId, String blockedUserId);
  
  /// Unblock a user
  Future<void> unblockUser(String userId, String blockedUserId);
  
  /// Check if user is blocked
  Future<bool> isBlocked(String userId, String targetUserId);
  
  /// Get blocked users list
  Future<List<String>> getBlockedUsers(String userId);
  
  /// Update online status
  Future<void> updateOnlineStatus(String userId, bool isOnline);
  
  /// Get user's mutual friends with another user
  Future<List<String>> getMutualFriends(String userId1, String userId2);
}

enum FriendStatus {
  none,           // Not friends, no request
  friends,        // Already friends
  requestSent,    // Current user sent request
  requestReceived // Current user received request
}
