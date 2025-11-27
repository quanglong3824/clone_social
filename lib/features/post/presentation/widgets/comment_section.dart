import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import '../../domain/entities/comment_entity.dart';
import '../providers/post_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';

/// A widget that displays comments with optimistic update support.
/// Shows comments immediately when submitted, with rollback on failure.
class CommentSection extends StatefulWidget {
  final String postId;
  final bool showInput;
  final int? maxComments;

  const CommentSection({
    super.key,
    required this.postId,
    this.showInput = true,
    this.maxComments,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  final _uuid = const Uuid();
  bool _isSubmitting = false;
  
  /// Local optimistic comments that haven't been confirmed by server yet
  final List<_OptimisticComment> _optimisticComments = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    // Create optimistic comment
    final optimisticId = _uuid.v4();
    final optimisticComment = _OptimisticComment(
      id: optimisticId,
      comment: CommentEntity(
        id: optimisticId,
        postId: widget.postId,
        userId: currentUser.id,
        userName: currentUser.name,
        userProfileImage: currentUser.profileImage,
        text: text,
        createdAt: DateTime.now(),
      ),
      status: _CommentStatus.sending,
    );

    // Add optimistic comment immediately
    setState(() {
      _optimisticComments.insert(0, optimisticComment);
      _commentController.clear();
      _isSubmitting = true;
    });

    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    try {
      await context.read<PostProvider>().addComment(
        widget.postId,
        currentUser.id,
        text,
      );

      // Mark as sent (will be replaced by server data on next stream update)
      if (mounted) {
        setState(() {
          final index = _optimisticComments.indexWhere((c) => c.id == optimisticId);
          if (index != -1) {
            _optimisticComments[index] = optimisticComment.copyWith(
              status: _CommentStatus.sent,
            );
          }
          _isSubmitting = false;
        });

        // Remove optimistic comment after a delay (server data should have arrived)
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _optimisticComments.removeWhere((c) => c.id == optimisticId);
            });
          }
        });
      }
    } catch (e) {
      // Rollback on error
      if (mounted) {
        setState(() {
          final index = _optimisticComments.indexWhere((c) => c.id == optimisticId);
          if (index != -1) {
            _optimisticComments[index] = optimisticComment.copyWith(
              status: _CommentStatus.failed,
            );
          }
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to post comment'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _retryComment(optimisticComment),
            ),
          ),
        );
      }
    }
  }

  Future<void> _retryComment(_OptimisticComment optimisticComment) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    setState(() {
      final index = _optimisticComments.indexWhere((c) => c.id == optimisticComment.id);
      if (index != -1) {
        _optimisticComments[index] = optimisticComment.copyWith(
          status: _CommentStatus.sending,
        );
      }
    });

    try {
      await context.read<PostProvider>().addComment(
        widget.postId,
        currentUser.id,
        optimisticComment.comment.text,
      );

      if (mounted) {
        setState(() {
          _optimisticComments.removeWhere((c) => c.id == optimisticComment.id);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final index = _optimisticComments.indexWhere((c) => c.id == optimisticComment.id);
          if (index != -1) {
            _optimisticComments[index] = optimisticComment.copyWith(
              status: _CommentStatus.failed,
            );
          }
        });
      }
    }
  }

  void _removeFailedComment(String id) {
    setState(() {
      _optimisticComments.removeWhere((c) => c.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCommentsList(),
        if (widget.showInput) _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<List<CommentEntity>>(
      stream: context.read<PostProvider>().getComments(widget.postId),
      builder: (context, snapshot) {
        final serverComments = snapshot.data ?? [];
        
        // Combine optimistic comments with server comments
        // Filter out optimistic comments that match server comments by text
        final filteredOptimistic = _optimisticComments.where((opt) {
          return !serverComments.any((server) =>
              server.text == opt.comment.text &&
              server.userId == opt.comment.userId);
        }).toList();

        final allComments = [
          ...filteredOptimistic.map((o) => _CommentWithStatus(
            comment: o.comment,
            status: o.status,
            optimisticId: o.id,
          )),
          ...serverComments.map((c) => _CommentWithStatus(
            comment: c,
            status: _CommentStatus.sent,
          )),
        ];

        // Apply max comments limit
        final displayComments = widget.maxComments != null
            ? allComments.take(widget.maxComments!).toList()
            : allComments;

        if (displayComments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No comments yet. Be the first to comment!',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayComments.length,
          itemBuilder: (context, index) {
            final item = displayComments[index];
            return _CommentItem(
              comment: item.comment,
              status: item.status,
              onRetry: item.optimisticId != null
                  ? () => _retryComment(_optimisticComments.firstWhere(
                      (c) => c.id == item.optimisticId))
                  : null,
              onRemove: item.optimisticId != null
                  ? () => _removeFailedComment(item.optimisticId!)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: AppTheme.primaryBlue),
              onPressed: _isSubmitting ? null : _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}

enum _CommentStatus { sending, sent, failed }

class _OptimisticComment {
  final String id;
  final CommentEntity comment;
  final _CommentStatus status;

  _OptimisticComment({
    required this.id,
    required this.comment,
    required this.status,
  });

  _OptimisticComment copyWith({
    String? id,
    CommentEntity? comment,
    _CommentStatus? status,
  }) {
    return _OptimisticComment(
      id: id ?? this.id,
      comment: comment ?? this.comment,
      status: status ?? this.status,
    );
  }
}

class _CommentWithStatus {
  final CommentEntity comment;
  final _CommentStatus status;
  final String? optimisticId;

  _CommentWithStatus({
    required this.comment,
    required this.status,
    this.optimisticId,
  });
}

class _CommentItem extends StatelessWidget {
  final CommentEntity comment;
  final _CommentStatus status;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  const _CommentItem({
    required this.comment,
    required this.status,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isFailed = status == _CommentStatus.failed;
    final isSending = status == _CommentStatus.sending;

    return Opacity(
      opacity: isSending ? 0.6 : 1.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: comment.userProfileImage != null
              ? NetworkImage(comment.userProfileImage!)
              : null,
          radius: 16,
          child: comment.userProfileImage == null
              ? const Icon(Icons.person, size: 20)
              : null,
        ),
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isFailed ? Colors.red[50] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: isFailed ? Border.all(color: Colors.red[200]!) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(comment.text),
              if (isFailed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onRemove,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Remove',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
          child: Row(
            children: [
              Text(
                isSending ? 'Sending...' : timeago.format(comment.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
              if (isFailed) ...[
                const SizedBox(width: 8),
                Icon(Icons.error_outline, size: 14, color: Colors.red[400]),
                const SizedBox(width: 4),
                Text(
                  'Failed',
                  style: TextStyle(color: Colors.red[400], fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
