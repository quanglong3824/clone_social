class AppConstants {
  // App Info
  static const String appName = 'Facebook Clone';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String friendRequestsCollection = 'friendRequests';
  static const String notificationsCollection = 'notifications';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String postImagesPath = 'post_images';
  static const String postVideosPath = 'post_videos';
  static const String chatImagesPath = 'chat_images';
  static const String coverImagesPath = 'cover_images';
  
  // Shared Preferences Keys
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeKey = 'theme_mode';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPostLength = 5000;
  static const int maxCommentLength = 500;
  static const int maxMessageLength = 1000;
  static const int maxBioLength = 150;
  
  // Pagination
  static const int postsPerPage = 10;
  static const int commentsPerPage = 20;
  static const int messagesPerPage = 50;
  static const int friendsPerPage = 20;
  
  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxVideoSizeMB = 50;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoExtensions = ['mp4', 'mov', 'avi', 'mkv'];
  
  // Notification Types
  static const String notificationTypeLike = 'like';
  static const String notificationTypeComment = 'comment';
  static const String notificationTypeShare = 'share';
  static const String notificationTypeFriendRequest = 'friend_request';
  static const String notificationTypeFriendAccept = 'friend_accept';
  static const String notificationTypeMessage = 'message';
  
  // Friend Request Status
  static const String friendRequestPending = 'pending';
  static const String friendRequestAccepted = 'accepted';
  static const String friendRequestRejected = 'rejected';
  
  // Message Types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeVideo = 'video';
  
  // Post Types
  static const String postTypeText = 'text';
  static const String postTypeImage = 'image';
  static const String postTypeVideo = 'video';
  static const String postTypeMixed = 'mixed';
  
  // Error Messages
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorUserNotFound = 'User not found.';
  static const String errorWrongPassword = 'Incorrect password.';
  static const String errorEmailInUse = 'Email is already in use.';
  
  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successRegister = 'Registration successful!';
  static const String successPasswordReset = 'Password reset email sent!';
  static const String successPostCreated = 'Post created successfully!';
  static const String successCommentAdded = 'Comment added!';
  static const String successFriendRequestSent = 'Friend request sent!';
  static const String successFriendRequestAccepted = 'Friend request accepted!';
}
