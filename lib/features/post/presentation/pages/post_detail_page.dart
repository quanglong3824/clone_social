import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:clone_social/features/post/domain/entities/post_entity.dart';
import 'package:clone_social/features/post/domain/entities/comment_entity.dart';
import 'package:clone_social/features/post/presentation/providers/post_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/features/post/presentation/widgets/post_item.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    setState(() {
      _isSubmitting = true;
    });

    await context.read<PostProvider>().addComment(
      widget.postId,
      currentUser.id,
      _commentController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _commentController.clear();
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    
    // Find the post in the provider's list
    PostEntity? post;
    try {
      post = postProvider.posts.firstWhere((p) => p.id == widget.postId);
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
                  PostItem(post: post),
                  const Divider(),
                  _buildCommentsList(post),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsList(PostEntity post) {
    // Note: In a real app, we would fetch comments separately or have them in the post entity
    // For this implementation, we'll assume we need to fetch them or they are not yet implemented in the entity fully
    // The current PostEntity doesn't have a list of CommentEntities, just a count.
    // We need to update PostRepository to fetch comments or listen to them.
    // For now, let's assume we'll add a stream listener for comments here or in the provider.
    
    // Since we haven't implemented fetching comments in the provider yet, 
    // we'll show a placeholder or implement a simple stream builder here.
    
    return StreamBuilder(
      stream: context.read<PostProvider>().getComments(post.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No comments yet. Be the first to comment!'),
          );
        }

        final comments = snapshot.data as List<CommentEntity>;
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: comment.userProfileImage != null
                    ? NetworkImage(comment.userProfileImage!)
                    : null,
                child: comment.userProfileImage == null
                    ? const Icon(Icons.person, size: 20)
                    : null,
                radius: 16,
              ),
              title: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(comment.text),
                  ],
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Text(
                  timeago.format(comment.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ),
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
        color: Colors.white,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                minLines: 1,
                maxLines: 5,
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
