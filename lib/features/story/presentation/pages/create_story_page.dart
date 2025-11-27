import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/features/story/presentation/providers/story_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/core/widgets/app_button.dart';

/// Page for creating a new story with image or video.
/// Allows selecting media from gallery or camera, preview, and confirm.
class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedMedia;
  String _mediaType = 'image';
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedMedia = File(image.path);
          _mediaType = 'image';
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 30),
      );
      
      if (video != null) {
        setState(() {
          _selectedMedia = File(video.path);
          _mediaType = 'video';
        });
      }
    } catch (e) {
      _showError('Failed to pick video: $e');
    }
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMediaSourceDialog({required bool isVideo}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(isVideo ? 'Record Video' : 'Take Photo'),
              onTap: () {
                Navigator.pop(context);
                if (isVideo) {
                  _pickVideo(ImageSource.camera);
                } else {
                  _pickImage(ImageSource.camera);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(isVideo ? 'Choose from Gallery' : 'Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                if (isVideo) {
                  _pickVideo(ImageSource.gallery);
                } else {
                  _pickImage(ImageSource.gallery);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadStory() async {
    if (_selectedMedia == null) return;
    
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      _showError('Please login to create a story');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final success = await context.read<StoryProvider>().createStory(
        currentUser.id,
        _selectedMedia!,
        _mediaType,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        _showError('Failed to create story');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedMedia = null;
      _mediaType = 'image';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Create Story'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_selectedMedia != null)
            TextButton(
              onPressed: _isUploading ? null : _uploadStory,
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: _selectedMedia == null
          ? _buildMediaPicker()
          : _buildPreview(),
    );
  }

  Widget _buildMediaPicker() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 24),
          const Text(
            'Create a Story',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share a photo or video that disappears after 24 hours',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MediaOptionButton(
                icon: Icons.photo,
                label: 'Photo',
                onTap: () => _showMediaSourceDialog(isVideo: false),
              ),
              const SizedBox(width: 24),
              _MediaOptionButton(
                icon: Icons.videocam,
                label: 'Video',
                onTap: () => _showMediaSourceDialog(isVideo: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Stack(
      children: [
        // Media preview
        Center(
          child: _mediaType == 'video'
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Video selected',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                )
              : Image.file(
                  _selectedMedia!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        
        // Clear button
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            onPressed: _clearSelection,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        
        // Upload progress overlay
        if (_isUploading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Uploading story...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Button for selecting media type (photo/video)
class _MediaOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
