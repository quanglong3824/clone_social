import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:clone_social/features/post/domain/entities/post_entity.dart';
import 'package:clone_social/features/post/domain/entities/comment_entity.dart';
import 'package:clone_social/features/post/domain/repositories/post_repository.dart';
import 'package:clone_social/core/services/firebase_service.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebaseService _firebaseService;
  final FirebaseStorage _firebaseStorage;
  final Uuid _uuid;

  PostRepositoryImpl({
    FirebaseService? firebaseService,
    FirebaseStorage? firebaseStorage,
    Uuid? uuid,
  })  : _firebaseService = firebaseService ?? FirebaseService(),
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<PostEntity>> getPosts() {
    return _firebaseService.postsRef().onValue.map((event) {
      final posts = <PostEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          posts.add(_mapToPostEntity(key, Map<String, dynamic>.from(value)));
        });
      }
      // Sort by createdAt descending
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
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
  Future<void> createPost(String content, {List<File>? images, File? video}) async {
    final user = await _getCurrentUser();
    if (user == null) throw Exception('User not found');

    final postId = _firebaseService.generateKey(_firebaseService.postsRef());
    final List<String> imageUrls = [];
    String? videoUrl;

    // Upload images
    if (images != null && images.isNotEmpty) {
      for (var image in images) {
        final ref = _firebaseStorage
            .ref()
            .child('post_images/${user['id']}/$postId/${_uuid.v4()}.jpg');
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    }

    // Upload video
    if (video != null) {
      final ref = _firebaseStorage
          .ref()
          .child('post_videos/${user['id']}/$postId/${_uuid.v4()}.mp4');
      await ref.putFile(video);
      videoUrl = await ref.getDownloadURL();
    }

    final postData = {
      'userId': user['id'],
      'userName': user['name'],
      'userProfileImage': user['profileImage'],
      'content': content,
      'images': imageUrls,
      'videoUrl': videoUrl,
      'createdAt': ServerValue.timestamp,
      'commentCount': 0,
      'shareCount': 0,
    };

    await _firebaseService.postRef(postId).set(postData);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _firebaseService.postRef(postId).remove();
    // Note: Should also delete images/videos from storage
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    // Default to 'like' reaction for backward compatibility
    await addReaction(postId, userId, 'like');
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await removeReaction(postId, userId);
  }

  /// Add a reaction to a post
  Future<void> addReaction(String postId, String userId, String reactionType) async {
    await _firebaseService.reactionsRef(postId).child(userId).set(reactionType);
    
    // Send notification
    final postSnapshot = await _firebaseService.postRef(postId).get();
    if (postSnapshot.exists) {
      final post = Map<String, dynamic>.from(postSnapshot.value as Map);
      if (post['userId'] != userId) {
        final notifId = _firebaseService.generateKey(_firebaseService.notificationsRef());
        await _firebaseService.userNotificationsRef(post['userId']).child(notifId).set({
          'type': 'reaction',
          'reactionType': reactionType,
          'fromUserId': userId,
          'postId': postId,
          'read': false,
          'createdAt': ServerValue.timestamp,
        });
      }
    }
  }

  /// Remove a reaction from a post
  Future<void> removeReaction(String postId, String userId) async {
    await _firebaseService.reactionsRef(postId).child(userId).remove();
  }

  @override
  Future<void> addComment(String postId, String userId, String text) async {
    final user = await _getCurrentUser();
    if (user == null) throw Exception('User not found');

    final commentId = _firebaseService.generateKey(_firebaseService.commentsRef(postId));
    
    await _firebaseService.commentRef(postId, commentId).set({
      'userId': userId,
      'userName': user['name'],
      'userProfileImage': user['profileImage'],
      'text': text,
      'createdAt': ServerValue.timestamp,
    });

    // Increment comment count
    await _firebaseService.postRef(postId).child('commentCount').set(ServerValue.increment(1));
    
    // Send notification
    final postSnapshot = await _firebaseService.postRef(postId).get();
    if (postSnapshot.exists) {
      final post = Map<String, dynamic>.from(postSnapshot.value as Map);
      if (post['userId'] != userId) {
        final notifId = _firebaseService.generateKey(_firebaseService.notificationsRef());
        await _firebaseService.userNotificationsRef(post['userId']).child(notifId).set({
          'type': 'comment',
          'fromUserId': userId,
          'postId': postId,
          'message': text,
          'read': false,
          'createdAt': ServerValue.timestamp,
        });
      }
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    await _firebaseService.commentRef(postId, commentId).remove();
    await _firebaseService.postRef(postId).child('commentCount').set(ServerValue.increment(-1));
  }

  @override
  Future<void> sharePost(String postId, String userId) async {
    await _firebaseService.postRef(postId).child('shareCount').set(ServerValue.increment(1));
    // Implement actual sharing logic (e.g., create a new post referencing this one)
  }

  @override
  Stream<List<CommentEntity>> getComments(String postId) {
    return _firebaseService.commentsRef(postId).onValue.map((event) {
      final comments = <CommentEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          comments.add(_mapToCommentEntity(key, postId, Map<String, dynamic>.from(value)));
        });
      }
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return comments;
    });
  }

  CommentEntity _mapToCommentEntity(String id, String postId, Map<String, dynamic> data) {
    return CommentEntity(
      id: id,
      postId: postId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userProfileImage: data['userProfileImage'],
      text: data['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      likes: data['likes'] != null ? Map<String, bool>.from(data['likes']) : {},
      parentCommentId: data['parentCommentId'],
      replyCount: data['replyCount'] ?? 0,
    );
  }

  @override
  Future<void> likeComment(String postId, String commentId, String userId) async {
    await _firebaseService.commentRef(postId, commentId).child('likes').child(userId).set(true);
  }

  @override
  Future<void> unlikeComment(String postId, String commentId, String userId) async {
    await _firebaseService.commentRef(postId, commentId).child('likes').child(userId).remove();
  }

  @override
  Future<void> replyToComment(String postId, String commentId, String userId, String text) async {
    final user = await _getCurrentUser();
    if (user == null) throw Exception('User not found');

    final replyId = _firebaseService.generateKey(_firebaseService.commentsRef(postId));
    
    await _firebaseService.commentRef(postId, replyId).set({
      'userId': userId,
      'userName': user['name'],
      'userProfileImage': user['profileImage'],
      'text': text,
      'parentCommentId': commentId,
      'createdAt': ServerValue.timestamp,
    });

    // Increment reply count on parent comment
    await _firebaseService.commentRef(postId, commentId).child('replyCount').set(ServerValue.increment(1));
    
    // Increment total comment count
    await _firebaseService.postRef(postId).child('commentCount').set(ServerValue.increment(1));
  }

  @override
  Stream<List<CommentEntity>> getCommentReplies(String postId, String commentId) {
    return _firebaseService.commentsRef(postId)
        .orderByChild('parentCommentId')
        .equalTo(commentId)
        .onValue
        .map((event) {
      final replies = <CommentEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          replies.add(_mapToCommentEntity(key, postId, Map<String, dynamic>.from(value)));
        });
      }
      replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return replies;
    });
  }

  @override
  Future<void> sharePostToFeed(String postId, String userId, {String? text}) async {
    final user = await _getCurrentUser();
    if (user == null) throw Exception('User not found');

    // Get original post
    final originalPostSnapshot = await _firebaseService.postRef(postId).get();
    if (!originalPostSnapshot.exists) throw Exception('Original post not found');

    final originalPost = Map<String, dynamic>.from(originalPostSnapshot.value as Map);

    // Create shared post
    final sharedPostId = _firebaseService.generateKey(_firebaseService.postsRef());
    
    await _firebaseService.postRef(sharedPostId).set({
      'userId': user['id'],
      'userName': user['name'],
      'userProfileImage': user['profileImage'],
      'content': text ?? '',
      'sharedPostId': postId,
      'sharedPostUserId': originalPost['userId'],
      'sharedPostUserName': originalPost['userName'],
      'sharedPostUserProfileImage': originalPost['userProfileImage'],
      'sharedPostContent': originalPost['content'],
      'sharedPostImages': originalPost['images'],
      'createdAt': ServerValue.timestamp,
      'commentCount': 0,
      'shareCount': 0,
    });

    // Increment share count on original post
    await _firebaseService.postRef(postId).child('shareCount').set(ServerValue.increment(1));

    // Send notification to original post owner
    if (originalPost['userId'] != userId) {
      final notifId = _firebaseService.generateKey(_firebaseService.notificationsRef());
      await _firebaseService.userNotificationsRef(originalPost['userId']).child(notifId).set({
        'type': 'share',
        'fromUserId': userId,
        'postId': postId,
        'read': false,
        'createdAt': ServerValue.timestamp,
      });
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPostReactions(String postId) async {
    final snapshot = await _firebaseService.reactionsRef(postId).get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final reactions = <Map<String, dynamic>>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    for (var entry in data.entries) {
      final userId = entry.key;
      final reactionType = entry.value.toString();
      
      // Get user info
      final userSnapshot = await _firebaseService.userRef(userId).get();
      if (userSnapshot.exists && userSnapshot.value != null) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        reactions.add({
          'userId': userId,
          'userName': userData['name'] ?? 'Unknown',
          'userProfileImage': userData['profileImage'],
          'reactionType': reactionType,
        });
      }
    }

    return reactions;
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
      sharedPostId: data['sharedPostId'],
      sharedPostUserId: data['sharedPostUserId'],
      sharedPostUserName: data['sharedPostUserName'],
      sharedPostUserProfileImage: data['sharedPostUserProfileImage'],
      sharedPostContent: data['sharedPostContent'],
      sharedPostImages: data['sharedPostImages'] != null 
          ? List<String>.from(data['sharedPostImages']) 
          : null,
    );
  }
}
