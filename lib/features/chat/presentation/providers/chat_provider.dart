import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clone_social/features/chat/domain/entities/chat_entity.dart';
import 'package:clone_social/features/chat/domain/entities/message_entity.dart';
import 'package:clone_social/features/chat/domain/repositories/chat_repository.dart';
import 'package:clone_social/features/chat/data/repositories/chat_repository_impl.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  
  List<ChatEntity> _chats = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider({ChatRepository? chatRepository}) 
      : _chatRepository = chatRepository ?? ChatRepositoryImpl();

  List<ChatEntity> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init(String userId) {
    _chatRepository.getChats(userId).listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }

  Stream<List<ChatEntity>> getChats(String userId) {
    return _chatRepository.getChats(userId);
  }

  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _chatRepository.getMessages(chatId);
  }

  Future<String?> createChat(String currentUserId, String otherUserId) async {
    try {
      print('ChatProvider: Creating chat between $currentUserId and $otherUserId');
      final chatId = await _chatRepository.createChat(currentUserId, otherUserId);
      print('ChatProvider: Chat created with ID: $chatId');
      return chatId;
    } catch (e) {
      print('ChatProvider Error: $e');
      _setError(e.toString());
      rethrow; // Re-throw to let UI handle it
    }
  }

  Future<void> sendMessage(String chatId, String senderId, String text, {File? image, File? video}) async {
    try {
      await _chatRepository.sendMessage(chatId, senderId, text, image: image, video: video);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
