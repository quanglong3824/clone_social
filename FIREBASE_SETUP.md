# Firebase Configuration Guide

## Prerequisites
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable the following services:
   - Authentication (Email/Password)
   - Realtime Database
   - Storage
   - Cloud Messaging (for notifications)

## Setup Steps

### 1. Android Configuration

1. In Firebase Console, add an Android app
2. Download `google-services.json`
3. Place it in `android/app/google-services.json`
4. Update `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```
5. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### 2. iOS Configuration

1. In Firebase Console, add an iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/GoogleService-Info.plist`
4. Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

### 3. Web Configuration

1. In Firebase Console, add a Web app
2. Copy the Firebase configuration
3. Update `web/index.html`:
```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-database-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-storage-compat.js"></script>

<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    databaseURL: "YOUR_DATABASE_URL",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  
  firebase.initializeApp(firebaseConfig);
</script>
```

### 4. Realtime Database Rules

Set up security rules in Firebase Console > Realtime Database > Rules:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null",
        ".write": "$uid === auth.uid"
      }
    },
    "posts": {
      ".read": "auth != null",
      "$postId": {
        ".write": "auth != null && (!data.exists() || data.child('userId').val() === auth.uid)"
      }
    },
    "friendRequests": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "auth != null"
      }
    },
    "chats": {
      "$chatId": {
        ".read": "auth != null && data.child('participants').hasChild(auth.uid)",
        ".write": "auth != null && data.child('participants').hasChild(auth.uid)"
      }
    },
    "messages": {
      "$chatId": {
        ".read": "auth != null && root.child('chats').child($chatId).child('participants').hasChild(auth.uid)",
        ".write": "auth != null && root.child('chats').child($chatId).child('participants').hasChild(auth.uid)"
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

### 5. Storage Rules

Set up storage rules in Firebase Console > Storage > Rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /post_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /post_videos/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /chat_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 6. Authentication Setup

1. Go to Firebase Console > Authentication
2. Enable Email/Password sign-in method
3. (Optional) Enable other providers like Google, Facebook

## Environment Configuration

Create `lib/firebase_options.dart` using FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will automatically generate the configuration file.

## Testing Firebase Connection

Run the app and check the console for Firebase initialization:
```bash
flutter run
```

You should see "Firebase initialized successfully" in the console.
