import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/features/chat/domain/entities/chat_entity.dart';
import 'package:clone_social/features/chat/domain/entities/message_entity.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;

  const ChatDetailPage({super.key, required this.chatId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    setState(() => _isSending = true);

    await context.read<ChatProvider>().sendMessage(
      widget.chatId,
      currentUser.id,
      _messageController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSending = false;
        _messageController.clear();
      });
      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // Reverse list view, 0 is bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    
    print('ChatDetailPage - chatId: ${widget.chatId}');
    print('ChatDetailPage - currentUser: ${currentUser?.id}');
    
    return StreamBuilder<List<ChatEntity>>(
      stream: currentUser != null 
          ? context.read<ChatProvider>().getChats(currentUser.id)
          : const Stream.empty(),
      builder: (context, chatSnapshot) {
        String title = 'Chat';
        String? otherUserImage;
        
        if (chatSnapshot.hasData && currentUser != null) {
          final chat = chatSnapshot.data!.firstWhere(
            (c) => c.id == widget.chatId,
            orElse: () => ChatEntity(
              id: widget.chatId,
              participants: [],
              lastMessageTime: DateTime.now(),
            ),
          );
          
          print('ChatDetailPage - Found chat: ${chat.id}');
          print('ChatDetailPage - Participants: ${chat.participants}');
          print('ChatDetailPage - ParticipantInfo: ${chat.participantInfo}');
          
          if (chat.participants.isNotEmpty) {
            final otherUserId = chat.participants.firstWhere(
              (id) => id != currentUser.id,
              orElse: () => '',
            );
            
            if (otherUserId.isNotEmpty) {
              final otherUserInfo = chat.participantInfo[otherUserId] ?? {};
              title = otherUserInfo['name'] ?? 'Unknown User';
              otherUserImage = otherUserInfo['profileImage'];
              
              print('ChatDetailPage - Other user: $title');
            }
          }
        }
        
        return _buildChatUI(context, currentUser, title, otherUserImage);
      },
    );
  }

  Widget _buildChatUI(BuildContext context, currentUser, String title, String? otherUserImage) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: otherUserImage != null
                  ? NetworkImage(otherUserImage)
                  : null,
              child: otherUserImage == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageEntity>>(
              stream: context.read<ChatProvider>().getMessages(widget.chatId),
              builder: (context, snapshot) {
                print('StreamBuilder state: ${snapshot.connectionState}');
                print('Has data: ${snapshot.hasData}');
                print('Data: ${snapshot.data}');
                print('Error: ${snapshot.error}');
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No messages yet', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Send a message to start the conversation', 
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;
                print('Messages count: ${messages.length}');

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Show newest at bottom
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.id;
                    print('Rendering message $index: ${message.text}');

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.primaryBlue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20).copyWith(
                            bottomRight: isMe ? Radius.zero : null,
                            bottomLeft: !isMe ? Radius.zero : null,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.type == 'image' && message.mediaUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    message.mediaUrl!,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image, size: 50),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (message.type == 'video' && message.mediaUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
                                  ),
                                ),
                              ),
                            if (message.text.isNotEmpty)
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.primaryBlue),
              onPressed: () {
                // TODO: Implement media picker
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: AppTheme.primaryBlue),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
