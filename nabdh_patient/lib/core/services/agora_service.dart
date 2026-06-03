import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';

/// Singleton Agora service.
///
/// The [RtcEngine] is created ONCE and reused across calls.
/// Call screens just join/leave channels — they never release the engine.
/// This avoids ERR_JOIN_CHANNEL_REJECTED (-17) caused by recreating the
/// engine before the native layer has fully released the previous instance.
class AgoraService {
  AgoraService._();
  static final AgoraService instance = AgoraService._();

  RtcEngine? _engine;
  bool _initializing = false;

  /// Fetch a short-lived RTC token for [channel] from our Laravel backend.
  Future<String> fetchToken({required String channel, int uid = 0}) async {
    try {
      final res = await ApiClient.instance.post(
        '/agora/token',
        data: {'channel': channel, 'uid': uid},
      );
      final token = res.data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('الخادم لم يُرجع رمزاً — تأكد من إعداد AGORA_APP_ID في .env');
      }
      return token;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('فشل جلب رمز الاتصال: $e');
    }
  }

  /// Returns the shared [RtcEngine], initializing it if necessary.
  /// The engine is a singleton — it is never released between calls.
  Future<RtcEngine> getEngine() async {
    if (_engine != null) return _engine!;

    // Guard against concurrent calls
    if (_initializing) {
      // Wait until the other init finishes
      while (_initializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_engine != null) return _engine!;
    }

    _initializing = true;
    try {
      final engine = createAgoraRtcEngine();
      await engine.initialize(const RtcEngineContext(
        appId: AppConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      _engine = engine;
      return engine;
    } finally {
      _initializing = false;
    }
  }

  /// Leave the current channel (safe to call even if not joined).
  Future<void> leaveChannel() async {
    try { await _engine?.leaveChannel(); } catch (_) {}
  }
}
