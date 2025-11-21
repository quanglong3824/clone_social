import 'dart:io';
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
  bool _isLoading = false;
  String? _error;

  ProfileProvider({ProfileRepository? profileRepository}) 
      : _profileRepository = profileRepository ?? ProfileRepositoryImpl();

  UserEntity? get userProfile => _userProfile;
  List<PostEntity> get userPosts => _userPosts;
  List<String> get userFriends => _userFriends;
  List<String> get userPhotos => _userPhotos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile(String userId) async {
    _setLoading(true);
    try {
      _userProfile = await _profileRepository.getUserProfile(userId);
      
      // Listen to streams
      _profileRepository.getUserPosts(userId).listen((posts) {
        _userPosts = posts;
        notifyListeners();
      });
      
      _profileRepository.getUserFriends(userId).listen((friends) {
        _userFriends = friends;
        notifyListeners();
      });
      
      _profileRepository.getUserPhotos(userId).listen((photos) {
        _userPhotos = photos;
        notifyListeners();
      });
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) async {
    _setLoading(true);
    try {
      await _profileRepository.updateProfile(
        userId: userId,
        name: name,
        bio: bio,
        profileImage: profileImage,
        coverImage: coverImage,
      );
      
      // Refresh profile data
      _userProfile = await _profileRepository.getUserProfile(userId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
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
