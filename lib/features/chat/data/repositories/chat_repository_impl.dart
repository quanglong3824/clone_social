import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
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
    String? imageUrl;
    String? videoUrl;

    if (image != null) {
      final ref = _firebaseStorage
          .ref()
          .child('chat_images/$chatId/${_uuid.v4()}.jpg');
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    }

    if (video != null) {
      final ref = _firebaseStorage
          .ref()
          .child('chat_videos/$chatId/${_uuid.v4()}.mp4');
      await ref.putFile(video);
      videoUrl = await ref.getDownloadURL();
    }

    final messageId = _firebaseService.generateKey(_firebaseService.messagesRef(chatId));
    final messageData = {
      'senderId': senderId,
      'content': text,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'createdAt': ServerValue.timestamp,
      'read': false,
    };

    await _firebaseService.messagesRef(chatId).child(messageId).set(messageData);

    // Update last message for all participants
    final chatSnapshot = await _firebaseService.userChatsRef(senderId).child(chatId).get();
    if (chatSnapshot.exists) {
      final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
      final participants = List<String>.from(chatData['participants'] ?? []);
      
      for (var userId in participants) {
        await _firebaseService.userChatsRef(userId).child(chatId).update({
          'lastMessage': text.isNotEmpty ? text : (imageUrl != null ? 'Sent an image' : 'Sent a video'),
          'lastMessageTime': ServerValue.timestamp,
          'lastMessageSenderId': senderId,
          'unreadCount': userId != senderId ? ServerValue.increment(1) : 0,
        });
      }
    }
  }

  @override
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _firebaseService.messagesRef(chatId).child(messageId).update({'read': true});
  }

  ChatEntity _mapToChatEntity(String id, Map<String, dynamic> data) {
    return ChatEntity(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'] ?? 0),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCount: data['unreadCount'] ?? 0,
      participantInfo: data['participantInfo'] != null 
          ? Map<String, Map<String, dynamic>>.from(data['participantInfo'])
          : {},
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
