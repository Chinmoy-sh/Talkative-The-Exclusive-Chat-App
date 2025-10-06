# 🚀 Talkative - Production Build Instructions

## 📋 Prerequisites

Before building for production, ensure you have:

### Development Environment

- **Flutter SDK**: 3.8.1 or higher
- **Dart SDK**: 3.8.0 or higher
- **Android Studio**: Latest stable version
- **Xcode**: Latest version (for iOS)
- **VS Code** with Flutter extensions

### Firebase Setup

- Firebase project created
- Firebase CLI installed
- FlutterFire CLI installed

## 🔧 Firebase Configuration

### 1. Create Firebase Project

```bash
# Create a new Firebase project at console.firebase.google.com
# Enable the following services:
# - Authentication
# - Firestore Database  
# - Storage
# - Cloud Messaging
# - Analytics
# - Crashlytics
```

### 2. Configure Authentication

Enable the following sign-in methods:

- Email/Password
- Google Sign-In
- Phone Authentication (optional)

### 3. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat rules
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Messages rules
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
    }
    
    // Status rules
    match /status/{statusId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4. Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile pictures
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat media
    match /chat_media/{chatId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
    
    // Status media
    match /status_media/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5. Configure FlutterFire

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure for your project
flutterfire configure

# Follow the prompts to select your Firebase project
# This will generate firebase_options.dart
```

## 📱 Building for Production

### Android Production Build

1. **Update App Signing**

```bash
# Generate signing key
keytool -genkey -v -keystore ~/talkative-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias talkative

# Create key.properties in android/
storePassword=your_store_password
keyPassword=your_key_password  
keyAlias=talkative
storeFile=../talkative-key.jks
```

2.**Build Release APK**

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

3.**Build App Bundle (Recommended)**

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

### iOS Production Build

1. **Configure Signing**

- Open `ios/Runner.xcworkspace` in Xcode
- Select your development team
- Configure provisioning profiles

2.**Build for Archive**

```bash
flutter build ios --release --obfuscate --split-debug-info=build/debug-info
```

3.**Archive in Xcode**

- Open Xcode
- Product → Archive
- Distribute to App Store

### Web Production Build

```bash
# Build web version
flutter build web --release --web-renderer canvaskit

# Deploy to Firebase Hosting (optional)
firebase deploy --only hosting
```

## 🔐 Environment Configuration

### Create Environment Files

1. **Create `.env.production`**

```bash
# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id

# Encryption
ENCRYPTION_KEY=your_32_char_encryption_key
MESSAGE_ENCRYPTION_IV=your_16_char_iv

# API Keys
GOOGLE_MAPS_API_KEY=your_maps_key
GIPHY_API_KEY=your_giphy_key

# Feature Flags
ENABLE_VOICE_CALLS=true
ENABLE_VIDEO_CALLS=true
ENABLE_GROUPS=true
ENABLE_STATUS=true
ENABLE_AI_FEATURES=false

# Analytics
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
```

### 2. **Update App Configuration**

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String appName = 'Talkative';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  
  // Environment specific configs
  static bool get isProduction => 
      const String.fromEnvironment('ENV') == 'production';
  
  static String get apiBaseUrl => isProduction 
      ? 'https://api.talkative.com' 
      : 'https://api-dev.talkative.com';
}
```

## 🧪 Testing Before Release

### 1. Run All Tests

```bash
# Unit tests
flutter test

# Integration tests  
flutter test integration_test/

# Widget tests
flutter test test/
```

### 2. Performance Testing

```bash
# Profile mode build
flutter build apk --profile

# Run performance tests
flutter drive --target=test_driver/perf_test.dart --profile
```

### 3. Security Testing

- Verify all API endpoints use HTTPS
- Test authentication flows
- Verify data encryption
- Test privacy controls
- Validate input sanitization

## 📊 Release Checklist

### Pre-Release

- [ ] All tests passing
- [ ] Code review completed
- [ ] Security audit completed
- [ ] Performance benchmarks met
- [ ] Documentation updated
- [ ] Privacy policy updated
- [ ] Terms of service updated

### App Store Preparation

- [ ] App icons (all sizes)
- [ ] Screenshots (all devices)
- [ ] App description
- [ ] Keywords optimized
- [ ] Age rating configured
- [ ] In-app purchases configured (if any)

### Google Play Preparation

- [ ] Feature graphic
- [ ] App screenshots
- [ ] App description
- [ ] Content rating
- [ ] Privacy policy link
- [ ] Data safety form completed

### Post-Release

- [ ] Monitor crash reports
- [ ] Monitor user feedback
- [ ] Monitor performance metrics
- [ ] Monitor server costs
- [ ] Plan next iteration

## 🔧 CI/CD Pipeline

### GitHub Actions (Recommended)

Create `.github/workflows/build_and_deploy.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze

  build_android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build appbundle --release

  build_ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

## 📈 Performance Optimization

### 1. Image Optimization

```dart
// Use optimized image loading
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 300,
  memCacheHeight: 300,
  placeholder: (context, url) => ShimmerWidget(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2. Database Optimization

```dart
// Use proper indexing
await FirebaseFirestore.instance
    .collection('messages')
    .where('chatId', isEqualTo: chatId)
    .orderBy('timestamp', descending: true)
    .limit(20)
    .get();
```

### 3. Memory Management

```dart
// Dispose controllers properly
@override
void dispose() {
  _textController.dispose();
  _animationController.dispose();
  _subscription?.cancel();
  super.dispose();
}
```

## 🛡️ Security Best Practices

### 1. API Security

- Use HTTPS for all API calls
- Implement proper authentication
- Validate all user inputs
- Use proper error handling

### 2. Data Protection

- Encrypt sensitive data at rest
- Use secure storage for keys
- Implement proper session management
- Regular security audits

### 3. User Privacy

- Minimal data collection
- Clear privacy controls
- Data retention policies
- GDPR compliance

## 📞 Support & Maintenance

### Monitoring

- Firebase Analytics for user behavior
- Crashlytics for crash reporting
- Custom metrics for app performance
- Server monitoring for backend health

### Updates

- Regular dependency updates
- Security patches
- Feature updates based on user feedback
- Performance improvements

---

### Ready for Production! 🚀**

Follow this guide to build and deploy Talkative as a production-ready application. For questions, create an issue on GitHub or contact our team.
