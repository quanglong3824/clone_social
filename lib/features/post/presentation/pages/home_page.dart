import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../providers/post_provider.dart';
import '../widgets/post_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showElevation = false;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: AppCurves.smooth,
    );
    _headerController.forward();
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShowElevation = _scrollController.offset > 0;
    if (shouldShowElevation != _showElevation) {
      setState(() => _showElevation = shouldShowElevation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            boxShadow: _showElevation
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: AppBar(
            title: FadeTransition(
              opacity: _headerAnimation,
              child: const Text(
                'facebook',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.2,
                ),
              ),
            ),
            actions: [
              _AnimatedAppBarAction(
                icon: Icons.search,
                onPressed: () {},
                delay: const Duration(milliseconds: 100),
              ),
              _AnimatedAppBarAction(
                icon: Icons.notifications,
                onPressed: () => context.push('/notifications'),
                delay: const Duration(milliseconds: 150),
              ),
              _AnimatedAppBarAction(
                icon: Icons.message,
                onPressed: () => context.push('/chat'),
                delay: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Create Post Bar
            SliverToBoxAdapter(
              child: SlideIn.fromTop(
                duration: AppDurations.normal,
                child: _CreatePostBar(user: user),
              ),
            ),
            
            // Feed
            if (postProvider.isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const PostShimmer(),
                  childCount: 3,
                ),
              )
            else if (postProvider.posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: SlideIn.fromBottom(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'Chưa có bài viết nào',
                          style: TextStyle(
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = postProvider.posts[index];
                    return AnimatedListItem(
                      index: index,
                      child: PostItem(post: post),
                    );
                  },
                  childCount: postProvider.posts.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedAppBarAction extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Duration delay;

  const _AnimatedAppBarAction({
    required this.icon,
    required this.onPressed,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedAppBarAction> createState() => _AnimatedAppBarActionState();
}

class _AnimatedAppBarActionState extends State<_AnimatedAppBarAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleIn(
      delay: widget.delay,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(widget.icon),
          ),
        ),
      ),
    );
  }
}

class _CreatePostBar extends StatefulWidget {
  final dynamic user;

  const _CreatePostBar({required this.user});

  @override
  State<_CreatePostBar> createState() => _CreatePostBarState();
}

class _CreatePostBarState extends State<_CreatePostBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      child: Row(
        children: [
          TapScale(
            onTap: () {
              if (widget.user != null) {
                context.push('/profile/${widget.user.id}');
              }
            },
            child: CircleAvatar(
              backgroundImage: widget.user?.profileImage != null
                  ? NetworkImage(widget.user!.profileImage!)
                  : null,
              child: widget.user?.profileImage == null
                  ? const Icon(Icons.person)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) {
                _controller.reverse();
                context.push('/create-post');
              },
              onTapCancel: () => _controller.reverse(),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                    border: Border.all(
                      color: isDark ? AppTheme.dividerDark : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    "Bạn đang nghĩ gì?",
                    style: TextStyle(
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          TapScale(
            onTap: () => context.push('/create-post'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.photo_library,
                color: AppTheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
