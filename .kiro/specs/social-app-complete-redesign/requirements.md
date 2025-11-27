# Requirements Document

## Introduction

Tài liệu này mô tả các yêu cầu để hoàn thiện ứng dụng clone mạng xã hội (Facebook Clone) với Flutter và Firebase. Dự án bao gồm việc cải thiện các tính năng hiện có và viết lại toàn bộ giao diện theo phong cách hiện đại, mượt mà hơn.

## Glossary

- **Social_App**: Ứng dụng mạng xã hội clone Facebook
- **User**: Người dùng đã đăng ký và đăng nhập vào hệ thống
- **Post**: Bài đăng của người dùng (text, hình ảnh, video)
- **Feed**: Danh sách bài đăng trên trang chủ
- **Story**: Nội dung tạm thời hiển thị 24 giờ
- **Chat**: Cuộc hội thoại giữa hai người dùng
- **Message**: Tin nhắn trong cuộc hội thoại
- **Notification**: Thông báo về hoạt động liên quan đến người dùng
- **Friend**: Người dùng đã kết bạn với nhau
- **Profile**: Trang cá nhân của người dùng
- **Marketplace**: Chợ mua bán sản phẩm
- **Watch**: Trang xem video
- **UI_Component**: Thành phần giao diện có thể tái sử dụng

## Requirements

### Requirement 1: Cải thiện hệ thống Authentication

**User Story:** Là một người dùng, tôi muốn có trải nghiệm đăng nhập/đăng ký mượt mà và đẹp mắt, để tôi có ấn tượng tốt ngay từ đầu.

#### Acceptance Criteria

1. WHEN User mở ứng dụng lần đầu THEN Social_App SHALL hiển thị màn hình splash với animation logo trong 2 giây
2. WHEN User nhập email không hợp lệ THEN Social_App SHALL hiển thị thông báo lỗi inline ngay dưới trường nhập
3. WHEN User đăng nhập thành công THEN Social_App SHALL chuyển đến trang chủ với animation fade transition
4. WHEN User đăng ký tài khoản mới THEN Social_App SHALL yêu cầu xác thực email trước khi cho phép đăng nhập
5. WHEN User quên mật khẩu THEN Social_App SHALL gửi email reset password và hiển thị thông báo xác nhận

### Requirement 2: Thiết kế lại trang chủ (Home Feed)

**User Story:** Là một người dùng, tôi muốn trang chủ hiển thị nội dung hấp dẫn và dễ tương tác, để tôi có thể theo dõi hoạt động của bạn bè.

#### Acceptance Criteria

1. WHEN User mở trang chủ THEN Social_App SHALL hiển thị Stories bar ở đầu trang với khả năng cuộn ngang
2. WHEN User kéo xuống để refresh THEN Social_App SHALL tải lại danh sách bài đăng mới nhất
3. WHEN User cuộn qua bài đăng THEN Social_App SHALL lazy load thêm bài đăng khi còn 3 bài cuối
4. WHEN User nhấn vào nút tạo bài đăng THEN Social_App SHALL mở bottom sheet với các tùy chọn (text, photo, video)
5. WHEN User xem bài đăng có hình ảnh THEN Social_App SHALL hiển thị hình ảnh với khả năng zoom và swipe gallery

### Requirement 3: Hoàn thiện tính năng Stories

**User Story:** Là một người dùng, tôi muốn đăng và xem Stories của bạn bè, để tôi có thể chia sẻ khoảnh khắc ngắn.

#### Acceptance Criteria

1. WHEN User tạo Story mới THEN Social_App SHALL cho phép chọn ảnh hoặc video từ thư viện hoặc camera
2. WHEN User xem Story THEN Social_App SHALL hiển thị fullscreen với progress bar và auto-advance sau 5 giây
3. WHEN Story đã tồn tại quá 24 giờ THEN Social_App SHALL tự động xóa Story khỏi danh sách hiển thị
4. WHEN User nhấn giữ Story THEN Social_App SHALL tạm dừng progress bar để xem lâu hơn
5. WHEN User vuốt sang trái/phải THEN Social_App SHALL chuyển đến Story tiếp theo hoặc trước đó

### Requirement 4: Cải thiện tính năng Post

**User Story:** Là một người dùng, tôi muốn tạo và tương tác với bài đăng một cách dễ dàng, để tôi có thể chia sẻ và kết nối với bạn bè.

#### Acceptance Criteria

1. WHEN User tạo bài đăng với nhiều ảnh THEN Social_App SHALL hiển thị grid layout tối đa 4 ảnh với indicator số ảnh còn lại
2. WHEN User nhấn nút Like THEN Social_App SHALL cập nhật số lượng like với animation heart
3. WHEN User nhấn giữ nút Like THEN Social_App SHALL hiển thị reaction picker (like, love, haha, wow, sad, angry)
4. WHEN User viết comment THEN Social_App SHALL hiển thị comment mới ngay lập tức với optimistic update
5. WHEN User nhấn Share THEN Social_App SHALL hiển thị bottom sheet với các tùy chọn chia sẻ

### Requirement 5: Hoàn thiện tính năng Chat

**User Story:** Là một người dùng, tôi muốn nhắn tin với bạn bè một cách mượt mà, để tôi có thể giao tiếp hiệu quả.

#### Acceptance Criteria

1. WHEN User mở cuộc chat THEN Social_App SHALL hiển thị tin nhắn với bubble style và timestamp
2. WHEN User gửi tin nhắn THEN Social_App SHALL hiển thị trạng thái gửi (sending, sent, delivered, read)
3. WHEN User đang nhập tin nhắn THEN Social_App SHALL hiển thị typing indicator cho người nhận
4. WHEN User gửi hình ảnh trong chat THEN Social_App SHALL hiển thị preview và progress upload
5. WHEN User nhận tin nhắn mới THEN Social_App SHALL hiển thị notification và badge count trên icon chat
6. WHEN User vuốt tin nhắn sang phải THEN Social_App SHALL hiển thị tùy chọn reply to message

### Requirement 6: Thiết kế lại Profile Page

**User Story:** Là một người dùng, tôi muốn trang cá nhân hiển thị đầy đủ thông tin và đẹp mắt, để tôi có thể thể hiện bản thân.

#### Acceptance Criteria

1. WHEN User xem profile THEN Social_App SHALL hiển thị cover photo với parallax effect khi cuộn
2. WHEN User chỉnh sửa profile THEN Social_App SHALL cho phép crop ảnh đại diện và cover photo
3. WHEN User xem tab Photos THEN Social_App SHALL hiển thị grid gallery với khả năng xem fullscreen
4. WHEN User xem tab Friends THEN Social_App SHALL hiển thị danh sách bạn bè với avatar và tên
5. WHEN User nhấn nút Edit Profile THEN Social_App SHALL mở form chỉnh sửa với các trường thông tin

### Requirement 7: Cải thiện tính năng Friends

**User Story:** Là một người dùng, tôi muốn quản lý danh sách bạn bè và lời mời kết bạn dễ dàng, để tôi có thể mở rộng mạng lưới.

#### Acceptance Criteria

1. WHEN User tìm kiếm bạn bè THEN Social_App SHALL hiển thị kết quả realtime khi gõ với debounce 300ms
2. WHEN User gửi lời mời kết bạn THEN Social_App SHALL cập nhật trạng thái nút thành "Đã gửi lời mời"
3. WHEN User nhận lời mời kết bạn THEN Social_App SHALL hiển thị notification và badge trên tab Friends
4. WHEN User chấp nhận lời mời THEN Social_App SHALL thêm người đó vào danh sách bạn bè ngay lập tức
5. WHEN User xem gợi ý kết bạn THEN Social_App SHALL hiển thị danh sách người dùng có bạn chung

### Requirement 8: Hoàn thiện Notification System

**User Story:** Là một người dùng, tôi muốn nhận thông báo về các hoạt động liên quan, để tôi không bỏ lỡ điều gì.

#### Acceptance Criteria

1. WHEN có hoạt động mới THEN Social_App SHALL gửi push notification với nội dung phù hợp
2. WHEN User mở trang Notifications THEN Social_App SHALL hiển thị danh sách thông báo với icon theo loại
3. WHEN User nhấn vào notification THEN Social_App SHALL điều hướng đến nội dung liên quan
4. WHEN User vuốt notification sang trái THEN Social_App SHALL hiển thị nút xóa notification
5. WHEN User nhấn "Mark all as read" THEN Social_App SHALL đánh dấu tất cả thông báo đã đọc

### Requirement 9: Thiết kế lại Watch Page

**User Story:** Là một người dùng, tôi muốn xem video một cách thoải mái, để tôi có thể giải trí.

#### Acceptance Criteria

1. WHEN User mở Watch page THEN Social_App SHALL hiển thị danh sách video với thumbnail và thông tin
2. WHEN User nhấn vào video THEN Social_App SHALL phát video fullscreen với controls
3. WHEN User cuộn qua video THEN Social_App SHALL auto-play video tiếp theo khi video hiện tại kết thúc
4. WHEN User nhấn nút mute THEN Social_App SHALL tắt/bật âm thanh video
5. WHEN User vuốt lên/xuống THEN Social_App SHALL chuyển đến video tiếp theo/trước đó (TikTok style)

### Requirement 10: Hoàn thiện Marketplace

**User Story:** Là một người dùng, tôi muốn mua bán sản phẩm trên marketplace, để tôi có thể giao dịch với cộng đồng.

#### Acceptance Criteria

1. WHEN User mở Marketplace THEN Social_App SHALL hiển thị danh sách sản phẩm theo grid với filter categories
2. WHEN User tạo listing mới THEN Social_App SHALL cho phép upload nhiều ảnh và nhập thông tin sản phẩm
3. WHEN User tìm kiếm sản phẩm THEN Social_App SHALL hiển thị kết quả với filter theo giá và vị trí
4. WHEN User nhấn vào sản phẩm THEN Social_App SHALL hiển thị chi tiết với gallery ảnh và nút liên hệ
5. WHEN User nhấn "Message Seller" THEN Social_App SHALL tạo cuộc chat với người bán

### Requirement 11: Thiết kế UI Components tái sử dụng

**User Story:** Là một developer, tôi muốn có bộ UI components nhất quán, để tôi có thể phát triển nhanh và đồng bộ.

#### Acceptance Criteria

1. THE Social_App SHALL sử dụng design system với màu sắc, typography, spacing nhất quán
2. THE Social_App SHALL có custom buttons với các variants (primary, secondary, outline, text)
3. THE Social_App SHALL có custom input fields với validation states (normal, focus, error, disabled)
4. THE Social_App SHALL có custom cards với shadow và border radius theo design system
5. THE Social_App SHALL có loading states (shimmer, skeleton) cho tất cả danh sách

### Requirement 12: Cải thiện Navigation và UX

**User Story:** Là một người dùng, tôi muốn điều hướng trong app mượt mà và trực quan, để tôi có trải nghiệm tốt.

#### Acceptance Criteria

1. WHEN User chuyển tab THEN Social_App SHALL sử dụng smooth animation transition
2. WHEN User nhấn back THEN Social_App SHALL quay lại màn hình trước với animation phù hợp
3. WHEN User double-tap bottom nav icon THEN Social_App SHALL scroll to top của danh sách
4. THE Social_App SHALL hiển thị bottom navigation bar với 5 tabs chính (Home, Friends, Watch, Marketplace, Menu)
5. WHEN User ở màn hình con THEN Social_App SHALL ẩn bottom navigation bar

### Requirement 13: Dark Mode và Theming

**User Story:** Là một người dùng, tôi muốn sử dụng dark mode, để tôi có thể bảo vệ mắt khi dùng app ban đêm.

#### Acceptance Criteria

1. WHEN User bật dark mode THEN Social_App SHALL chuyển đổi toàn bộ giao diện sang theme tối
2. THE Social_App SHALL tự động theo system theme nếu user chưa chọn preference
3. WHEN User chuyển theme THEN Social_App SHALL animate smooth transition giữa light và dark
4. THE Social_App SHALL lưu theme preference vào local storage
5. THE Social_App SHALL đảm bảo contrast ratio đạt chuẩn WCAG AA cho cả hai themes

