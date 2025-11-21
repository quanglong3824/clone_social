import 'dart:io';
import '../entities/post_entity.dart';
import '../entities/comment_entity.dart';

abstract class PostRepository {
  Stream<List<PostEntity>> getPosts();
  Stream<List<PostEntity>> getUserPosts(String userId);
  Future<void> createPost(String content, {List<File>? images, File? video});
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId, String userId);
  Future<void> unlikePost(String postId, String userId);
  Future<void> addComment(String postId, String userId, String text);
  Future<void> deleteComment(String postId, String commentId);
  Future<void> sharePost(String postId, String userId);
  Stream<List<CommentEntity>> getComments(String postId);
}
