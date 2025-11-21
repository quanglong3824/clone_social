import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SeedData {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Sample user data
  static final List<Map<String, String>> sampleUsers = [
    {'name': 'Nguyễn Văn An', 'email': 'an@socialhome.com'},
    {'name': 'Trần Thị Bình', 'email': 'binh@socialhome.com'},
    {'name': 'Lê Văn Cường', 'email': 'cuong@socialhome.com'},
    {'name': 'Phạm Thị Dung', 'email': 'dung@socialhome.com'},
    {'name': 'Hoàng Văn Em', 'email': 'em@socialhome.com'},
    {'name': 'Vũ Thị Phương', 'email': 'phuong@socialhome.com'},
    {'name': 'Đặng Văn Giang', 'email': 'giang@socialhome.com'},
    {'name': 'Bùi Thị Hoa', 'email': 'hoa@socialhome.com'},
    {'name': 'Ngô Văn Inh', 'email': 'inh@socialhome.com'},
    {'name': 'Trịnh Thị Kim', 'email': 'kim@socialhome.com'},
    {'name': 'Lý Văn Long', 'email': 'long@socialhome.com'},
    {'name': 'Phan Thị Mai', 'email': 'mai@socialhome.com'},
  ];

  static final List<String> samplePosts = [
    'Hôm nay thật là một ngày tuyệt vời! 🌞',
    'Vừa xem một bộ phim hay lắm, các bạn nên xem thử!',
    'Cuối tuần này ai đi chơi không? 🎉',
    'Công việc hôm nay mệt quá! 😴',
    'Chia sẻ một số tips học tập hiệu quả...',
    'Món ăn ngon nhất hôm nay! 🍜',
    'Đang nghe nhạc và thư giãn 🎵',
    'Cảm ơn mọi người đã ủng hộ!',
    'Chúc mọi người một ngày tốt lành! ❤️',
    'Vừa đọc xong một cuốn sách hay!',
  ];

  static Future<void> seedAllData(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Creating sample data...\nThis may take a few minutes.'),
            ],
          ),
        ),
      );

      // Create users
      final userIds = await _createUsers();
      
      // Create posts
      await _createPosts(userIds);
      
      // Create friend connections
      await _createFriendships(userIds);
      
      // Create some chats
      await _createChats(userIds);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample data created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      print('Error seeding data: $e');
    }
  }

  static Future<List<String>> _createUsers() async {
    final List<String> userIds = [];
    const password = '123456';

    for (var userData in sampleUsers) {
      try {
        // Create auth user
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: userData['email']!,
          password: password,
        );

        final userId = userCredential.user!.uid;
        userIds.add(userId);

        // Create user profile in database
        await _database.ref('users/$userId').set({
          'email': userData['email'],
          'name': userData['name'],
          'profileImage': _getRandomAvatar(userData['name']!),
          'coverImage': null,
          'bio': 'Xin chào! Tôi là ${userData['name']}',
          'createdAt': ServerValue.timestamp,
          'isOnline': false,
        });

        print('Created user: ${userData['name']} (${userData['email']})');
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          print('User ${userData['email']} already exists, skipping...');
          // Try to get existing user ID
          try {
            final signInResult = await _auth.signInWithEmailAndPassword(
              email: userData['email']!,
              password: password,
            );
            userIds.add(signInResult.user!.uid);
            await _auth.signOut();
          } catch (_) {}
        } else {
          print('Error creating user ${userData['email']}: $e');
        }
      }
    }

    return userIds;
  }

  static Future<void> _createPosts(List<String> userIds) async {
    if (userIds.isEmpty) return;

    for (int i = 0; i < samplePosts.length; i++) {
      final userId = userIds[i % userIds.length];
      final postId = _database.ref('posts').push().key!;

      // Get user info
      final userSnapshot = await _database.ref('users/$userId').get();
      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);

      await _database.ref('posts/$postId').set({
        'userId': userId,
        'userName': userData['name'],
        'userProfileImage': userData['profileImage'],
        'content': samplePosts[i],
        'imageUrl': i % 3 == 0 ? _getRandomImage() : null,
        'createdAt': ServerValue.timestamp,
        'likeCount': (i * 3) % 20,
        'commentCount': (i * 2) % 10,
        'shareCount': i % 5,
      });

      // Add some likes
      final likeCount = (i * 2) % 5;
      for (int j = 0; j < likeCount && j < userIds.length; j++) {
        await _database.ref('posts/$postId/likes/${userIds[j]}').set(true);
      }

      print('Created post: ${samplePosts[i].substring(0, 30)}...');
    }
  }

  static Future<void> _createFriendships(List<String> userIds) async {
    if (userIds.length < 2) return;

    // Create friendships between users
    for (int i = 0; i < userIds.length; i++) {
      // Each user has 3-5 friends
      final friendCount = 3 + (i % 3);
      for (int j = 1; j <= friendCount && (i + j) < userIds.length; j++) {
        final userId1 = userIds[i];
        final userId2 = userIds[(i + j) % userIds.length];

        // Add to friends list
        await _database.ref('users/$userId1/friends/$userId2').set(true);
        await _database.ref('users/$userId2/friends/$userId1').set(true);
      }
    }

    print('Created friendships between users');
  }

  static Future<void> _createChats(List<String> userIds) async {
    if (userIds.length < 2) return;

    // Create some sample chats
    for (int i = 0; i < 5 && i < userIds.length - 1; i++) {
      final userId1 = userIds[i];
      final userId2 = userIds[i + 1];

      final chatId = _database.ref('chats').push().key!;

      // Get user info
      final user1Snapshot = await _database.ref('users/$userId1').get();
      final user2Snapshot = await _database.ref('users/$userId2').get();

      final user1Data = Map<String, dynamic>.from(user1Snapshot.value as Map);
      final user2Data = Map<String, dynamic>.from(user2Snapshot.value as Map);

      final chatData = {
        'participants': [userId1, userId2],
        'lastMessage': 'Xin chào!',
        'lastMessageTime': ServerValue.timestamp,
        'lastMessageSenderId': userId1,
        'createdAt': ServerValue.timestamp,
        'participantInfo': {
          userId1: {
            'name': user1Data['name'],
            'profileImage': user1Data['profileImage'],
          },
          userId2: {
            'name': user2Data['name'],
            'profileImage': user2Data['profileImage'],
          },
        }
      };

      // Save chat for both users
      await _database.ref('userChats/$userId1/$chatId').set(chatData);
      await _database.ref('userChats/$userId2/$chatId').set(chatData);

      // Add a sample message
      final messageId = _database.ref('messages/$chatId').push().key!;
      await _database.ref('messages/$chatId/$messageId').set({
        'senderId': userId1,
        'content': 'Xin chào! Bạn khỏe không?',
        'createdAt': ServerValue.timestamp,
        'read': false,
      });

      print('Created chat between ${user1Data['name']} and ${user2Data['name']}');
    }
  }

  static String _getRandomAvatar(String name) {
    // Use UI Avatars service
    final encoded = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encoded&size=200&background=random';
  }

  static String _getRandomImage() {
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    return 'https://picsum.photos/seed/$random/400/300';
  }

  static Future<void> clearAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Warning'),
        content: const Text('This will delete ALL data in the database. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting all data...'),
            ],
          ),
        ),
      );

      // Delete all data
      await _database.ref('posts').remove();
      await _database.ref('userChats').remove();
      await _database.ref('messages').remove();
      await _database.ref('friendRequests').remove();
      await _database.ref('notifications').remove();

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All data cleared!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
