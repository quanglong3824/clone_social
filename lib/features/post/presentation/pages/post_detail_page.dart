import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/features/post/domain/entities/post_entity.dart';
import 'package:clone_social/features/post/presentation/providers/post_provider.dart';
import 'package:clone_social/features/post/presentation/widgets/post_item.dart';
import 'package:clone_social/features/post/presentation/widgets/comment_section.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';

class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    
    // Find the post in the provider's list
    PostEntity? post;
    try {
      post = postProvider.posts.firstWhere((p) => p.id == postId);
    } catch (e) {
      // Post might not be loaded yet or deleted
      post = null;
    }

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: Text('Post not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PostItem(post: post, showFullContent: true),
                  const Divider(),
                  _CommentsListOnly(postId: postId),
                ],
              ),
            ),
          ),
          _CommentInputOnly(postId: postId),
        ],
      ),
    );
  }
}

/// Widget that only shows the comments list without input
class _CommentsListOnly extends StatelessWidget {
  final String postId;

  const _CommentsListOnly({required this.postId});

  @override
  Widget build(BuildContext context) {
    return CommentSection(
      postId: postId,
      showInput: false,
    );
  }
}

/// Widget that only shows the comment input
class _CommentInputOnly extends StatelessWidget {
  final String postId;

  const _CommentInputOnly({required this.postId});

  @override
  Widget build(BuildContext context) {
    // We need a separate stateful widget for just the input
    return _CommentInput(postId: postId);
  }
}

class _CommentInput extends StatefulWidget {
  final String postId;

  const _CommentInput({required this.postId});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
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

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<PostProvider>().addComment(
        widget.postId,
        currentUser.id,
        text,
      );
      _controller.clear();
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _controller,
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
                onSubmitted: (_) => _submit(),
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
                  : Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
