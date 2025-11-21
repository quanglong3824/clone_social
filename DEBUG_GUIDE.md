# Debug Guide - Tính năng Add Friend và Messaging

## 🔍 Đã cải thiện

### 1. Error Handling & Logging
Đã thêm comprehensive logging và error handling cho:
- ✅ Search users
- ✅ Send friend request
- ✅ Create chat
- ✅ Send message

### 2. User Feedback
Đã thêm UI feedback rõ ràng:
- ✅ Loading indicators
- ✅ Success messages (màu xanh)
- ✅ Error messages (màu đỏ)
- ✅ Progress dialogs

## 🧪 Cách kiểm tra lỗi

### Bước 1: Kiểm tra Console Logs

Khi bấm **Message button**, bạn sẽ thấy logs:
```
Creating chat between [userId1] and [userId2]
ChatProvider: Creating chat between [userId1] and [userId2]
ChatRepo: Checking existing chats for user [userId1]
ChatRepo: No existing chat found, creating new one
ChatRepo: Generated chat ID: [chatId]
ChatRepo: Fetching user data...
ChatRepo: Current user: [userName1]
ChatRepo: Other user: [userName2]
ChatRepo: Saving chat data to Firebase...
ChatRepo: Chat created successfully: [chatId]
ChatProvider: Chat created with ID: [chatId]
Navigating to chat: [chatId]
```

Khi bấm **Add Friend button**, bạn sẽ thấy:
```
Sending friend request...
Friend request sent to [userName]!
```

### Bước 2: Kiểm tra Firebase Realtime Database

Mở Firebase Console → Realtime Database và kiểm tra:

#### Sau khi Add Friend:
```json
{
  "friendRequests": {
    "[toUserId]": {
      "[requestId]": {
        "fromUserId": "[fromUserId]",
        "fromUserName": "User Name",
        "fromUserProfileImage": "url",
        "status": "pending",
        "createdAt": 1234567890
      }
    }
  },
  "notifications": {
    "[toUserId]": {
      "[notifId]": {
        "type": "friend_request",
        "fromUserId": "[fromUserId]",
        "read": false,
        "createdAt": 1234567890
      }
    }
  }
}
```

#### Sau khi Create Chat:
```json
{
  "userChats": {
    "[userId1]": {
      "[chatId]": {
        "participants": ["[userId1]", "[userId2]"],
        "lastMessage": "",
        "lastMessageTime": 1234567890,
        "lastMessageSenderId": "",
        "createdAt": 1234567890,
        "participantInfo": {
          "[userId1]": {
            "name": "User 1",
            "profileImage": "url"
          },
          "[userId2]": {
            "name": "User 2",
            "profileImage": "url"
          }
        }
      }
    },
    "[userId2]": {
      "[chatId]": {
        // Same data
      }
    }
  }
}
```

## ❌ Các lỗi thường gặp

### Lỗi 1: "Current user not found"
**Nguyên nhân:** User chưa được tạo trong Firebase Realtime Database

**Giải pháp:**
1. Kiểm tra xem user có trong `users/[userId]` không
2. Đảm bảo khi đăng ký, user được lưu vào database
3. Check AuthProvider có currentUser không

```dart
// Trong auth_repository_impl.dart
Future<void> signUpWithEmailAndPassword(String email, String password, String name) async {
  final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  
  // QUAN TRỌNG: Phải lưu user vào Realtime Database
  await _firebaseService.userRef(userCredential.user!.uid).set({
    'email': email,
    'name': name,
    'profileImage': null,
    'coverImage': null,
    'bio': '',
    'createdAt': ServerValue.timestamp,
    'isOnline': true,
  });
}
```

### Lỗi 2: "Permission denied"
**Nguyên nhân:** Firebase Realtime Database rules chưa đúng

**Giải pháp:** Cập nhật rules trong Firebase Console:

```json
{
  "rules": {
    "users": {
      ".read": "auth != null",
      ".indexOn": ["name", "email"],
      "$uid": {
        ".write": "$uid === auth.uid"
      }
    },
    "friendRequests": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "auth != null"
      }
    },
    "userChats": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "messages": {
      "$chatId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    },
    "notifications": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "auth != null"
      }
    }
  }
}
```

### Lỗi 3: "Failed to create chat"
**Nguyên nhân:** 
- Network issue
- Firebase rules
- User data không tồn tại

**Giải pháp:**
1. Check console logs để xem lỗi cụ thể
2. Verify Firebase connection
3. Check user data exists

```dart
// Test Firebase connection
void testFirebaseConnection() async {
  try {
    final ref = FirebaseDatabase.instance.ref('test');
    await ref.set({'timestamp': ServerValue.timestamp});
    print('Firebase connected!');
  } catch (e) {
    print('Firebase error: $e');
  }
}
```

### Lỗi 4: Button không phản hồi
**Nguyên nhân:**
- currentUser = null
- Exception bị catch nhưng không hiển thị

**Giải pháp:** Đã fix bằng cách:
- Thêm null check cho currentUser
- Hiển thị SnackBar cho mọi error
- Thêm loading indicators

### Lỗi 5: Chat list không hiển thị
**Nguyên nhân:** ChatProvider.init() chưa được gọi

**Giải pháp:**
```dart
// Trong chat_list_page.dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      context.read<ChatProvider>().init(currentUser.id);
    }
  });
}
```

## 🔧 Debug Commands

### 1. Check current user
```dart
final currentUser = context.read<AuthProvider>().currentUser;
print('Current user: ${currentUser?.id} - ${currentUser?.name}');
```

### 2. Test friend request
```dart
try {
  await context.read<FriendProvider>().sendFriendRequest(
    'userId1',
    'userId2',
  );
  print('Friend request sent successfully');
} catch (e) {
  print('Error: $e');
}
```

### 3. Test chat creation
```dart
try {
  final chatId = await context.read<ChatProvider>().createChat(
    'userId1',
    'userId2',
  );
  print('Chat created: $chatId');
} catch (e) {
  print('Error: $e');
}
```

### 4. Check Firebase data
```dart
// Check if user exists
final userSnapshot = await FirebaseDatabase.instance
    .ref('users/$userId')
    .get();
print('User exists: ${userSnapshot.exists}');
print('User data: ${userSnapshot.value}');

// Check user chats
final chatsSnapshot = await FirebaseDatabase.instance
    .ref('userChats/$userId')
    .get();
print('User chats: ${chatsSnapshot.value}');
```

## 📱 Test Flow

### Test Add Friend
1. Login với User A
2. Search User B
3. Click Add Friend icon
4. Xem SnackBar "Sending friend request..."
5. Sau đó thấy "Friend request sent to [User B]!" (màu xanh)
6. Logout và login với User B
7. Vào Friends page → Tab "Requests"
8. Thấy friend request từ User A
9. Click "Confirm"
10. Check Friends tab → Thấy User A trong danh sách

### Test Messaging
1. Login với User A
2. Search User B
3. Click Message icon (💬)
4. Xem loading dialog "Creating chat..."
5. Tự động chuyển đến chat page
6. Gửi tin nhắn "Hello!"
7. Logout và login với User B
8. Vào Chat list (hoặc từ menu)
9. Thấy chat với User A, unread count = 1
10. Click vào chat
11. Thấy tin nhắn "Hello!"
12. Reply "Hi!"
13. Logout và login lại User A
14. Thấy reply realtime

## 🐛 Common Issues Checklist

- [ ] Firebase initialized trong main.dart?
- [ ] User đã login?
- [ ] User data tồn tại trong Firebase?
- [ ] Firebase rules đúng?
- [ ] Internet connection OK?
- [ ] Providers được setup trong MultiProvider?
- [ ] ChatProvider.init() được gọi?
- [ ] Console có error messages?

## 📊 Monitoring

### Thêm analytics tracking
```dart
// Track friend request
void trackFriendRequest(String fromUserId, String toUserId) {
  FirebaseAnalytics.instance.logEvent(
    name: 'friend_request_sent',
    parameters: {
      'from_user': fromUserId,
      'to_user': toUserId,
    },
  );
}

// Track chat creation
void trackChatCreation(String userId1, String userId2) {
  FirebaseAnalytics.instance.logEvent(
    name: 'chat_created',
    parameters: {
      'user1': userId1,
      'user2': userId2,
    },
  );
}
```

## 🎯 Next Steps

1. **Test với real users**
   - Tạo 2-3 test accounts
   - Test tất cả flows
   - Document any issues

2. **Monitor Firebase usage**
   - Check read/write operations
   - Monitor database size
   - Check for errors in Firebase Console

3. **Optimize if needed**
   - Add caching
   - Implement pagination
   - Add debouncing for search

4. **Add more features**
   - Group chat
   - Media messages
   - Voice/Video calls
