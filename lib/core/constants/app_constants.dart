class AppConstants {
  // App Information
  static const String appName = 'Talkative';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Revolutionary Chat Experience';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String chatBox = 'chat_box';
  static const String mediaBox = 'media_box';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String groupsCollection = 'groups';
  static const String statusCollection = 'status';
  static const String callsCollection = 'calls';

  // Firebase Storage Paths
  static const String profilePictures = 'profile_pictures';
  static const String chatMedia = 'chat_media';
  static const String statusMedia = 'status_media';
  static const String documents = 'documents';

  // Message Types
  static const String textMessage = 'text';
  static const String imageMessage = 'image';
  static const String videoMessage = 'video';
  static const String audioMessage = 'audio';
  static const String documentMessage = 'document';
  static const String locationMessage = 'location';
  static const String contactMessage = 'contact';
  static const String voiceMessage = 'voice';
  static const String stickerMessage = 'sticker';
  static const String gifMessage = 'gif';

  // Chat Types
  static const String privateChat = 'private';
  static const String groupChat = 'group';
  static const String broadcastChat = 'broadcast';

  // Call Types
  static const String voiceCall = 'voice';
  static const String videoCall = 'video';

  // Status Types
  static const String textStatus = 'text_status';
  static const String imageStatus = 'image_status';
  static const String videoStatus = 'video_status';

  // User Online Status
  static const String online = 'online';
  static const String offline = 'offline';
  static const String away = 'away';
  static const String busy = 'busy';

  // Theme Constants
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';

  // Notification Channels
  static const String messageChannel = 'message_channel';
  static const String callChannel = 'call_channel';
  static const String statusChannel = 'status_channel';

  // SharedPreferences Keys
  static const String isFirstTime = 'is_first_time';
  static const String selectedLanguage = 'selected_language';
  static const String selectedTheme = 'selected_theme';
  static const String biometricEnabled = 'biometric_enabled';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  static const String autoDownloadImages = 'auto_download_images';
  static const String autoDownloadVideos = 'auto_download_videos';
  static const String autoDownloadDocuments = 'auto_download_documents';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // File Size Limits (in bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxDocumentSize = 20 * 1024 * 1024; // 20MB
  static const int maxVoiceSize = 5 * 1024 * 1024; // 5MB

  // Pagination
  static const int messagesPerPage = 20;
  static const int chatsPerPage = 20;
  static const int contactsPerPage = 50;

  // Voice Recording
  static const int maxVoiceDuration = 300; // 5 minutes in seconds
  static const int minVoiceDuration = 1; // 1 second

  // Status Duration
  static const Duration statusDuration = Duration(hours: 24);

  // Encryption Keys
  static const String encryptionKey = 'talkative_encryption_key_2024';
  static const String messageEncryption = 'message_encryption_iv';

  // Error Messages
  static const String networkError =
      'Network connection failed. Please check your internet connection.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String authError =
      'Authentication failed. Please sign in again.';
  static const String permissionError =
      'Permission denied. Please grant required permissions.';

  // Success Messages
  static const String messageSent = 'Message sent successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String settingsSaved = 'Settings saved successfully';

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int maxBioLength = 150;
  static const int maxMessageLength = 1000;

  // Regular Expressions
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,20}$';

  // Deep Links
  static const String deepLinkScheme = 'talkative';
  static const String chatDeepLink = 'talkative://chat';
  static const String profileDeepLink = 'talkative://profile';
  static const String callDeepLink = 'talkative://call';

  // Social Media Links
  static const String githubRepo =
      'https://github.com/Chinmoy-sh/Talkative-The-Exclusive-Chat-App';
  static const String supportEmail = 'support@talkative.app';
  static const String privacyPolicy = 'https://talkative.app/privacy';
  static const String termsOfService = 'https://talkative.app/terms';
}
