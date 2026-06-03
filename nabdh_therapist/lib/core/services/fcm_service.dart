import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';
import 'notification_service.dart';

// ── Call notification action IDs ─────────────────────────────────────────────
const _kAcceptCall = 'accept_call';
const _kRejectCall = 'reject_call';

// ── Call notification details ─────────────────────────────────────────────────
const _callDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'call_channel', 'مكالمات واردة',
    importance:       Importance.max,
    priority:         Priority.max,
    fullScreenIntent: true,
    category:         AndroidNotificationCategory.call,
    visibility:       NotificationVisibility.public,
    ongoing:          true,
    autoCancel:       false,
    icon:             '@mipmap/ic_launcher',
    actions: [
      AndroidNotificationAction(
        _kRejectCall, '❌  رفض',
        showsUserInterface: false,
        cancelNotification: true,
      ),
      AndroidNotificationAction(
        _kAcceptCall, '✅  قبول',
        showsUserInterface: true,
        cancelNotification: true,
      ),
    ],
  ),
);

/// Top-level background handler — runs in a separate Dart isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
  );

  final payload = NotificationService.buildPayloadFromData(message.data);
  final isCall  = message.data['type'] == 'incoming_call';

  await plugin.show(
    message.hashCode,
    message.notification?.title ?? 'نبض',
    message.notification?.body  ?? '',
    isCall
        ? _callDetails
        : const NotificationDetails(
            android: AndroidNotificationDetails(
              'nabdh_therapist_channel', 'إشعارات نبض',
              importance: Importance.high,
              priority:   Priority.high,
              icon:       '@mipmap/ic_launcher',
            ),
          ),
    payload: payload,
  );
}

// ── Background tap handler ────────────────────────────────────────────────────
@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  if (response.actionId == _kRejectCall) {
    _backgroundRejectCall(response.payload);
    return;
  }
  NotificationService._storePendingPayload(response.payload);
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

// ─────────────────────────────────────────────────────────────────────────────

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  static const _permChannel = MethodChannel('com.nabdh/permissions');

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    _requestFullScreenIntentPermission();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _saveToken();
    _messaging.onTokenRefresh.listen(_sendTokenToServer);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onMessageOpened(initial);
  }

  Future<void> _requestFullScreenIntentPermission() async {
    try {
      await _permChannel.invokeMethod('requestFullScreenIntent');
    } catch (_) {}
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
    final type = message.data['type'] as String? ?? '';

    if (type == 'incoming_call') {
      final payload = NotificationService.buildPayloadFromData(message.data);
      if (payload != null) NotificationService.instance.handleDeepLink(payload);
      return;
    }

    final plugin = FlutterLocalNotificationsPlugin();
    final notification = message.notification;
    if (notification == null) return;
    final payload = NotificationService.buildPayloadFromData(message.data);
    plugin.show(
      message.hashCode,
      notification.title ?? 'نبض',
      notification.body  ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nabdh_therapist_channel', 'إشعارات نبض',
          importance: Importance.high,
          priority:   Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    final payload = NotificationService.buildPayloadFromData(message.data)
        ?? 'notifications';
    NotificationService.instance.handleDeepLink(payload);
  }
}
