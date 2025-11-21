import 'dart:io';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> getChats(String userId);
  Stream<List<MessageEntity>> getMessages(String chatId);
  Future<String> createChat(String currentUserId, String otherUserId);
  Future<void> sendMessage(String chatId, String senderId, String text, {File? image, File? video});
  Future<void> markMessageAsRead(String chatId, String messageId);
}
