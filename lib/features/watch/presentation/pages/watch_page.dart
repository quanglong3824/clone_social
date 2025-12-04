import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/core/animations/app_animations.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import '../providers/watch_provider.dart';
import '../widgets/video_card.dart';
import '../widgets/watch_stats_widget.dart';
import 'video_detail_page.dart';
import 'search_video_page.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchProvider>().loadVideos();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WatchProvider>().loadMoreVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<WatchProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.loadVideos(refresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildCategoryChips(provider),
                _buildVideoList(provider),
              ],
            ),
          );
        },
      ),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: FadeTransition(
        opacity: _headerAnimation,
        child: const Text(
          'Watch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        ScaleIn(
          delay: const Duration(milliseconds: 100),
          child: IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _showStatsBottomSheet(),
            tooltip: 'Thống kê',
          ),
        ),
        ScaleIn(
          delay: const Duration(milliseconds: 150),
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchVideoPage()),
            ),
            tooltip: 'Tìm kiếm',
          ),
        ),
      ],
    );
  }

  void _showStatsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: const WatchStatsWidget(),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(WatchProvider provider) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: provider.categories.length,
          itemBuilder: (context, index) {
            final category = provider.categories[index];
            final isSelected = category == provider.selectedCategory;
            return SlideIn.fromLeft(
              delay: Duration(milliseconds: 50 * index.clamp(0, 5)),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TapScale(
                  onTap: () => provider.selectCategory(category),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryBlue.withOpacity(0.2) 
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected 
                          ? Border.all(color: AppTheme.primaryBlue, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: AppDurations.fast,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        child: Text(category),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildVideoList(WatchProvider provider) {
    if (provider.isLoading && provider.videos.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null && provider.videos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(provider.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadVideos(refresh: true),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.videos.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Chưa có video nào'),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == provider.videos.length) {
            return provider.isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }

          final video = provider.videos[index];
          return AnimatedListItem(
            index: index,
            child: VideoCard(
              video: video,
              onTap: () => _openVideoDetail(video.id),
              onMoreTap: () => _showVideoOptions(video.id),
              onChannelTap: () => _openChannel(video.channelId),
            ),
          );
        },
        childCount: provider.videos.length + 1,
      ),
    );
  }

  void _openVideoDetail(String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoDetailPage(videoId: videoId),
      ),
    );
  }

  void _openChannel(String channelId) {
    // TODO: Navigate to channel page
  }

  void _showVideoOptions(String videoId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Lưu video'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Save video
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.not_interested),
              title: const Text('Không quan tâm'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Báo cáo'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
