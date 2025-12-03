import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/watch_repository.dart';

class WatchRepositoryImpl implements WatchRepository {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Pexels API - Free video API
  static const String _pexelsApiKey = 'PgjcRBT49xqXnmyY6Dvfin4NxLmOS3NQUF8M9RynwieXxS67unwLA1J6';
  static const String _pexelsBaseUrl = 'https://api.pexels.com/videos';
  
  final List<String> _categories = [
    'Dành cho bạn',
    'Trực tiếp',
    'Gaming',
    'Theo dõi',
    'Đã lưu',
    'Âm nhạc',
    'Thể thao',
    'Tin tức',
    'Giải trí',
  ];

  // Map category to Pexels search query
  final Map<String, String> _categoryQueries = {
    'Dành cho bạn': 'popular',
    'Gaming': 'gaming',
    'Âm nhạc': 'music',
    'Thể thao': 'sports',
    'Tin tức': 'news',
    'Giải trí': 'entertainment funny',
  };

  @override
  List<String> getCategories() => _categories;

  @override
  Future<List<VideoEntity>> getVideos({String? category, int page = 1, int perPage = 10}) async {
    try {
      final query = _categoryQueries[category] ?? 'popular';
      final url = '$_pexelsBaseUrl/search?query=$query&page=$page&per_page=$perPage';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': _pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videos = (data['videos'] as List).map((video) {
          return _mapPexelsVideoToEntity(video);
        }).toList();
        return videos;
      }
      
      // Fallback to mock data if API fails
      return _getMockVideos(category: category);
    } catch (e) {
      // Return mock data on error
      return _getMockVideos(category: category);
    }
  }

  VideoEntity _mapPexelsVideoToEntity(Map<String, dynamic> video) {
    final videoFiles = video['video_files'] as List;
    final hdVideo = videoFiles.firstWhere(
      (f) => f['quality'] == 'hd',
      orElse: () => videoFiles.first,
    );
    
    final user = video['user'];
    final random = Random();
    
    return VideoEntity(
      id: video['id'].toString(),
      title: video['url']?.split('/').last?.replaceAll('-', ' ') ?? 'Video',
      description: '',
      videoUrl: hdVideo['link'] ?? '',
      thumbnailUrl: video['image'] ?? '',
      channelId: user['id'].toString(),
      channelName: user['name'] ?? 'Unknown',
      channelAvatar: user['url'],
      duration: video['duration'] ?? 0,
      viewCount: random.nextInt(1000000) + 1000,
      likeCount: random.nextInt(50000) + 100,
      commentCount: random.nextInt(5000) + 10,
      shareCount: random.nextInt(1000) + 5,
      createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
      category: 'Dành cho bạn',
    );
  }

  List<VideoEntity> _getMockVideos({String? category}) {
    final random = Random();
    final mockData = [
      {
        'id': '1',
        'title': 'Hướng dẫn Flutter cơ bản cho người mới',
        'channel': 'Flutter Vietnam',
        'views': 125000,
        'duration': 624,
      },
      {
        'id': '2', 
        'title': 'Top 10 địa điểm du lịch đẹp nhất Việt Nam',
        'channel': 'Travel VN',
        'views': 890000,
        'duration': 845,
      },
      {
        'id': '3',
        'title': 'Review iPhone 15 Pro Max sau 1 tháng sử dụng',
        'channel': 'Tech Review',
        'views': 2100000,
        'duration': 1205,
      },
      {
        'id': '4',
        'title': 'Công thức nấu phở bò chuẩn vị Hà Nội',
        'channel': 'Bếp Việt',
        'views': 456000,
        'duration': 932,
      },
      {
        'id': '5',
        'title': 'Workout tại nhà 30 phút đốt mỡ hiệu quả',
        'channel': 'Fitness VN',
        'views': 678000,
        'duration': 1800,
      },
    ];

    return mockData.map((data) {
      return VideoEntity(
        id: data['id'] as String,
        title: data['title'] as String,
        description: 'Mô tả video ${data['title']}',
        videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
        thumbnailUrl: 'https://picsum.photos/seed/${data['id']}/400/225',
        channelId: 'channel_${data['id']}',
        channelName: data['channel'] as String,
        channelAvatar: 'https://picsum.photos/seed/avatar${data['id']}/100/100',
        duration: data['duration'] as int,
        viewCount: data['views'] as int,
        likeCount: random.nextInt(50000) + 100,
        commentCount: random.nextInt(5000) + 10,
        shareCount: random.nextInt(1000) + 5,
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        category: category ?? 'Dành cho bạn',
      );
    }).toList();
  }

  @override
  Future<VideoEntity?> getVideoById(String videoId) async {
    try {
      final url = '$_pexelsBaseUrl/videos/$videoId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': _pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _mapPexelsVideoToEntity(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<VideoEntity>> searchVideos(String query, {int page = 1, int perPage = 10}) async {
    try {
      final url = '$_pexelsBaseUrl/search?query=$query&page=$page&per_page=$perPage';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': _pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['videos'] as List).map((video) {
          return _mapPexelsVideoToEntity(video);
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<VideoEntity>> getSavedVideos(String userId) {
    return _database
        .ref('users/$userId/savedVideos')
        .onValue
        .asyncMap((event) async {
      if (event.snapshot.value == null) return <VideoEntity>[];
      
      final savedMap = Map<String, dynamic>.from(event.snapshot.value as Map);
      final videos = <VideoEntity>[];
      
      for (final videoId in savedMap.keys) {
        final video = await getVideoById(videoId);
        if (video != null) {
          videos.add(video.copyWith(saved: {userId: true}));
        }
      }
      return videos;
    });
  }

  @override
  Stream<List<VideoEntity>> getFollowingVideos(String userId) {
    // Trả về stream video từ các channel đã follow
    return _database
        .ref('users/$userId/followingChannels')
        .onValue
        .asyncMap((event) async {
      if (event.snapshot.value == null) return <VideoEntity>[];
      return _getMockVideos(category: 'Theo dõi');
    });
  }

  @override
  Future<void> likeVideo(String videoId, String userId) async {
    await _database.ref('videoLikes/$videoId/$userId').set(true);
    await _database.ref('users/$userId/likedVideos/$videoId').set(true);
  }

  @override
  Future<void> unlikeVideo(String videoId, String userId) async {
    await _database.ref('videoLikes/$videoId/$userId').remove();
    await _database.ref('users/$userId/likedVideos/$videoId').remove();
  }

  @override
  Future<void> saveVideo(String videoId, String userId) async {
    await _database.ref('users/$userId/savedVideos/$videoId').set({
      'savedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> unsaveVideo(String videoId, String userId) async {
    await _database.ref('users/$userId/savedVideos/$videoId').remove();
  }

  @override
  Future<void> incrementViewCount(String videoId) async {
    await _database.ref('videoViews/$videoId').set(ServerValue.increment(1));
  }

  @override
  Future<void> followChannel(String channelId, String userId) async {
    await _database.ref('users/$userId/followingChannels/$channelId').set(true);
    await _database.ref('channels/$channelId/followers/$userId').set(true);
  }

  @override
  Future<void> unfollowChannel(String channelId, String userId) async {
    await _database.ref('users/$userId/followingChannels/$channelId').remove();
    await _database.ref('channels/$channelId/followers/$userId').remove();
  }

  @override
  Future<bool> isFollowingChannel(String channelId, String userId) async {
    final snapshot = await _database
        .ref('users/$userId/followingChannels/$channelId')
        .get();
    return snapshot.exists;
  }
}
