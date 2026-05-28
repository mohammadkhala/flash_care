import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

// ─── Top-level background tap handler ─────────────────────────────────────────
@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  NotificationService._storePendingPayload(response.payload);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _unreadCount = ValueNotifier<int>(0);
  Timer? _pollTimer;

  void Function(String route)? _navigate;
  static String? _pendingPayload;

  ValueNotifier<int> get unreadCount => _unreadCount;

  static void _storePendingPayload(String? payload) {
    _pendingPayload = payload;
  }

  void setNavigator(void Function(String route) navigate) {
    _navigate = navigate;
    final pending = _pendingPayload;
    if (pending != null) {
      _pendingPayload = null;
      _handlePayload(pending);
    }
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    const android  = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onForegroundTap,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // Request POST_NOTIFICATIONS permission on Android 13+
    await androidPlugin?.requestNotificationsPermission();

    // Create high-importance channel
    const channel = AndroidNotificationChannel(
      'nabdh_therapist_channel', 'إشعارات نبض',
      description: 'إشعارات تطبيق نبض للأخصائي',
      importance: Importance.high,
    );
    await androidPlugin?.createNotificationChannel(channel);

    // Check if app was LAUNCHED by tapping a notification
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      final payload = launch!.notificationResponse?.payload;
      if (payload != null) _pendingPayload = payload;
    }

    _startPolling();
  }

  // ── Tap handlers ──────────────────────────────────────────────────────────

  void _onForegroundTap(NotificationResponse response) {
    _handlePayload(response.payload);
  }

  void _handlePayload(String? payload) {
    if (payload == null) return;
    if (payload.startsWith('appointment:')) {
      final id    = payload.substring('appointment:'.length);
      final route = '/appointments/$id';
      if (_navigate != null) {
        Future.delayed(const Duration(milliseconds: 400), () => _navigate!(route));
      } else {
        _pendingPayload = payload;
      }
    } else if (payload.startsWith('messages/')) {
      if (_navigate != null) {
        Future.delayed(const Duration(milliseconds: 400), () => _navigate!('/$payload'));
      }
    }
  }

  // ── Polling ───────────────────────────────────────────────────────────────

  void _startPolling() {
    _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final token = await ApiClient.getToken();
      if (token == null) return;

      // 1. Fast unread-count check
      final countRes = await ApiClient.instance.get('/notifications/unread-count');
      final count = (countRes.data['count'] as num?)?.toInt() ?? 0;
      final prev  = _unreadCount.value;
      _unreadCount.value = count;

      // 2. Only fetch & display when count rose
      if (count > prev) {
        final listRes = await ApiClient.instance.get(
          '/notifications', queryParameters: {'per_page': 10});
        final raw  = listRes.data;
        final list = ((raw is Map ? raw['data'] : raw) as List?) ?? [];

        for (final item in list) {
          final n = item as Map<String, dynamic>;
          if (n['read_at'] != null) continue; // already read

          final dataField = n['data'];
          final dataMap   = dataField is Map
              ? dataField.cast<String, dynamic>()
              : <String, dynamic>{};

          final aptId   = dataMap['appointment_id'];
          final payload = aptId != null ? 'appointment:$aptId' : null;

          await _showNotification(
            id:      (n['id'] as num).toInt(),
            title:   n['title'] as String? ?? 'نبض',
            body:    n['body']  as String? ?? '',
            payload: payload,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _showNotification({
    required int    id,
    required String title,
    required String body,
    String?         payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'nabdh_therapist_channel', 'إشعارات نبض',
        importance: Importance.high,
        priority:   Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> showMessageNotification({
    required String senderName,
    required String message,
    int? conversationId,
  }) async {
    await _showNotification(
      id:      conversationId ?? 2,
      title:   'رسالة من $senderName',
      body:    message,
      payload: conversationId != null ? 'messages/$conversationId' : null,
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> forceRefresh() => _poll();

  void dispose() {
    _pollTimer?.cancel();
    _unreadCount.dispose();
  }
}
