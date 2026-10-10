import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}
  debugPrint("🔔 Handling background FCM message: ${message.messageId}");
}

/// Distinct Notification Channels with separate sounds and priorities
enum AppNotificationChannel {
  promos(
    id: 'fresh_yard_promos',
    name: '🍓 Deals & Organic Offers',
    description: 'Special discounts, harvest offers, and organic deals',
    soundFile: 'fresh_promo',
  ),
  orders(
    id: 'fresh_yard_orders',
    name: '🚚 Order Status & Courier',
    description: 'Order confirmation, dispatch, and delivery updates',
    soundFile: 'fresh_order',
  ),
  vip(
    id: 'fresh_yard_vip',
    name: '🎁 VIP Loyalty & Perks',
    description: 'Loyalty points, VIP rewards, and exclusive perks',
    soundFile: 'fresh_vip',
  );

  final String id;
  final String name;
  final String description;
  final String soundFile;

  const AppNotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.soundFile,
  });
}

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _fcmTokenStorageKey = 'fcm_device_token';

  bool _initialized = false;
  bool _firebaseReady = false;
  bool _localReady = false;
  Function(String? payload)? onNotificationTapped;

  Future<void> initialize({Function(String? payload)? onTap}) async {
    if (_initialized) return;
    _initialized = true;
    onNotificationTapped = onTap;

    // 1. Initialize Local Notifications Plugin first
    try {
      await _initLocalNotifications();
      _localReady = true;
      debugPrint('✅ Local Notifications initialized with 3 Channels');
    } catch (e) {
      debugPrint('❌ Local Notifications init failed: $e');
    }

    // 2. Request Android 13+ runtime notification permission
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('🔔 Android notification permission granted: $granted');
      }
    } catch (e) {
      debugPrint('⚠️ Android notification permission request error: $e');
    }

    // 3. Initialize Firebase with DefaultFirebaseOptions
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firebaseReady = true;
      debugPrint('🔥 Firebase initialized successfully: ${Firebase.app().name}');
    } catch (e) {
      debugPrint('⚠️ Firebase init status: $e');
    }

    // 4. Setup FCM Listeners & Topics if Firebase initialized
    if (_firebaseReady) {
      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        await requestPermissions();
        _setupFcmListeners();
        await _registerAndStoreFcmToken();
        await subscribeToTopic('all_fresh_yard_users');
        await subscribeToTopic('fresh_yard_promos');
        debugPrint('✅ Firebase FCM setup complete & subscribed to topics');
      } catch (e) {
        debugPrint('⚠️ FCM Messaging setup error: $e');
      }
    }
  }

  Future<void> requestPermissions() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('🔔 FCM Authorization status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('⚠️ FCM Permission request error: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notification response received with payload: ${response.payload}');
        if (onNotificationTapped != null) {
          onNotificationTapped!(response.payload);
        }
      },
    );

    // Create 3 Android High Importance Channels
    if (!kIsWeb) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        for (final channel in AppNotificationChannel.values) {
          await androidPlugin.createNotificationChannel(
            AndroidNotificationChannel(
              channel.id,
              channel.name,
              description: channel.description,
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
              ledColor: const Color(0xFF1B3B2B), // AppColors.brandDarkGreen
            ),
          );
        }
      }
    }
  }

  void _setupFcmListeners() {
    // Foreground FCM Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        final channelType = _determineChannelType(message.data['type']);
        showLocalNotification(
          id: message.hashCode,
          title: notification.title ?? 'The Fresh Yard',
          body: notification.body ?? '',
          payload: message.data['route'] ?? message.data['type'],
          channel: channelType,
        );
      }
    });

    // App Opened from Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && onNotificationTapped != null) {
        onNotificationTapped!(message.data['route'] ?? message.data['type']);
      }
    });

    // App Opened from Background State
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (onNotificationTapped != null) {
        onNotificationTapped!(message.data['route'] ?? message.data['type']);
      }
    });
  }

  AppNotificationChannel _determineChannelType(String? type) {
    switch (type) {
      case 'order':
      case 'orders':
        return AppNotificationChannel.orders;
      case 'vip':
      case 'reward':
        return AppNotificationChannel.vip;
      default:
        return AppNotificationChannel.promos;
    }
  }

  /// Show a local notification on the current device using specified channel
  Future<bool> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    AppNotificationChannel channel = AppNotificationChannel.promos,
  }) async {
    if (!_localReady) {
      debugPrint('❌ Cannot show notification: local notifications not initialized');
      return false;
    }

    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF1B3B2B),
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/launcher_icon',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _localNotifications.show(id, title, body, details, payload: payload);
      debugPrint('✅ Notification shown [${channel.id}]: "$title"');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to show notification: $e');
      return false;
    }
  }

  Future<String?> _registerAndStoreFcmToken() async {
    if (!_firebaseReady) return null;
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _storage.write(key: _fcmTokenStorageKey, value: token);
        debugPrint('🔑 FCM Token registered & saved: ${token.substring(0, 20)}...');
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        await _storage.write(key: _fcmTokenStorageKey, value: newToken);
        debugPrint('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
      });

      return token;
    } catch (e) {
      debugPrint('⚠️ FCM Token error: $e');
      return null;
    }
  }

  Future<String?> getStoredFcmToken() async {
    return await _storage.read(key: _fcmTokenStorageKey);
  }

  Future<void> subscribeToTopic(String topic) async {
    if (!_firebaseReady || kIsWeb) return;
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('📢 Subscribed to FCM Topic: $topic');
    } catch (e) {
      debugPrint('⚠️ Failed to subscribe to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_firebaseReady || kIsWeb) return;
    try {
      await _fcm.unsubscribeFromTopic(topic);
    } catch (_) {}
  }

  Future<String?> getFcmToken() async {
    if (!_firebaseReady) return null;
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  bool get isLocalReady => _localReady;
  bool get isFirebaseReady => _firebaseReady;
}
