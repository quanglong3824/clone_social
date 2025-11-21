# Hướng dẫn sử dụng tính năng Tìm bạn bè và Nhắn tin

## ✅ Tính năng đã hoàn thành

### 1. Tìm kiếm người dùng
**File:** `lib/features/friend/presentation/pages/search_users_page.dart`

#### Chức năng:
- ✅ Tìm kiếm người dùng theo tên/email
- ✅ Hiển thị kết quả realtime khi gõ (debounce > 2 ký tự)
- ✅ Gửi lời mời kết bạn
- ✅ **Nhắn tin trực tiếp** từ kết quả tìm kiếm
- ✅ Xem profile người dùng

#### Cách sử dụng:
```dart
// Từ bất kỳ đâu trong app
context.push('/search-users');

// Hoặc từ Friends page
IconButton(
  icon: const Icon(Icons.search),
  onPressed: () => context.push('/search-users'),
)
```

#### UI Components:
- **Search bar** ở AppBar
- **Message button** (icon tin nhắn) - Tạo chat và chuyển đến trang chat
- **Add friend button** (icon thêm bạn) - Gửi lời mời kết bạn
- **Tap vào user** - Xem profile

---

### 2. Danh sách bạn bè
**File:** `lib/features/friend/presentation/pages/friends_page.dart`

#### Chức năng:
- ✅ 2 tabs: "Your Friends" và "Requests"
- ✅ Hiển thị danh sách bạn bè
- ✅ **Nhắn tin với bạn bè** (icon message)
- ✅ Xem profile bạn bè
- ✅ Chấp nhận/Từ chối lời mời kết bạn

#### Cách sử dụng:
```dart
// Navigate to friends page
context.push('/friends');

// Hoặc từ bottom navigation
// Tab index 1
```

---

### 3. Hệ thống Chat - Đa người dùng

#### 3.1. Danh sách Chat
**File:** `lib/features/chat/presentation/pages/chat_list_page.dart`

**Chức năng:**
- ✅ Hiển thị tất cả cuộc trò chuyện
- ✅ Realtime updates
- ✅ Hiển thị tin nhắn cuối cùng
- ✅ Thời gian tin nhắn (timeago)
- ✅ **Unread count** (số tin chưa đọc)
- ✅ Avatar người chat
- ✅ Nút tạo chat mới (chuyển đến friends page)

**Cách sử dụng:**
```dart
// Navigate to chat list
context.push('/chat');

// Hoặc từ bottom navigation
// Không có trong bottom nav hiện tại, cần thêm
```

#### 3.2. Chi tiết Chat
**File:** `lib/features/chat/presentation/pages/chat_detail_page.dart`

**Chức năng:**
- ✅ Hiển thị tin nhắn realtime
- ✅ Gửi tin nhắn text
- ✅ Hỗ trợ gửi ảnh/video (UI đã có, cần implement picker)
- ✅ Tin nhắn của mình (màu xanh, bên phải)
- ✅ Tin nhắn người khác (màu xám, bên trái)
- ✅ Auto scroll xuống tin mới nhất
- ✅ Avatar và tên người chat ở AppBar

**Cách sử dụng:**
```dart
// Navigate to specific chat
context.push('/chat/$chatId');
```

---

## 🔥 Kiến trúc Chat System

### Database Structure (Firebase Realtime Database)

```
firebase_realtime_database/
├── users/
│   └── {userId}/
│       ├── name: "User Name"
│       ├── email: "user@email.com"
│       ├── profileImage: "url"
│       └── ...
│
├── user_chats/
│   └── {userId}/
│       └── {chatId}/
│           ├── participants: [userId1, userId2]
│           ├── lastMessage: "Hello"
│           ├── lastMessageTime: timestamp
│           ├── lastMessageSenderId: "userId"
│           ├── unreadCount: 2
│           └── participantInfo/
│               ├── {userId1}/
│               │   ├── name: "User 1"
│               │   └── profileImage: "url"
│               └── {userId2}/
│                   ├── name: "User 2"
│                   └── profileImage: "url"
│
└── messages/
    └── {chatId}/
        └── {messageId}/
            ├── senderId: "userId"
            ├── content: "Message text"
            ├── imageUrl: "url" (optional)
            ├── videoUrl: "url" (optional)
            ├── createdAt: timestamp
            └── read: false
```

### Luồng hoạt động

#### 1. Tạo Chat mới
```
User A tìm User B → Click message icon
    ↓
ChatProvider.createChat(userA_id, userB_id)
    ↓
Check if chat exists between A & B
    ↓
If exists: Return chatId
If not: Create new chat
    ↓
Save chat metadata to:
- user_chats/userA_id/chatId
- user_chats/userB_id/chatId
    ↓
Navigate to /chat/{chatId}
```

#### 2. Gửi tin nhắn
```
User A gõ tin nhắn → Click send
    ↓
ChatProvider.sendMessage(chatId, senderId, text)
    ↓
Upload media (if any) to Firebase Storage
    ↓
Save message to messages/{chatId}/{messageId}
    ↓
Update lastMessage & unreadCount for all participants
    ↓
Realtime update → User B sees message instantly
```

#### 3. Nhận tin nhắn (Realtime)
```
User B đang ở chat list hoặc chat detail
    ↓
StreamBuilder listening to:
- user_chats/{userId} (for chat list)
- messages/{chatId} (for chat detail)
    ↓
Firebase sends update
    ↓
UI rebuilds automatically with new data
```

---

## 🎯 Các tính năng chính

### ✅ Đã có:

1. **Multi-user Chat**
   - 1 user có thể chat với nhiều user khác
   - Mỗi chat là 1-1 (2 người)
   - Không giới hạn số lượng chat

2. **Realtime Messaging**
   - Tin nhắn cập nhật tức thì
   - Không cần refresh
   - Firebase Realtime Database

3. **Chat Discovery**
   - Tìm user → Chat ngay
   - Từ friends list → Chat
   - Từ profile → Chat (có thể thêm)

4. **Message Status**
   - Unread count
   - Last message preview
   - Timestamp

5. **Rich Messages**
   - Text messages
   - Image support (backend ready)
   - Video support (backend ready)

---

## 🚧 Cần cải thiện

### 1. Group Chat
```dart
// Hiện tại: Chỉ 1-1 chat
// Cần: Nhóm chat nhiều người

// Structure mới:
chat/
  ├── type: "private" | "group"
  ├── participants: [userId1, userId2, userId3, ...]
  ├── groupName: "Group Name" (if group)
  ├── groupImage: "url" (if group)
  └── admins: [userId1] (if group)
```

### 2. Media Picker
```dart
// File: chat_detail_page.dart line 189
IconButton(
  icon: const Icon(Icons.add_circle),
  onPressed: () {
    // TODO: Implement media picker
    // Cần: image_picker package
    // - Pick image from gallery
    // - Pick video from gallery
    // - Take photo
    // - Record video
  },
)
```

**Implementation:**
```dart
import 'package:image_picker/image_picker.dart';

Future<void> _pickMedia() async {
  final picker = ImagePicker();
  
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.photo_library),
          title: Text('Choose from gallery'),
          onTap: () async {
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              _sendImageMessage(File(image.path));
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.camera_alt),
          title: Text('Take a photo'),
          onTap: () async {
            final image = await picker.pickImage(source: ImageSource.camera);
            if (image != null) {
              _sendImageMessage(File(image.path));
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.videocam),
          title: Text('Record video'),
          onTap: () async {
            final video = await picker.pickVideo(source: ImageSource.camera);
            if (video != null) {
              _sendVideoMessage(File(video.path));
            }
          },
        ),
      ],
    ),
  );
}

Future<void> _sendImageMessage(File image) async {
  final currentUser = context.read<AuthProvider>().currentUser;
  if (currentUser == null) return;
  
  await context.read<ChatProvider>().sendMessage(
    widget.chatId,
    currentUser.id,
    '',
    image: image,
  );
}
```

### 3. Message Reactions
```dart
// Long press message → Show reactions
// Like, Love, Haha, Wow, Sad, Angry

// Database structure:
messages/{chatId}/{messageId}/
  └── reactions/
      └── {userId}: "like" | "love" | "haha" | ...
```

### 4. Typing Indicator
```dart
// Show "User is typing..." when other user is typing

// Database structure:
chats/{chatId}/
  └── typing/
      └── {userId}: timestamp
```

### 5. Message Status
```dart
// Sent, Delivered, Seen
// Double check marks like WhatsApp

// Database structure:
messages/{chatId}/{messageId}/
  ├── status: "sent" | "delivered" | "seen"
  └── seenBy/
      └── {userId}: timestamp
```

### 6. Voice Messages
```dart
// Record and send voice messages
// Package: flutter_sound

// Database structure:
messages/{chatId}/{messageId}/
  ├── type: "voice"
  ├── audioUrl: "url"
  └── duration: 15 // seconds
```

### 7. Search trong Chat
```dart
// Search messages in a chat
// Search chats by name/last message
```

### 8. Delete/Edit Messages
```dart
// Delete for me / Delete for everyone
// Edit message (show "edited" label)
```

### 9. Forward Messages
```dart
// Forward message to other chats
```

### 10. Push Notifications
```dart
// FCM notifications when new message arrives
// Show notification even when app is closed
```

---

## 📱 Cách test tính năng

### Test 1: Tìm và nhắn tin
1. Login với User A
2. Vào Search Users (từ Friends page)
3. Tìm User B
4. Click icon message
5. Gửi tin nhắn "Hello from A"
6. Logout và login với User B
7. Vào Chat list
8. Thấy chat với User A, unread count = 1
9. Click vào chat
10. Thấy tin nhắn "Hello from A"
11. Reply "Hi from B"
12. Logout và login lại User A
13. Thấy tin nhắn reply realtime

### Test 2: Chat từ Friends list
1. Login với User A
2. Vào Friends page
3. Click icon message ở bạn bè
4. Chat ngay lập tức

### Test 3: Multiple chats
1. Login với User A
2. Tạo chat với User B
3. Tạo chat với User C
4. Tạo chat với User D
5. Vào Chat list
6. Thấy 3 chats
7. Mỗi chat có thể nhắn tin độc lập

---

## 🔧 Troubleshooting

### Lỗi: Chat không hiển thị
**Nguyên nhân:** Firebase Realtime Database rules chưa đúng

**Giải pháp:**
```json
{
  "rules": {
    "users": {
      ".read": "auth != null",
      "$uid": {
        ".write": "$uid === auth.uid"
      }
    },
    "user_chats": {
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
    }
  }
}
```

### Lỗi: Tin nhắn không realtime
**Nguyên nhân:** StreamBuilder không được setup đúng

**Giải pháp:** Check `ChatProvider.init()` được gọi trong `initState`

### Lỗi: Unread count không reset
**Nguyên nhân:** Chưa implement mark as read

**Giải pháp:** Thêm logic reset unread khi vào chat:
```dart
@override
void initState() {
  super.initState();
  // Reset unread count when entering chat
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      _firebaseService.userChatsRef(currentUser.id)
        .child(widget.chatId)
        .update({'unreadCount': 0});
    }
  });
}
```

---

## 📦 Dependencies cần thiết

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  
  # Navigation
  go_router: ^12.0.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_database: ^10.4.0
  firebase_storage: ^11.5.0
  firebase_auth: ^4.15.0
  
  # UI
  timeago: ^3.5.0
  cached_network_image: ^3.3.0
  
  # Media (cần thêm cho upload ảnh/video)
  image_picker: ^1.0.0
  video_player: ^2.8.0
  
  # Utils
  uuid: ^4.0.0
```

---

## 🎓 Best Practices

1. **Always check user authentication**
   ```dart
   final currentUser = context.read<AuthProvider>().currentUser;
   if (currentUser == null) return;
   ```

2. **Handle loading states**
   ```dart
   if (_isLoading) return CircularProgressIndicator();
   ```

3. **Show error messages**
   ```dart
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Error: $error')),
   );
   ```

4. **Dispose controllers**
   ```dart
   @override
   void dispose() {
     _messageController.dispose();
     _scrollController.dispose();
     super.dispose();
   }
   ```

5. **Use mounted check**
   ```dart
   if (mounted) {
     setState(() { ... });
   }
   ```

---

## 🚀 Kết luận

Hệ thống chat đã hoàn chỉnh với các tính năng:
- ✅ Tìm kiếm người dùng
- ✅ Nhắn tin 1-1
- ✅ Multi-user support (1 user chat với nhiều user)
- ✅ Realtime messaging
- ✅ Unread count
- ✅ Media support (backend ready)

Sẵn sàng để mở rộng thêm:
- Group chat
- Voice/Video call
- Message reactions
- Advanced features
