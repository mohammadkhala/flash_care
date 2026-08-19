import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../utils/json_utils.dart';

import 'local_notification_helper.dart';

const _kLastShownNotifKey = 'last_shown_notif_id';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _unreadCount = ValueNotifier<int>(0);
  Timer? _pollTimer;
  bool _initialPollDone = false; // skip first poll to avoid showing old notifications on launch

  /// Set by main.dart after appRouter is ready — avoids circular imports.
  void Function(String route, [Object? extra])? _navigate;

  /// Payload from a background/closed-app tap — consumed once.
  static String? _pendingPayload;

  /// True if app was launched by tapping a notification (cold start).
  /// Set before runApp so SplashPage can read it synchronously.
  static bool hadPendingAtStartup = false;

  ValueNotifier<int> get unreadCount => _unreadCount;

  static void storePendingPayload(String? payload) {
    _pendingPayload = payload;
    if (payload != null) hadPendingAtStartup = true;
  }

  /// Wire up navigation after GoRouter is ready.
  void setNavigator(void Function(String route, [Object? extra]) navigate) {
    _navigate = navigate;
    final pending = _pendingPayload;
    if (pending != null) {
      _pendingPayload = null;
      // Delay long enough for splash to reach /home (300ms) + render settle (300ms)
      Future.delayed(const Duration(milliseconds: 600), () => _handlePayload(pending));
    }
  }

  /// Called by FcmService when a background-FCM notification is tapped.
  void handleDeepLink(String payload) => _handlePayload(payload);

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    const android  = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onForegroundTap,
    );

    await LocalNotificationHelper.ensureAndroidChannels(_plugin);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      final payload = launch!.notificationResponse?.payload;
      if (payload != null) {
        _pendingPayload = payload;
        hadPendingAtStartup = true; // tell SplashPage to navigate quickly
      }
    }

    _startPolling();
  }

  // ── Tap handlers ──────────────────────────────────────────────────────────

  void _onForegroundTap(NotificationResponse response) {
    if (response.actionId == kRejectCall) return;
    _handlePayload(response.payload);
  }

  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    // Incoming call: navigate directly with extra data (no tap needed)
    if (payload.startsWith('call:')) {
      _handleCallPayload(payload);
      return;
    }

    final route = _payloadToRoute(payload);
    if (_navigate != null) {
      Future.delayed(const Duration(milliseconds: 400), () => _navigate!(route));
    } else {
      _pendingPayload = payload;
    }
  }

  // Format: call:CHANNEL|CALLER_NAME|IS_VIDEO
  void _handleCallPayload(String payload) {
    final rest       = payload.substring('call:'.length);
    final parts      = rest.split('|');
    final channel    = parts.isNotEmpty ? parts[0] : '';
    final callerName = parts.length > 1 ? parts[1] : 'مكالمة';
    final isVideo    = parts.length > 2 && parts[2] == '1';
    final extra = <String, dynamic>{
      'channel':    channel,
      'callerName': callerName,
      'isVideo':    isVideo,
    };
    if (_navigate != null) {
      Future.delayed(const Duration(milliseconds: 400),
          () => _navigate!('/incoming-call', extra));
    } else {
      _pendingPayload = payload;
    }
  }

  String _payloadToRoute(String payload) => payloadToRoute(payload);

  /// Public static version — used by NotificationsPage to navigate on tap.
  static String payloadToRoute(String payload) {
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
    return '/notifications';
  }

  // ── Build payload from notification data map (shared with FcmService) ─────

  static String? buildPayloadFromData(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';

    // Incoming call — encode channel + caller name + video flag
    if (type == 'incoming_call') {
      final channel    = data['channel']     as String? ?? '';
      final callerName = data['caller_name'] as String? ?? 'مكالمة';
      final isVideo    = data['is_video'] == 'true' || data['is_video'] == true;
      return 'call:$channel|$callerName|${isVideo ? '1' : '0'}';
    }

    final aptId  = data['appointment_id'];
    if (aptId != null) return 'appointment:$aptId';
    final convId = data['conversation_id'];
    if (convId != null) return 'message:$convId';
    final goalId = data['goal_id'];
    if (goalId != null) return 'goal:$goalId';
    final progId = data['program_id'];
    if (progId != null) return 'program:$progId';
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

      // 1. Fast unread-count check
      final countRes = await ApiClient.instance.get('/notifications/unread-count');
      final count = jsonInt(countRes.data['count']);
      final prev  = _unreadCount.value;
      _unreadCount.value = count;

      // 2. First poll after launch: record baseline count only — don't show anything
      //    This prevents replaying all existing unread notifications on every app open.
      if (!_initialPollDone) {
        _initialPollDone = true;
        return;
      }

      // 3. Only fetch & display when count rose since last check
      if (count > prev) {
        final listRes = await ApiClient.instance.get(
          '/notifications', queryParameters: {'per_page': 10});
        final raw = listRes.data;
        final list = ((raw is Map ? raw['data'] : raw) as List?) ?? [];

        // Only show notifications with ID higher than the last one we showed
        final prefs = await SharedPreferences.getInstance();
        final lastShownId = prefs.getInt(_kLastShownNotifKey) ?? 0;
        int maxIdSeen = lastShownId;

        for (final item in list) {
          final n = item as Map<String, dynamic>;
          if (n['read_at'] != null) continue;

          final notifId = jsonInt(n['id']);
          if (notifId <= lastShownId) continue; // already shown before
          if (notifId > maxIdSeen) maxIdSeen = notifId;

          final dataField = n['data'];
          final dataMap   = dataField is Map
              ? dataField.cast<String, dynamic>()
              : <String, dynamic>{};

          final payload = buildPayloadFromData(dataMap);
          final type = dataMap['type'] as String? ?? '';

          if (type == 'incoming_call' && payload != null) {
            await showIncomingCall(
              title: n['title'] as String? ?? 'مكالمة واردة',
              body:  n['body']  as String? ?? '',
              payload: payload,
            );
            continue;
          }

          await _showNotification(
            id:      notifId,
            title:   n['title']  as String? ?? 'نبض',
            body:    n['body']   as String? ?? '',
            payload: payload,
          );
        }

        if (maxIdSeen > lastShownId) {
          await prefs.setInt(_kLastShownNotifKey, maxIdSeen);
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
    await _plugin.show(
      id,
      title,
      body,
      LocalNotificationHelper.generalDetails(),
      payload: payload,
    );
  }

  Future<void> showIncomingCall({
    required String title,
    required String body,
    required String payload,
  }) async {
    await _plugin.show(
      payload.hashCode,
      title,
      body,
      LocalNotificationHelper.callDetails,
      payload: payload,
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> forceRefresh() => _poll();

  void dispose() {
    _pollTimer?.cancel();
    _unreadCount.dispose();
  }
}
