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
  List<UserEntity> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    
    final results = await context.read<FriendProvider>().searchUsers(query);
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _sendFriendRequest(BuildContext context, UserEntity currentUser, String toUserId, String toUserName) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Sending friend request...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await context.read<FriendProvider>().sendFriendRequest(
        currentUser.id,
        toUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend request sent to $toUserName!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('Error sending friend request: $e');
    }
  }

  Future<void> _startChat(BuildContext context, UserEntity currentUser, String otherUserId) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating chat...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      print('Creating chat between ${currentUser.id} and $otherUserId');
      
      // Create or get existing chat
      final chatId = await context.read<ChatProvider>().createChat(
        currentUser.id,
        otherUserId,
      );

      print('Chat created/found: $chatId');

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        if (chatId != null && chatId.isNotEmpty) {
          // Navigate to chat
          print('Navigating to chat: $chatId');
          context.push('/chat/$chatId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create chat. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error creating chat: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            // Debounce could be added here
            if (value.length > 2) _search(value);
          },
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                if (user.id == currentUser?.id) return const SizedBox.shrink();

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
                  subtitle: Text(user.email),
                  trailing: currentUser?.id == user.id 
                    ? const Chip(
                        label: Text('You', style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey,
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.message, color: AppTheme.primaryBlue),
                            onPressed: () => _startChat(context, currentUser!, user.id),
                            tooltip: 'Send message',
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_add, color: AppTheme.primaryBlue),
                            onPressed: () => _sendFriendRequest(context, currentUser!, user.id, user.name),
                            tooltip: 'Add friend',
                          ),
                        ],
                      ),
                  onTap: () => context.push('/profile/${user.id}'),
                );
              },
            ),
    );
  }
}
