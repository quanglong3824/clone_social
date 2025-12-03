# Firebase Realtime Database Rules

## Cách deploy rules

1. Vào [Firebase Console](https://console.firebase.google.com)
2. Chọn project `social-home-9eb59`
3. Vào **Realtime Database** > **Rules**
4. Copy toàn bộ nội dung từ file `firebase_database_rules.json`
5. Paste vào editor và click **Publish**

## Giải thích Rules

### Users (`/users`)
- **Read**: Tất cả users đã đăng nhập có thể đọc danh sách users (cho tính năng tìm kiếm, gợi ý bạn bè)
- **Write**: Chỉ user đó mới có thể sửa profile của mình
- **Friends**: Cả 2 user đều có thể thêm/xóa quan hệ bạn bè

### Posts (`/posts`)
- **Read**: Tất cả users đã đăng nhập có thể đọc posts
- **Write**: Chỉ tác giả mới có thể sửa/xóa post
- **Reactions/Likes**: User chỉ có thể thêm/xóa reaction của chính mình
- **Comments**: User chỉ có thể sửa/xóa comment của chính mình

### Friend Requests (`/friendRequests`)
- **Read**: User có thể đọc requests gửi đến mình
- **Write**: 
  - Người gửi có thể tạo request mới
  - Người nhận có thể accept/reject
  - Người gửi có thể hủy request

### Notifications (`/notifications`)
- **Read**: User chỉ đọc được notifications của mình
- **Write**: 
  - User có thể mark as read/delete notifications của mình
  - Bất kỳ ai cũng có thể tạo notification mới cho user khác

### Chats & Messages
- **userChats**: User chỉ đọc được danh sách chat của mình
- **messages**: User chỉ đọc/gửi tin nhắn trong chat mà mình tham gia
- **typing**: User chỉ có thể set typing status của mình

### Stories (`/stories`)
- **Read**: Tất cả users đã đăng nhập có thể xem stories
- **Write**: Chỉ tác giả mới có thể tạo/xóa story
- **viewerIds**: User có thể đánh dấu đã xem story

## Indexes

Các indexes được thêm để tối ưu query:
- `users`: name, email, createdAt
- `posts`: userId, createdAt
- `friendRequests`: fromUserId, status, createdAt
- `userChats`: lastMessageTime
- `messages`: createdAt, senderId
- `notifications`: createdAt, read, type
- `stories`: userId, createdAt, expiresAt

## Test Rules

Sau khi deploy, test các tính năng:
1. ✅ Đăng ký/Đăng nhập
2. ✅ Tìm kiếm users
3. ✅ Gợi ý bạn bè
4. ✅ Gửi lời mời kết bạn
5. ✅ Nhận thông báo lời mời
6. ✅ Accept/Reject lời mời
7. ✅ Danh sách bạn bè
8. ✅ Nhắn tin với bạn bè
9. ✅ Tạo/xem posts
10. ✅ Like/Comment posts
11. ✅ Tạo/xem stories
