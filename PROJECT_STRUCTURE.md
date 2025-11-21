# Facebook Clone - Project Structure Documentation

## Overview
This is a comprehensive Facebook clone built with Flutter and Firebase Realtime Database, supporting both mobile (iOS/Android) and web platforms.

## Architecture
The project follows **Clean Architecture** principles with three main layers:
- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: UI, widgets, and state management

## Directory Structure

### Core (`lib/core/`)
Contains shared functionality used across the entire application.

#### `constants/`
- `app_constants.dart` - App-wide constants, error messages, validation rules

#### `utils/`
- `date_time_utils.dart` - Date/time formatting and relative time calculations
- `validation_utils.dart` - Form validation functions

#### `services/`
- `firebase_service.dart` - Firebase Realtime Database service singleton

#### `routes/`
- `app_router.dart` - GoRouter configuration for navigation

#### `themes/`
- `app_theme.dart` - Light and dark theme configurations

#### `widgets/`
- Reusable widgets used across features

### Features (`lib/features/`)
Each feature follows the same structure with three layers:

#### Authentication (`auth/`)
**Purpose**: User registration, login, password reset

**Domain Entities**:
- `user_entity.dart` - User profile information

**Key Functionality**:
- Email/password authentication
- Email verification
- Password reset
- User profile management

#### Posts (`post/`)
**Purpose**: Create, view, like, comment, and share posts

**Domain Entities**:
- `post_entity.dart` - Post content, media, likes, comments
- `comment_entity.dart` - Comment content and likes

**Key Functionality**:
- Create posts with text, images, or videos
- Like/unlike posts
- Comment on posts
- Share posts
- Real-time updates

#### Friends (`friend/`)
**Purpose**: Friend requests and friend management

**Domain Entities**:
- `friend_request_entity.dart` - Friend request status

**Key Functionality**:
- Send friend requests
- Accept/reject friend requests
- View friends list
- Search for users

#### Chat (`chat/`)
**Purpose**: Real-time messaging between friends

**Domain Entities**:
- `chat_entity.dart` - Chat conversation metadata
- `message_entity.dart` - Individual messages

**Key Functionality**:
- Send text messages
- Send images/videos
- Real-time message updates
- Read receipts
- Typing indicators

#### Profile (`profile/`)
**Purpose**: User profile viewing and editing

**Key Functionality**:
- View user profiles
- Edit profile information
- Upload profile/cover images
- View user's posts
- View friends list

#### Notifications (`notification/`)
**Purpose**: Push notifications for user activities

**Domain Entities**:
- `notification_entity.dart` - Notification data

**Key Functionality**:
- Like notifications
- Comment notifications
- Friend request notifications
- Message notifications
- Real-time notification updates

## Firebase Realtime Database Structure

```
{
  "users": {
    "<userId>": {
      "email": "string",
      "name": "string",
      "profileImage": "string",
      "coverImage": "string",
      "bio": "string",
      "friends": ["userId1", "userId2"],
      "createdAt": timestamp,
      "lastSeen": timestamp,
      "isOnline": boolean
    }
  },
  "posts": {
    "<postId>": {
      "userId": "string",
      "userName": "string",
      "userProfileImage": "string",
      "content": "string",
      "images": ["url1", "url2"],
      "videoUrl": "string",
      "likes": {
        "<userId>": true
      },
      "commentCount": number,
      "shareCount": number,
      "createdAt": timestamp,
      "updatedAt": timestamp,
      "comments": {
        "<commentId>": {
          "userId": "string",
          "userName": "string",
          "userProfileImage": "string",
          "text": "string",
          "createdAt": timestamp,
          "likes": {
            "<userId>": true
          }
        }
      }
    }
  },
  "friendRequests": {
    "<userId>": {
      "<requestId>": {
        "fromUserId": "string",
        "fromUserName": "string",
        "fromUserProfileImage": "string",
        "status": "pending|accepted|rejected",
        "createdAt": timestamp
      }
    }
  },
  "chats": {
    "<chatId>": {
      "participants": ["userId1", "userId2"],
      "participantNames": {
        "userId1": "name1",
        "userId2": "name2"
      },
      "participantImages": {
        "userId1": "imageUrl1",
        "userId2": "imageUrl2"
      },
      "lastMessage": "string",
      "lastMessageTime": timestamp,
      "lastMessageSenderId": "string"
    }
  },
  "messages": {
    "<chatId>": {
      "<messageId>": {
        "senderId": "string",
        "senderName": "string",
        "senderProfileImage": "string",
        "text": "string",
        "type": "text|image|video",
        "mediaUrl": "string",
        "createdAt": timestamp,
        "read": boolean
      }
    }
  },
  "notifications": {
    "<userId>": {
      "<notificationId>": {
        "type": "like|comment|share|friend_request|friend_accept|message",
        "fromUserId": "string",
        "fromUserName": "string",
        "fromUserProfileImage": "string",
        "postId": "string",
        "message": "string",
        "read": boolean,
        "createdAt": timestamp
      }
    }
  }
}
```

## State Management
The project uses **Provider** for state management. Each feature has its own provider in the `presentation/providers/` directory.

## Routing
Navigation is handled by **GoRouter** with the following main routes:
- `/splash` - Splash screen
- `/login` - Login page
- `/register` - Registration page
- `/forgot-password` - Password reset
- `/` - Home feed
- `/profile/:userId` - User profile
- `/friends` - Friends list
- `/chat` - Chat list
- `/chat/:chatId` - Chat conversation
- `/notifications` - Notifications
- `/post/:postId` - Post details

## Assets
- `assets/images/` - Image assets
- `assets/icons/` - Icon assets
- `assets/fonts/` - Custom fonts
- `assets/animations/` - Lottie animations

## Configuration
- `config/firebase/` - Firebase configuration files
- `config/environment/` - Environment-specific configs

## Testing
- `test/unit/` - Unit tests
- `test/widget/` - Widget tests
- `test/integration/` - Integration tests

## Key Dependencies
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `firebase_database` - Realtime Database
- `firebase_storage` - File storage
- `provider` - State management
- `go_router` - Navigation
- `google_fonts` - Typography
- `cached_network_image` - Image caching
- `image_picker` - Image selection
- `video_player` - Video playback

## Next Steps
1. Configure Firebase project
2. Implement authentication pages
3. Build home feed UI
4. Implement post creation
5. Add real-time listeners
6. Implement chat functionality
7. Add notifications
8. Test on mobile and web
