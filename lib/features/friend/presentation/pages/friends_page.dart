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
      length: 2,
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
              Tab(text: 'Your Friends'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
                                    context.push('/chat/$chatId');
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
            friendProvider.friendRequests.isEmpty
                ? const Center(child: Text('No friend requests'))
                : ListView.builder(
                    itemCount: friendProvider.friendRequests.length,
                    itemBuilder: (context, index) {
                      final request = friendProvider.friendRequests[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: request.fromUserProfileImage != null
                              ? NetworkImage(request.fromUserProfileImage!)
                              : null,
                          child: request.fromUserProfileImage == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(request.fromUserName),
                        subtitle: const Text('Sent you a friend request'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.read<FriendProvider>().acceptFriendRequest(
                                      currentUser.id,
                                      request.id,
                                      request.fromUserId,
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text('Confirm', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {
                                context.read<FriendProvider>().rejectFriendRequest(
                                      currentUser.id,
                                      request.id,
                                    );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text('Delete', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
