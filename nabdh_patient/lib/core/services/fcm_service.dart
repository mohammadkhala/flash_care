import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';
import 'notification_service.dart';

/// Top-level handler for background/terminated FCM messages.
/// Must be a top-level function annotated with vm:entry-point.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
  );
  // Build deep-link payload so tapping the notification routes correctly
  final payload = NotificationService.buildPayloadFromData(message.data);
  await plugin.show(
    message.hashCode,
    message.notification?.title ?? 'نبض',
    message.notification?.body ?? '',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'nabdh_patient_channel', 'إشعارات نبض',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    payload: payload,
  );
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission (iOS + Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Save token to backend
    await _saveToken();

    // Refresh token whenever it rotates
    _messaging.onTokenRefresh.listen(_sendTokenToServer);

    // Handle FCM message when app is in FOREGROUND
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle notification tap when app was in BACKGROUND (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // Handle notification tap when app was TERMINATED (FCM-launched)
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onMessageOpened(initial);
  }

  Future<void> _saveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _sendTokenToServer(token);
    } catch (_) {}
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final authToken = await ApiClient.getToken();
      if (authToken == null) return;
      await ApiClient.instance.post('/auth/fcm-token', data: {'fcm_token': token});
    } catch (_) {}
  }

  void _onForegroundMessage(RemoteMessage message) {
    final plugin = FlutterLocalNotificationsPlugin();
    final notification = message.notification;
    if (notification == null) return;
    // Include deep-link payload so tapping the local notification navigates correctly
    final payload = NotificationService.buildPayloadFromData(message.data);
    plugin.show(
      message.hashCode,
      notification.title ?? 'نبض',
      notification.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nabdh_patient_channel', 'إشعارات نبض',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  /// Called when user taps an FCM notification while the app was in background
  /// or when the app was launched from a terminated state via FCM.
  void _onMessageOpened(RemoteMessage message) {
    final payload = NotificationService.buildPayloadFromData(message.data)
        ?? 'notifications';
    NotificationService.instance.handleDeepLink(payload);
  }
}
