import 'dart:io';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:clone_social/features/chat/domain/entities/chat_entity.dart';
import 'package:clone_social/features/chat/domain/entities/message_entity.dart';
import 'package:clone_social/features/chat/domain/repositories/chat_repository.dart';
import 'package:clone_social/core/services/firebase_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseService _firebaseService;
  final FirebaseStorage _firebaseStorage;
  final Uuid _uuid;

  ChatRepositoryImpl({
    FirebaseService? firebaseService,
    FirebaseStorage? firebaseStorage,
    Uuid? uuid,
  })  : _firebaseService = firebaseService ?? FirebaseService(),
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  /// Reference to typing status
  DatabaseReference _typingRef(String chatId) =>
      _firebaseService.database.child('typing').child(chatId);

  @override
  Stream<List<ChatEntity>> getChats(String userId) {
    return _firebaseService.userChatsRef(userId).onValue.map((event) {
      final chats = <ChatEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          chats.add(_mapToChatEntity(key, Map<String, dynamic>.from(value)));
        });
      }
      // Sort by last message time
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return chats;
    });
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _firebaseService.messagesRef(chatId).onValue.map((event) {
      final messages = <MessageEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          messages.add(_mapToMessageEntity(key, Map<String, dynamic>.from(value), chatId));
        });
      }
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return messages;
    });
  }

  @override
  Future<String> createChat(String currentUserId, String otherUserId) async {
    try {
      // Validate: Cannot chat with yourself
      if (currentUserId == otherUserId) {
        throw Exception('Cannot create chat with yourself');
      }
      
      print('ChatRepo: Checking existing chats for user $currentUserId');
      
      // Check if chat already exists
      final snapshot = await _firebaseService.userChatsRef(currentUserId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (var entry in data.entries) {
          final chatData = Map<String, dynamic>.from(entry.value);
          final participants = List<String>.from(chatData['participants'] ?? []);
          if (participants.contains(otherUserId)) {
            print('ChatRepo: Found existing chat: ${entry.key}');
            return entry.key;
          }
        }
      }

      print('ChatRepo: No existing chat found, creating new one');
      
      // Create new chat
      final chatId = _firebaseService.generateKey(_firebaseService.chatsRef());
      print('ChatRepo: Generated chat ID: $chatId');
      
      final participants = [currentUserId, otherUserId];
      
      // Get user info for denormalization
      print('ChatRepo: Fetching user data...');
      final currentUserSnapshot = await _firebaseService.userRef(currentUserId).get();
      final otherUserSnapshot = await _firebaseService.userRef(otherUserId).get();
      
      if (!currentUserSnapshot.exists) {
        throw Exception('Current user not found: $currentUserId');
      }
      if (!otherUserSnapshot.exists) {
        throw Exception('Other user not found: $otherUserId');
      }
      
      final currentUserData = Map<String, dynamic>.from(currentUserSnapshot.value as Map);
      final otherUserData = Map<String, dynamic>.from(otherUserSnapshot.value as Map);

      print('ChatRepo: Current user: ${currentUserData['name']}');
      print('ChatRepo: Other user: ${otherUserData['name']}');

      final chatData = {
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': ServerValue.timestamp,
        'lastMessageSenderId': '',
        'createdAt': ServerValue.timestamp,
        'participantInfo': {
          currentUserId: {
            'name': currentUserData['name'],
            'profileImage': currentUserData['profileImage'],
          },
          otherUserId: {
            'name': otherUserData['name'],
            'profileImage': otherUserData['profileImage'],
          },
        }
      };

      // Save chat metadata for both users
      print('ChatRepo: Saving chat data to Firebase...');
      await _firebaseService.userChatsRef(currentUserId).child(chatId).set(chatData);
      await _firebaseService.userChatsRef(otherUserId).child(chatId).set(chatData);
      
      print('ChatRepo: Chat created successfully: $chatId');
      return chatId;
    } catch (e) {
      print('ChatRepo Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String chatId, String senderId, String text, {File? image, File? video}) async {
    if (text.trim().isEmpty) return;

    print('ChatRepo: Sending message in chat $chatId from $senderId');

    try {
      final messageId = _firebaseService.generateKey(_firebaseService.messagesRef(chatId));
      final messageData = {
        'senderId': senderId,
        'content': text.trim(),
        'createdAt': ServerValue.timestamp,
        'read': false,
      };

      await _firebaseService.messagesRef(chatId).child(messageId).set(messageData);
      print('ChatRepo: Message saved with ID: $messageId');

      // Update last message for all participants
      final chatSnapshot = await _firebaseService.userChatsRef(senderId).child(chatId).get();
      if (chatSnapshot.exists && chatSnapshot.value != null) {
        final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
        final participants = List<String>.from(chatData['participants'] ?? []);
        
        print('ChatRepo: Updating last message for ${participants.length} participants');
        
        for (var userId in participants) {
          await _firebaseService.userChatsRef(userId).child(chatId).update({
            'lastMessage': text.trim(),
            'lastMessageTime': ServerValue.timestamp,
            'lastMessageSenderId': senderId,
            'unreadCount': userId != senderId ? ServerValue.increment(1) : 0,
          });
        }
      }
      
      print('ChatRepo: Message sent successfully');
    } catch (e) {
      print('ChatRepo: Error sending message: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendImageMessage(String chatId, String senderId, String base64Image) async {
    print('ChatRepo: Sending image message in chat $chatId from $senderId');

    try {
      final messageId = _firebaseService.generateKey(_firebaseService.messagesRef(chatId));
      final messageData = {
        'senderId': senderId,
        'content': '',
        'imageUrl': base64Image,
        'createdAt': ServerValue.timestamp,
        'read': false,
      };

      await _firebaseService.messagesRef(chatId).child(messageId).set(messageData);
      print('ChatRepo: Image message saved with ID: $messageId');

      // Update last message for all participants
      final chatSnapshot = await _firebaseService.userChatsRef(senderId).child(chatId).get();
      if (chatSnapshot.exists && chatSnapshot.value != null) {
        final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
        final participants = List<String>.from(chatData['participants'] ?? []);
        
        for (var userId in participants) {
          await _firebaseService.userChatsRef(userId).child(chatId).update({
            'lastMessage': '📷 Hình ảnh',
            'lastMessageTime': ServerValue.timestamp,
            'lastMessageSenderId': senderId,
            'unreadCount': userId != senderId ? ServerValue.increment(1) : 0,
          });
        }
      }
      
      print('ChatRepo: Image message sent successfully');
    } catch (e) {
      print('ChatRepo: Error sending image message: $e');
      rethrow;
    }
  }

  @override
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _firebaseService.messagesRef(chatId).child(messageId).update({'read': true});
  }

  @override
  Future<void> markAllMessagesAsRead(String chatId, String userId) async {
    try {
      // Get all unread messages
      final snapshot = await _firebaseService.messagesRef(chatId).get();
      if (!snapshot.exists || snapshot.value == null) return;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final updates = <String, dynamic>{};

      data.forEach((messageId, messageData) {
        final message = Map<String, dynamic>.from(messageData);
        if (message['senderId'] != userId && message['read'] != true) {
          updates['$messageId/read'] = true;
        }
      });

      if (updates.isNotEmpty) {
        await _firebaseService.messagesRef(chatId).update(updates);
      }

      // Reset unread count for this user
      await _firebaseService.userChatsRef(userId).child(chatId).update({
        'unreadCount': 0,
      });
    } catch (e) {
      print('Error marking all messages as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId, String userId) async {
    try {
      // Get message to check ownership
      final snapshot = await _firebaseService.messagesRef(chatId).child(messageId).get();
      if (!snapshot.exists) return;

      final messageData = Map<String, dynamic>.from(snapshot.value as Map);
      
      // Only allow sender to delete their own message
      if (messageData['senderId'] != userId) {
        throw Exception('You can only delete your own messages');
      }

      // Delete media from storage if exists
      if (messageData['imageUrl'] != null) {
        try {
          await _firebaseStorage.refFromURL(messageData['imageUrl']).delete();
        } catch (_) {}
      }
      if (messageData['videoUrl'] != null) {
        try {
          await _firebaseStorage.refFromURL(messageData['videoUrl']).delete();
        } catch (_) {}
      }

      // Delete message
      await _firebaseService.messagesRef(chatId).child(messageId).remove();

      // Update last message if this was the last one
      final messagesSnapshot = await _firebaseService.messagesRef(chatId)
          .orderByChild('createdAt')
          .limitToLast(1)
          .get();

      if (messagesSnapshot.exists && messagesSnapshot.value != null) {
        final messages = Map<String, dynamic>.from(messagesSnapshot.value as Map);
        final lastMessage = messages.values.first;
        final lastMessageData = Map<String, dynamic>.from(lastMessage);

        // Update for all participants
        final chatSnapshot = await _firebaseService.userChatsRef(userId).child(chatId).get();
        if (chatSnapshot.exists) {
          final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
          final participants = List<String>.from(chatData['participants'] ?? []);

          for (var participantId in participants) {
            await _firebaseService.userChatsRef(participantId).child(chatId).update({
              'lastMessage': lastMessageData['content'] ?? '',
              'lastMessageTime': lastMessageData['createdAt'],
              'lastMessageSenderId': lastMessageData['senderId'],
            });
          }
        }
      }
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteChat(String chatId, String userId) async {
    try {
      // Remove chat from user's chat list only (not for other user)
      await _firebaseService.userChatsRef(userId).child(chatId).remove();
      
      // Note: We don't delete messages as the other user might still want to see them
      // If you want to delete messages when both users delete the chat, 
      // you'd need to track deletion status for both users
    } catch (e) {
      print('Error deleting chat: $e');
      rethrow;
    }
  }

  @override
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    try {
      if (isTyping) {
        await _typingRef(chatId).child(userId).set({
          'isTyping': true,
          'timestamp': ServerValue.timestamp,
        });
      } else {
        await _typingRef(chatId).child(userId).remove();
      }
    } catch (e) {
      print('Error setting typing status: $e');
    }
  }

  @override
  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _typingRef(chatId).onValue.map((event) {
      final typingStatus = <String, bool>{};
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((userId, value) {
          final typingData = Map<String, dynamic>.from(value);
          // Only consider typing if timestamp is within last 10 seconds
          final timestamp = typingData['timestamp'] ?? 0;
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - timestamp < 10000) {
            typingStatus[userId] = typingData['isTyping'] ?? false;
          }
        });
      }
      return typingStatus;
    });
  }

  @override
  Future<ChatEntity?> getChatById(String chatId, String userId) async {
    try {
      final snapshot = await _firebaseService.userChatsRef(userId).child(chatId).get();
      if (!snapshot.exists || snapshot.value == null) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return _mapToChatEntity(chatId, data);
    } catch (e) {
      print('Error getting chat by ID: $e');
      return null;
    }
  }

  @override
  Future<List<MessageEntity>> searchMessages(String chatId, String query) async {
    try {
      final snapshot = await _firebaseService.messagesRef(chatId).get();
      if (!snapshot.exists || snapshot.value == null) return [];

      final messages = <MessageEntity>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final lowerQuery = query.toLowerCase();

      data.forEach((key, value) {
        final messageData = Map<String, dynamic>.from(value);
        final content = (messageData['content'] ?? '').toString().toLowerCase();
        if (content.contains(lowerQuery)) {
          messages.add(_mapToMessageEntity(key, messageData, chatId));
        }
      });

      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return messages;
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _firebaseService.userChatsRef(userId).onValue.map((event) {
      int totalUnread = 0;
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final chatData = Map<String, dynamic>.from(value);
          totalUnread += (chatData['unreadCount'] ?? 0) as int;
        });
      }
      return totalUnread;
    });
  }

  ChatEntity _mapToChatEntity(String id, Map<String, dynamic> data) {
    // Parse participantInfo safely
    Map<String, Map<String, dynamic>> participantInfo = {};
    if (data['participantInfo'] != null) {
      try {
        final rawInfo = Map<String, dynamic>.from(data['participantInfo'] as Map);
        rawInfo.forEach((key, value) {
          if (value != null) {
            participantInfo[key] = Map<String, dynamic>.from(value as Map);
          }
        });
      } catch (e) {
        print('Error parsing participantInfo: $e');
      }
    }

    return ChatEntity(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'] ?? 0),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCount: data['unreadCount'] ?? 0,
      participantInfo: participantInfo,
    );
  }

  MessageEntity _mapToMessageEntity(String id, Map<String, dynamic> data, String chatId) {
    String type = 'text';
    String? mediaUrl;
    
    if (data['imageUrl'] != null) {
      type = 'image';
      mediaUrl = data['imageUrl'];
    } else if (data['videoUrl'] != null) {
      type = 'video';
      mediaUrl = data['videoUrl'];
    }

    return MessageEntity(
      id: id,
      chatId: chatId,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'User',
      senderProfileImage: data['senderProfileImage'],
      text: data['content'] ?? '',
      type: type,
      mediaUrl: mediaUrl,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      read: data['read'] ?? false,
    );
  }
}
