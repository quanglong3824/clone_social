# Design Document

## Overview

Tài liệu này mô tả thiết kế kỹ thuật để hoàn thiện ứng dụng clone mạng xã hội Facebook với Flutter và Firebase. Thiết kế tập trung vào việc cải thiện UX/UI, hoàn thiện các tính năng còn thiếu, và xây dựng hệ thống component tái sử dụng.

### Mục tiêu chính:
- Viết lại giao diện theo phong cách hiện đại, mượt mà
- Hoàn thiện các tính năng: Stories, Chat, Marketplace, Watch
- Xây dựng Design System nhất quán
- Tối ưu performance và UX

### Tech Stack:
- Flutter 3.x với Material Design 3
- Firebase (Auth, Realtime Database, Storage, Cloud Messaging)
- Provider cho State Management
- GoRouter cho Navigation

## Architecture

```
lib/
├── core/
│   ├── constants/          # App constants, API endpoints
│   ├── routes/             # GoRouter configuration
│   ├── services/           # Firebase services, local storage
│   ├── themes/             # Design system, themes
│   ├── utils/              # Helpers, extensions
│   └── widgets/            # Shared UI components
│
├── features/
│   ├── auth/               # Authentication feature
│   ├── chat/               # Messaging feature
│   ├── friend/             # Friends management
│   ├── marketplace/        # Marketplace feature
│   ├── menu/               # Settings & menu
│   ├── notification/       # Notifications
│   ├── post/               # Posts & feed
│   ├── profile/            # User profiles
│   ├── story/              # Stories feature (NEW)
│   └── watch/              # Video watching
│
└── main.dart
```

### Feature Structure (Clean Architecture):
```
feature/
├── data/
│   ├── models/             # Data models with JSON serialization
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business entities
│   └── repositories/       # Repository interfaces
└── presentation/
    ├── pages/              # Screen widgets
    ├── providers/          # State management
    └── widgets/            # Feature-specific widgets
```

## Components and Interfaces

### 1. Design System Components

#### AppButton
```dart
enum ButtonVariant { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
}
```

#### AppTextField
```dart
enum TextFieldState { normal, focused, error, disabled }

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
}
```

#### AppCard
```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final VoidCallback? onTap;
}
```

#### ShimmerLoading
```dart
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
}

class PostShimmer extends StatelessWidget {} // Shimmer cho post item
class StoryShimmer extends StatelessWidget {} // Shimmer cho story item
class ChatShimmer extends StatelessWidget {}  // Shimmer cho chat item
```

### 2. Story Feature Components

#### StoryEntity
```dart
class StoryEntity {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String mediaUrl;
  final String mediaType; // 'image' | 'video'
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewerIds;
}
```

#### StoryRepository Interface
```dart
abstract class StoryRepository {
  Stream<List<StoryEntity>> getStories(String userId);
  Future<void> createStory(String userId, File media, String mediaType);
  Future<void> markStoryAsViewed(String storyId, String viewerId);
  Future<void> deleteExpiredStories();
}
```

### 3. Enhanced Chat Components

#### MessageStatus Enum
```dart
enum MessageStatus { sending, sent, delivered, read }
```

#### Enhanced MessageEntity
```dart
class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderProfileImage;
  final String text;
  final String type; // text, image, video, reply
  final String? mediaUrl;
  final DateTime createdAt;
  final MessageStatus status;
  final String? replyToMessageId;
  final String? replyToText;
}
```

#### TypingIndicator
```dart
class TypingIndicator extends StatelessWidget {
  final bool isTyping;
  final String userName;
}
```

### 4. Marketplace Components

#### ProductEntity
```dart
class ProductEntity {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerProfileImage;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String category;
  final String location;
  final DateTime createdAt;
  final bool isSold;
}
```

#### MarketplaceRepository Interface
```dart
abstract class MarketplaceRepository {
  Stream<List<ProductEntity>> getProducts({String? category, String? searchQuery});
  Future<ProductEntity> getProductById(String productId);
  Future<void> createProduct(ProductEntity product, List<File> images);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String productId);
  Future<void> markAsSold(String productId);
}
```

### 5. Watch/Video Components

#### VideoEntity
```dart
class VideoEntity {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String? description;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
}
```

## Data Models

### Firebase Database Structure

```
/users/{userId}
  - name: string
  - email: string
  - profileImage: string?
  - coverImage: string?
  - bio: string?
  - createdAt: timestamp

/posts/{postId}
  - userId: string
  - content: string
  - imageUrls: string[]
  - videoUrl: string?
  - createdAt: timestamp
  - likeCount: number
  - commentCount: number
  - shareCount: number

/posts/{postId}/reactions/{reactionId}
  - userId: string
  - type: string (like, love, haha, wow, sad, angry)
  - createdAt: timestamp

/stories/{storyId}
  - userId: string
  - mediaUrl: string
  - mediaType: string
  - createdAt: timestamp
  - expiresAt: timestamp
  - viewerIds: string[]

/userChats/{userId}/{chatId}
  - participants: string[]
  - lastMessage: string
  - lastMessageTime: timestamp
  - lastMessageSenderId: string
  - unreadCount: number
  - participantInfo: map
  - typingUsers: map

/messages/{chatId}/{messageId}
  - senderId: string
  - content: string
  - imageUrl: string?
  - videoUrl: string?
  - createdAt: timestamp
  - status: string
  - replyToMessageId: string?
  - replyToText: string?

/products/{productId}
  - sellerId: string
  - title: string
  - description: string
  - price: number
  - currency: string
  - imageUrls: string[]
  - category: string
  - location: string
  - createdAt: timestamp
  - isSold: boolean

/videos/{videoId}
  - userId: string
  - videoUrl: string
  - thumbnailUrl: string
  - title: string
  - description: string?
  - viewCount: number
  - likeCount: number
  - commentCount: number
  - createdAt: timestamp
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

Sau khi phân tích các acceptance criteria, tôi đã xác định các properties có thể test được và loại bỏ các properties trùng lặp:

- Properties về validation (email, input) có thể gộp thành property chung về input validation
- Properties về badge count (chat, friends, notifications) có thể gộp thành property chung về badge increment
- Properties về navigation có thể gộp thành property chung về navigation behavior

### Correctness Properties

**Property 1: Email Validation Rejection**
*For any* string that does not match email regex pattern, the validation function SHALL return false and display error message.
**Validates: Requirements 1.2**

**Property 2: Story Expiration**
*For any* story with createdAt timestamp older than 24 hours, the story SHALL NOT appear in the stories list.
**Validates: Requirements 3.3**

**Property 3: Post Image Grid Layout**
*For any* post with N images where N > 0, the grid SHALL display min(N, 4) images with correct layout and show "+X" indicator when N > 4.
**Validates: Requirements 4.1**

**Property 4: Like Count Increment**
*For any* post, when a user likes it, the likeCount SHALL increase by exactly 1, and when unliked, SHALL decrease by exactly 1.
**Validates: Requirements 4.2**

**Property 5: Comment Optimistic Update**
*For any* comment submission, the comment SHALL appear in the UI immediately before server confirmation.
**Validates: Requirements 4.4**

**Property 6: Message Status Transition**
*For any* message, the status SHALL transition in order: sending → sent → delivered → read, and SHALL NOT skip or reverse states.
**Validates: Requirements 5.2**

**Property 7: Typing Indicator Visibility**
*For any* chat where user A is typing, user B SHALL see the typing indicator within 500ms, and indicator SHALL disappear within 2 seconds after typing stops.
**Validates: Requirements 5.3**

**Property 8: Unread Badge Increment**
*For any* new message received, the unread badge count SHALL increase by exactly 1.
**Validates: Requirements 5.5**

**Property 9: Search Debounce and Results**
*For any* search query, results SHALL only be fetched after 300ms of no typing, and all results SHALL contain the search term.
**Validates: Requirements 7.1**

**Property 10: Friend Request State Change**
*For any* friend request sent, the button state SHALL change from "Add Friend" to "Request Sent" immediately.
**Validates: Requirements 7.2**

**Property 11: Friend List Update on Accept**
*For any* accepted friend request, both users' friend lists SHALL contain each other immediately after acceptance.
**Validates: Requirements 7.4**

**Property 12: Notification Icon by Type**
*For any* notification, the displayed icon SHALL match the notification type (like → heart, comment → chat, friend → person).
**Validates: Requirements 8.2**

**Property 13: Notification Navigation**
*For any* notification tap, the app SHALL navigate to the correct destination based on notification type and associated content ID.
**Validates: Requirements 8.3**

**Property 14: Mark All Read**
*For any* "mark all as read" action, all notifications for that user SHALL have read = true.
**Validates: Requirements 8.5**

**Property 15: Product Search Filter**
*For any* product search with filters, all returned products SHALL match the search query AND all applied filters.
**Validates: Requirements 10.3**

**Property 16: Message Seller Chat Creation**
*For any* "Message Seller" action, a chat SHALL be created with the correct seller as participant.
**Validates: Requirements 10.5**

**Property 17: Button Variant Styling**
*For any* AppButton with a given variant, the rendered button SHALL have the correct colors, borders, and text style for that variant.
**Validates: Requirements 11.2**

**Property 18: Input Field State Styling**
*For any* AppTextField with a given state, the rendered field SHALL have the correct border color, background, and icon for that state.
**Validates: Requirements 11.3**

**Property 19: Navigation Back Behavior**
*For any* back navigation action, the app SHALL return to the previous screen in the navigation stack.
**Validates: Requirements 12.2**

**Property 20: Dark Mode Color Application**
*For any* UI component when dark mode is enabled, the component SHALL use colors from the dark theme palette.
**Validates: Requirements 13.1**

**Property 21: Theme Persistence**
*For any* theme preference change, the preference SHALL be saved to local storage and restored on app restart.
**Validates: Requirements 13.4**

## Error Handling

### Network Errors
- Hiển thị snackbar với message lỗi và nút retry
- Cache data offline với Hive/SharedPreferences
- Optimistic updates với rollback khi fail

### Validation Errors
- Inline error messages dưới input fields
- Disable submit button khi form invalid
- Real-time validation khi user typing

### Firebase Errors
- Auth errors: Hiển thị message cụ thể (wrong password, user not found, etc.)
- Database errors: Retry với exponential backoff
- Storage errors: Show upload progress và retry option

### UI Error States
- Empty states với illustration và action button
- Error states với retry button
- Loading states với shimmer/skeleton

## Testing Strategy

### Property-Based Testing Library
Sử dụng `glados` package cho Dart property-based testing.

```yaml
dev_dependencies:
  glados: ^0.0.5
```

### Unit Tests
- Test validation functions (email, password, etc.)
- Test data transformations (entity to model, etc.)
- Test business logic trong providers

### Widget Tests
- Test UI components render đúng với các props
- Test user interactions (tap, swipe, etc.)
- Test navigation flows

### Property-Based Tests
Mỗi correctness property sẽ được implement bằng một property-based test:

```dart
// Example: Property 1 - Email Validation
// **Feature: social-app-complete-redesign, Property 1: Email Validation Rejection**
Glados<String>().test('invalid emails are rejected', (email) {
  final isValidFormat = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  if (!isValidFormat) {
    expect(validateEmail(email), isFalse);
  }
});
```

### Integration Tests
- Test complete user flows (login → home → create post)
- Test Firebase integration
- Test navigation stack

### Test Configuration
- Minimum 100 iterations cho mỗi property-based test
- Mock Firebase services trong unit tests
- Use golden tests cho UI consistency

