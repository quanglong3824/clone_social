import 'package:firebase_database/firebase_database.dart';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/post/domain/entities/post_entity.dart';
import 'package:clone_social/features/profile/domain/repositories/profile_repository.dart';
import 'package:clone_social/core/services/firebase_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseService _firebaseService;

  ProfileRepositoryImpl({
    FirebaseService? firebaseService,
  })  : _firebaseService = firebaseService ?? FirebaseService();

  /// Reference to blocked users
  DatabaseReference _blockedUsersRef(String userId) =>
      _firebaseService.userRef(userId).child('blockedUsers');

  @override
  Future<UserEntity?> getUserProfile(String userId) async {
    final snapshot = await _firebaseService.userRef(userId).get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return UserEntity(
      id: userId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profileImage: data['profileImage'],
      coverImage: data['coverImage'],
      bio: data['bio'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      isOnline: data['isOnline'] ?? false,
    );
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
  }) async {
    final updates = <String, dynamic>{};
    
    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;

    if (updates.isNotEmpty) {
      await _firebaseService.userRef(userId).update(updates);
    }
  }

  @override
  Stream<List<PostEntity>> getUserPosts(String userId) {
    return _firebaseService.postsRef()
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final posts = <PostEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          posts.add(_mapToPostEntity(key, Map<String, dynamic>.from(value)));
        });
      }
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  @override
  Stream<List<String>> getUserFriends(String userId) {
    return _firebaseService.friendsRef(userId).onValue.map((event) {
      final friends = <String>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        friends.addAll(data.keys);
      }
      return friends;
    });
  }

  @override
  Stream<List<String>> getUserPhotos(String userId) {
    // This is a simplified implementation. 
    // Ideally we should query posts with images by this user.
    // Since Firebase RTDB querying is limited, we'll fetch user posts and filter.
    return getUserPosts(userId).map((posts) {
      final photos = <String>[];
      for (var post in posts) {
        photos.addAll(post.images);
      }
      return photos;
    });
  }

  PostEntity _mapToPostEntity(String id, Map<String, dynamic> data) {
    // Handle both old 'likes' format and new 'reactions' format
    Map<String, String> reactions = {};
    if (data['reactions'] != null) {
      reactions = Map<String, String>.from(data['reactions']);
    } else if (data['likes'] != null) {
      // Convert old likes format to reactions format
      final likes = Map<String, dynamic>.from(data['likes']);
      reactions = likes.map((key, value) => MapEntry(key, 'like'));
    }
    
    return PostEntity(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userProfileImage: data['userProfileImage'],
      content: data['content'] ?? '',
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      videoUrl: data['videoUrl'],
      reactions: reactions,
      commentCount: data['commentCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }

  @override
  Future<List<UserEntity>> getFriendsWithProfile(String userId) async {
    try {
      final snapshot = await _firebaseService.friendsRef(userId).get();
      if (!snapshot.exists || snapshot.value == null) return [];

      final friendIds = Map<String, dynamic>.from(snapshot.value as Map).keys.toList();
      final friends = <UserEntity>[];

      for (final friendId in friendIds) {
        final friend = await getUserProfile(friendId);
        if (friend != null) {
          friends.add(friend);
        }
      }

      return friends;
    } catch (e) {
      print('Error getting friends with profile: $e');
      return [];
    }
  }

  @override
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final snapshot = await _firebaseService.friendsRef(userId1).child(userId2).get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking friendship: $e');
      return false;
    }
  }

  @override
  Future<FriendStatus> getFriendStatus(String currentUserId, String targetUserId) async {
    try {
      // Check if already friends
      if (await areFriends(currentUserId, targetUserId)) {
        return FriendStatus.friends;
      }

      // Check if current user sent a request
      final sentSnapshot = await _firebaseService
          .userFriendRequestsRef(targetUserId)
          .orderByChild('fromUserId')
          .equalTo(currentUserId)
          .get();
      
      if (sentSnapshot.exists && sentSnapshot.value != null) {
        final requests = Map<String, dynamic>.from(sentSnapshot.value as Map);
        for (var request in requests.values) {
          final requestData = Map<String, dynamic>.from(request);
          if (requestData['status'] == 'pending') {
            return FriendStatus.requestSent;
          }
        }
      }

      // Check if current user received a request
      final receivedSnapshot = await _firebaseService
          .userFriendRequestsRef(currentUserId)
          .orderByChild('fromUserId')
          .equalTo(targetUserId)
          .get();
      
      if (receivedSnapshot.exists && receivedSnapshot.value != null) {
        final requests = Map<String, dynamic>.from(receivedSnapshot.value as Map);
        for (var request in requests.values) {
          final requestData = Map<String, dynamic>.from(request);
          if (requestData['status'] == 'pending') {
            return FriendStatus.requestReceived;
          }
        }
      }

      return FriendStatus.none;
    } catch (e) {
      print('Error getting friend status: $e');
      return FriendStatus.none;
    }
  }

  @override
  Future<void> unfriend(String userId, String friendId) async {
    try {
      // Remove from both users' friend lists
      await _firebaseService.friendsRef(userId).child(friendId).remove();
      await _firebaseService.friendsRef(friendId).child(userId).remove();
    } catch (e) {
      print('Error unfriending: $e');
      rethrow;
    }
  }

  @override
  Future<void> blockUser(String userId, String blockedUserId) async {
    try {
      // Add to blocked list
      await _blockedUsersRef(userId).child(blockedUserId).set({
        'blockedAt': ServerValue.timestamp,
      });

      // Also unfriend if they were friends
      await _firebaseService.friendsRef(userId).child(blockedUserId).remove();
      await _firebaseService.friendsRef(blockedUserId).child(userId).remove();

      // Remove any pending friend requests
      final sentRequests = await _firebaseService
          .userFriendRequestsRef(blockedUserId)
          .orderByChild('fromUserId')
          .equalTo(userId)
          .get();
      
      if (sentRequests.exists && sentRequests.value != null) {
        final requests = Map<String, dynamic>.from(sentRequests.value as Map);
        for (var requestId in requests.keys) {
          await _firebaseService.userFriendRequestsRef(blockedUserId).child(requestId).remove();
        }
      }

      final receivedRequests = await _firebaseService
          .userFriendRequestsRef(userId)
          .orderByChild('fromUserId')
          .equalTo(blockedUserId)
          .get();
      
      if (receivedRequests.exists && receivedRequests.value != null) {
        final requests = Map<String, dynamic>.from(receivedRequests.value as Map);
        for (var requestId in requests.keys) {
          await _firebaseService.userFriendRequestsRef(userId).child(requestId).remove();
        }
      }
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }

  @override
  Future<void> unblockUser(String userId, String blockedUserId) async {
    try {
      await _blockedUsersRef(userId).child(blockedUserId).remove();
    } catch (e) {
      print('Error unblocking user: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isBlocked(String userId, String targetUserId) async {
    try {
      // Check if userId blocked targetUserId
      final snapshot1 = await _blockedUsersRef(userId).child(targetUserId).get();
      if (snapshot1.exists) return true;

      // Check if targetUserId blocked userId
      final snapshot2 = await _blockedUsersRef(targetUserId).child(userId).get();
      return snapshot2.exists;
    } catch (e) {
      print('Error checking block status: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getBlockedUsers(String userId) async {
    try {
      final snapshot = await _blockedUsersRef(userId).get();
      if (!snapshot.exists || snapshot.value == null) return [];

      return Map<String, dynamic>.from(snapshot.value as Map).keys.toList();
    } catch (e) {
      print('Error getting blocked users: $e');
      return [];
    }
  }

  @override
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firebaseService.userRef(userId).update({
        'isOnline': isOnline,
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  @override
  Future<List<String>> getMutualFriends(String userId1, String userId2) async {
    try {
      final snapshot1 = await _firebaseService.friendsRef(userId1).get();
      final snapshot2 = await _firebaseService.friendsRef(userId2).get();

      if (!snapshot1.exists || !snapshot2.exists) return [];

      final friends1 = Map<String, dynamic>.from(snapshot1.value as Map? ?? {}).keys.toSet();
      final friends2 = Map<String, dynamic>.from(snapshot2.value as Map? ?? {}).keys.toSet();

      return friends1.intersection(friends2).toList();
    } catch (e) {
      print('Error getting mutual friends: $e');
      return [];
    }
  }
}
