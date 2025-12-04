# 📱 Facebook Clone - Flutter App

Ứng dụng mạng xã hội clone Facebook đầy đủ tính năng, được xây dựng bằng Flutter và Firebase Realtime Database, hỗ trợ cả mobile và web.

## ✨ Tính năng chính

### 🔐 Xác thực (Authentication)
- ✅ Đăng ký tài khoản
- ✅ Đăng nhập Email/Password
- ✅ Đăng nhập Google
- ✅ Quên mật khẩu
- ✅ Theo dõi trạng thái online/offline

### 📝 Bài viết (Posts)
- ✅ Tạo bài viết (Text, Hình ảnh, Video)
- ✅ Hệ thống Reactions (6 loại: Like, Love, Haha, Wow, Sad, Angry)
- ✅ Bình luận & Trả lời bình luận
- ✅ Chia sẻ bài viết
- ✅ Xóa bài viết
- ✅ Cập nhật realtime

### 💬 Nhắn tin (Chat)
- ✅ Danh sách cuộc trò chuyện
- ✅ Gửi tin nhắn text & hình ảnh
- ✅ Typing indicator
- ✅ Đánh dấu đã đọc
- ✅ Tìm kiếm tin nhắn
- ✅ Xóa cuộc trò chuyện

### 👥 Bạn bè (Friends)
- ✅ Tìm kiếm người dùng
- ✅ Gửi/Nhận lời mời kết bạn
- ✅ Chấp nhận/Từ chối lời mời
- ✅ Hủy kết bạn

### 👤 Hồ sơ (Profile)
- ✅ Xem/Chỉnh sửa hồ sơ
- ✅ Xem bài viết của người dùng
- ✅ Xem danh sách bạn bè
- ✅ Chặn/Bỏ chặn người dùng

### 🛒 Marketplace
- ✅ Đăng bán sản phẩm
- ✅ Tìm kiếm & Lọc theo danh mục
- ✅ Lưu sản phẩm yêu thích
- ✅ Liên hệ người bán
- ✅ Quản lý sản phẩm của tôi

### 🎬 Watch (Video)
- ✅ Xem danh sách video
- ✅ Phân loại theo danh mục
- ✅ Like/Lưu video
- ✅ Follow kênh
- ✅ Tích hợp Pexels API

### 🔔 Thông báo
- ✅ Thông báo reaction/comment/share
- ✅ Thông báo lời mời kết bạn
- ✅ Thông báo tin nhắn mới
- ✅ Đánh dấu đã đọc

---

## 📱 Danh sách màn hình (28 màn hình)

### 🔐 Authentication (4 màn hình)
| Màn hình | Route | Mô tả |
|----------|-------|-------|
| Splash | `/splash` | Màn hình khởi động |
| Đăng nhập | `/login` | Đăng nhập tài khoản |
| Đăng ký | `/register` | Tạo tài khoản mới |
| Quên mật khẩu | `/forgot-password` | Reset mật khẩu |

### 🏠 Main Navigation (7 tab)
| Màn hình | Route | Tab |
|----------|-------|-----|
| Trang chủ | `/` | 0 |
| Bạn bè | `/friends` | 1 |
| Chat | `/chat` | 2 |
| Watch | `/watch` | 3 |
| Marketplace | `/marketplace` | 4 |
| Thông báo | `/notifications` | 5 |
| Menu | `/menu` | 6 |

### 📝 Post (2 màn hình phụ)
| Màn hình | Route |
|----------|-------|
| Tạo bài viết | `/create-post` |
| Chi tiết bài viết | `/post/:postId` |

### 💬 Chat (1 màn hình phụ)
| Màn hình | Route |
|----------|-------|
| Chi tiết chat | `/chat/:chatId` |

### 👥 Friends (1 màn hình phụ)
| Màn hình | Route |
|----------|-------|
| Tìm kiếm người dùng | `/search-users` |

### 👤 Profile (2 màn hình)
| Màn hình | Route |
|----------|-------|
| Xem hồ sơ | `/profile/:userId` |
| Chỉnh sửa hồ sơ | `/edit-profile` |

### 🛒 Marketplace (5 màn hình phụ)
| Màn hình | Route |
|----------|-------|
| Tạo sản phẩm | `/marketplace/create` |
| Chi tiết sản phẩm | `/marketplace/product/:productId` |
| Sản phẩm của tôi | `/marketplace/my-products` |
| Sản phẩm đã lưu | `/marketplace/saved` |
| Tìm kiếm sản phẩm | `/marketplace/search` |

### 🎬 Watch (3 màn hình phụ)
| Màn hình | Navigation |
|----------|------------|
| Chi tiết video | Push navigation |
| Tìm kiếm video | Push navigation |
| Thống kê xem | Bottom sheet |

---

## 🛠 Tech Stack

| Công nghệ | Mục đích |
|-----------|----------|
| **Flutter 3.x** | Framework chính |
| **Firebase Auth** | Xác thực |
| **Firebase Realtime Database** | Database |
| **Firebase Storage** | Lưu trữ media |
| **Provider** | State management |
| **go_router** | Navigation |
| **Pexels API** | Video content |

---

## 📁 Cấu trúc dự án

```
lib/
├── core/                    # Core modules
│   ├── animations/         # Animation utilities
│   ├── constants/          # Hằng số
│   ├── routes/             # Định tuyến (go_router)
│   ├── services/           # Firebase services
│   ├── themes/             # Theme (Light/Dark)
│   ├── utils/              # Tiện ích
│   └── widgets/            # Widget dùng chung
├── features/               # Các tính năng
│   ├── auth/              # Xác thực
│   ├── chat/              # Nhắn tin
│   ├── friend/            # Bạn bè
│   ├── marketplace/       # Marketplace
│   ├── menu/              # Menu
│   ├── notification/      # Thông báo
│   ├── post/              # Bài viết
│   ├── profile/           # Hồ sơ
│   └── watch/             # Video
└── main.dart

assets/
├── animations/            # Lottie animations
├── fonts/                 # Custom fonts
├── icons/                 # Icon assets
└── images/                # Image assets
```

Mỗi feature có cấu trúc Clean Architecture:
```
feature/
├── data/
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Entity models
│   └── repositories/      # Repository interfaces
└── presentation/
    ├── pages/             # UI pages
    ├── providers/         # State management
    └── widgets/           # Feature widgets
```

---

## 🚀 Bắt đầu

### Yêu cầu
- Flutter SDK >= 3.0.0
- Firebase account
- Android Studio / VS Code

### Cài đặt

```bash
# Clone repository
git clone <repository-url>
cd clone_social

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run

# Chạy trên web
flutter run -d chrome
```

### Cấu hình Firebase
1. Tạo Firebase project
2. Thêm Android/iOS/Web apps
3. Download và đặt file cấu hình:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Cập nhật `lib/firebase_options.dart`

---

## 📊 Database Structure

```json
{
  "users": { "userId": { "name", "email", "profileImage", "friends", "isOnline" } },
  "posts": { "postId": { "userId", "content", "images", "reactions", "commentCount" } },
  "comments": { "postId": { "commentId": { "userId", "text", "likes", "replyCount" } } },
  "chats": { "chatId": { "participants", "lastMessage", "unreadCount" } },
  "messages": { "chatId": { "messageId": { "senderId", "text", "type", "read" } } },
  "friendRequests": { "userId": { "requestId": { "fromUserId", "status" } } },
  "notifications": { "userId": { "notificationId": { "type", "fromUserId", "read" } } },
  "products": { "productId": { "sellerId", "title", "price", "category", "status" } }
}
```

---

## 🎨 Animations

App sử dụng smooth animations cho UX tốt hơn:
- **FadeIn/SlideIn**: Hiệu ứng xuất hiện
- **TapScale**: Hiệu ứng nhấn button
- **AnimatedListItem**: Staggered list animation
- **Shimmer Loading**: Loading placeholders
- **Page Transitions**: Smooth navigation

---

## 📈 Tổng kết

| Feature | Trạng thái | Màn hình |
|---------|------------|----------|
| Authentication | ✅ | 4 |
| Posts | ✅ | 3 |
| Chat | ✅ | 2 |
| Friends | ✅ | 2 |
| Profile | ✅ | 2 |
| Marketplace | ✅ | 6 |
| Watch | ✅ | 4 |
| Notifications | ✅ | 1 |
| Menu | ✅ | 1 |
| Story | 🚧 | 0 |

**Tổng: 28 màn hình, 9/10 features hoàn thành**

---

## 📄 License

Dự án này chỉ dành cho mục đích học tập.

*Cập nhật: Tháng 12, 2025*
