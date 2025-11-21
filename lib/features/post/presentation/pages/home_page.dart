import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../providers/post_provider.dart';
import '../widgets/post_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'facebook',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => context.push('/chat'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh posts logic if needed (provider listens to stream so auto-updates)
        },
        child: CustomScrollView(
          slivers: [
            // Create Post Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                color: Theme.of(context).cardColor,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (user != null) {
                          context.push('/profile/${user.id}');
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage: user?.profileImage != null
                            ? NetworkImage(user!.profileImage!)
                            : null,
                        child: user?.profileImage == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/create-post'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "What's on your mind?",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.green),
                      onPressed: () => context.push('/create-post'),
                    ),
                  ],
                ),
              ),
            ),
            
            // Feed
            if (postProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (postProvider.posts.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No posts yet')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = postProvider.posts[index];
                    return PostItem(post: post);
                  },
                  childCount: postProvider.posts.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
