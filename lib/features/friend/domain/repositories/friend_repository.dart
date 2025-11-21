import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/friend/domain/entities/friend_request_entity.dart';

abstract class FriendRepository {
  Stream<List<String>> getFriendIds(String userId);
  Stream<List<FriendRequestEntity>> getFriendRequests(String userId);
  Future<void> sendFriendRequest(String fromUserId, String toUserId);
  Future<void> acceptFriendRequest(String userId, String requestId, String fromUserId);
  Future<void> rejectFriendRequest(String userId, String requestId);
  Future<void> unfriend(String userId, String friendId);
  Future<List<UserEntity>> searchUsers(String query);
  Future<UserEntity?> getUserProfile(String userId);
}
