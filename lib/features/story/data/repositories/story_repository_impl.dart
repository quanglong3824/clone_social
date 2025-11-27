import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:clone_social/features/story/domain/entities/story_entity.dart';
import 'package:clone_social/features/story/domain/repositories/story_repository.dart';
import 'package:clone_social/core/services/firebase_service.dart';

class StoryRepositoryImpl implements StoryRepository {
  final FirebaseService _firebaseService;
  final FirebaseStorage _firebaseStorage;
  final Uuid _uuid;

  /// Duration after which stories expire (24 hours)
  static const Duration storyDuration = Duration(hours: 24);

  StoryRepositoryImpl({
    FirebaseService? firebaseService,
    FirebaseStorage? firebaseStorage,
    Uuid? uuid,
  })  : _firebaseService = firebaseService ?? FirebaseService(),
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<StoryEntity>> getStories(String userId) {
    return _firebaseService.storiesRef().onValue.asyncMap((event) async {
      final stories = <StoryEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final now = DateTime.now();
        
        for (var entry in data.entries) {
          final story = _mapToStoryEntity(
            entry.key, 
            Map<String, dynamic>.from(entry.value),
          );
          
          // Only include non-expired stories
          if (!story.isExpired) {
            stories.add(story);
          }
        }
      }
      
      // Sort by createdAt descending (newest first)
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return stories;
    });
  }


  @override
  Stream<List<StoryEntity>> getUserStories(String userId) {
    return _firebaseService.storiesRef()
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final stories = <StoryEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        for (var entry in data.entries) {
          final story = _mapToStoryEntity(
            entry.key,
            Map<String, dynamic>.from(entry.value),
          );
          
          // Only include non-expired stories
          if (!story.isExpired) {
            stories.add(story);
          }
        }
      }
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return stories;
    });
  }

  @override
  Future<void> createStory(String userId, File media, String mediaType) async {
    final user = await _getCurrentUser();
    if (user == null) throw Exception('User not authenticated');

    final storyId = _firebaseService.generateKey(_firebaseService.storiesRef());
    
    // Upload media to Firebase Storage
    final extension = mediaType == 'video' ? 'mp4' : 'jpg';
    final ref = _firebaseStorage
        .ref()
        .child('story_media/${user['id']}/$storyId/${_uuid.v4()}.$extension');
    
    await ref.putFile(media);
    final mediaUrl = await ref.getDownloadURL();

    final now = DateTime.now();
    final expiresAt = now.add(storyDuration);

    final storyData = {
      'userId': user['id'],
      'userName': user['name'],
      'userProfileImage': user['profileImage'],
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': now.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'viewerIds': <String>[],
    };

    await _firebaseService.storyRef(storyId).set(storyData);
  }

  @override
  Future<void> markStoryAsViewed(String storyId, String viewerId) async {
    // Get current viewers
    final snapshot = await _firebaseService.storyViewersRef(storyId).get();
    List<String> viewers = [];
    
    if (snapshot.exists && snapshot.value != null) {
      viewers = List<String>.from(snapshot.value as List);
    }
    
    // Add viewer if not already in list
    if (!viewers.contains(viewerId)) {
      viewers.add(viewerId);
      await _firebaseService.storyViewersRef(storyId).set(viewers);
    }
  }

  @override
  Future<void> deleteExpiredStories() async {
    final snapshot = await _firebaseService.storiesRef().get();
    
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final now = DateTime.now();
      
      for (var entry in data.entries) {
        final storyData = Map<String, dynamic>.from(entry.value);
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(
          storyData['expiresAt'] ?? 0,
        );
        
        if (now.isAfter(expiresAt)) {
          // Delete the story
          await deleteStory(entry.key);
        }
      }
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    // Get story data to find media URL
    final snapshot = await _firebaseService.storyRef(storyId).get();
    
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final mediaUrl = data['mediaUrl'] as String?;
      
      // Delete media from storage
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        try {
          final ref = _firebaseStorage.refFromURL(mediaUrl);
          await ref.delete();
        } catch (e) {
          // Media might already be deleted, continue
        }
      }
    }
    
    // Delete story from database
    await _firebaseService.storyRef(storyId).remove();
  }

  @override
  Future<StoryEntity?> getStoryById(String storyId) async {
    final snapshot = await _firebaseService.storyRef(storyId).get();
    
    if (snapshot.exists && snapshot.value != null) {
      return _mapToStoryEntity(
        storyId,
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await _firebaseService.userRef(user.uid).get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return {
        'id': user.uid,
        'name': data['name'] ?? user.displayName ?? 'User',
        'profileImage': data['profileImage'] ?? user.photoURL,
      };
    }
    
    return {
      'id': user.uid,
      'name': user.displayName ?? 'User',
      'profileImage': user.photoURL,
    };
  }

  StoryEntity _mapToStoryEntity(String id, Map<String, dynamic> data) {
    return StoryEntity(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userProfileImage: data['userProfileImage'],
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? 'image',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(data['expiresAt'] ?? 0),
      viewerIds: data['viewerIds'] != null 
          ? List<String>.from(data['viewerIds']) 
          : [],
    );
  }
}
