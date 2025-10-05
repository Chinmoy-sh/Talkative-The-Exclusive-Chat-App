import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _requestPermissions();
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    // Message notifications channel
    AndroidNotificationChannel messageChannel = AndroidNotificationChannel(
      AppConstants.messageChannel,
      'Messages',
      description: 'Notifications for new messages',
      importance: Importance.high,
      sound: const RawResourceAndroidNotificationSound('message_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    // Call notifications channel
    AndroidNotificationChannel callChannel = AndroidNotificationChannel(
      AppConstants.callChannel,
      'Calls',
      description: 'Notifications for incoming calls',
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('call_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 1000, 1000, 1000]),
    );

    // Status notifications channel
    const AndroidNotificationChannel statusChannel = AndroidNotificationChannel(
      AppConstants.statusChannel,
      'Status Updates',
      description: 'Notifications for status updates',
      importance: Importance.low,
      enableVibration: false,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(messageChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(callChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(statusChannel);
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get initial message if app was launched from notification
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // Request audio permission for call notifications
    await Permission.audio.request();

    // Request phone permission for call functionality
    await Permission.phone.request();
  }

  static Future<String?> getFirebaseToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Show message notification
  static Future<void> showMessageNotification({
    required String title,
    required String body,
    required String chatId,
    required String senderId,
    String? imageUrl,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          AppConstants.messageChannel,
          'Messages',
          channelDescription: 'Notifications for new messages',
          importance: Importance.high,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('message_sound'),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          icon: '@mipmap/ic_launcher',
          // largeIcon will be set dynamically if needed
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: true,
            contentTitle: title,
            htmlFormatContentTitle: true,
          ),
          actions: [
            AndroidNotificationAction(
              'reply',
              'Reply',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_reply'),
              inputs: [
                AndroidNotificationActionInput(label: 'Type a message...'),
              ],
            ),
            AndroidNotificationAction(
              'mark_read',
              'Mark as Read',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_check'),
            ),
          ],
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          sound: 'message_sound.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      chatId.hashCode,
      title,
      body,
      notificationDetails,
      payload: 'message:$chatId:$senderId',
    );

    // Play custom sound if enabled
    await _playNotificationSound('message');
  }

  // Show call notification
  static Future<void> showCallNotification({
    required String callerName,
    required String callId,
    required bool isVideoCall,
    String? callerImageUrl,
  }) async {
    final String title = isVideoCall
        ? 'Incoming Video Call'
        : 'Incoming Voice Call';
    final String body = 'From $callerName';

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          AppConstants.callChannel,
          'Calls',
          channelDescription: 'Notifications for incoming calls',
          importance: Importance.max,
          priority: Priority.max,
          sound: const RawResourceAndroidNotificationSound('call_sound'),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 1000, 1000, 1000]),
          icon: '@mipmap/ic_launcher',
          fullScreenIntent: true,
          category: AndroidNotificationCategory.call,
          ongoing: true,
          autoCancel: false,
          actions: [
            AndroidNotificationAction(
              'accept_call',
              'Accept',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_call_accept'),
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'decline_call',
              'Decline',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_call_decline'),
            ),
          ],
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          sound: 'call_sound.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      callId.hashCode,
      title,
      body,
      notificationDetails,
      payload: 'call:$callId:${isVideoCall ? 'video' : 'voice'}',
    );

    // Play call ringtone
    await _playCallRingtone();
  }

  // Show status notification
  static Future<void> showStatusNotification({
    required String title,
    required String body,
    required String statusId,
    String? imageUrl,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          AppConstants.statusChannel,
          'Status Updates',
          channelDescription: 'Notifications for status updates',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          enableVibration: false,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      statusId.hashCode,
      title,
      body,
      notificationDetails,
      payload: 'status:$statusId',
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Play notification sound
  static Future<void> _playNotificationSound(String type) async {
    try {
      switch (type) {
        case 'message':
          await _audioPlayer.play(AssetSource('sounds/message_sound.mp3'));
          break;
        case 'call':
          await _audioPlayer.play(AssetSource('sounds/call_sound.mp3'));
          break;
        default:
          await _audioPlayer.play(AssetSource('sounds/default_sound.mp3'));
      }
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
    }
  }

  // Play call ringtone
  static Future<void> _playCallRingtone() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/ringtone.mp3'));
    } catch (e) {
      debugPrint('Error playing call ringtone: $e');
    }
  }

  // Stop call ringtone
  static Future<void> stopCallRingtone() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping call ringtone: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null) {
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final type = parts[0];
        final id = parts[1];

        switch (type) {
          case 'message':
            // Navigate to chat screen
            _navigateToChat(id);
            break;
          case 'call':
            // Navigate to call screen or handle call action
            _handleCallAction(id, parts.length > 2 ? parts[2] : 'voice');
            break;
          case 'status':
            // Navigate to status screen
            _navigateToStatus(id);
            break;
        }
      }
    }
  }

  static void _navigateToChat(String chatId) {
    // Navigation logic here
    debugPrint('Navigate to chat: $chatId');
  }

  static void _handleCallAction(String callId, String callType) {
    // Call handling logic here
    debugPrint('Handle call: $callId, type: $callType');
  }

  static void _navigateToStatus(String statusId) {
    // Status navigation logic here
    debugPrint('Navigate to status: $statusId');
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');

    final data = message.data;
    final notification = message.notification;

    if (notification != null) {
      final type = data['type'] ?? 'message';

      switch (type) {
        case 'message':
          showMessageNotification(
            title: notification.title ?? 'New Message',
            body: notification.body ?? '',
            chatId: data['chatId'] ?? '',
            senderId: data['senderId'] ?? '',
            imageUrl: data['imageUrl'],
          );
          break;
        case 'call':
          showCallNotification(
            callerName: notification.title ?? 'Unknown Caller',
            callId: data['callId'] ?? '',
            isVideoCall: data['isVideoCall'] == 'true',
            callerImageUrl: data['callerImageUrl'],
          );
          break;
        case 'status':
          showStatusNotification(
            title: notification.title ?? 'Status Update',
            body: notification.body ?? '',
            statusId: data['statusId'] ?? '',
            imageUrl: data['imageUrl'],
          );
          break;
      }
    }
  }

  // Handle notification tap from background
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');

    final data = message.data;
    final type = data['type'] ?? 'message';

    switch (type) {
      case 'message':
        _navigateToChat(data['chatId'] ?? '');
        break;
      case 'call':
        _handleCallAction(
          data['callId'] ?? '',
          data['isVideoCall'] == 'true' ? 'video' : 'voice',
        );
        break;
      case 'status':
        _navigateToStatus(data['statusId'] ?? '');
        break;
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');

  // Handle background message
  final data = message.data;
  final notification = message.notification;

  if (notification != null) {
    final type = data['type'] ?? 'message';

    switch (type) {
      case 'message':
        await NotificationService.showMessageNotification(
          title: notification.title ?? 'New Message',
          body: notification.body ?? '',
          chatId: data['chatId'] ?? '',
          senderId: data['senderId'] ?? '',
          imageUrl: data['imageUrl'],
        );
        break;
      case 'call':
        await NotificationService.showCallNotification(
          callerName: notification.title ?? 'Unknown Caller',
          callId: data['callId'] ?? '',
          isVideoCall: data['isVideoCall'] == 'true',
          callerImageUrl: data['callerImageUrl'],
        );
        break;
      case 'status':
        await NotificationService.showStatusNotification(
          title: notification.title ?? 'Status Update',
          body: notification.body ?? '',
          statusId: data['statusId'] ?? '',
          imageUrl: data['imageUrl'],
        );
        break;
    }
  }
}
