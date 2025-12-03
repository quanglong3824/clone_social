import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/post/domain/entities/post_entity.dart';
import 'package:clone_social/features/profile/domain/repositories/profile_repository.dart';
import 'package:clone_social/features/profile/data/repositories/profile_repository_impl.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  
  UserEntity? _userProfile;
  List<PostEntity> _userPosts = [];
  List<String> _userFriends = [];
  List<String> _userPhotos = [];
  List<UserEntity> _friendsWithProfile = [];
  FriendStatus _friendStatus = FriendStatus.none;
  List<String> _mutualFriends = [];
  bool _isLoading = false;
  String? _error;
  
  StreamSubscription? _postsSubscription;
  StreamSubscription? _friendsSubscription;
  StreamSubscription? _photosSubscription;

  ProfileProvider({ProfileRepository? profileRepository}) 
      : _profileRepository = profileRepository ?? ProfileRepositoryImpl();

  UserEntity? get userProfile => _userProfile;
  List<PostEntity> get userPosts => _userPosts;
  List<String> get userFriends => _userFriends;
  List<String> get userPhotos => _userPhotos;
  List<UserEntity> get friendsWithProfile => _friendsWithProfile;
  FriendStatus get friendStatus => _friendStatus;
  List<String> get mutualFriends => _mutualFriends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile(String userId, {String? currentUserId}) async {
    _setLoading(true);
    
    // Cancel previous subscriptions
    _postsSubscription?.cancel();
    _friendsSubscription?.cancel();
    _photosSubscription?.cancel();
    
    try {
      _userProfile = await _profileRepository.getUserProfile(userId);
      
      // Listen to streams
      _postsSubscription = _profileRepository.getUserPosts(userId).listen((posts) {
        _userPosts = posts;
        notifyListeners();
      });
      
      _friendsSubscription = _profileRepository.getUserFriends(userId).listen((friends) {
        _userFriends = friends;
        notifyListeners();
      });
      
      _photosSubscription = _profileRepository.getUserPhotos(userId).listen((photos) {
        _userPhotos = photos;
        notifyListeners();
      });

      // Load friends with profile
      _friendsWithProfile = await _profileRepository.getFriendsWithProfile(userId);

      // Load friend status if viewing another user's profile
      if (currentUserId != null && currentUserId != userId) {
        _friendStatus = await _profileRepository.getFriendStatus(currentUserId, userId);
        _mutualFriends = await _profileRepository.getMutualFriends(currentUserId, userId);
      } else {
        _friendStatus = FriendStatus.none;
        _mutualFriends = [];
      }
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
  }) async {
    _setLoading(true);
    try {
      await _profileRepository.updateProfile(
        userId: userId,
        name: name,
        bio: bio,
      );
      
      // Refresh profile data
      _userProfile = await _profileRepository.getUserProfile(userId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Unfriend a user
  Future<bool> unfriend(String userId, String friendId) async {
    try {
      await _profileRepository.unfriend(userId, friendId);
      _friendStatus = FriendStatus.none;
      _userFriends.remove(friendId);
      _friendsWithProfile.removeWhere((f) => f.id == friendId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Block a user
  Future<bool> blockUser(String userId, String blockedUserId) async {
    try {
      await _profileRepository.blockUser(userId, blockedUserId);
      _friendStatus = FriendStatus.none;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String userId, String blockedUserId) async {
    try {
      await _profileRepository.unblockUser(userId, blockedUserId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Check if user is blocked
  Future<bool> isBlocked(String userId, String targetUserId) async {
    return await _profileRepository.isBlocked(userId, targetUserId);
  }

  /// Get blocked users
  Future<List<String>> getBlockedUsers(String userId) async {
    return await _profileRepository.getBlockedUsers(userId);
  }

  /// Update online status
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await _profileRepository.updateOnlineStatus(userId, isOnline);
  }

  /// Refresh friend status
  Future<void> refreshFriendStatus(String currentUserId, String targetUserId) async {
    _friendStatus = await _profileRepository.getFriendStatus(currentUserId, targetUserId);
    notifyListeners();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _friendsSubscription?.cancel();
    _photosSubscription?.cancel();
    super.dispose();
  }
}
