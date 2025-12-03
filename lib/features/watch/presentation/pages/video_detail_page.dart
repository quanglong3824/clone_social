import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/video_entity.dart';
import '../providers/watch_provider.dart';
import '../widgets/video_player_widget.dart';

class VideoDetailPage extends StatefulWidget {
  final String videoId;

  const VideoDetailPage({super.key, required this.videoId});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  VideoEntity? _video;
  bool _isFollowing = false;
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  int _watchedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _recordView();
  }

  @override
  void dispose() {
    // Record watch time when leaving
    if (_video != null && _watchedSeconds > 0) {
      context.read<WatchProvider>().updateWatchStats(
        _watchedSeconds,
        _video!.category,
      );
    }
    super.dispose();
  }

  void _loadVideo() {
    final provider = context.read<WatchProvider>();
    final video = provider.videos.firstWhere(
      (v) => v.id == widget.videoId,
      orElse: () => provider.videos.first,
    );
    setState(() => _video = video);
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    if (_video == null) return;
    final isFollowing = await context.read<WatchProvider>()
        .isFollowingChannel(_video!.channelId, _currentUserId);
    setState(() => _isFollowing = isFollowing);
  }


  void _recordView() {
    context.read<WatchProvider>().recordView(widget.videoId);
  }

  @override
  Widget build(BuildContext context) {
    if (_video == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            VideoPlayerWidget(
              video: _video!,
              onVideoEnd: () {
                // Auto play next video or show suggestions
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVideoInfo(),
                    const Divider(),
                    _buildChannelInfo(),
                    const Divider(),
                    _buildActionButtons(),
                    const Divider(),
                    _buildCommentSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _video!.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_video!.formattedViews} lượt xem • ${_video!.timeAgo}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (_video!.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _video!.description,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildChannelInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: _video!.channelAvatar != null
                ? NetworkImage(_video!.channelAvatar!)
                : null,
            child: _video!.channelAvatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _video!.channelName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '1.2M người theo dõi',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _toggleFollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowing ? Colors.grey[300] : Colors.blue,
              foregroundColor: _isFollowing ? Colors.black : Colors.white,
            ),
            child: Text(_isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
          ),
        ],
      ),
    );
  }

  void _toggleFollow() async {
    final provider = context.read<WatchProvider>();
    if (_isFollowing) {
      await provider.unfollowChannel(_video!.channelId, _currentUserId);
    } else {
      await provider.followChannel(_video!.channelId, _currentUserId);
    }
    setState(() => _isFollowing = !_isFollowing);
  }


  Widget _buildActionButtons() {
    final isLiked = _video!.isLikedBy(_currentUserId);
    final isSaved = _video!.isSavedBy(_currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: _video!.likeCount.toString(),
            color: isLiked ? Colors.blue : null,
            onTap: () => _toggleLike(),
          ),
          _buildActionButton(
            icon: Icons.thumb_down_outlined,
            label: 'Không thích',
            onTap: () {},
          ),
          _buildActionButton(
            icon: Icons.share,
            label: 'Chia sẻ',
            onTap: () => _shareVideo(),
          ),
          _buildActionButton(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
            label: 'Lưu',
            color: isSaved ? Colors.blue : null,
            onTap: () => _toggleSave(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color ?? Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLike() {
    context.read<WatchProvider>().toggleLike(widget.videoId, _currentUserId);
    _loadVideo();
  }

  void _toggleSave() {
    context.read<WatchProvider>().toggleSave(widget.videoId, _currentUserId);
    _loadVideo();
  }

  void _shareVideo() {
    // TODO: Implement share
  }


  Widget _buildCommentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Bình luận',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_video!.commentCount}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Comment input
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Thêm bình luận...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sample comments
          _buildCommentItem(
            'Nguyễn Văn A',
            'Video rất hay và bổ ích!',
            '2 giờ trước',
            12,
          ),
          _buildCommentItem(
            'Trần Thị B',
            'Cảm ơn bạn đã chia sẻ 👍',
            '5 giờ trước',
            8,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    String userName,
    String comment,
    String time,
    int likes,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('$likes', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 16),
                    Text('Trả lời', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
