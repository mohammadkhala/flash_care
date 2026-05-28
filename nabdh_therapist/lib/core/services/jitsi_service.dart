import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiService {
  static final JitsiMeet _jitsi = JitsiMeet();

  /// فتح غرفة مكالمة مدمجة داخل التطبيق
  static Future<void> startCall({
    required String room,
    required String displayName,
    bool videoMuted = true,
  }) async {
    final options = JitsiMeetConferenceOptions(
      serverURL: 'https://meet.jit.si',
      room: room,
      configOverrides: {
        'startWithAudioMuted': false,
        'startWithVideoMuted': videoMuted,
        'disableDeepLinking': true,
      },
      featureFlags: {
        'unsafeRoomWarning.enabled': false,
        'welcomePage.enabled': false,
        'pipEnabled': true,
      },
      userInfo: JitsiMeetUserInfo(displayName: displayName),
    );
    await _jitsi.join(options);
  }
}
