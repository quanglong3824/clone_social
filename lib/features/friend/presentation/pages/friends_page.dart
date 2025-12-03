import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clone_social/features/friend/presentation/providers/friend_provider.dart';
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser != null) {
        context.read<FriendProvider>().init(currentUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendProvider = context.watch<FriendProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/search-users'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Gợi ý'),
              Tab(text: 'Bạn bè'),
              Tab(text: 'Lời mời'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Suggestions Tab
            _SuggestionsTab(
              currentUserId: currentUser.id,
              friendIds: friendProvider.friendIds,
            ),
            // Friends List
            friendProvider.friendIds.isEmpty
                ? const Center(child: Text('No friends yet'))
                : ListView.builder(
                    itemCount: friendProvider.friendIds.length,
                    itemBuilder: (context, index) {
                      final friendId = friendProvider.friendIds[index];
                      return FutureBuilder(
                        future: friendProvider.getUserProfile(friendId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person)),
                              title: Text('Loading...'),
                            );
                          }
                          final user = snapshot.data!;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.profileImage != null
                                  ? NetworkImage(user.profileImage!)
                                  : null,
                              child: user.profileImage == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(user.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.message),
                              onPressed: () async {
                                final currentUser = context.read<AuthProvider>().currentUser;
                                if (currentUser != null) {
                                  final chatId = await context.read<ChatProvider>().createChat(
                                    currentUser.id,
                                    user.id,
                                  );
                                  if (chatId != null && context.mounted) {
                                    context.push(
                                      '/chat/$chatId',
                                      extra: {
                                        'otherUserName': user.name,
                                        'otherUserImage': user.profileImage,
                                        'otherUserId': user.id,
                                      },
                                    );
                                  }
                                }
                              },
                            ),
                            onTap: () => context.push('/profile/${user.id}'),
                          );
                        },
                      );
                    },
                  ),

            // Friend Requests
            _FriendRequestsTab(currentUserId: currentUser.id),
          ],
        ),
      ),
    );
  }
}


/// Widget hiển thị gợi ý bạn bè từ tất cả users trong hệ thống
class _SuggestionsTab extends StatefulWidget {
  final String currentUserId;
  final List<String> friendIds;

  const _SuggestionsTab({
    required this.currentUserId,
    required this.friendIds,
  });

  @override
  State<_SuggestionsTab> createState() => _SuggestionsTabState();
}

class _SuggestionsTabState extends State<_SuggestionsTab> {
  List<dynamic> _suggestions = [];
  bool _isLoading = true;
  Set<String> _sentRequests = {};

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void didUpdateWidget(_SuggestionsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.friendIds != widget.friendIds) {
      _loadSuggestions();
    }
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);
    
    try {
      // Search all users (empty query returns all)
      final allUsers = await context.read<FriendProvider>().searchUsers('');
      
      // Filter out current user and existing friends
      final suggestions = allUsers.where((user) {
        return user.id != widget.currentUserId && 
               !widget.friendIds.contains(user.id);
      }).toList();
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendFriendRequest(String toUserId) async {
    setState(() {
      _sentRequests.add(toUserId);
    });
    
    try {
      await context.read<FriendProvider>().sendFriendRequest(
        widget.currentUserId,
        toUserId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi lời mời kết bạn'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sentRequests.remove(toUserId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không có gợi ý bạn bè'),
            SizedBox(height: 8),
            Text(
              'Hãy mời bạn bè tham gia ứng dụng',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSuggestions,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final user = _suggestions[index];
          final hasSentRequest = _sentRequests.contains(user.id);
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? const Icon(Icons.person, size: 28)
                    : null,
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                user.bio ?? 'Người dùng mới',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: hasSentRequest
                  ? OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Đã gửi'),
                    )
                  : ElevatedButton(
                      onPressed: () => _sendFriendRequest(user.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Thêm bạn'),
                    ),
              onTap: () => context.push('/profile/${user.id}'),
            ),
          );
        },
      ),
    );
  }
}


/// Widget hiển thị danh sách lời mời kết bạn
class _FriendRequestsTab extends StatelessWidget {
  final String currentUserId;

  const _FriendRequestsTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final friendProvider = context.watch<FriendProvider>();
    final requests = friendProvider.friendRequests;

    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_disabled, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không có lời mời kết bạn'),
            SizedBox(height: 8),
            Text(
              'Khi có người gửi lời mời, bạn sẽ thấy ở đây',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _FriendRequestCard(
          request: request,
          currentUserId: currentUserId,
        );
      },
    );
  }
}

class _FriendRequestCard extends StatefulWidget {
  final dynamic request;
  final String currentUserId;

  const _FriendRequestCard({
    required this.request,
    required this.currentUserId,
  });

  @override
  State<_FriendRequestCard> createState() => _FriendRequestCardState();
}

class _FriendRequestCardState extends State<_FriendRequestCard> {
  bool _isProcessing = false;

  Future<void> _acceptRequest() async {
    setState(() => _isProcessing = true);

    try {
      await context.read<FriendProvider>().acceptFriendRequest(
        widget.currentUserId,
        widget.request.id,
        widget.request.fromUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chấp nhận lời mời từ ${widget.request.fromUserName}'),
            backgroundColor: AppTheme.success,
            action: SnackBarAction(
              label: 'Nhắn tin',
              textColor: Colors.white,
              onPressed: () async {
                final chatId = await context.read<ChatProvider>().createChat(
                  widget.currentUserId,
                  widget.request.fromUserId,
                );
                if (chatId != null && mounted) {
                  context.push(
                    '/chat/$chatId',
                    extra: {
                      'otherUserName': widget.request.fromUserName,
                      'otherUserImage': widget.request.fromUserProfileImage,
                      'otherUserId': widget.request.fromUserId,
                    },
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest() async {
    setState(() => _isProcessing = true);

    try {
      await context.read<FriendProvider>().rejectFriendRequest(
        widget.currentUserId,
        widget.request.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối lời mời kết bạn')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => context.push('/profile/${widget.request.fromUserId}'),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: widget.request.fromUserProfileImage != null
                    ? NetworkImage(widget.request.fromUserProfileImage!)
                    : null,
                child: widget.request.fromUserProfileImage == null
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Info & Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/profile/${widget.request.fromUserId}'),
                    child: Text(
                      widget.request.fromUserName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đã gửi lời mời kết bạn',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  // Action buttons
                  if (_isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _acceptRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Chấp nhận'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _rejectRequest,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Từ chối'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
