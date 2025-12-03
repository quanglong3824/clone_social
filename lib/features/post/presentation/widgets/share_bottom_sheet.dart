import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/features/post/presentation/providers/post_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';

/// Share options available in the bottom sheet
enum ShareOption {
  shareToFeed,
  shareToStory,
  copyLink,
  more;

  String get label {
    switch (this) {
      case ShareOption.shareToFeed:
        return 'Share to Feed';
      case ShareOption.shareToStory:
        return 'Share to Story';
      case ShareOption.copyLink:
        return 'Copy Link';
      case ShareOption.more:
        return 'More Options';
    }
  }

  IconData get icon {
    switch (this) {
      case ShareOption.shareToFeed:
        return Icons.dynamic_feed;
      case ShareOption.shareToStory:
        return Icons.amp_stories;
      case ShareOption.copyLink:
        return Icons.link;
      case ShareOption.more:
        return Icons.more_horiz;
    }
  }
}

/// A bottom sheet widget for sharing posts
class ShareBottomSheet extends StatelessWidget {
  final String postId;
  final String? postUrl;
  final void Function(ShareOption option)? onOptionSelected;

  const ShareBottomSheet({
    super.key,
    required this.postId,
    this.postUrl,
    this.onOptionSelected,
  });

  /// Shows the share bottom sheet and returns the selected option
  static Future<ShareOption?> show(
    BuildContext context, {
    required String postId,
    String? postUrl,
  }) {
    return showModalBottomSheet<ShareOption>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(
        postId: postId,
        postUrl: postUrl,
        onOptionSelected: (option) => Navigator.of(context).pop(option),
      ),
    );
  }

  void _handleOptionTap(BuildContext context, ShareOption option) {
    if (option == ShareOption.copyLink) {
      _copyLink(context);
      onOptionSelected?.call(option);
    } else if (option == ShareOption.shareToFeed) {
      // Get providers before closing bottom sheet
      final postProvider = context.read<PostProvider>();
      final authProvider = context.read<AuthProvider>();
      Navigator.of(context).pop();
      _showShareToFeedDialog(context, postProvider, authProvider);
    } else {
      onOptionSelected?.call(option);
    }
  }

  void _showShareToFeedDialog(BuildContext context, PostProvider postProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => _ShareToFeedDialog(
        postId: postId,
        postProvider: postProvider,
        authProvider: authProvider,
      ),
    );
  }

  void _copyLink(BuildContext context) {
    final link = postUrl ?? 'https://app.example.com/post/$postId';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Share Post',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            // Options
            ...ShareOption.values.map((option) => _ShareOptionTile(
              option: option,
              onTap: () => _handleOptionTap(context, option),
            )),
            const SizedBox(height: 8),
            // Cancel button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  final ShareOption option;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          option.icon,
          color: AppTheme.primaryBlue,
        ),
      ),
      title: Text(
        option.label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}


/// Dialog for sharing post to feed with optional text
class _ShareToFeedDialog extends StatefulWidget {
  final String postId;
  final PostProvider postProvider;
  final AuthProvider authProvider;

  const _ShareToFeedDialog({
    required this.postId,
    required this.postProvider,
    required this.authProvider,
  });

  @override
  State<_ShareToFeedDialog> createState() => _ShareToFeedDialogState();
}

class _ShareToFeedDialogState extends State<_ShareToFeedDialog> {
  final _controller = TextEditingController();
  bool _isSharing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final currentUser = widget.authProvider.currentUser;
    if (currentUser == null) return;

    setState(() => _isSharing = true);

    try {
      final success = await widget.postProvider.sharePostToFeed(
        widget.postId,
        currentUser.id,
        text: _controller.text.trim().isEmpty ? null : _controller.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã chia sẻ bài viết' : 'Không thể chia sẻ'),
            backgroundColor: success ? AppTheme.success : AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSharing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chia sẻ lên bảng tin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Viết gì đó về bài viết này...',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isSharing ? null : _share,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
          ),
          child: _isSharing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Chia sẻ'),
        ),
      ],
    );
  }
}
