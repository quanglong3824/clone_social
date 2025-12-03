import 'dart:io';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  /// Get all chats for a user
  Stream<List<ChatEntity>> getChats(String userId);
  
  /// Get all messages in a chat
  Stream<List<MessageEntity>> getMessages(String chatId);
  
  /// Create a new chat between two users
  Future<String> createChat(String currentUserId, String otherUserId);
  
  /// Send a message (text, image, or video)
  Future<void> sendMessage(String chatId, String senderId, String text, {File? image, File? video});
  
  /// Send an image message with base64 data
  Future<void> sendImageMessage(String chatId, String senderId, String base64Image);
  
  /// Mark a single message as read
  Future<void> markMessageAsRead(String chatId, String messageId);
  
  /// Mark all messages in a chat as read
  Future<void> markAllMessagesAsRead(String chatId, String userId);
  
  /// Delete a message
  Future<void> deleteMessage(String chatId, String messageId, String userId);
  
  /// Delete entire chat for a user
  Future<void> deleteChat(String chatId, String userId);
  
  /// Set typing indicator
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping);
  
  /// Get typing status stream
  Stream<Map<String, bool>> getTypingStatus(String chatId);
  
  /// Get chat by ID
  Future<ChatEntity?> getChatById(String chatId, String userId);
  
  /// Search messages in a chat
  Future<List<MessageEntity>> searchMessages(String chatId, String query);
  
  /// Get unread message count for a user
  Stream<int> getUnreadCount(String userId);
}
