import 'dart:io';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/post/domain/entities/post_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity?> getUserProfile(String userId);
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
    File? profileImage,
    File? coverImage,
  });
  Stream<List<PostEntity>> getUserPosts(String userId);
  Stream<List<String>> getUserFriends(String userId);
  Stream<List<String>> getUserPhotos(String userId);
}
