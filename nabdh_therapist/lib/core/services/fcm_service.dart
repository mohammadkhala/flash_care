import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';
import 'call_service.dart';
import 'local_notification_helper.dart';
import 'notification_service.dart';

/// Top-level background handler — runs in a separate Dart isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Calls arrive as data-only pushes so this handler runs even when the app
  // is killed and can show the ringing screen.
  if (await _handleCallMessage(message.data)) return;

  // When FCM includes a `notification` block, Android already shows the tray
  // item. Showing another local notification would duplicate it.
  if (message.notification != null) return;

  final title = message.data['title'] as String?;
  if (title == null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
  );
  await LocalNotificationHelper.ensureAndroidChannels(plugin);

  await plugin.show(
    message.hashCode,
    title,
    message.data['body'] as String? ?? '',
    LocalNotificationHelper.generalDetails(),
    payload: NotificationService.buildPayloadFromData(message.data),
  );
}

/// Returns true when [data] was a call signal and has been handled.
Future<bool> _handleCallMessage(Map<String, dynamic> data) async {
  switch (data['type']) {
    case 'incoming_call':
      if (data['channel'] != CallService.instance.activeChannel) {
        await showIncomingCallUi(data);
      }
      return true;
    case 'call_ended':
      final channel = data['channel'] as String?;
      if (channel != null) await endIncomingCallUi(channel);
      return true;
  }
  return false;
}

@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  NotificationService.storePendingPayload(response.payload);
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _saveToken();
    _messaging.onTokenRefresh.listen(_sendTokenToServer);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onMessageOpened(initial);
  }

  Future<void> refreshToken() => _saveToken();

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

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (await _handleCallMessage(message.data)) return;

    final payload = NotificationService.buildPayloadFromData(message.data);
    final title = message.notification?.title ?? message.data['title'] as String?;
    final body  = message.notification?.body ?? message.data['body'] as String?;
    if (title == null) return;

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.show(
      message.hashCode,
      title,
      body ?? '',
      LocalNotificationHelper.generalDetails(),
      payload: payload,
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    final payload = NotificationService.buildPayloadFromData(message.data)
        ?? 'notifications';
    NotificationService.instance.handleDeepLink(payload);
  }
}
