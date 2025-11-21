import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/post/domain/entities/post_entity.dart';
import 'package:clone_social/features/profile/domain/repositories/profile_repository.dart';
import 'package:clone_social/core/services/firebase_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseService _firebaseService;
  final FirebaseStorage _firebaseStorage;
  final Uuid _uuid;

  ProfileRepositoryImpl({
    FirebaseService? firebaseService,
    FirebaseStorage? firebaseStorage,
    Uuid? uuid,
  })  : _firebaseService = firebaseService ?? FirebaseService(),
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

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
    File? profileImage,
    File? coverImage,
  }) async {
    final updates = <String, dynamic>{};
    
    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;

    if (profileImage != null) {
      final ref = _firebaseStorage
          .ref()
          .child('profile_images/$userId/${_uuid.v4()}.jpg');
      await ref.putFile(profileImage);
      updates['profileImage'] = await ref.getDownloadURL();
    }

    if (coverImage != null) {
      final ref = _firebaseStorage
          .ref()
          .child('cover_images/$userId/${_uuid.v4()}.jpg');
      await ref.putFile(coverImage);
      updates['coverImage'] = await ref.getDownloadURL();
    }

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
    return PostEntity(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userProfileImage: data['userProfileImage'],
      content: data['content'] ?? '',
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      videoUrl: data['videoUrl'],
      likes: data['likes'] != null ? Map<String, bool>.from(data['likes']) : {},
      commentCount: data['commentCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }
}
