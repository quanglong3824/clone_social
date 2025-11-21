import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../../../../core/themes/app_theme.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    final success = await context.read<PostProvider>().createPost(
      _contentController.text.trim(),
      // TODO: Add image/video support
    );

    if (mounted) {
      setState(() {
        _isPosting = false;
      });
      
      if (success) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isPosting || _contentController.text.trim().isEmpty
                ? null
                : _createPost,
            child: const Text(
              'POST',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const Divider(),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.green),
                  onPressed: () {
                    // TODO: Implement image picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image picker coming soon')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.video_library, color: Colors.red),
                  onPressed: () {
                    // TODO: Implement video picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video picker coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
