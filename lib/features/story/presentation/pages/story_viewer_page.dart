import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/features/story/domain/entities/story_entity.dart';
import 'package:clone_social/features/story/presentation/providers/story_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Fullscreen story viewer page with progress bar and auto-advance.
/// Supports tap to pause, swipe to navigate between stories.
class StoryViewerPage extends StatefulWidget {
  final String userId;

  const StoryViewerPage({super.key, required this.userId});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  
  int _currentIndex = 0;
  bool _isPaused = false;
  List<StoryEntity> _stories = [];

  /// Duration for each story (5 seconds)
  static const Duration storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: storyDuration,
    );
    
    _progressController.addStatusListener(_onProgressComplete);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStories();
    });
  }

  void _loadStories() {
    final storyProvider = context.read<StoryProvider>();
    _stories = storyProvider.getStoriesForUser(widget.userId);
    
    if (_stories.isNotEmpty) {
      _markCurrentStoryAsViewed();
      _progressController.forward();
    }
  }


  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goToNextStory();
    }
  }

  void _markCurrentStoryAsViewed() {
    if (_stories.isEmpty) return;
    
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;
    
    final currentStory = _stories[_currentIndex];
    context.read<StoryProvider>().markAsViewed(currentStory.id, currentUser.id);
  }

  void _goToNextStory() {
    if (_currentIndex < _stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
      _markCurrentStoryAsViewed();
    } else {
      // End of stories, go back
      context.pop();
    }
  }

  void _goToPreviousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
      _markCurrentStoryAsViewed();
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPaused = true;
    });
    _progressController.stop();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPaused = false;
    });
    _progressController.forward();
  }

  void _onTapCancel() {
    setState(() {
      _isPaused = false;
    });
    _progressController.forward();
  }

  void _onTap(TapUpDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition.dx;
    
    if (tapPosition < screenWidth / 3) {
      // Tap on left third - go to previous
      _goToPreviousStory();
    } else if (tapPosition > screenWidth * 2 / 3) {
      // Tap on right third - go to next
      _goToNextStory();
    }
    // Tap in middle - just resume (handled by onTapUp)
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No stories available',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: (details) {
          _onTapUp(details);
          _onTap(details);
        },
        onTapCancel: _onTapCancel,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          
          if (details.primaryVelocity! < -100) {
            // Swipe left - next story
            _goToNextStory();
          } else if (details.primaryVelocity! > 100) {
            // Swipe right - previous story
            _goToPreviousStory();
          }
        },
        child: Stack(
          children: [
            // Story content
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                final story = _stories[index];
                return _StoryContent(story: story);
              },
            ),
            
            // Progress bars and header
            SafeArea(
              child: Column(
                children: [
                  // Progress bars
                  _ProgressBars(
                    count: _stories.length,
                    currentIndex: _currentIndex,
                    progressController: _progressController,
                  ),
                  
                  // Header with user info
                  _StoryHeader(
                    story: _stories[_currentIndex],
                    onClose: () => context.pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Progress bars at the top of the story viewer
class _ProgressBars extends StatelessWidget {
  final int count;
  final int currentIndex;
  final AnimationController progressController;

  const _ProgressBars({
    required this.count,
    required this.currentIndex,
    required this.progressController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(count, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: index < currentIndex
                    ? Container(color: Colors.white)
                    : index == currentIndex
                        ? AnimatedBuilder(
                            animation: progressController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: progressController.value,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.3),
                          ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Header showing user info and close button
class _StoryHeader extends StatelessWidget {
  final StoryEntity story;
  final VoidCallback onClose;

  const _StoryHeader({
    required this.story,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: story.userProfileImage != null
                ? NetworkImage(story.userProfileImage!)
                : null,
            child: story.userProfileImage == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  timeago.format(story.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

/// Story content (image or video)
class _StoryContent extends StatelessWidget {
  final StoryEntity story;

  const _StoryContent({required this.story});

  @override
  Widget build(BuildContext context) {
    if (story.mediaType == 'video') {
      // TODO: Implement video player
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(
              'Video playback coming soon',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return Image.network(
      story.mediaUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
