# 📱 Clone Social - Tài liệu tính năng

> Ứng dụng mạng xã hội clone Facebook được xây dựng bằng Flutter và Firebase Realtime Database

## 📋 Mục lục

- [Tổng quan kiến trúc](#tổng-quan-kiến-trúc)
- [1. Xác thực (Authentication)](#1-xác-thực-authentication)
- [2. Bài viết (Posts)](#2-bài-viết-posts)
- [3. Nhắn tin (Chat)](#3-nhắn-tin-chat)
- [4. Bạn bè (Friends)](#4-bạn-bè-friends)
- [5. Thông báo (Notifications)](#5-thông-báo-notifications)
- [6. Hồ sơ (Profile)](#6-hồ-sơ-profile)
- [7. Marketplace](#7-marketplace)
- [8. Watch (Video)](#8-watch-video)
- [9. Story](#9-story)
- [10. Menu](#10-menu)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)

---

## Tổng quan kiến trúc

Dự án sử dụng **Clean Architecture** với cấu trúc:

```
lib/
├── core/                    # Core modules
│   ├── constants/           # Hằng số
│   ├── routes/              # Định tuyến (go_router)
│   ├── services/            # Firebase services
│   ├── themes/              # Theme (Light/Dark)
│   ├── utils/               # Tiện ích
│   └── widgets/             # Widget dùng chung
├── features/                # Các tính năng
│   ├── auth/
│   ├── chat/
│   ├── friend/
│   ├── marketplace/
│   ├── menu/
│   ├── notification/
│   ├── post/
│   ├── profile/
│   ├── story/
│   └── watch/
└── main.dart
```

Mỗi feature có cấu trúc:
- `data/repositories/` - Triển khai repository
- `domain/entities/` - Entity models
- `domain/repositories/` - Repository interfaces
- `presentation/pages/` - UI pages
- `presentation/providers/` - State management (Provider)
- `presentation/widgets/` - Widget riêng của feature

---

## 1. Xác thực (Authentication)

### Tính năng
- ✅ Đăng nhập bằng Email/Password
- ✅ Đăng ký tài khoản mới
- ✅ Đăng nhập bằng Google (Web & Mobile)
- ✅ Quên mật khẩu (gửi email reset)
- ✅ Splash screen với kiểm tra trạng thái đăng nhập
- ✅ Theo dõi trạng thái online/offline
- ✅ Cập nhật lastSeen khi đăng xuất

### Entity: UserEntity
```dart
- id: String
- email: String
- name: String
- profileImage: String?
- coverImage: String?
- bio: String?
- friends: List<String>
- createdAt: DateTime
- lastSeen: DateTime?
- isOnline: bool
```

### Màn hình
- `SplashPage` - Màn hình khởi động
- `LoginPage` - Đăng nhập
- `RegisterPage` - Đăng ký
- `ForgotPasswordPage` - Quên mật khẩu

---

## 2. Bài viết (Posts)

### Tính năng
- ✅ Xem danh sách bài viết (News Feed)
- ✅ Tạo bài viết mới với nội dung text
- ✅ Đăng bài với nhiều hình ảnh
- ✅ Đăng bài với video
- ✅ Xóa bài viết
- ✅ **Hệ thống Reactions** (6 loại: Like, Love, Haha, Wow, Sad, Angry)
- ✅ Hiển thị top 3 reactions phổ biến
- ✅ Xem danh sách người đã react
- ✅ Bình luận bài viết
- ✅ Like/Unlike bình luận
- ✅ Trả lời bình luận (Reply)
- ✅ Chia sẻ bài viết lên Feed
- ✅ Hiển thị bài viết được chia sẻ (Shared Post)
- ✅ Xem chi tiết bài viết
- ✅ Thông báo khi có người react/comment/share

### Entity: PostEntity
```dart
- id: String
- userId: String
- userName: String
- userProfileImage: String?
- content: String
- images: List<String>
- videoUrl: String?
- reactions: Map<String, String>  // userId -> reactionType
- commentCount: int
- shareCount: int
- createdAt: DateTime
- updatedAt: DateTime?
// Shared post fields
- sharedPostId: String?
- sharedPostUserId: String?
- sharedPostUserName: String?
- sharedPostUserProfileImage: String?
- sharedPostContent: String?
- sharedPostImages: List<String>?
```

### Entity: CommentEntity
```dart
- id: String
- postId: String
- userId: String
- userName: String
- userProfileImage: String?
- text: String
- createdAt: DateTime
- likes: Map<String, bool>
- parentCommentId: String?  // For replies
- replyCount: int
```

### Màn hình
- `HomePage` - News Feed
- `CreatePostPage` - Tạo bài viết
- `PostDetailPage` - Chi tiết bài viết

### Widgets
- `PostItem` - Hiển thị bài viết
- `PostImageGrid` - Grid hình ảnh
- `ReactionPicker` - Chọn reaction
- `CommentSection` - Phần bình luận
- `ShareBottomSheet` - Bottom sheet chia sẻ

---

## 3. Nhắn tin (Chat)

### Tính năng
- ✅ Danh sách cuộc trò chuyện
- ✅ Tạo cuộc trò chuyện mới
- ✅ Gửi tin nhắn text
- ✅ Gửi hình ảnh (base64)
- ✅ Hiển thị trạng thái đang nhập (Typing indicator)
- ✅ Đánh dấu tin nhắn đã đọc
- ✅ Đánh dấu tất cả tin nhắn đã đọc
- ✅ Xóa tin nhắn (chỉ người gửi)
- ✅ Xóa cuộc trò chuyện
- ✅ Tìm kiếm tin nhắn trong cuộc trò chuyện
- ✅ Đếm số tin nhắn chưa đọc
- ✅ Sắp xếp theo thời gian tin nhắn cuối
- ✅ Hiển thị thông tin người tham gia

### Entity: ChatEntity
```dart
- id: String
- participants: List<String>
- lastMessage: String
- lastMessageTime: DateTime
- lastMessageSenderId: String
- unreadCount: int
- participantInfo: Map<String, Map<String, dynamic>>
```

### Entity: MessageEntity
```dart
- id: String
- chatId: String
- senderId: String
- senderName: String
- senderProfileImage: String?
- text: String
- type: String  // text, image, video
- mediaUrl: String?
- createdAt: DateTime
- read: bool
```

### Màn hình
- `ChatListPage` - Danh sách chat
- `ChatDetailPage` - Chi tiết cuộc trò chuyện

---

## 4. Bạn bè (Friends)

### Tính năng
- ✅ Xem danh sách bạn bè
- ✅ Tìm kiếm người dùng
- ✅ Gửi lời mời kết bạn
- ✅ Xem danh sách lời mời kết bạn
- ✅ Chấp nhận lời mời kết bạn
- ✅ Từ chối lời mời kết bạn
- ✅ Hủy kết bạn
- ✅ Xem hồ sơ người dùng
- ✅ Thông báo khi có lời mời/chấp nhận kết bạn

### Entity: FriendRequestEntity
```dart
- id: String
- fromUserId: String
- fromUserName: String
- fromUserProfileImage: String?
- toUserId: String
- status: String  // pending, accepted, rejected
- createdAt: DateTime
```

### Màn hình
- `FriendsPage` - Danh sách bạn bè & lời mời
- `SearchUsersPage` - Tìm kiếm người dùng

---

## 5. Thông báo (Notifications)

### Tính năng
- ✅ Danh sách thông báo
- ✅ Thông báo reaction bài viết
- ✅ Thông báo bình luận
- ✅ Thông báo chia sẻ bài viết
- ✅ Thông báo lời mời kết bạn
- ✅ Thông báo chấp nhận kết bạn
- ✅ Thông báo tin nhắn mới
- ✅ Đánh dấu đã đọc
- ✅ Hiển thị avatar và tên người gửi

### Entity: NotificationEntity
```dart
- id: String
- userId: String
- type: String  // like, reaction, comment, share, friend_request, friend_accept, message
- fromUserId: String
- fromUserName: String
- fromUserProfileImage: String?
- postId: String?
- message: String?
- read: bool
- createdAt: DateTime
```

### Màn hình
- `NotificationPage` - Danh sách thông báo

---

## 6. Hồ sơ (Profile)

### Tính năng
- ✅ Xem hồ sơ cá nhân
- ✅ Xem hồ sơ người khác
- ✅ Chỉnh sửa thông tin (tên, bio)
- ✅ Xem bài viết của người dùng
- ✅ Xem danh sách bạn bè
- ✅ Xem ảnh đã đăng
- ✅ Kiểm tra trạng thái bạn bè (none, requestSent, requestReceived, friends)
- ✅ Xem bạn chung
- ✅ Chặn/Bỏ chặn người dùng
- ✅ Cập nhật trạng thái online

### Màn hình
- `ProfilePage` - Trang hồ sơ
- `EditProfilePage` - Chỉnh sửa hồ sơ

---

## 7. Marketplace

### Tính năng
- ✅ Xem danh sách sản phẩm
- ✅ Lọc theo danh mục (10 danh mục)
- ✅ Tìm kiếm sản phẩm
- ✅ Xem chi tiết sản phẩm
- ✅ Đăng bán sản phẩm mới
- ✅ Chỉnh sửa sản phẩm
- ✅ Xóa sản phẩm
- ✅ Đánh dấu đã bán
- ✅ Lưu/Bỏ lưu sản phẩm
- ✅ Xem sản phẩm đã lưu
- ✅ Xem sản phẩm của tôi
- ✅ Liên hệ người bán (tạo chat)
- ✅ Đếm lượt xem sản phẩm
- ✅ Hiển thị tình trạng sản phẩm (Mới, Như mới, Tốt, Khá)
- ✅ Hiển thị trạng thái (Đang bán, Đang chờ, Đã bán)

### Entity: ProductEntity
```dart
- id: String
- sellerId: String
- sellerName: String
- sellerProfileImage: String?
- title: String
- description: String
- price: double
- category: String
- condition: ProductCondition  // newProduct, likeNew, good, fair
- status: ProductStatus  // available, pending, sold
- images: List<String>
- location: String?
- latitude: double?
- longitude: double?
- createdAt: DateTime
- updatedAt: DateTime?
- viewCount: int
- savedBy: List<String>
```

### Danh mục sản phẩm
1. Xe cộ
2. Đồ điện tử
3. Bất động sản
4. Thời trang
5. Đồ gia dụng
6. Thú cưng
7. Thể thao
8. Sách
9. Đồ chơi
10. Khác

### Màn hình
- `MarketplacePage` - Trang chính Marketplace
- `ProductDetailPage` - Chi tiết sản phẩm
- `CreateProductPage` - Đăng sản phẩm
- `MyProductsPage` - Sản phẩm của tôi
- `SavedProductsPage` - Sản phẩm đã lưu
- `SearchProductsPage` - Tìm kiếm sản phẩm

---

## 8. Watch (Video)

### Tính năng
- ✅ Xem danh sách video
- ✅ Phân loại video theo danh mục (9 danh mục)
- ✅ Tìm kiếm video
- ✅ Xem chi tiết video
- ✅ Phát video
- ✅ Like/Unlike video
- ✅ Lưu/Bỏ lưu video
- ✅ Xem video đã lưu
- ✅ Xem video từ kênh đang theo dõi
- ✅ Follow/Unfollow kênh
- ✅ Đếm lượt xem
- ✅ Hiển thị thống kê (views, likes, comments, shares)
- ✅ Tích hợp Pexels API để lấy video thực
- ✅ Fallback mock data khi API lỗi

### Entity: VideoEntity
```dart
- id: String
- title: String
- description: String
- videoUrl: String
- thumbnailUrl: String
- channelId: String
- channelName: String
- channelAvatar: String?
- duration: int  // seconds
- viewCount: int
- likeCount: int
- commentCount: int
- shareCount: int
- likes: Map<String, bool>
- saved: Map<String, bool>
- createdAt: DateTime
- category: String
- isLive: bool
```

### Danh mục video
1. Dành cho bạn
2. Trực tiếp
3. Gaming
4. Theo dõi
5. Đã lưu
6. Âm nhạc
7. Thể thao
8. Tin tức
9. Giải trí

### Màn hình
- `WatchPage` - Trang chính Watch
- `VideoDetailPage` - Chi tiết video
- `SearchVideoPage` - Tìm kiếm video
- `WatchStatsPage` - Thống kê xem

### Widgets
- `VideoCard` - Card hiển thị video
- `VideoPlayerWidget` - Widget phát video
- `WatchStatsWidget` - Widget thống kê

---

## 9. Story

### Tính năng
> ⚠️ **Đang phát triển** - Cấu trúc folder đã có nhưng chưa implement

Dự kiến:
- Xem story của bạn bè
- Tạo story (ảnh/video)
- Story tự động hết hạn sau 24h
- Xem ai đã xem story

---

## 10. Menu

### Tính năng
- ✅ Trang menu chính với các shortcut
- ✅ Điều hướng đến các tính năng

### Màn hình
- `MenuPage` - Trang menu

---

## Công nghệ sử dụng

### Frontend
- **Flutter** 3.x
- **Provider** - State management
- **go_router** - Navigation
- **cached_network_image** - Cache hình ảnh
- **video_player** - Phát video
- **lottie** - Animations
- **shimmer** - Loading effects
- **emoji_picker_flutter** - Chọn emoji
- **flutter_chat_bubble** - UI chat

### Backend
- **Firebase Authentication** - Xác thực
- **Firebase Realtime Database** - Database
- **Firebase Storage** - Lưu trữ media
- **Firebase Messaging** - Push notifications

### APIs bên ngoài
- **Pexels API** - Video content cho Watch

### Utilities
- **intl** - Internationalization
- **timeago** - Format thời gian
- **uuid** - Generate unique IDs
- **http/dio** - HTTP requests

---

## 📊 Tổng kết

| Feature | Trạng thái | Số màn hình |
|---------|------------|-------------|
| Authentication | ✅ Hoàn thành | 4 |
| Posts | ✅ Hoàn thành | 3 |
| Chat | ✅ Hoàn thành | 2 |
| Friends | ✅ Hoàn thành | 2 |
| Notifications | ✅ Hoàn thành | 1 |
| Profile | ✅ Hoàn thành | 2 |
| Marketplace | ✅ Hoàn thành | 6 |
| Watch | ✅ Hoàn thành | 4 |
| Story | 🚧 Đang phát triển | 0 |
| Menu | ✅ Hoàn thành | 1 |

**Tổng cộng: 25 màn hình, 9/10 features hoàn thành**

---

*Cập nhật lần cuối: Tháng 12, 2025*
