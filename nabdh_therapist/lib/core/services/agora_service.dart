import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';

/// Singleton Agora service.
///
/// The [RtcEngine] is created ONCE and reused across calls.
/// Call screens just join/leave channels — they never release the engine.
/// This avoids ERR_JOIN_CHANNEL_REJECTED (-17) caused by recreating the
/// engine before the native layer has fully released the previous instance.
///
/// One event handler is registered at engine creation and forwards to the
/// current call screen ([listener]). The SDK's register/unregister calls are
/// fire-and-forget, so registering per call could miss events of that call.
class AgoraService {
  AgoraService._();
  static final AgoraService instance = AgoraService._();

  RtcEngine? _engine;
  Future<RtcEngine>? _initFuture;

  /// Events of the shared engine go to the call screen that is open.
  RtcEngineEventHandler? listener;

  void clearListener(RtcEngineEventHandler handler) {
    if (identical(listener, handler)) listener = null;
  }

  /// Fetch a short-lived RTC token for [channel] from our Laravel backend.
  Future<String> fetchToken(String channel) async {
    try {
      final res = await ApiClient.instance.post(
        '/agora/token',
        data: {'channel': channel, 'uid': 0},
      );
      final token = res.data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('الخادم لم يُرجع رمز الاتصال');
      }
      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('غير مصرح لك بالانضمام إلى هذه المكالمة');
      }
      throw Exception('تعذّر الاتصال بالخادم');
    }
  }

  /// Returns the shared [RtcEngine], initializing it if necessary.
  Future<RtcEngine> getEngine() {
    if (_engine != null) return Future.value(_engine!);
    return _initFuture ??= _init();
  }

  Future<RtcEngine> _init() async {
    try {
      final engine = createAgoraRtcEngine();
      await engine.initialize(const RtcEngineContext(
        appId: AppConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      engine.registerEventHandler(_forwarder());
      _engine = engine;
      return engine;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }

  RtcEngineEventHandler _forwarder() => RtcEngineEventHandler(
        onJoinChannelSuccess: (c, elapsed) =>
            listener?.onJoinChannelSuccess?.call(c, elapsed),
        onUserJoined: (c, uid, elapsed) =>
            listener?.onUserJoined?.call(c, uid, elapsed),
        onUserOffline: (c, uid, reason) =>
            listener?.onUserOffline?.call(c, uid, reason),
        onRemoteAudioStateChanged: (c, uid, state, reason, elapsed) =>
            listener?.onRemoteAudioStateChanged?.call(c, uid, state, reason, elapsed),
        onRemoteVideoStateChanged: (c, uid, state, reason, elapsed) =>
            listener?.onRemoteVideoStateChanged?.call(c, uid, state, reason, elapsed),
        onConnectionStateChanged: (c, state, reason) =>
            listener?.onConnectionStateChanged?.call(c, state, reason),
        onError: (err, msg) => listener?.onError?.call(err, msg),
      );
}
