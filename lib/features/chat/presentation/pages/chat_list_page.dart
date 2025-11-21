import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser != null) {
        context.read<ChatProvider>().init(currentUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;

    print('ChatListPage - Current user: ${currentUser?.id}');
    print('ChatListPage - Chats count: ${chatProvider.chats.length}');
    print('ChatListPage - Is loading: ${chatProvider.isLoading}');

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to friend list to start a new chat
              context.push('/friends');
            },
          ),
        ],
      ),
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No chats yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Start a conversation with your friends', 
                        style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/friends'),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Find Friends'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
              itemCount: chatProvider.chats.length,
              itemBuilder: (context, index) {
                final chat = chatProvider.chats[index];
                final otherUserId = chat.participants.firstWhere(
                  (id) => id != currentUser.id,
                  orElse: () => '',
                );
                final otherUserInfo = chat.participantInfo[otherUserId] ?? {};
                final otherUserName = otherUserInfo['name'] ?? 'Unknown';
                final otherUserImage = otherUserInfo['profileImage'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: otherUserImage != null
                        ? NetworkImage(otherUserImage)
                        : null,
                    child: otherUserImage == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    otherUserName,
                    style: TextStyle(
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: chat.unreadCount > 0 ? Colors.black : Colors.grey,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeago.format(chat.lastMessageTime, locale: 'en_short'),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () => context.push('/chat/${chat.id}'),
                );
              },
            ),
    );
  }
}
