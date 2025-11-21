import 'package:flutter/material.dart';

class WatchPage extends StatelessWidget {
  const WatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Watch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Categories
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('Dành cho bạn', true),
                _buildCategoryChip('Trực tiếp', false),
                _buildCategoryChip('Gaming', false),
                _buildCategoryChip('Theo dõi', false),
                _buildCategoryChip('Đã lưu', false),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Video list
          _buildVideoCard(
            'Video Title 1',
            'Channel Name',
            '1.2M views • 2 days ago',
            'https://via.placeholder.com/400x225',
          ),
          _buildVideoCard(
            'Video Title 2',
            'Channel Name',
            '500K views • 1 week ago',
            'https://via.placeholder.com/400x225',
          ),
          _buildVideoCard(
            'Video Title 3',
            'Channel Name',
            '2M views • 3 days ago',
            'https://via.placeholder.com/400x225',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool value) {},
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
      ),
    );
  }

  Widget _buildVideoCard(
    String title,
    String channelName,
    String views,
    String thumbnailUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        Container(
          width: double.infinity,
          height: 225,
          color: Colors.grey[300],
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  color: Colors.black87,
                  child: const Text(
                    '10:24',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Video info
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[400],
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channelName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      views,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
