import 'dart:io';
import '../entities/post_entity.dart';
import '../entities/comment_entity.dart';

abstract class PostRepository {
  Stream<List<PostEntity>> getPosts();
  Stream<List<PostEntity>> getUserPosts(String userId);
  Future<void> createPost(String content, {List<File>? images, File? video});
  Future<void> deletePost(String postId);
  /// @deprecated Use addReaction instead
  Future<void> likePost(String postId, String userId);
  /// @deprecated Use removeReaction instead
  Future<void> unlikePost(String postId, String userId);
  /// Add a reaction to a post
  Future<void> addReaction(String postId, String userId, String reactionType);
  /// Remove a reaction from a post
  Future<void> removeReaction(String postId, String userId);
  Future<void> addComment(String postId, String userId, String text);
  Future<void> deleteComment(String postId, String commentId);
  Future<void> sharePost(String postId, String userId);
  Stream<List<CommentEntity>> getComments(String postId);
  
  /// Like a comment
  Future<void> likeComment(String postId, String commentId, String userId);
  /// Unlike a comment
  Future<void> unlikeComment(String postId, String commentId, String userId);
  /// Reply to a comment
  Future<void> replyToComment(String postId, String commentId, String userId, String text);
  /// Get replies for a comment
  Stream<List<CommentEntity>> getCommentReplies(String postId, String commentId);
  /// Share post to feed with optional text
  Future<void> sharePostToFeed(String postId, String userId, {String? text});
  /// Get list of users who reacted to a post
  Future<List<Map<String, dynamic>>> getPostReactions(String postId);
}
