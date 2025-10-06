# iOS-specific Configuration

## ios/Runner.xcodeproj/project.pbxproj Configuration

Key settings to configure in Xcode:

### Deployment Target

- iOS Deployment Target: 11.0 or higher
- Support for iPhone and iPad

### Bundle Identifier

- Production: com.talkative.app
- Staging: com.talkative.app.staging
- Development: com.talkative.app.dev

### App Transport Security

- Allow arbitrary loads for development (disable in production)
- Configure secure network connections

## ios/Runner/Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>Talkative</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>talkative</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    
    <!-- Permissions -->
    <key>NSCameraUsageDescription</key>
    <string>Talkative needs camera access to take photos and videos for sharing in chats.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Talkative needs microphone access to record voice messages and make voice calls.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Talkative needs photo library access to share images and videos from your gallery.</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Talkative needs location access to share your location with friends.</string>
    <key>NSContactsUsageDescription</key>
    <string>Talkative needs contacts access to help you find and connect with friends.</string>
    <key>NSFaceIDUsageDescription</key>
    <string>Talkative uses Face ID for secure authentication and app protection.</string>
    <key>NSLocalNetworkUsageDescription</key>
    <string>Talkative uses local network to discover nearby devices for file sharing.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>Talkative uses speech recognition for voice-to-text features.</string>
    
    <!-- Background Modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>background-fetch</string>
        <string>background-processing</string>
        <string>remote-notification</string>
        <string>voip</string>
        <string>audio</string>
    </array>
    
    <!-- URL Schemes -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>talkative.app</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>talkative</string>
                <string>https</string>
            </array>
        </dict>
    </array>
    
    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
        <key>NSExceptionDomains</key>
        <dict>
            <key>firebase.googleapis.com</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSExceptionMinimumTLSVersion</key>
                <string>TLSv1.0</string>
                <key>NSIncludesSubdomains</key>
                <true/>
            </dict>
        </dict>
    </dict>
    
    <!-- Firebase Configuration -->
    <key>GOOGLE_APP_ID</key>
    <string>$(GOOGLE_APP_ID)</string>
    <key>GCM_SENDER_ID</key>
    <string>$(GCM_SENDER_ID)</string>
    <key>GOOGLE_API_KEY</key>
    <string>$(GOOGLE_API_KEY)</string>
    <key>BUNDLE_ID</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    
    <!-- Push Notifications -->
    <key>aps-environment</key>
    <string>production</string>
    
    <!-- Supported File Types -->
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Images</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.image</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Videos</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.movie</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Documents</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.data</string>
            </array>
        </dict>
    </array>
    
    <!-- App Icon -->
    <key>CFBundleIcons</key>
    <dict>
        <key>CFBundlePrimaryIcon</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon</string>
            </array>
        </dict>
    </dict>
    
    <!-- Status Bar -->
    <key>UIStatusBarStyle</key>
    <string>UIStatusBarStyleDefault</string>
    
    <!-- Interface Style -->
    <key>UIUserInterfaceStyle</key>
    <string>Automatic</string>
    
    <!-- Appearance -->
    <key>UIAppearance</key>
    <dict>
        <key>UIUserInterfaceIdiom</key>
        <string>Universal</string>
    </dict>
</dict>
</plist>
```

## ios/Runner/AppDelegate.swift

```swift
import UIKit
import Flutter
import Firebase
import GoogleMaps
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Configure Firebase
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            if let plist = FirebaseApp.configure() {
                print("Firebase configured successfully")
            }
        }
        
        // Configure Google Maps
        if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String {
            GMSServices.provideAPIKey(mapsApiKey)
        }
        
        // Configure push notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Configure Flutter
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Push Notifications
    
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    // MARK: - URL Handling
    
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        // Handle custom URL schemes
        if url.scheme == "talkative" {
            // Handle deep link
            handleDeepLink(url: url)
            return true
        }
        
        return super.application(app, open: url, options: options)
    }
    
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        
        // Handle universal links
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleUniversalLink(url: url)
            return true
        }
        
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    // MARK: - Background Processing
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        // Handle background mode
        super.applicationDidEnterBackground(application)
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Handle foreground mode
        super.applicationWillEnterForeground(application)
    }
    
    // MARK: - Helper Methods
    
    private func handleDeepLink(url: URL) {
        // Process deep link
        let controller = window?.rootViewController as? FlutterViewController
        let channel = FlutterMethodChannel(name: "talkative/deep_link", binaryMessenger: controller!.binaryMessenger)
        channel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
    }
    
    private func handleUniversalLink(url: URL) {
        // Process universal link
        let controller = window?.rootViewController as? FlutterViewController
        let channel = FlutterMethodChannel(name: "talkative/universal_link", binaryMessenger: controller!.binaryMessenger)
        channel.invokeMethod("handleUniversalLink", arguments: url.absoluteString)
    }
}

// MARK: - UNUserNotificationCenterDelegate

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        
        // Process notification data
        if let messageData = userInfo["message"] as? [String: Any] {
            // Handle message notification
            processMessageNotification(messageData)
        }
        
        completionHandler([[.alert, .sound, .badge]])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification action
        switch response.actionIdentifier {
        case "REPLY_ACTION":
            if let textResponse = response as? UNTextInputNotificationResponse {
                handleQuickReply(message: textResponse.userText, userInfo: userInfo)
            }
        case "MARK_READ_ACTION":
            handleMarkAsRead(userInfo: userInfo)
        default:
            // Default action - open app
            handleNotificationTap(userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    // MARK: - Notification Helpers
    
    private func processMessageNotification(_ messageData: [String: Any]) {
        // Process incoming message notification
    }
    
    private func handleQuickReply(message: String, userInfo: [AnyHashable: Any]) {
        // Handle quick reply from notification
    }
    
    private func handleMarkAsRead(userInfo: [AnyHashable: Any]) {
        // Mark message as read
    }
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Handle notification tap - navigate to specific chat
        let controller = window?.rootViewController as? FlutterViewController
        let channel = FlutterMethodChannel(name: "talkative/notification", binaryMessenger: controller!.binaryMessenger)
        channel.invokeMethod("handleNotificationTap", arguments: userInfo)
    }
}
```

## ios/Podfile

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '11.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  
  # Google Maps
  pod 'GoogleMaps'
  
  # Additional pods
  pod 'FMDB/SQLCipher'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      # Enable bitcode
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      
      # Set minimum deployment target
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      
      # Disable warnings
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      
      # Code signing
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    end
  end
end
```

## Key iOS Configuration Steps

### 1. Xcode Project Settings

- Set deployment target to iOS 11.0+
- Configure signing certificates and provisioning profiles
- Add required capabilities: Push Notifications, Background Modes, Associated Domains

### 2. Push Notifications Setup

- Enable Push Notifications capability
- Configure APNs certificates
- Set up notification categories and actions

### 3. Background Modes

- Remote notifications
- Background fetch
- Background processing
- VoIP (for voice calls)
- Audio (for voice messages)

### 4. Associated Domains

- Add associated domains for universal links
- Configure apple-app-site-association file

### 5. App Store Configuration

- Prepare app icons in all required sizes
- Configure metadata and screenshots
- Set up in-app purchases (if applicable)
- Configure TestFlight for beta testing
