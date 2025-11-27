# Implementation Plan

## Phase 1: Design System & Core Components

- [x] 1. Thiết lập Design System và UI Components cơ bản
  - [x] 1.1 Cập nhật AppTheme với color palette mới và typography
    - Thêm semantic colors (success, warning, error, info)
    - Cập nhật spacing constants
    - _Requirements: 11.1, 13.1_
  - [x] 1.2 Tạo AppButton component với các variants
    - Implement primary, secondary, outline, text variants
    - Implement small, medium, large sizes
    - Thêm loading state với CircularProgressIndicator
    - _Requirements: 11.2_
  - [x] 1.3 Write property test cho AppButton variants
    - **Property 17: Button Variant Styling**
    - **Validates: Requirements 11.2**
  - [x] 1.4 Tạo AppTextField component với validation states
    - Implement normal, focused, error, disabled states
    - Thêm prefix/suffix icon support
    - Integrate với Form validation
    - _Requirements: 11.3_
  - [x] 1.5 Write property test cho AppTextField states
    - **Property 18: Input Field State Styling**
    - **Validates: Requirements 11.3**
  - [x] 1.6 Tạo AppCard component
    - Implement với shadow và border radius theo design system
    - Thêm onTap callback
    - _Requirements: 11.4_
  - [x] 1.7 Tạo ShimmerLoading components
    - Implement base ShimmerLoading widget
    - Tạo PostShimmer, StoryShimmer, ChatShimmer, ProductShimmer
    - _Requirements: 11.5_

- [x] 2. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 2: Authentication & Splash Screen

- [x] 3. Cải thiện Authentication UI
  - [x] 3.1 Tạo SplashPage với animation logo
    - Implement Lottie animation hoặc custom animation
    - Auto-navigate sau 2 giây
    - _Requirements: 1.1_
  - [x] 3.2 Cập nhật LoginPage với design mới
    - Sử dụng AppTextField với inline validation
    - Thêm animation transitions
    - _Requirements: 1.2, 1.3_
  - [x] 3.3 Implement email validation function
    - Validate email format với regex
    - Return error message cho invalid emails
    - _Requirements: 1.2_
  - [x] 3.4 Write property test cho email validation
    - **Property 1: Email Validation Rejection**
    - **Validates: Requirements 1.2**
  - [x] 3.5 Cập nhật RegisterPage với design mới
    - Thêm email verification flow
    - Sử dụng AppButton và AppTextField
    - _Requirements: 1.4_
  - [x] 3.6 Implement ForgotPasswordPage
    - Gửi reset email qua Firebase Auth
    - Hiển thị confirmation message
    - _Requirements: 1.5_

- [x] 4. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 3: Stories Feature

- [x] 5. Implement Stories Feature
  - [x] 5.1 Tạo StoryEntity và StoryRepository interface
    - Define entity với id, userId, mediaUrl, mediaType, createdAt, expiresAt, viewerIds
    - Define repository methods: getStories, createStory, markAsViewed, deleteExpired
    - _Requirements: 3.1, 3.2, 3.3_
  - [x] 5.2 Implement StoryRepositoryImpl với Firebase
    - Implement CRUD operations
    - Implement auto-delete logic cho stories > 24h
    - _Requirements: 3.3_
  - [x] 5.3 Write property test cho Story expiration
    - **Property 2: Story Expiration**
    - **Validates: Requirements 3.3**
  - [x] 5.4 Tạo StoryProvider cho state management
    - Manage stories list
    - Handle create, view, delete operations
    - _Requirements: 3.1, 3.2_
  - [x] 5.5 Tạo StoriesBar widget cho HomePage
    - Horizontal scrollable list
    - Hiển thị user avatar với gradient ring cho unviewed stories
    - _Requirements: 2.1_
  - [x] 5.6 Tạo StoryViewerPage
    - Fullscreen display với progress bar
    - Auto-advance sau 5 giây
    - Tap to pause, swipe to navigate
    - _Requirements: 3.2, 3.4, 3.5_
  - [x] 5.7 Tạo CreateStoryPage
    - Image/video picker từ gallery hoặc camera
    - Preview và confirm
    - _Requirements: 3.1_

- [x] 6. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 4: Enhanced Post Feature

- [-] 7. Cải thiện Post Feature
  - [x] 7.1 Cập nhật PostEntity với reactions support
    - Thêm reactions map thay vì chỉ likeCount
    - Thêm shareCount
    - _Requirements: 4.2, 4.3_
  - [x] 7.2 Implement PostImageGrid widget
    - Grid layout cho 1-4 ảnh
    - Hiển thị "+X" indicator khi > 4 ảnh
    - _Requirements: 4.1_
  - [ ] 7.3 Write property test cho PostImageGrid layout
    - **Property 3: Post Image Grid Layout**
    - **Validates: Requirements 4.1**
  - [x] 7.4 Implement ReactionPicker widget
    - Long press để hiển thị picker
    - 6 reactions: like, love, haha, wow, sad, angry
    - Animation khi chọn
    - _Requirements: 4.3_
  - [x] 7.5 Cập nhật PostProvider với reaction logic
    - Implement addReaction, removeReaction
    - Optimistic update cho UI
    - _Requirements: 4.2_
  - [ ]* 7.6 Write property test cho Like count
    - **Property 4: Like Count Increment**
    - **Validates: Requirements 4.2**
  - [x] 7.7 Cải thiện CommentSection với optimistic update
    - Hiển thị comment ngay khi submit
    - Rollback nếu server fail
    - _Requirements: 4.4_
  - [ ]* 7.8 Write property test cho Comment optimistic update
    - **Property 5: Comment Optimistic Update**
    - **Validates: Requirements 4.4**
  - [x] 7.9 Implement ShareBottomSheet
    - Options: Share to Feed, Share to Story, Copy Link, More
    - _Requirements: 4.5_
  - [ ] 7.10 Cập nhật PostItem widget với design mới
    - Sử dụng PostImageGrid
    - Thêm ReactionPicker
    - Cải thiện layout và animations
    - _Requirements: 4.1, 4.2, 4.3_

- [ ] 8. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 5: Enhanced Chat Feature

- [ ] 9. Hoàn thiện Chat Feature
  - [ ] 9.1 Cập nhật MessageEntity với status và reply support
    - Thêm MessageStatus enum
    - Thêm replyToMessageId, replyToText fields
    - _Requirements: 5.2, 5.6_
  - [ ] 9.2 Implement message status tracking trong ChatRepositoryImpl
    - Update status: sending → sent → delivered → read
    - Listen for status changes
    - _Requirements: 5.2_
  - [ ]* 9.3 Write property test cho Message status transition
    - **Property 6: Message Status Transition**
    - **Validates: Requirements 5.2**
  - [ ] 9.4 Implement TypingIndicator widget và logic
    - Update typing status trong Firebase
    - Hiển thị indicator cho recipient
    - Auto-clear sau 2 giây không typing
    - _Requirements: 5.3_
  - [ ]* 9.5 Write property test cho Typing indicator
    - **Property 7: Typing Indicator Visibility**
    - **Validates: Requirements 5.3**
  - [ ] 9.6 Implement unread badge count logic
    - Increment khi nhận message mới
    - Reset khi mở chat
    - _Requirements: 5.5_
  - [ ]* 9.7 Write property test cho Unread badge
    - **Property 8: Unread Badge Increment**
    - **Validates: Requirements 5.5**
  - [ ] 9.8 Implement reply to message feature
    - Swipe right để reply
    - Hiển thị quoted message trong input
    - _Requirements: 5.6_
  - [ ] 9.9 Cập nhật ChatDetailPage với design mới
    - Message bubbles với status indicators
    - Typing indicator
    - Reply preview
    - Image upload với progress
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.6_
  - [ ] 9.10 Cập nhật ChatListPage với design mới
    - Unread badge
    - Last message preview
    - Online status indicator
    - _Requirements: 5.5_

- [ ] 10. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 6: Friends Feature Enhancement

- [ ] 11. Cải thiện Friends Feature
  - [ ] 11.1 Implement search với debounce
    - 300ms debounce trước khi search
    - Realtime results
    - _Requirements: 7.1_
  - [ ]* 11.2 Write property test cho Search debounce
    - **Property 9: Search Debounce and Results**
    - **Validates: Requirements 7.1**
  - [ ] 11.3 Cập nhật friend request button states
    - Add Friend → Request Sent → Friends
    - Optimistic update
    - _Requirements: 7.2_
  - [ ]* 11.4 Write property test cho Friend request state
    - **Property 10: Friend Request State Change**
    - **Validates: Requirements 7.2**
  - [ ] 11.5 Implement friend list update on accept
    - Update cả hai users' friend lists
    - Send notification
    - _Requirements: 7.4_
  - [ ]* 11.6 Write property test cho Friend list update
    - **Property 11: Friend List Update on Accept**
    - **Validates: Requirements 7.4**
  - [ ] 11.7 Implement friend suggestions
    - Dựa trên mutual friends
    - Hiển thị số bạn chung
    - _Requirements: 7.5_
  - [ ] 11.8 Cập nhật FriendsPage với design mới
    - Tabs: Friends, Requests, Suggestions
    - Search bar với debounce
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 12. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 7: Notification System

- [ ] 13. Hoàn thiện Notification System
  - [ ] 13.1 Cập nhật NotificationEntity với type-specific icons
    - Map notification type to icon
    - like → heart, comment → chat, friend → person, etc.
    - _Requirements: 8.2_
  - [ ]* 13.2 Write property test cho Notification icon mapping
    - **Property 12: Notification Icon by Type**
    - **Validates: Requirements 8.2**
  - [ ] 13.3 Implement notification navigation logic
    - Navigate to correct destination based on type
    - Handle postId, userId, chatId
    - _Requirements: 8.3_
  - [ ]* 13.4 Write property test cho Notification navigation
    - **Property 13: Notification Navigation**
    - **Validates: Requirements 8.3**
  - [ ] 13.5 Implement mark all as read
    - Update all notifications for user
    - _Requirements: 8.5_
  - [ ]* 13.6 Write property test cho Mark all read
    - **Property 14: Mark All Read**
    - **Validates: Requirements 8.5**
  - [ ] 13.7 Implement push notifications với FCM
    - Setup Firebase Cloud Messaging
    - Handle foreground/background notifications
    - _Requirements: 8.1_
  - [ ] 13.8 Cập nhật NotificationPage với design mới
    - Swipe to delete
    - Type-specific icons
    - Mark all as read button
    - _Requirements: 8.2, 8.3, 8.4, 8.5_

- [ ] 14. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 8: Profile Page Redesign

- [ ] 15. Thiết kế lại Profile Page
  - [ ] 15.1 Implement parallax cover photo effect
    - SliverAppBar với expandedHeight
    - Parallax scroll effect
    - _Requirements: 6.1_
  - [ ] 15.2 Implement image cropper cho profile/cover photos
    - Integrate image_cropper package
    - Crop và upload
    - _Requirements: 6.2_
  - [ ] 15.3 Tạo ProfileTabs widget
    - Posts, Photos, Friends tabs
    - Smooth tab switching
    - _Requirements: 6.3, 6.4_
  - [ ] 15.4 Implement PhotosGrid trong Profile
    - Grid gallery
    - Tap to view fullscreen với PhotoView
    - _Requirements: 6.3_
  - [ ] 15.5 Implement FriendsList trong Profile
    - Grid hoặc list view
    - Avatar và name
    - _Requirements: 6.4_
  - [ ] 15.6 Cập nhật EditProfilePage
    - Form với tất cả fields
    - Image pickers cho avatar và cover
    - _Requirements: 6.5_

- [ ] 16. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 9: Watch Page (Video Feature)

- [ ] 17. Implement Watch Feature
  - [ ] 17.1 Tạo VideoEntity và VideoRepository
    - Define entity và repository interface
    - Implement với Firebase
    - _Requirements: 9.1_
  - [ ] 17.2 Tạo VideoProvider
    - Manage video list
    - Handle play/pause/mute states
    - _Requirements: 9.1, 9.4_
  - [ ] 17.3 Implement VideoPlayerWidget
    - Fullscreen video player
    - Controls: play/pause, mute, progress
    - _Requirements: 9.2, 9.4_
  - [ ]* 17.4 Write property test cho Mute toggle
    - **Property 19 (custom): Mute Toggle State**
    - **Validates: Requirements 9.4**
  - [ ] 17.5 Implement TikTok-style vertical swipe
    - PageView với vertical scroll
    - Auto-play next video
    - _Requirements: 9.3, 9.5_
  - [ ] 17.6 Cập nhật WatchPage với design mới
    - Video feed với swipe navigation
    - Video info overlay
    - Like, comment, share buttons
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 18. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 10: Marketplace Feature

- [ ] 19. Hoàn thiện Marketplace Feature
  - [ ] 19.1 Tạo ProductEntity và MarketplaceRepository
    - Define entity với tất cả fields
    - Implement repository với Firebase
    - _Requirements: 10.1, 10.2_
  - [ ] 19.2 Tạo MarketplaceProvider
    - Manage products list
    - Handle CRUD operations
    - _Requirements: 10.1, 10.2_
  - [ ] 19.3 Implement product search với filters
    - Search by title/description
    - Filter by category, price range, location
    - _Requirements: 10.3_
  - [ ]* 19.4 Write property test cho Product search filter
    - **Property 15: Product Search Filter**
    - **Validates: Requirements 10.3**
  - [ ] 19.5 Tạo CreateProductPage
    - Multi-image upload
    - Form với validation
    - _Requirements: 10.2_
  - [ ] 19.6 Tạo ProductDetailPage
    - Image gallery với PageView
    - Product info
    - Message Seller button
    - _Requirements: 10.4_
  - [ ] 19.7 Implement Message Seller functionality
    - Tạo chat với seller
    - Navigate to chat
    - _Requirements: 10.5_
  - [ ]* 19.8 Write property test cho Message Seller
    - **Property 16: Message Seller Chat Creation**
    - **Validates: Requirements 10.5**
  - [ ] 19.9 Cập nhật MarketplacePage với design mới
    - Categories filter
    - Product grid
    - Search bar
    - _Requirements: 10.1, 10.3_

- [ ] 20. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 11: Navigation & Dark Mode

- [ ] 21. Cải thiện Navigation và implement Dark Mode
  - [ ] 21.1 Cập nhật MainLayout với improved bottom navigation
    - 5 tabs: Home, Friends, Watch, Marketplace, Menu
    - Double-tap to scroll to top
    - Hide on child screens
    - _Requirements: 12.3, 12.4, 12.5_
  - [ ]* 21.2 Write property test cho Navigation back behavior
    - **Property 19: Navigation Back Behavior**
    - **Validates: Requirements 12.2**
  - [ ] 21.3 Implement smooth page transitions
    - Fade transitions cho tab changes
    - Slide transitions cho push/pop
    - _Requirements: 12.1, 12.2_
  - [ ] 21.4 Implement Dark Mode toggle
    - ThemeProvider với light/dark modes
    - Follow system theme by default
    - _Requirements: 13.1, 13.2_
  - [ ]* 21.5 Write property test cho Dark mode colors
    - **Property 20: Dark Mode Color Application**
    - **Validates: Requirements 13.1**
  - [ ] 21.6 Implement theme persistence
    - Save preference to SharedPreferences
    - Restore on app start
    - _Requirements: 13.4_
  - [ ]* 21.7 Write property test cho Theme persistence
    - **Property 21: Theme Persistence**
    - **Validates: Requirements 13.4**
  - [ ] 21.8 Tạo MenuPage với settings
    - Theme toggle
    - Account settings
    - Logout
    - _Requirements: 13.1, 13.2_

- [ ] 22. Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 12: Home Page Redesign & Final Polish

- [ ] 23. Thiết kế lại HomePage và hoàn thiện
  - [ ] 23.1 Cập nhật HomePage với StoriesBar
    - Integrate StoriesBar ở đầu feed
    - Pull to refresh
    - _Requirements: 2.1, 2.2_
  - [ ] 23.2 Implement lazy loading cho posts
    - Load thêm khi còn 3 posts cuối
    - Loading indicator
    - _Requirements: 2.3_
  - [ ] 23.3 Cập nhật CreatePostPage
    - Bottom sheet với options
    - Multi-image selection
    - _Requirements: 2.4_
  - [ ] 23.4 Implement image zoom trong posts
    - PhotoView integration
    - Swipe gallery cho multi-image posts
    - _Requirements: 2.5_
  - [ ] 23.5 Final UI polish và consistency check
    - Đảm bảo tất cả screens sử dụng design system
    - Fix any UI inconsistencies
    - _Requirements: 11.1_

- [ ] 24. Final Checkpoint - Đảm bảo tất cả tests pass
  - Ensure all tests pass, ask the user if questions arise.

