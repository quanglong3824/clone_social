import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clone_social/core/animations/app_animations.dart';
import '../../domain/entities/video_entity.dart';

class VideoCard extends StatefulWidget {
  final VideoEntity video;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onChannelTap;

  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onMoreTap,
    this.onChannelTap,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(),
              _buildVideoInfo(context),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: widget.video.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error, size: 48),
            ),
          ),
        ),
        // Duration badge
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.video.formattedDuration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // Live badge
        if (widget.video.isLive)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Play icon overlay with hover effect
        Positioned.fill(
          child: AnimatedOpacity(
            duration: AppDurations.fast,
            opacity: _isHovered ? 1.0 : 0.7,
            child: Center(
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: EdgeInsets.all(_isHovered ? 16 : 12),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: _isHovered ? 36 : 32,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildVideoInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel avatar
          TapScale(
            onTap: widget.onChannelTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.video.channelAvatar != null
                  ? CachedNetworkImageProvider(widget.video.channelAvatar!)
                  : null,
              child: widget.video.channelAvatar == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Video details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.video.channelName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${widget.video.formattedViews} lượt xem • ${widget.video.timeAgo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // More button
          TapScale(
            onTap: widget.onMoreTap,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.more_vert, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
