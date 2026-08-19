import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';
import 'local_notification_helper.dart';
import 'notification_service.dart';

/// Top-level background handler — runs in a separate Dart isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
  );

  await LocalNotificationHelper.ensureAndroidChannels(plugin);

  final payload = NotificationService.buildPayloadFromData(message.data);
  final isCall  = (message.data['type'] as String? ?? '').contains('call');

  final title = message.data['title'] as String? ??
      (isCall ? 'مكالمة واردة' : 'نبض');
  final body = message.data['body'] as String? ??
      (isCall ? 'اضغط للرد على المكالمة' : '');

  await plugin.show(
    message.hashCode,
    title,
    body,
    isCall ? LocalNotificationHelper.callDetails : LocalNotificationHelper.generalDetails(),
    payload: payload,
  );
}

@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  if (response.actionId == kRejectCall) {
    _backgroundRejectCall(response.payload);
    return;
  }
  NotificationService.storePendingPayload(response.payload);
}

Future<void> _backgroundRejectCall(String? payload) async {
  if (payload == null || !payload.startsWith('call:')) return;
  final channel = payload.substring('call:'.length).split('|').first;
  if (channel.isEmpty) return;
  try {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.tokenKey);
    if (token == null) return;
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ));
    await dio.post('/calls/$channel/status', data: {'status': 'rejected'});
  } catch (_) {}
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
    final type = message.data['type'] as String? ?? '';
    final payload = NotificationService.buildPayloadFromData(message.data);

    if (type.contains('call') && payload != null) {
      final title = message.notification?.title ??
          message.data['title'] as String? ??
          'مكالمة واردة';
      final body  = message.notification?.body ??
          message.data['body'] as String? ??
          'اضغط للرد على المكالمة';
      await NotificationService.instance.showIncomingCall(
        title: title,
        body: body,
        payload: payload,
      );
      return;
    }

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
