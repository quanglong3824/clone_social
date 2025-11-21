import 'package:flutter/material.dart';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/friend/domain/entities/friend_request_entity.dart';
import 'package:clone_social/features/friend/domain/repositories/friend_repository.dart';
import 'package:clone_social/features/friend/data/repositories/friend_repository_impl.dart';

class FriendProvider extends ChangeNotifier {
  final FriendRepository _friendRepository;
  
  List<String> _friendIds = [];
  List<FriendRequestEntity> _friendRequests = [];
  bool _isLoading = false;
  String? _error;

  FriendProvider({FriendRepository? friendRepository}) 
      : _friendRepository = friendRepository ?? FriendRepositoryImpl();

  List<String> get friendIds => _friendIds;
  List<FriendRequestEntity> get friendRequests => _friendRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init(String userId) {
    _friendRepository.getFriendIds(userId).listen((ids) {
      _friendIds = ids;
      notifyListeners();
    });

    _friendRepository.getFriendRequests(userId).listen((requests) {
      _friendRequests = requests;
      notifyListeners();
    });
  }

  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      await _friendRepository.sendFriendRequest(fromUserId, toUserId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> acceptFriendRequest(String userId, String requestId, String fromUserId) async {
    try {
      await _friendRepository.acceptFriendRequest(userId, requestId, fromUserId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> rejectFriendRequest(String userId, String requestId) async {
    try {
      await _friendRepository.rejectFriendRequest(userId, requestId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<List<UserEntity>> searchUsers(String query) async {
    _setLoading(true);
    try {
      final users = await _friendRepository.searchUsers(query);
      _setLoading(false);
      return users;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  Future<UserEntity?> getUserProfile(String userId) async {
    try {
      return await _friendRepository.getUserProfile(userId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
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
