import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clone_social/features/friend/presentation/providers/friend_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);
  
  List<UserEntity> _searchResults = [];
  List<UserEntity> _suggestions = [];
  bool _isSearching = false;
  bool _isLoadingSuggestions = true;
  Set<String> _sentRequests = {};
  Set<String> _friendIds = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      print('SearchUsersPage: No current user');
      return;
    }

    print('SearchUsersPage: Loading data for user ${currentUser.id}');

    // Load friend IDs
    final friendProvider = context.read<FriendProvider>();
    _friendIds = friendProvider.friendIds.toSet();
    print('SearchUsersPage: Friend IDs: $_friendIds');

    // Load suggestions (all users except current user and friends)
    setState(() => _isLoadingSuggestions = true);
    
    try {
      print('SearchUsersPage: Fetching all users...');
      final allUsers = await friendProvider.searchUsers('');
      print('SearchUsersPage: Got ${allUsers.length} users');
      
      final suggestions = allUsers.where((user) {
        return user.id != currentUser.id && !_friendIds.contains(user.id);
      }).toList();

      print('SearchUsersPage: ${suggestions.length} suggestions after filtering');

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      print('SearchUsersPage: Error loading suggestions: $e');
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final results = await context.read<FriendProvider>().searchUsers(query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  FriendshipStatus _getFriendshipStatus(String userId) {
    if (_friendIds.contains(userId)) {
      return FriendshipStatus.friends;
    }
    if (_sentRequests.contains(userId)) {
      return FriendshipStatus.requestSent;
    }
    return FriendshipStatus.none;
  }

  Future<void> _sendFriendRequest(String toUserId, String toUserName) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    setState(() {
      _sentRequests.add(toUserId);
    });

    try {
      await context.read<FriendProvider>().sendFriendRequest(
        currentUser.id,
        toUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi lời mời kết bạn đến $toUserName'),
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
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _startChat(UserEntity user) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final chatId = await context.read<ChatProvider>().createChat(
        currentUser.id,
        user.id,
      );

      if (mounted) {
        Navigator.of(context).pop();
        if (chatId != null && chatId.isNotEmpty) {
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
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm người dùng...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchResults = []);
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
            _debouncer.run(() => _search(value));
          },
        ),
      ),
      body: _buildBody(currentUser, hasSearchQuery),
    );
  }

  Widget _buildBody(UserEntity? currentUser, bool hasSearchQuery) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show search results if searching
    if (hasSearchQuery) {
      return _buildSearchResults(currentUser);
    }

    // Show suggestions when not searching
    return _buildSuggestions(currentUser);
  }

  Widget _buildSearchResults(UserEntity? currentUser) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy người dùng',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        if (user.id == currentUser?.id) return const SizedBox.shrink();
        return _buildUserCard(user, currentUser);
      },
    );
  }

  Widget _buildSuggestions(UserEntity? currentUser) {
    if (_isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.people_outline, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Gợi ý bạn bè',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _loadInitialData,
                  child: const Text('Làm mới'),
                ),
              ],
            ),
          ),
        ),

        // Suggestions list
        if (_suggestions.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không có gợi ý bạn bè',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = _suggestions[index];
                  return _buildUserCard(user, currentUser);
                },
                childCount: _suggestions.length,
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildUserCard(UserEntity user, UserEntity? currentUser) {
    final status = _getFriendshipStatus(user.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => context.push('/profile/${user.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? const Icon(Icons.person, size: 28)
                    : null,
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.bio ?? user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    if (user.isOnline) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đang hoạt động',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              _buildActionButtons(user, status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(UserEntity user, FriendshipStatus status) {
    switch (status) {
      case FriendshipStatus.friends:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 16, color: AppTheme.success),
                  const SizedBox(width: 4),
                  Text(
                    'Bạn bè',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.message, color: AppTheme.primaryBlue),
              onPressed: () => _startChat(user),
              tooltip: 'Nhắn tin',
            ),
          ],
        );

      case FriendshipStatus.requestSent:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Đã gửi',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

      case FriendshipStatus.none:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => _sendFriendRequest(user.id, user.name),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Thêm bạn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        );
    }
  }
}

enum FriendshipStatus { none, requestSent, friends }

/// Simple debouncer for search
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
