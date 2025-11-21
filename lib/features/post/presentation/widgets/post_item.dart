import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/post_entity.dart';
import 'package:clone_social/features/post/presentation/providers/post_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/themes/app_theme.dart';

class PostItem extends StatelessWidget {
  final PostEntity post;

  const PostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final isLiked = currentUser != null && post.isLikedBy(currentUser.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: GestureDetector(
              onTap: () => context.push('/profile/${post.userId}'),
              child: CircleAvatar(
                backgroundImage: post.userProfileImage != null
                    ? NetworkImage(post.userProfileImage!)
                    : null,
                child: post.userProfileImage == null
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            title: GestureDetector(
              onTap: () => context.push('/profile/${post.userId}'),
              child: Text(
                post.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              timeago.format(post.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),

          // Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(post.content),
            ),

          // Images
          if (post.images.isNotEmpty)
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                post.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.error)),
              ),
            ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.thumb_up, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Text('${post.likeCount}'),
                const Spacer(),
                Text('${post.commentCount} comments'),
                const SizedBox(width: 8),
                Text('${post.shareCount} shares'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    if (currentUser == null) return;
                    if (isLiked) {
                      context.read<PostProvider>().unlikePost(post.id, currentUser.id);
                    } else {
                      context.read<PostProvider>().likePost(post.id, currentUser.id);
                    }
                  },
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? AppTheme.primaryBlue : Colors.grey[600],
                  ),
                  label: Text(
                    'Like',
                    style: TextStyle(
                      color: isLiked ? AppTheme.primaryBlue : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    context.push('/post/${post.id}');
                  },
                  icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
                  label: Text(
                    'Comment',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Implement share
                  },
                  icon: Icon(Icons.share_outlined, color: Colors.grey[600]),
                  label: Text(
                    'Share',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
