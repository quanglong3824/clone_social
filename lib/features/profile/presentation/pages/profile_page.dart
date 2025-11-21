import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clone_social/features/profile/presentation/providers/profile_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/features/friend/presentation/providers/friend_provider.dart';
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/features/post/presentation/widgets/post_item.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile(widget.userId);
    });
  }

  Future<void> _sendFriendRequest(BuildContext context) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    try {
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
        widget.userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend request sent!'),
            backgroundColor: Colors.green,
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
          ),
        );
      }
    }
  }

  Future<void> _startChat(BuildContext context) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

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
      final chatId = await context.read<ChatProvider>().createChat(
        currentUser.id,
        widget.userId,
      );

      if (mounted) {
        Navigator.of(context).pop();

        if (chatId != null && chatId.isNotEmpty) {
          context.push('/chat/$chatId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create chat'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;
    final isMe = currentUser?.id == widget.userId;
    final user = profileProvider.userProfile;

    if (profileProvider.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: user.coverImage != null
                  ? Image.network(user.coverImage!, fit: BoxFit.cover)
                  : Container(color: Colors.grey),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.bio != null)
                              Text(
                                user.bio!,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: isMe
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/edit-profile');
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () => _sendFriendRequest(context),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Add Friend'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      if (!isMe)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _startChat(context),
                            icon: const Icon(Icons.message),
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildStats(profileProvider),
                  const Divider(height: 32),
                  const Text(
                    'Posts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = profileProvider.userPosts[index];
                return PostItem(post: post);
              },
              childCount: profileProvider.userPosts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ProfileProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Posts', provider.userPosts.length.toString()),
        _buildStatItem('Friends', provider.userFriends.length.toString()),
        _buildStatItem('Photos', provider.userPhotos.length.toString()),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
