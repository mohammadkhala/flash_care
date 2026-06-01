import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';

/// Lightweight wrapper around agora_rtc_engine.
/// Fetches RTC token from the backend, then lets the call screen
/// take full ownership of the engine.
class AgoraService {
  AgoraService._();
  static final AgoraService instance = AgoraService._();

  /// Fetch a short-lived RTC token for [channel] from our Laravel backend.
  /// Returns null when the backend is not configured (test / no-token mode).
  Future<String?> fetchToken({
    required String channel,
    int uid = 0,
  }) async {
    try {
      final res = await ApiClient.instance.post(
        '/agora/token',
        data: {'channel': channel, 'uid': uid},
      );
      final token = res.data['token'] as String?;
      return (token == null || token.isEmpty) ? null : token;
    } catch (_) {
      // If the endpoint is unreachable fall back to no-token mode
      return null;
    }
  }

  /// Create and initialise a fresh RtcEngine.
  /// The call screen is responsible for calling [engine.release()] on dispose.
  Future<RtcEngine> createEngine() async {
    final engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: AppConstants.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    return engine;
  }
}
