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

  Future<void> likePost(String postId, String userId) async {
    try {
      await _postRepository.likePost(postId, userId);
    } catch (e) {
      // Optimistic update failed, handle error if needed
      print('Error liking post: $e');
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _postRepository.unlikePost(postId, userId);
    } catch (e) {
      print('Error unliking post: $e');
    }
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
