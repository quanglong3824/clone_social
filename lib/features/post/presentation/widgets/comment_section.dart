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

        // Filter to show only top-level comments (not replies)
        final topLevelComments = displayComments.where((c) => !c.comment.isReply).toList();

        if (topLevelComments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chưa có bình luận. Hãy là người đầu tiên bình luận!',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topLevelComments.length,
          itemBuilder: (context, index) {
            final item = topLevelComments[index];
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
              onReply: (comment) => _showReplyInput(comment),
            );
          },
        );
      },
    );
  }

  void _showReplyInput(CommentEntity parentComment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _ReplyInput(
          postId: widget.postId,
          parentComment: parentComment,
          onSubmitted: () => Navigator.pop(ctx),
        ),
      ),
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

class _CommentItem extends StatefulWidget {
  final CommentEntity comment;
  final _CommentStatus status;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;
  final void Function(CommentEntity comment)? onReply;

  const _CommentItem({
    required this.comment,
    required this.status,
    this.onRetry,
    this.onRemove,
    this.onReply,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final isFailed = widget.status == _CommentStatus.failed;
    final isSending = widget.status == _CommentStatus.sending;
    final currentUser = context.read<AuthProvider>().currentUser;
    final isLiked = currentUser != null && widget.comment.isLikedBy(currentUser.id);

    return Opacity(
      opacity: isSending ? 0.6 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: widget.comment.isReply ? 48.0 : 8.0,
              right: 8.0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: widget.comment.userProfileImage != null
                      ? NetworkImage(widget.comment.userProfileImage!)
                      : null,
                  radius: widget.comment.isReply ? 14 : 18,
                  backgroundColor: Colors.grey[300],
                  child: widget.comment.userProfileImage == null
                      ? Icon(Icons.person, size: widget.comment.isReply ? 16 : 20, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFailed ? Colors.red[50] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: isFailed ? Border.all(color: Colors.red[200]!) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.comment.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(widget.comment.text, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      // Actions row
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Row(
                          children: [
                            Text(
                              isSending ? 'Đang gửi...' : timeago.format(widget.comment.createdAt),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            // Like button
                            GestureDetector(
                              onTap: () => _toggleLike(context, currentUser?.id),
                              child: Text(
                                'Thích',
                                style: TextStyle(
                                  color: isLiked ? AppTheme.primaryBlue : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: isLiked ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (widget.comment.likeCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${widget.comment.likeCount}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                            const SizedBox(width: 16),
                            // Reply button
                            if (!widget.comment.isReply)
                              GestureDetector(
                                onTap: () => widget.onReply?.call(widget.comment),
                                child: Text(
                                  'Trả lời',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (isFailed) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.error_outline, size: 14, color: Colors.red[400]),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: widget.onRetry,
                                child: Text(
                                  'Thử lại',
                                  style: TextStyle(color: Colors.red[400], fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // View replies button
                      if (!widget.comment.isReply && widget.comment.replyCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _showReplies = !_showReplies),
                            child: Row(
                              children: [
                                Icon(
                                  _showReplies ? Icons.subdirectory_arrow_right : Icons.subdirectory_arrow_right,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _showReplies 
                                      ? 'Ẩn phản hồi' 
                                      : 'Xem ${widget.comment.replyCount} phản hồi',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Replies
          if (_showReplies && !widget.comment.isReply)
            _CommentReplies(
              postId: widget.comment.postId,
              commentId: widget.comment.id,
            ),
        ],
      ),
    );
  }

  void _toggleLike(BuildContext context, String? userId) {
    if (userId == null) return;
    
    final postProvider = context.read<PostProvider>();
    if (widget.comment.isLikedBy(userId)) {
      postProvider.unlikeComment(widget.comment.postId, widget.comment.id, userId);
    } else {
      postProvider.likeComment(widget.comment.postId, widget.comment.id, userId);
    }
  }
}

/// Widget to display replies for a comment
class _CommentReplies extends StatelessWidget {
  final String postId;
  final String commentId;

  const _CommentReplies({
    required this.postId,
    required this.commentId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommentEntity>>(
      stream: context.read<PostProvider>().getCommentReplies(postId, commentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: snapshot.data!.map((reply) => _CommentItem(
            comment: reply,
            status: _CommentStatus.sent,
          )).toList(),
        );
      },
    );
  }
}

/// Widget for replying to a comment
class _ReplyInput extends StatefulWidget {
  final String postId;
  final CommentEntity parentComment;
  final VoidCallback onSubmitted;

  const _ReplyInput({
    required this.postId,
    required this.parentComment,
    required this.onSubmitted,
  });

  @override
  State<_ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<_ReplyInput> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<PostProvider>().replyToComment(
        widget.postId,
        widget.parentComment.id,
        currentUser.id,
        text,
      );
      widget.onSubmitted();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.reply, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Trả lời ${widget.parentComment.userName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Viết phản hồi...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
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
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
