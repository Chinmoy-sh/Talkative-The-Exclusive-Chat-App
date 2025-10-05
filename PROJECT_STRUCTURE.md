# Talkative - Project Structure

## 🏗️ Complete Project Architecture

This document outlines the complete structure of the Talkative chat application, built with Flutter and following clean architecture principles.

## 📁 Directory Structure

```text
Talkative-The-Exclusive-Chat-App/
├── 📁 android/                    # Android-specific configuration
├── 📁 ios/                        # iOS-specific configuration
├── 📁 web/                        # Web-specific configuration
├── 📁 windows/                    # Windows-specific configuration
├── 📁 linux/                      # Linux-specific configuration
├── 📁 macos/                      # macOS-specific configuration
├── 📁 assets/                     # Application assets
│   ├── 📁 images/                 # Image assets
│   ├── 📁 icons/                  # Icon assets
│   ├── 📁 animations/             # Lottie animations
│   ├── 📁 sounds/                 # Audio files
│   └── 📁 fonts/                  # Custom fonts
├── 📁 lib/                        # Main application code
│   ├── 📄 main.dart               # Application entry point
│   ├── 📁 core/                   # Core functionality
│   │   ├── 📁 constants/          # App constants
│   │   │   ├── 📄 app_constants.dart
│   │   │   └── 📄 app_colors.dart
│   │   ├── 📁 theme/              # Theme configuration
│   │   │   └── 📄 app_theme.dart
│   │   ├── 📁 utils/              # Utilities and helpers
│   │   │   ├── 📄 app_router.dart
│   │   │   ├── 📄 validators.dart
│   │   │   ├── 📄 extensions.dart
│   │   │   └── 📄 helpers.dart
│   │   └── 📁 services/           # Core services
│   │       ├── 📄 auth_service.dart
│   │       ├── 📄 notification_service.dart
│   │       ├── 📄 database_service.dart
│   │       ├── 📄 storage_service.dart
│   │       ├── 📄 encryption_service.dart
│   │       └── 📄 api_service.dart
│   ├── 📁 features/               # Feature modules
│   │   ├── 📁 auth/               # Authentication feature
│   │   │   ├── 📁 screens/        # Authentication screens
│   │   │   │   ├── 📄 splash_screen.dart
│   │   │   │   ├── 📄 login_screen.dart
│   │   │   │   ├── 📄 signup_screen.dart
│   │   │   │   ├── 📄 phone_verification_screen.dart
│   │   │   │   └── 📄 profile_setup_screen.dart
│   │   │   ├── 📁 providers/      # State management
│   │   │   │   ├── 📄 auth_provider.dart
│   │   │   │   └── 📄 user_provider.dart
│   │   │   ├── 📁 services/       # Feature services
│   │   │   │   └── 📄 auth_repository.dart
│   │   │   └── 📁 widgets/        # Feature widgets
│   │   │       ├── 📄 login_form.dart
│   │   │       └── 📄 social_login_buttons.dart
│   │   ├── 📁 chat/               # Chat functionality
│   │   │   ├── 📁 screens/        # Chat screens
│   │   │   │   ├── 📄 chat_home_screen.dart
│   │   │   │   ├── 📄 chat_screen.dart
│   │   │   │   ├── 📄 chat_list_screen.dart
│   │   │   │   └── 📄 chat_settings_screen.dart
│   │   │   ├── 📁 providers/      # Chat state management
│   │   │   │   ├── 📄 chat_provider.dart
│   │   │   │   ├── 📄 message_provider.dart
│   │   │   │   └── 📄 typing_provider.dart
│   │   │   ├── 📁 services/       # Chat services
│   │   │   │   ├── 📄 chat_repository.dart
│   │   │   │   ├── 📄 message_service.dart
│   │   │   │   └── 📄 realtime_service.dart
│   │   │   └── 📁 widgets/        # Chat widgets
│   │   │       ├── 📄 message_bubble.dart
│   │   │       ├── 📄 chat_input.dart
│   │   │       ├── 📄 message_list.dart
│   │   │       ├── 📄 typing_indicator.dart
│   │   │       └── 📄 media_message.dart
│   │   ├── 📁 profile/            # User profile
│   │   │   ├── 📁 screens/        # Profile screens
│   │   │   │   ├── 📄 profile_screen.dart
│   │   │   │   ├── 📄 edit_profile_screen.dart
│   │   │   │   └── 📄 settings_screen.dart
│   │   │   ├── 📁 providers/      # Profile state
│   │   │   │   └── 📄 profile_provider.dart
│   │   │   ├── 📁 services/       # Profile services
│   │   │   │   └── 📄 profile_repository.dart
│   │   │   └── 📁 widgets/        # Profile widgets
│   │   │       ├── 📄 avatar_widget.dart
│   │   │       ├── 📄 profile_info.dart
│   │   │       └── 📄 settings_tile.dart
│   │   ├── 📁 contacts/           # Contact management
│   │   │   ├── 📁 screens/        # Contact screens
│   │   │   │   ├── 📄 contacts_screen.dart
│   │   │   │   ├── 📄 add_contact_screen.dart
│   │   │   │   └── 📄 contact_profile_screen.dart
│   │   │   ├── 📁 providers/      # Contact state
│   │   │   │   └── 📄 contacts_provider.dart
│   │   │   ├── 📁 services/       # Contact services
│   │   │   │   └── 📄 contacts_repository.dart
│   │   │   └── 📁 widgets/        # Contact widgets
│   │   │       ├── 📄 contact_tile.dart
│   │   │       └── 📄 contact_list.dart
│   │   ├── 📁 groups/             # Group management
│   │   │   ├── 📁 screens/        # Group screens
│   │   │   │   ├── 📄 group_creation_screen.dart
│   │   │   │   ├── 📄 group_info_screen.dart
│   │   │   │   └── 📄 group_settings_screen.dart
│   │   │   ├── 📁 providers/      # Group state
│   │   │   │   └── 📄 group_provider.dart
│   │   │   ├── 📁 services/       # Group services
│   │   │   │   └── 📄 group_repository.dart
│   │   │   └── 📁 widgets/        # Group widgets
│   │   │       ├── 📄 group_tile.dart
│   │   │       ├── 📄 member_list.dart
│   │   │       └── 📄 group_avatar.dart
│   │   ├── 📁 calls/              # Voice/Video calls
│   │   │   ├── 📁 screens/        # Call screens
│   │   │   │   ├── 📄 call_screen.dart
│   │   │   │   ├── 📄 incoming_call_screen.dart
│   │   │   │   └── 📄 call_history_screen.dart
│   │   │   ├── 📁 providers/      # Call state
│   │   │   │   ├── 📄 call_provider.dart
│   │   │   │   └── 📄 webrtc_provider.dart
│   │   │   ├── 📁 services/       # Call services
│   │   │   │   ├── 📄 call_service.dart
│   │   │   │   └── 📄 webrtc_service.dart
│   │   │   └── 📁 widgets/        # Call widgets
│   │   │       ├── 📄 call_controls.dart
│   │   │       ├── 📄 video_renderer.dart
│   │   │       └── 📄 call_status.dart
│   │   └── 📁 status/             # Status/Stories
│   │       ├── 📁 screens/        # Status screens
│   │       │   ├── 📄 status_screen.dart
│   │       │   ├── 📄 add_status_screen.dart
│   │       │   └── 📄 view_status_screen.dart
│   │       ├── 📁 providers/      # Status state
│   │       │   └── 📄 status_provider.dart
│   │       ├── 📁 services/       # Status services
│   │       │   └── 📄 status_repository.dart
│   │       └── 📁 widgets/        # Status widgets
│   │           ├── 📄 status_tile.dart
│   │           ├── 📄 status_viewer.dart
│   │           └── 📄 status_indicator.dart
│   └── 📁 shared/                 # Shared components
│       ├── 📁 widgets/            # Reusable widgets
│       │   ├── 📄 custom_button.dart
│       │   ├── 📄 custom_text_field.dart
│       │   ├── 📄 loading_overlay.dart
│       │   ├── 📄 error_screen.dart
│       │   ├── 📄 avatar_widget.dart
│       │   ├── 📄 shimmer_widget.dart
│       │   ├── 📄 animated_fab.dart
│       │   └── 📄 custom_app_bar.dart
│       ├── 📁 models/             # Data models
│       │   ├── 📄 user_model.dart
│       │   ├── 📄 chat_model.dart
│       │   ├── 📄 message_model.dart
│       │   ├── 📄 group_model.dart
│       │   ├── 📄 call_model.dart
│       │   └── 📄 status_model.dart
│       ├── 📁 providers/          # Global providers
│       │   ├── 📄 connectivity_provider.dart
│       │   ├── 📄 theme_provider.dart
│       │   └── 📄 locale_provider.dart
│       └── 📁 extensions/         # Dart extensions
│           ├── 📄 string_extensions.dart
│           ├── 📄 datetime_extensions.dart
│           └── 📄 widget_extensions.dart
├── 📁 test/                       # Unit and widget tests
│   ├── 📁 unit/                   # Unit tests
│   ├── 📁 widget/                 # Widget tests
│   └── 📁 integration/            # Integration tests
├── 📁 test_driver/                # Integration test drivers
├── 📄 pubspec.yaml                # Dependencies configuration
├── 📄 analysis_options.yaml       # Lint rules
├── 📄 README.md                   # Project documentation
├── 📄 CHANGELOG.md               # Version history
├── 📄 LICENSE                    # License information
├── 📄 firebase.json              # Firebase configuration
├── 📄 .gitignore                 # Git ignore rules
├── 📄 .env                       # Environment variables
└── 📄 docker-compose.yml         # Docker configuration
```

## 🎯 Feature Modules

### 1. **Authentication Module** (`lib/features/auth/`)

- **Purpose**: Handle user authentication and authorization
- **Components**:
  - Login/Signup screens with modern UI
  - Phone number verification
  - Profile setup
  - Biometric authentication
  - Social login (Google, Facebook)

### 2. **Chat Module** (`lib/features/chat/`)

- **Purpose**: Core messaging functionality
- **Components**:
  - Real-time messaging
  - Rich text support
  - Media sharing (images, videos, documents)
  - Voice messages
  - Message encryption
  - Read receipts and delivery status

### 3. **Profile Module** (`lib/features/profile/`)

- **Purpose**: User profile management
- **Components**:
  - Profile viewing and editing
  - Privacy settings
  - Account management
  - Theme customization
  - Language preferences

### 4. **Contacts Module** (`lib/features/contacts/`)

- **Purpose**: Contact management
- **Components**:
  - Contact synchronization
  - Add/remove contacts
  - Block/unblock users
  - Contact search and filtering

### 5. **Groups Module** (`lib/features/groups/`)

- **Purpose**: Group chat functionality
- **Components**:
  - Group creation and management
  - Admin controls
  - Member management
  - Group settings
  - Broadcasting channels

### 6. **Calls Module** (`lib/features/calls/`)

- **Purpose**: Voice and video calling
- **Components**:
  - Voice/video calls
  - Group calls
  - Call history
  - Screen sharing
  - Call recording

### 7. **Status Module** (`lib/features/status/`)

- **Purpose**: Status/Stories functionality
- **Components**:
  - Create and share status
  - View friends' status
  - Status privacy controls
  - Status analytics

## 🔧 Core Services

### 1. **AuthService** (`lib/core/services/auth_service.dart`)

- User authentication
- Session management
- Token refresh
- Security checks

### 2. **NotificationService** (`lib/core/services/notification_service.dart`)

- Push notifications
- Local notifications
- Notification scheduling
- Custom notification sounds

### 3. **DatabaseService** (`lib/core/services/database_service.dart`)

- Firestore operations
- Local database (Hive)
- Data synchronization
- Offline support

### 4. **StorageService** (`lib/core/services/storage_service.dart`)

- File uploads/downloads
- Media compression
- Cloud storage management
- Cache management

### 5. **EncryptionService** (`lib/core/services/encryption_service.dart`)

- End-to-end encryption
- Key management
- Secure communication
- Data protection

## 📱 State Management

The application uses **Riverpod** for state management with the following structure:

### Providers Structure

```dart
// Global Providers
final authStateProvider = StreamProvider<User?>((ref) => ...);
final connectivityProvider = StateProvider<bool>((ref) => ...);
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ...);

// Feature Providers
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) => ...);
final messageProvider = FutureProvider.family<List<Message>, String>((ref, chatId) => ...);
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) => ...);
```

## 🗃️ Data Models

### Core Models

- **UserModel**: User information and preferences
- **ChatModel**: Chat metadata and settings
- **MessageModel**: Individual message data
- **GroupModel**: Group information and members
- **CallModel**: Call history and metadata
- **StatusModel**: Status/story data

## 🎨 UI Components

### Shared Widgets (`lib/shared/widgets/`)

- **CustomButton**: Animated button with multiple styles
- **CustomTextField**: Enhanced input field with validation
- **LoadingOverlay**: Loading states and progress indicators
- **ErrorScreen**: Error handling and retry mechanisms
- **AvatarWidget**: User profile pictures with status
- **ShimmerWidget**: Loading placeholders

## 🔒 Security Features

1. **End-to-End Encryption**
   - Message encryption using AES-256
   - Key exchange using RSA
   - Forward secrecy

2. **Authentication Security**
   - Multi-factor authentication
   - Biometric authentication
   - Session management
   - Token rotation

3. **Data Protection**
   - Secure storage
   - Data anonymization
   - Privacy controls
   - GDPR compliance

## 🌐 Internationalization

The app supports 50+ languages with:

- Localized strings
- RTL language support
- Cultural adaptations
- Date/time formatting

## 🧪 Testing Strategy

### Test Structure

```text
test/
├── unit/               # Unit tests for business logic
├── widget/            # Widget tests for UI components
├── integration/       # End-to-end integration tests
└── mock/              # Mock services and data
```

### Test Coverage

- **Unit Tests**: 90%+ coverage for business logic
- **Widget Tests**: All custom widgets tested
- **Integration Tests**: Critical user flows
- **Performance Tests**: App performance metrics

## 🚀 Build & Deployment

### Build Variants

- **Development**: Debug build with logging
- **Staging**: Pre-production testing
- **Production**: Optimized release build

### CI/CD Pipeline

1. **Code Quality**: Linting and analysis
2. **Testing**: Automated test execution
3. **Building**: Multi-platform builds
4. **Deployment**: Store deployment

## 📊 Analytics & Monitoring

### Metrics Tracking

- **User Engagement**: Message frequency, feature usage
- **Performance**: App startup time, crash rates
- **Business**: User retention, feature adoption
- **Security**: Failed login attempts, suspicious activity

### Tools Used

- Firebase Analytics
- Firebase Crashlytics
- Custom analytics dashboard
- Performance monitoring

## 🔄 Data Flow

```text
User Input → Widget → Provider → Service → Repository → API/Database
                ↓
User Interface ← Widget ← Provider ← Service ← Repository ← Response
```

This architecture ensures:

- **Separation of Concerns**: Each layer has specific responsibilities
- **Testability**: Easy to mock and test individual components
- **Maintainability**: Clean, organized, and scalable code
- **Reusability**: Shared components across features
- **Performance**: Optimized data flow and state management

## 📚 Documentation

- **API Documentation**: Detailed API specifications
- **Code Documentation**: Inline code comments and documentation
- **User Guide**: End-user documentation
- **Developer Guide**: Setup and contribution guidelines
- **Architecture Documentation**: System design and patterns

This comprehensive structure enables the Talkative app to deliver a revolutionary chat experience while maintaining high code quality, security, and performance standards.
