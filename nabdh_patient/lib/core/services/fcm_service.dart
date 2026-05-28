import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

/// Top-level handler for background/terminated FCM messages.
/// Must be a top-level function annotated with vm:entry-point.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main() before this fires on Flutter 3+
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
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
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    // Navigation handled by NotificationService tap handler
  }
}
