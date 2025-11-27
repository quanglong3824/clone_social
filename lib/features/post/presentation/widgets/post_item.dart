import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/post_entity.dart';
import 'package:clone_social/features/post/presentation/providers/post_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/themes/app_theme.dart';
import 'post_image_grid.dart';
import 'reaction_picker.dart';
import 'share_bottom_sheet.dart';

class PostItem extends StatelessWidget {
  final PostEntity post;
  final bool showFullContent;

  const PostItem({
    super.key,
    required this.post,
    this.showFullContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final currentReaction = currentUser != null
        ? post.getReactionBy(currentUser.id)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildContent(context),
          if (post.images.isNotEmpty) _buildImages(context),
          _buildStats(context),
          const Divider(height: 1),
          _buildActions(context, currentUser?.id, currentReaction),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        onPressed: () => _showPostOptions(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (post.content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        post.content,
        maxLines: showFullContent ? null : 5,
        overflow: showFullContent ? null : TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImages(BuildContext context) {
    return PostImageGrid(
      images: post.images,
      height: 300,
      onImageTap: (index) {
        // Navigate to image viewer or post detail
        context.push('/post/${post.id}');
      },
    );
  }

  Widget _buildStats(BuildContext context) {
    final topReactions = post.topReactions;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Reaction icons
          if (topReactions.isNotEmpty) ...[
            Row(
              children: [
                ...topReactions.take(3).map((reaction) => Container(
                  margin: const EdgeInsets.only(right: 2),
                  child: Text(
                    reaction.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                )),
                const SizedBox(width: 4),
                Text(
                  '${post.reactionCount}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.thumb_up, size: 10, color: Colors.white),
            ),
            const SizedBox(width: 4),
            Text(
              '${post.reactionCount}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          const Spacer(),
          Text(
            '${post.commentCount} comments',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Text(
            '${post.shareCount} shares',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    String? currentUserId,
    ReactionType? currentReaction,
  ) {
    return Row(
      children: [
        // Like/Reaction button with long press picker
        Expanded(
          child: ReactionButton(
            currentReaction: currentReaction,
            onReactionChanged: (reaction) {
              if (currentUserId == null) return;
              if (reaction == null) {
                context.read<PostProvider>().removeReaction(post.id, currentUserId);
              } else {
                context.read<PostProvider>().addReaction(post.id, currentUserId, reaction);
              }
            },
            child: _ActionButton(
              icon: currentReaction != null
                  ? Text(currentReaction.emoji, style: const TextStyle(fontSize: 20))
                  : Icon(Icons.thumb_up_outlined, color: Colors.grey[600]),
              label: currentReaction?.label ?? 'Like',
              isActive: currentReaction != null,
            ),
          ),
        ),
        // Comment button
        Expanded(
          child: InkWell(
            onTap: () => context.push('/post/${post.id}'),
            child: _ActionButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
              label: 'Comment',
              isActive: false,
            ),
          ),
        ),
        // Share button
        Expanded(
          child: InkWell(
            onTap: () => _showShareSheet(context),
            child: _ActionButton(
              icon: Icon(Icons.share_outlined, color: Colors.grey[600]),
              label: 'Share',
              isActive: false,
            ),
          ),
        ),
      ],
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Save Post'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('Turn off notifications'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report Post'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showShareSheet(BuildContext context) async {
    final option = await ShareBottomSheet.show(
      context,
      postId: post.id,
    );

    if (option != null && context.mounted) {
      switch (option) {
        case ShareOption.shareToFeed:
          // TODO: Implement share to feed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Share to Feed coming soon')),
          );
          break;
        case ShareOption.shareToStory:
          // TODO: Implement share to story
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Share to Story coming soon')),
          );
          break;
        case ShareOption.copyLink:
          // Already handled in ShareBottomSheet
          break;
        case ShareOption.more:
          // TODO: Implement native share
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('More options coming soon')),
          );
          break;
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryBlue : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
