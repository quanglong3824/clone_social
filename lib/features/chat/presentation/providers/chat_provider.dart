import 'dart:async';
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
  int _totalUnreadCount = 0;
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _unreadSubscription;

  ChatProvider({ChatRepository? chatRepository}) 
      : _chatRepository = chatRepository ?? ChatRepositoryImpl();

  List<ChatEntity> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalUnreadCount => _totalUnreadCount;

  void init(String userId) {
    _chatsSubscription?.cancel();
    _unreadSubscription?.cancel();
    _isLoading = true;
    notifyListeners();
    
    _chatsSubscription = _chatRepository.getChats(userId).listen((chats) {
      _chats = chats;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print('ChatProvider: Error loading chats: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });

    _unreadSubscription = _chatRepository.getUnreadCount(userId).listen((count) {
      _totalUnreadCount = count;
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
      rethrow;
    }
  }

  Future<void> sendMessage(String chatId, String senderId, String text, {File? image, File? video}) async {
    try {
      await _chatRepository.sendMessage(chatId, senderId, text, image: image, video: video);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Send an image message
  Future<void> sendImageMessage(String chatId, String senderId, String base64Image) async {
    try {
      await _chatRepository.sendImageMessage(chatId, senderId, base64Image);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Mark all messages in a chat as read
  Future<void> markAllAsRead(String chatId, String userId) async {
    try {
      await _chatRepository.markAllMessagesAsRead(chatId, userId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Delete a message
  Future<bool> deleteMessage(String chatId, String messageId, String userId) async {
    try {
      await _chatRepository.deleteMessage(chatId, messageId, userId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete a chat
  Future<bool> deleteChat(String chatId, String userId) async {
    try {
      await _chatRepository.deleteChat(chatId, userId);
      // Remove from local list
      _chats.removeWhere((chat) => chat.id == chatId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Set typing status
  Future<void> setTyping(String chatId, String userId, bool isTyping) async {
    try {
      await _chatRepository.setTypingStatus(chatId, userId, isTyping);
    } catch (e) {
      // Silent fail for typing indicator
      debugPrint('Error setting typing status: $e');
    }
  }

  /// Get typing status stream
  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _chatRepository.getTypingStatus(chatId);
  }

  /// Get chat by ID
  Future<ChatEntity?> getChatById(String chatId, String userId) async {
    try {
      return await _chatRepository.getChatById(chatId, userId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Search messages in a chat
  Future<List<MessageEntity>> searchMessages(String chatId, String query) async {
    try {
      return await _chatRepository.searchMessages(chatId, query);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _unreadSubscription?.cancel();
    super.dispose();
  }
}
