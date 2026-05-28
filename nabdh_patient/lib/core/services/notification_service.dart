import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

// ─── Top-level background tap handler (must NOT be inside a class) ────────────
@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  // The app is already fully launched when this fires on Android 12+.
  // Navigation is handled in NotificationService._handlePayload() on next init.
  NotificationService._storePendingPayload(response.payload);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _unreadCount = ValueNotifier<int>(0);
  Timer? _pollTimer;

  /// Set by main.dart after appRouter is ready — avoids circular imports.
  void Function(String route)? _navigate;

  /// Payload from a background/closed-app tap — consumed once.
  static String? _pendingPayload;

  ValueNotifier<int> get unreadCount => _unreadCount;

  // Called from the top-level background handler (separate isolate on some devices)
  static void _storePendingPayload(String? payload) {
    _pendingPayload = payload;
  }

  /// Wire up navigation after GoRouter is ready.
  void setNavigator(void Function(String route) navigate) {
    _navigate = navigate;
    // If a notification was tapped while the app was closed, navigate now.
    final pending = _pendingPayload;
    if (pending != null) {
      _pendingPayload = null;
      _handlePayload(pending);
    }
  }

  // ── Init ─────────────────────────────────────────────────────────────────

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
      'nabdh_patient_channel', 'إشعارات نبض',
      description: 'إشعارات تطبيق نبض للمريض',
      importance: Importance.high,
    );
    await androidPlugin?.createNotificationChannel(channel);

    // Check if the app was LAUNCHED by tapping a notification (app was closed)
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      final payload = launch!.notificationResponse?.payload;
      if (payload != null) {
        // Store for later — navigator isn't ready yet
        _pendingPayload = payload;
      }
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
      final id = payload.substring('appointment:'.length);
      final route = '/appointments/$id';
      if (_navigate != null) {
        // Small delay so the widget tree is fully settled
        Future.delayed(const Duration(milliseconds: 400), () => _navigate!(route));
      } else {
        // Navigator not ready yet — store for setNavigator() to pick up
        _pendingPayload = payload;
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
        final raw = listRes.data;
        final list = ((raw is Map ? raw['data'] : raw) as List?) ?? [];

        for (final item in list) {
          final n = item as Map<String, dynamic>;
          if (n['read_at'] != null) continue; // already read

          final dataField = n['data'];
          final dataMap   = dataField is Map
              ? dataField.cast<String, dynamic>()
              : <String, dynamic>{};

          final aptId  = dataMap['appointment_id'];
          final payload = aptId != null ? 'appointment:$aptId' : null;

          await _showNotification(
            id:      (n['id'] as num).toInt(),
            title:   n['title']  as String? ?? 'نبض',
            body:    n['body']   as String? ?? '',
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
        'nabdh_patient_channel', 'إشعارات نبض',
        importance: Importance.high,
        priority:   Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> forceRefresh() => _poll();

  void dispose() {
    _pollTimer?.cancel();
    _unreadCount.dispose();
  }
}
