import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clone_social/features/profile/presentation/providers/profile_provider.dart';
import 'package:clone_social/features/profile/domain/repositories/profile_repository.dart';
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

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthProvider>().currentUser;
      context.read<ProfileProvider>().loadUserProfile(
        widget.userId,
        currentUserId: currentUser?.id,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.userProfile;
    if (currentUser == null || user == null) return;

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
          context.push(
            '/chat/$chatId',
            extra: {
              'otherUserName': user.name,
              'otherUserImage': user.profileImage,
              'otherUserId': user.id,
            },
          );
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
                  // Action buttons based on relationship
                  _buildActionButtons(context, isMe, profileProvider),
                  
                  // Mutual friends (if not own profile)
                  if (!isMe && profileProvider.mutualFriends.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.people, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${profileProvider.mutualFriends.length} mutual friends',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  
                  const Divider(height: 32),
                  _buildStats(profileProvider),
                  const SizedBox(height: 16),
                  
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryBlue,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                      Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
                      Tab(icon: Icon(Icons.people), text: 'Friends'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Posts Tab
                _buildPostsTab(profileProvider),
                // Photos Tab
                _buildPhotosTab(profileProvider),
                // Friends Tab
                _buildFriendsTab(profileProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isMe, ProfileProvider profileProvider) {
    final currentUser = context.read<AuthProvider>().currentUser;
    
    if (isMe) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showProfileOptions(context, isMe),
            icon: const Icon(Icons.more_horiz),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[200],
            ),
          ),
        ],
      );
    }

    // For other users, show buttons based on friend status
    return Row(
      children: [
        Expanded(
          child: _buildFriendButton(context, profileProvider.friendStatus, currentUser?.id),
        ),
        const SizedBox(width: 8),
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
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showProfileOptions(context, isMe),
          icon: const Icon(Icons.more_horiz),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendButton(BuildContext context, FriendStatus status, String? currentUserId) {
    switch (status) {
      case FriendStatus.friends:
        return ElevatedButton.icon(
          onPressed: () => _showUnfriendDialog(context, currentUserId),
          icon: const Icon(Icons.check),
          label: const Text('Friends'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
          ),
        );
      case FriendStatus.requestSent:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.hourglass_empty),
          label: const Text('Request Sent'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.grey,
          ),
        );
      case FriendStatus.requestReceived:
        return ElevatedButton.icon(
          onPressed: () => context.push('/friends'),
          icon: const Icon(Icons.person_add),
          label: const Text('Respond'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
      case FriendStatus.none:
      default:
        return ElevatedButton.icon(
          onPressed: () => _sendFriendRequest(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Add Friend'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
    }
  }

  Future<void> _showUnfriendDialog(BuildContext context, String? currentUserId) async {
    if (currentUserId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unfriend'),
        content: Text('Are you sure you want to unfriend ${context.read<ProfileProvider>().userProfile?.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unfriend'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<ProfileProvider>().unfriend(currentUserId, widget.userId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfriended successfully')),
        );
      }
    }
  }

  void _showProfileOptions(BuildContext context, bool isMe) {
    final currentUser = context.read<AuthProvider>().currentUser;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Privacy'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to privacy settings
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Block', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  if (currentUser != null) {
                    final confirmed = await showDialog<bool>(
                      context: this.context,
                      builder: (context) => AlertDialog(
                        title: const Text('Block User'),
                        content: const Text('Are you sure you want to block this user? They won\'t be able to see your profile or message you.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Block'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && mounted) {
                      await this.context.read<ProfileProvider>().blockUser(currentUser.id, widget.userId);
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(content: Text('User blocked')),
                        );
                        this.context.pop();
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Report feature coming soon')),
                  );
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(ProfileProvider provider) {
    if (provider.userPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No posts yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: provider.userPosts.length,
      itemBuilder: (context, index) {
        final post = provider.userPosts[index];
        return PostItem(post: post);
      },
    );
  }

  Widget _buildPhotosTab(ProfileProvider provider) {
    if (provider.userPhotos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No photos yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: provider.userPhotos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // TODO: Open photo viewer
          },
          child: Image.network(
            provider.userPhotos[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendsTab(ProfileProvider provider) {
    if (provider.friendsWithProfile.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No friends yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: provider.friendsWithProfile.length,
      itemBuilder: (context, index) {
        final friend = provider.friendsWithProfile[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: friend.profileImage != null
                ? NetworkImage(friend.profileImage!)
                : null,
            child: friend.profileImage == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(friend.name),
          subtitle: friend.bio != null ? Text(friend.bio!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
          onTap: () => context.push('/profile/${friend.id}'),
        );
      },
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
