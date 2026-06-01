import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';
import '../utils/json_utils.dart';

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

  /// Called by FcmService when a background-FCM notification is tapped.
  void handleDeepLink(String payload) => _handlePayload(payload);

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

    await androidPlugin?.requestNotificationsPermission();

    const channel = AndroidNotificationChannel(
      'nabdh_therapist_channel', 'إشعارات نبض',
      description: 'إشعارات تطبيق نبض للأخصائي',
      importance: Importance.high,
    );
    await androidPlugin?.createNotificationChannel(channel);

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
    if (payload == null || payload.isEmpty) return;
    final route = _payloadToRoute(payload);
    if (_navigate != null) {
      Future.delayed(const Duration(milliseconds: 400), () => _navigate!(route));
    } else {
      _pendingPayload = payload;
    }
  }

  String _payloadToRoute(String payload) {
    if (payload.startsWith('appointment:')) {
      return '/appointments/${payload.substring('appointment:'.length)}';
    }
    if (payload.startsWith('message:')) {
      return '/messages/${payload.substring('message:'.length)}';
    }
    if (payload.startsWith('goal:')) {
      return '/goals/${payload.substring('goal:'.length)}';
    }
    if (payload.startsWith('program:')) {
      return '/programs/${payload.substring('program:'.length)}';
    }
    if (payload == 'reels') return '/reels';
    // Default: open notifications list
    return '/notifications';
  }

  // ── Build payload from notification data map (shared with FcmService) ─────

  static String? buildPayloadFromData(Map<String, dynamic> data) {
    final aptId  = data['appointment_id'];
    if (aptId != null) return 'appointment:$aptId';
    final convId = data['conversation_id'];
    if (convId != null) return 'message:$convId';
    final goalId = data['goal_id'];
    if (goalId != null) return 'goal:$goalId';
    final progId = data['program_id'];
    if (progId != null) return 'program:$progId';
    final type = data['type'] as String? ?? '';
    if (type == 'account_approved') return 'notifications';
    if (type == 'reel_approved' || type == 'new_reel') return 'reels';
    return null;
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

      final countRes = await ApiClient.instance.get('/notifications/unread-count');
      final count = jsonInt(countRes.data['count']);
      final prev  = _unreadCount.value;
      _unreadCount.value = count;

      if (count > prev) {
        final listRes = await ApiClient.instance.get(
          '/notifications', queryParameters: {'per_page': 10});
        final raw  = listRes.data;
        final list = ((raw is Map ? raw['data'] : raw) as List?) ?? [];

        for (final item in list) {
          final n = item as Map<String, dynamic>;
          if (n['read_at'] != null) continue;

          final dataField = n['data'];
          final dataMap   = dataField is Map
              ? dataField.cast<String, dynamic>()
              : <String, dynamic>{};

          final payload = buildPayloadFromData(dataMap);

          await _showNotification(
            id:      jsonInt(n['id']),
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
      payload: conversationId != null ? 'message:$conversationId' : null,
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> forceRefresh() => _poll();

  void dispose() {
    _pollTimer?.cancel();
    _unreadCount.dispose();
  }
}
