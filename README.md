# Facebook Clone - Flutter App

A full-featured Facebook clone built with Flutter and Firebase Realtime Database, supporting both mobile and web platforms.

## Features

### Authentication
- ✅ User Registration
- ✅ User Login
- ✅ Forgot Password
- ✅ Email Verification

### Posts
- ✅ Create Posts (Text, Images, Videos)
- ✅ Like Posts
- ✅ Comment on Posts
- ✅ Share Posts
- ✅ Real-time Updates

### Social Features
- ✅ Find Friends
- ✅ Send Friend Requests
- ✅ Accept/Reject Friend Requests
- ✅ Real-time Messaging
- ✅ User Profiles
- ✅ Notifications

## Tech Stack

- **Framework**: Flutter (Mobile & Web)
- **Database**: Firebase Realtime Database
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **State Management**: Provider / Riverpod
- **Architecture**: Clean Architecture

## Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── utils/              # Utility functions
│   ├── services/           # Core services (Firebase, etc.)
│   ├── routes/             # App routing
│   ├── themes/             # App themes
│   └── widgets/            # Reusable widgets
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── post/              # Post management
│   ├── friend/            # Friend system
│   ├── chat/              # Messaging
│   ├── profile/           # User profiles
│   └── notification/      # Notifications
│       ├── data/          # Data layer
│       │   ├── models/
│       │   ├── repositories/
│       │   └── datasources/
│       ├── domain/        # Domain layer
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/  # Presentation layer
│           ├── pages/
│           ├── widgets/
│           └── providers/
└── main.dart              # App entry point

assets/
├── images/                # Image assets
├── icons/                 # Icon assets
├── fonts/                 # Custom fonts
└── animations/            # Animation files

config/
├── firebase/              # Firebase configuration
└── environment/           # Environment configs
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase account
- Android Studio / VS Code
- Chrome (for web development)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd clone_social
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Create a Firebase project
   - Add Android/iOS/Web apps
   - Download configuration files
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`
   - Update web configuration in `web/index.html`

4. Run the app
```bash
# Mobile
flutter run

# Web
flutter run -d chrome
```

## Firebase Realtime Database Structure

```json
{
  "users": {
    "userId": {
      "name": "string",
      "email": "string",
      "profileImage": "string",
      "bio": "string",
      "friends": ["userId1", "userId2"],
      "createdAt": "timestamp"
    }
  },
  "posts": {
    "postId": {
      "userId": "string",
      "content": "string",
      "images": ["url1", "url2"],
      "likes": {
        "userId": true
      },
      "comments": {
        "commentId": {
          "userId": "string",
          "text": "string",
          "createdAt": "timestamp"
        }
      },
      "shares": 0,
      "createdAt": "timestamp"
    }
  },
  "friendRequests": {
    "userId": {
      "requestId": {
        "fromUserId": "string",
        "status": "pending|accepted|rejected",
        "createdAt": "timestamp"
      }
    }
  },
  "chats": {
    "chatId": {
      "participants": ["userId1", "userId2"],
      "lastMessage": "string",
      "lastMessageTime": "timestamp"
    }
  },
  "messages": {
    "chatId": {
      "messageId": {
        "senderId": "string",
        "text": "string",
        "type": "text|image|video",
        "createdAt": "timestamp",
        "read": false
      }
    }
  },
  "notifications": {
    "userId": {
      "notificationId": {
        "type": "like|comment|friend_request|message",
        "fromUserId": "string",
        "postId": "string",
        "read": false,
        "createdAt": "timestamp"
      }
    }
  }
}
```

## Development

### Running Tests
```bash
# Unit tests
flutter test test/unit

# Widget tests
flutter test test/widget

# Integration tests
flutter test test/integration
```

### Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is for educational purposes only.
