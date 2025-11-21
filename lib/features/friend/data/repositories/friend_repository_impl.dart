import 'package:firebase_database/firebase_database.dart';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/friend/domain/entities/friend_request_entity.dart';
import 'package:clone_social/features/friend/domain/repositories/friend_repository.dart';
import 'package:clone_social/core/services/firebase_service.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FirebaseService _firebaseService;

  FriendRepositoryImpl({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  @override
  Stream<List<String>> getFriendIds(String userId) {
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
  Stream<List<FriendRequestEntity>> getFriendRequests(String userId) {
    return _firebaseService.userFriendRequestsRef(userId).onValue.map((event) {
      final requests = <FriendRequestEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final requestData = Map<String, dynamic>.from(value);
          if (requestData['status'] == 'pending') {
            requests.add(FriendRequestEntity(
              id: key,
              fromUserId: requestData['fromUserId'],
              fromUserName: requestData['fromUserName'] ?? 'Unknown',
              fromUserProfileImage: requestData['fromUserProfileImage'],
              toUserId: userId,
              status: requestData['status'],
              createdAt: DateTime.fromMillisecondsSinceEpoch(requestData['createdAt'] ?? 0),
            ));
          }
        });
      }
      // Sort by newest first
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  @override
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    // Validate: Cannot send friend request to yourself
    if (fromUserId == toUserId) {
      throw Exception('Cannot send friend request to yourself');
    }
    
    // Check if request already exists
    final existingRequest = await _firebaseService
        .userFriendRequestsRef(toUserId)
        .orderByChild('fromUserId')
        .equalTo(fromUserId)
        .get();

    if (existingRequest.exists) {
      // Check if any is pending
      final data = Map<String, dynamic>.from(existingRequest.value as Map);
      bool hasPending = false;
      data.forEach((key, value) {
        if (value['status'] == 'pending') hasPending = true;
      });
      if (hasPending) return; // Already sent
    }

    // Get sender info
    final senderSnapshot = await _firebaseService.userRef(fromUserId).get();
    if (!senderSnapshot.exists) throw Exception('User not found');
    final senderData = Map<String, dynamic>.from(senderSnapshot.value as Map);

    final requestId = _firebaseService.generateKey(_firebaseService.friendRequestsRef());
    
    await _firebaseService.userFriendRequestsRef(toUserId).child(requestId).set({
      'fromUserId': fromUserId,
      'fromUserName': senderData['name'],
      'fromUserProfileImage': senderData['profileImage'],
      'status': 'pending',
      'createdAt': ServerValue.timestamp,
    });

    // Send notification
    final notifId = _firebaseService.generateKey(_firebaseService.notificationsRef());
    await _firebaseService.userNotificationsRef(toUserId).child(notifId).set({
      'type': 'friend_request',
      'fromUserId': fromUserId,
      'read': false,
      'createdAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> acceptFriendRequest(String userId, String requestId, String fromUserId) async {
    // Update request status
    await _firebaseService.userFriendRequestsRef(userId).child(requestId).update({
      'status': 'accepted',
    });

    // Add to friends list for both users
    await _firebaseService.friendsRef(userId).child(fromUserId).set(true);
    await _firebaseService.friendsRef(fromUserId).child(userId).set(true);

    // Send notification
    final notifId = _firebaseService.generateKey(_firebaseService.notificationsRef());
    await _firebaseService.userNotificationsRef(fromUserId).child(notifId).set({
      'type': 'friend_accept',
      'fromUserId': userId,
      'read': false,
      'createdAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> rejectFriendRequest(String userId, String requestId) async {
    await _firebaseService.userFriendRequestsRef(userId).child(requestId).update({
      'status': 'rejected',
    });
  }

  @override
  Future<void> unfriend(String userId, String friendId) async {
    await _firebaseService.friendsRef(userId).child(friendId).remove();
    await _firebaseService.friendsRef(friendId).child(userId).remove();
  }

  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    // Note: Firebase Realtime Database search is limited. 
    // We can only search by exact match or startAt/endAt on a specific child.
    // For a real app, use Algolia or ElasticSearch.
    // Here we'll do a simple client-side filtering for demonstration (not scalable).
    
    final snapshot = await _firebaseService.usersRef().get();
    if (!snapshot.exists) return [];

    final users = <UserEntity>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    
    data.forEach((key, value) {
      final userData = Map<String, dynamic>.from(value);
      final name = userData['name']?.toString().toLowerCase() ?? '';
      if (name.contains(query.toLowerCase())) {
        users.add(UserEntity(
          id: key,
          email: userData['email'] ?? '',
          name: userData['name'] ?? '',
          profileImage: userData['profileImage'],
          createdAt: DateTime.fromMillisecondsSinceEpoch(userData['createdAt'] ?? 0),
          isOnline: userData['isOnline'] ?? false,
        ));
      }
    });

    return users;
  }

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
}
