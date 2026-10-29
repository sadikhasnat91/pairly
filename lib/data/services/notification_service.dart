import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'supabase_service.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'safe_arrival_channel';
  static const String channelName = 'Safe Arrival Alerts';
  static const String channelDescription =
      'Instant notifications when your connected partner arrives home safely.';

  static const String callChannelId = 'pairly_incoming_call_channel';
  static const String callChannelName = 'Incoming Video Calls';
  static const String callChannelDescription =
      'Alerts and wakes device for incoming live camera and video requests.';
  static const int incomingCallNotificationId = 8888;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  StreamSubscription? _partnerArrivalSub;

  Future<NotificationService> init() async {
    if (_isInitialized) return this;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
              '[NotificationService] Notification clicked with payload: ${response.payload}');
          // Safe Arrival notifications navigate directly to Live Map
          Get.toNamed('/main');
        },
      );

      // Create Android Notification Channel
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        const androidChannel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(androidChannel);

        const callChannel = AndroidNotificationChannel(
          callChannelId,
          callChannelName,
          description: callChannelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(callChannel);

        // Request notification permissions for Android 13+
        await androidPlugin.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }

    return this;
  }

  /// Show instant safe arrival notification locally
  Future<void> showArrivalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload ?? '/main',
    );
  }

  /// Show high-priority incoming call notification that wakes the screen
  Future<void> showIncomingCallNotification({
    required String callerName,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      callChannelId,
      callChannelName,
      channelDescription: callChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: incomingCallNotificationId,
      title: 'Live Video Request',
      body: '$callerName is calling you for a Live Camera session',
      notificationDetails: notificationDetails,
      payload: payload ?? '/incoming-call',
    );
  }

  /// Dismiss the incoming call ringing notification
  Future<void> cancelIncomingCallNotification() async {
    await _localNotifications.cancel(id: incomingCallNotificationId);
  }

  /// Register push token in Supabase
  Future<void> registerDeviceToken({
    required String userId,
    required String token,
    String platform = 'android',
  }) async {
    try {
      final client = Get.find<SupabaseService>().client;
      if (client == null) return;

      await client.from('user_push_tokens').upsert(
        {
          'user_id': userId,
          'device_token': token,
          'platform': platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,device_token',
      );
      debugPrint('[NotificationService] Device token registered for $userId');
    } catch (e) {
      debugPrint('[NotificationService] registerDeviceToken error: $e');
    }
  }

  /// Listen for Realtime partner arrival events and show notification
  void listenToPartnerArrivalEvents({
    required String partnerId,
    required String partnerName,
  }) {
    _partnerArrivalSub?.cancel();

    try {
      final client = Get.find<SupabaseService>().client;
      if (client == null) return;

      _partnerArrivalSub = client
          .from('safe_arrival_events')
          .stream(primaryKey: ['id'])
          .eq('user_id', partnerId)
          .order('event_timestamp', ascending: false)
          .limit(1)
          .listen(
            (records) {
              if (records.isNotEmpty) {
                final latestEvent = records.first;
                final eventType = latestEvent['event_type'] as String? ?? 'arrival';
                final createdAtStr = latestEvent['created_at'] as String?;
                if (createdAtStr != null) {
                  final eventTime = DateTime.tryParse(createdAtStr);
                  // Only notify if event occurred in the last 2 minutes
                  if (eventTime != null &&
                      DateTime.now().difference(eventTime).inMinutes < 2) {
                    if (eventType == 'arrival') {
                      showArrivalNotification(
                        title: '❤️ Arrived Home Safely',
                        body: '$partnerName has arrived home safely.',
                        payload: '/main',
                      );
                    }
                  }
                }
              }
            },
            onError: (e) {
              debugPrint('[NotificationService] Realtime partner stream error: $e');
            },
          );
    } catch (e) {
      debugPrint('[NotificationService] Realtime setup error: $e');
    }
  }

  @override
  void onClose() {
    _partnerArrivalSub?.cancel();
    super.onClose();
  }
}
