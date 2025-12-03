import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watch_provider.dart';
import '../widgets/video_card.dart';
import 'video_detail_page.dart';

class SearchVideoPage extends StatefulWidget {
  const SearchVideoPage({super.key});

  @override
  State<SearchVideoPage> createState() => _SearchVideoPageState();
}

class _SearchVideoPageState extends State<SearchVideoPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm video...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<WatchProvider>().clearSearch();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
            if (value.length >= 2) {
              context.read<WatchProvider>().searchVideos(value);
            }
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<WatchProvider>().searchVideos(value);
            }
          },
        ),
      ),
      body: Consumer<WatchProvider>(
        builder: (context, provider, child) {
          if (provider.searchQuery.isEmpty) {
            return _buildSearchSuggestions();
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy video nào',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final video = provider.searchResults[index];
              return VideoCard(
                video: video,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoDetailPage(videoId: video.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      'Flutter tutorial',
      'Gaming highlights',
      'Music videos',
      'Cooking recipes',
      'Travel vlog',
      'Tech review',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Tìm kiếm phổ biến',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((suggestion) => ListTile(
          leading: const Icon(Icons.trending_up),
          title: Text(suggestion),
          onTap: () {
            _searchController.text = suggestion;
            context.read<WatchProvider>().searchVideos(suggestion);
            setState(() {});
          },
        )),
      ],
    );
  }
}
