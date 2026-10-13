import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';

/// How long the callee's phone rings. The caller gives up at the same time
/// and marks the call as missed.
const kRingDuration = Duration(seconds: 45);

// ── Ringing UI (safe to call from the FCM background isolate) ────────────────

/// Shows the system-style ringing screen for an `incoming_call` FCM message.
Future<void> showIncomingCallUi(Map<String, dynamic> data) async {
  final channel = data['channel'] as String? ?? '';
  if (channel.isEmpty) return;
  final callerName = data['caller_name'] as String? ?? 'مكالمة';
  final isVideo    = data['is_video'] == 'true' || data['is_video'] == true;
  final id         = data['call_id'] as String? ?? channel;

  // A second push for the same channel (caller retried) must not stack rings.
  await endIncomingCallUi(channel);

  await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
    id: id,
    nameCaller: callerName,
    appName: 'نبض',
    handle: isVideo ? 'مكالمة فيديو' : 'مكالمة صوتية',
    type: isVideo ? 1 : 0,
    duration: kRingDuration.inMilliseconds,
    missedCallNotification: const NotificationParams(showNotification: false),
    extra: <String, dynamic>{
      'channel':     channel,
      'caller_name': callerName,
      'is_video':    isVideo,
    },
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      isShowFullLockedScreen: true,
      isImportant: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0D47A1',
      actionColor: '#43A047',
      textColor: '#ffffff',
      incomingCallNotificationChannelName: 'مكالمات واردة',
      missedCallNotificationChannelName: 'مكالمات فائتة',
      isShowCallID: true,
      textAccept: 'رد',
      textDecline: 'رفض',
    ),
  ));
}

/// Stops the ring for [channel] (caller hung up / call answered elsewhere).
Future<void> endIncomingCallUi(String channel) async {
  try {
    final calls = await FlutterCallkitIncoming.activeCalls();
    for (final c in calls) {
      if (c.extra?['channel'] == channel) {
        await FlutterCallkitIncoming.endCall(c.id);
      }
    }
  } catch (_) {}
}

/// Decline pressed while the app process had no running Flutter UI.
@pragma('vm:entry-point')
Future<void> callkitBackgroundHandler(CallEvent event) async {
  if (event is CallEventActionCallDecline) {
    final channel = event.callKitParams.extra?['channel'] as String?;
    if (channel != null) await _postStatusWithStoredToken(channel, 'rejected');
  }
}

Future<void> _postStatusWithStoredToken(String channel, String status) async {
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
    await dio.post('/calls/$channel/status', data: {'status': status});
  } catch (_) {}
}

// ── Main-isolate service: reacts to accept / decline ─────────────────────────

class CallService {
  CallService._();
  static final CallService instance = CallService._();

  void Function(String route, [Object? extra])? _navigate;
  Map<String, dynamic>? _pendingAccept;
  StreamSubscription<CallEvent?>? _sub;

  /// Channel of the call screen currently open — a ring for it is ignored.
  String? activeChannel;

  /// True when the app was cold-started by tapping "accept" on the ring screen.
  bool get hasPendingAccept => _pendingAccept != null;

  Future<void> init() async {
    _sub ??= FlutterCallkitIncoming.onEvent.listen(_onEvent);
    try {
      await FlutterCallkitIncoming.onBackgroundMessage(callkitBackgroundHandler);
    } catch (_) {}

    // Accept pressed while the app was killed: the plugin launches us and the
    // accepted call is waiting in activeCalls().
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      for (final c in calls) {
        if (c.isAccepted) {
          _pendingAccept = _routeExtra(c);
          break;
        }
      }
    } catch (_) {}
  }

  /// [isReady] must turn true once the splash screen has handed over
  /// (otherwise its go('/home') would replace the call screen).
  void setNavigator(
    void Function(String route, [Object? extra]) navigate, {
    required bool Function() isReady,
  }) {
    _navigate = navigate;
    final pending = _pendingAccept;
    if (pending != null) {
      _pendingAccept = null;
      unawaited(_openWhenReady(pending, isReady));
    }
  }

  Future<void> _openWhenReady(
      Map<String, dynamic> extra, bool Function() isReady) async {
    for (var i = 0; i < 50 && !isReady(); i++) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _navigate?.call('/call', extra);
  }

  void _onEvent(CallEvent? event) {
    if (event is CallEventActionCallAccept) {
      final extra = _routeExtra(event.callKitParams);
      if (_navigate != null) {
        _navigate!('/call', extra);
      } else {
        _pendingAccept = extra;
      }
    } else if (event is CallEventActionCallDecline) {
      final channel = event.callKitParams.extra?['channel'] as String?;
      if (channel != null) unawaited(_reject(channel));
    }
  }

  Future<void> _reject(String channel) async {
    try {
      await ApiClient.instance
          .post('/calls/$channel/status', data: {'status': 'rejected'});
    } catch (_) {}
  }

  Map<String, dynamic> _routeExtra(CallKitParams c) {
    final extra = c.extra ?? const {};
    return {
      'peerName': extra['caller_name'] as String? ?? c.nameCaller ?? 'مكالمة',
      'isVideo':  extra['is_video'] == true || extra['is_video'] == 'true',
      'isCaller': false,
      'channel':  extra['channel'] as String?,
      'callkitId': c.id,
    };
  }

  /// Clears the ongoing-call entry the plugin keeps after "accept".
  Future<void> finishCallkit(String? id) async {
    if (id == null) return;
    try {
      await FlutterCallkitIncoming.endCall(id);
    } catch (_) {}
  }
}
