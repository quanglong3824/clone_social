import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Get database reference
  DatabaseReference get database => _database.ref();

  // Users
  DatabaseReference usersRef() => database.child('users');
  DatabaseReference userRef(String userId) => usersRef().child(userId);

  // Posts
  DatabaseReference postsRef() => database.child('posts');
  DatabaseReference postRef(String postId) => postsRef().child(postId);

  // Comments
  DatabaseReference commentsRef(String postId) => 
      postRef(postId).child('comments');
  DatabaseReference commentRef(String postId, String commentId) => 
      commentsRef(postId).child(commentId);

  // Likes (deprecated - use reactionsRef)
  DatabaseReference likesRef(String postId) => 
      postRef(postId).child('likes');

  // Reactions
  DatabaseReference reactionsRef(String postId) => 
      postRef(postId).child('reactions');

  // Friend Requests
  DatabaseReference friendRequestsRef() => database.child('friendRequests');
  DatabaseReference userFriendRequestsRef(String userId) => 
      friendRequestsRef().child(userId);

  // Friends
  DatabaseReference friendsRef(String userId) => 
      userRef(userId).child('friends');

  // Chats
  DatabaseReference chatsRef() => database.child('chats');
  DatabaseReference chatRef(String chatId) => chatsRef().child(chatId);
  DatabaseReference userChatsRef(String userId) =>
      database.child('userChats').child(userId);

  // Messages
  DatabaseReference messagesRef(String chatId) => 
      database.child('messages').child(chatId);
  DatabaseReference messageRef(String chatId, String messageId) => 
      messagesRef(chatId).child(messageId);

  // Notifications
  DatabaseReference notificationsRef() => database.child('notifications');
  DatabaseReference userNotificationsRef(String userId) => 
      notificationsRef().child(userId);

  // Stories
  DatabaseReference storiesRef() => database.child('stories');
  DatabaseReference storyRef(String storyId) => storiesRef().child(storyId);
  DatabaseReference storyViewersRef(String storyId) => 
      storyRef(storyId).child('viewerIds');

  // Helper methods
  String generateKey(DatabaseReference ref) {
    return ref.push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Enable offline persistence
  void enablePersistence() {
    _database.setPersistenceEnabled(true);
    _database.setPersistenceCacheSizeBytes(10000000); // 10MB
  }

  // Go online/offline
  void goOnline() => _database.goOnline();
  void goOffline() => _database.goOffline();
}
