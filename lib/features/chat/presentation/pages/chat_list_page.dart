import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/features/chat/domain/entities/chat_entity.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  List<ChatEntity> _filteredChats = [];

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats(String query, List<ChatEntity> chats, String currentUserId) {
    if (query.isEmpty) {
      setState(() => _filteredChats = []);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredChats = chats.where((chat) {
        final otherUserId = chat.participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        final otherUserInfo = chat.participantInfo[otherUserId] ?? {};
        final otherUserName = (otherUserInfo['name'] ?? '').toString().toLowerCase();
        return otherUserName.contains(lowerQuery) || 
               chat.lastMessage.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _deleteChat(String chatId, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<ChatProvider>().deleteChat(chatId, userId);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    final displayChats = _isSearching && _searchController.text.isNotEmpty
        ? _filteredChats
        : chatProvider.chats;

    return Scaffold(
      appBar: _isSearching
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _filteredChats = [];
                  });
                },
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search conversations...',
                  border: InputBorder.none,
                ),
                onChanged: (query) => _filterChats(query, chatProvider.chats, currentUser.id),
              ),
              actions: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterChats('', chatProvider.chats, currentUser.id);
                    },
                  ),
              ],
            )
          : AppBar(
              title: const Text('Chats'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _isSearching = true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/friends'),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(currentUser.id),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayChats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSearching ? Icons.search_off : Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSearching ? 'Không tìm thấy kết quả' : 'Chưa có cuộc trò chuyện',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSearching 
                            ? 'Thử từ khóa khác'
                            : 'Bắt đầu trò chuyện với bạn bè',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (!_isSearching) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/friends'),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Tìm bạn bè'),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: displayChats.length,
                  itemBuilder: (context, index) {
                    final chat = displayChats[index];
                    final otherUserId = chat.participants.firstWhere(
                      (id) => id != currentUser.id,
                      orElse: () => '',
                    );
                    final otherUserInfo = chat.participantInfo[otherUserId] ?? {};
                    final otherUserName = otherUserInfo['name'] ?? 'Unknown';
                    final otherUserImage = otherUserInfo['profileImage'];

                    return Dismissible(
                      key: Key(chat.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Conversation'),
                            content: const Text('Are you sure you want to delete this conversation?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        context.read<ChatProvider>().deleteChat(chat.id, currentUser.id);
                      },
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: otherUserImage != null && otherUserImage.toString().isNotEmpty
                                  ? NetworkImage(otherUserImage.toString())
                                  : null,
                              child: otherUserImage == null || otherUserImage.toString().isEmpty
                                  ? const Icon(Icons.person, color: Colors.white)
                                  : null,
                            ),
                            // Online indicator (placeholder - would need real-time status)
                          ],
                        ),
                        title: Text(
                          otherUserName,
                          style: TextStyle(
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            if (chat.lastMessageSenderId == currentUser.id)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Text('You: ', style: TextStyle(color: Colors.grey)),
                              ),
                            Expanded(
                              child: Text(
                                chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: chat.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: chat.unreadCount > 0 ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              timeago.format(chat.lastMessageTime, locale: 'en_short'),
                              style: TextStyle(
                                fontSize: 12,
                                color: chat.unreadCount > 0 ? AppTheme.primaryBlue : Colors.grey,
                              ),
                            ),
                            if (chat.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () => context.push(
                          '/chat/${chat.id}',
                          extra: {
                            'otherUserName': otherUserName,
                            'otherUserImage': otherUserImage,
                            'otherUserId': otherUserId,
                          },
                        ),
                        onLongPress: () => _showChatOptions(chat, currentUser.id),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showNewChatDialog(String currentUserId) async {
    // Navigate to friends page to select a friend to chat with
    context.push('/search-users');
  }

  void _showChatOptions(ChatEntity chat, String currentUserId) {
    final otherUserId = chat.participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                if (otherUserId.isNotEmpty) {
                  context.push('/profile/$otherUserId');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.mark_chat_read),
              title: const Text('Mark as Read'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatProvider>().markAllAsRead(chat.id, currentUserId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Conversation', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteChat(chat.id, currentUserId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
