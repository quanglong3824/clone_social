import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clone_social/core/themes/app_theme.dart';

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
    }
    onOptionSelected?.call(option);
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
