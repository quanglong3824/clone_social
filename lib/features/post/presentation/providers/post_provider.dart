import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clone_social/features/post/domain/entities/post_entity.dart';
import 'package:clone_social/features/post/domain/entities/comment_entity.dart';
import 'package:clone_social/features/post/domain/repositories/post_repository.dart';
import 'package:clone_social/features/post/data/repositories/post_repository_impl.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository _postRepository;
  
  List<PostEntity> _posts = [];
  bool _isLoading = false;
  String? _error;

  PostProvider({PostRepository? postRepository}) 
      : _postRepository = postRepository ?? PostRepositoryImpl() {
    _init();
  }

  List<PostEntity> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _init() {
    _setLoading(true);
    _postRepository.getPosts().listen((posts) {
      _posts = posts;
      _setLoading(false);
    }, onError: (e) {
      _setError(e.toString());
    });
  }

  Future<bool> createPost(String content, {List<File>? images, File? video}) async {
    _setLoading(true);
    try {
      await _postRepository.createPost(content, images: images, video: video);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Add a reaction to a post with optimistic update
  Future<void> addReaction(String postId, String userId, ReactionType reaction) async {
    // Optimistic update
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final updatedReactions = Map<String, String>.from(post.reactions);
      updatedReactions[userId] = reaction.name;
      _posts[postIndex] = post.copyWith(reactions: updatedReactions);
      notifyListeners();
    }

    try {
      await _postRepository.addReaction(postId, userId, reaction.name);
    } catch (e) {
      // Rollback on error
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final updatedReactions = Map<String, String>.from(post.reactions);
        updatedReactions.remove(userId);
        _posts[postIndex] = post.copyWith(reactions: updatedReactions);
        notifyListeners();
      }
      debugPrint('Error adding reaction: $e');
    }
  }

  /// Remove a reaction from a post with optimistic update
  Future<void> removeReaction(String postId, String userId) async {
    // Store previous state for rollback
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    String? previousReaction;
    
    if (postIndex != -1) {
      final post = _posts[postIndex];
      previousReaction = post.reactions[userId];
      final updatedReactions = Map<String, String>.from(post.reactions);
      updatedReactions.remove(userId);
      _posts[postIndex] = post.copyWith(reactions: updatedReactions);
      notifyListeners();
    }

    try {
      await _postRepository.removeReaction(postId, userId);
    } catch (e) {
      // Rollback on error
      if (postIndex != -1 && previousReaction != null) {
        final post = _posts[postIndex];
        final updatedReactions = Map<String, String>.from(post.reactions);
        updatedReactions[userId] = previousReaction;
        _posts[postIndex] = post.copyWith(reactions: updatedReactions);
        notifyListeners();
      }
      debugPrint('Error removing reaction: $e');
    }
  }

  /// Toggle reaction - if same reaction exists, remove it; otherwise add/change it
  Future<void> toggleReaction(String postId, String userId, ReactionType reaction) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final currentReaction = post.getReactionBy(userId);

    if (currentReaction == reaction) {
      // Same reaction - remove it
      await removeReaction(postId, userId);
    } else {
      // Different or no reaction - add/change it
      await addReaction(postId, userId, reaction);
    }
  }

  /// @deprecated Use addReaction instead
  Future<void> likePost(String postId, String userId) async {
    await addReaction(postId, userId, ReactionType.like);
  }

  /// @deprecated Use removeReaction instead
  Future<void> unlikePost(String postId, String userId) async {
    await removeReaction(postId, userId);
  }

  Future<void> addComment(String postId, String userId, String text) async {
    try {
      await _postRepository.addComment(postId, userId, text);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Stream<List<CommentEntity>> getComments(String postId) {
    return _postRepository.getComments(postId);
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
