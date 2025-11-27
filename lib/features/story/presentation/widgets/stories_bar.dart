import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/features/story/presentation/providers/story_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';

/// A horizontal scrollable bar displaying user stories.
/// Shows user avatars with gradient rings for unviewed stories.
class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        final currentUser = context.read<AuthProvider>().currentUser;
        final storiesByUser = storyProvider.storiesByUser;
        
        if (storyProvider.isLoading && storiesByUser.isEmpty) {
          return const _StoriesBarShimmer();
        }

        return Container(
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: storiesByUser.length + 1, // +1 for "Add Story" button
            itemBuilder: (context, index) {
              if (index == 0) {
                // Add Story button
                return _AddStoryItem(
                  userProfileImage: currentUser?.profileImage,
                  onTap: () => context.push('/create-story'),
                );
              }

              final userId = storiesByUser.keys.elementAt(index - 1);
              final userStories = storiesByUser[userId]!;
              final firstStory = userStories.first;
              final hasUnviewed = currentUser != null &&
                  storyProvider.hasUnviewedStories(userId, currentUser.id);

              return _StoryItem(
                userName: firstStory.userName,
                userProfileImage: firstStory.userProfileImage,
                hasUnviewedStories: hasUnviewed,
                onTap: () => context.push('/story-viewer/$userId'),
              );
            },
          ),
        );
      },
    );
  }
}


/// Widget for adding a new story
class _AddStoryItem extends StatelessWidget {
  final String? userProfileImage;
  final VoidCallback onTap;

  const _AddStoryItem({
    this.userProfileImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: userProfileImage != null
                        ? NetworkImage(userProfileImage!)
                        : null,
                    child: userProfileImage == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Your Story',
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying a user's story avatar
class _StoryItem extends StatelessWidget {
  final String userName;
  final String? userProfileImage;
  final bool hasUnviewedStories;
  final VoidCallback onTap;

  const _StoryItem({
    required this.userName,
    this.userProfileImage,
    required this.hasUnviewedStories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnviewedStories
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF833AB4), // Purple
                          Color(0xFFF77737), // Orange
                          Color(0xFFE1306C), // Pink
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: hasUnviewedStories
                    ? null
                    : Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: userProfileImage != null
                      ? NetworkImage(userProfileImage!)
                      : null,
                  child: userProfileImage == null
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder for stories bar
class _StoriesBarShimmer extends StatelessWidget {
  const _StoriesBarShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 72,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
