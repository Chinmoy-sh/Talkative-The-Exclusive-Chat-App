// Environment Configuration for Talkative Chat App
// This file contains environment-specific configurations

enum Environment { development, staging, production }

class AppEnvironment {
  static const Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;

  // API Endpoints
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'https://dev-api.talkative.com';
      case Environment.staging:
        return 'https://staging-api.talkative.com';
      case Environment.production:
        return 'https://api.talkative.com';
    }
  }

  // Firebase Project IDs
  static String get firebaseProjectId {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'talkative-dev';
      case Environment.staging:
        return 'talkative-staging';
      case Environment.production:
        return 'talkative-prod';
    }
  }

  // App Configuration
  static String get appName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Talkative Dev';
      case Environment.staging:
        return 'Talkative Staging';
      case Environment.production:
        return 'Talkative';
    }
  }

  static String get packageName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'com.talkative.chat.dev';
      case Environment.staging:
        return 'com.talkative.chat.staging';
      case Environment.production:
        return 'com.talkative.chat';
    }
  }

  // Debug Settings
  static bool get enableLogging => !isProduction;
  static bool get enableDebugMode => isDevelopment;
  static bool get enableCrashlytics => isStaging || isProduction;
  static bool get enableAnalytics => isStaging || isProduction;

  // Feature Flags
  static bool get enableBetaFeatures => isDevelopment || isStaging;
  static bool get enableTestPayments => isDevelopment || isStaging;
  static bool get enableAdvancedSecurity => isProduction;

  // Performance Settings
  static int get httpTimeoutSeconds => isDevelopment ? 30 : 15;
  static int get maxRetryAttempts => 3;
  static int get cacheExpiryHours => isDevelopment ? 1 : 24;
}
