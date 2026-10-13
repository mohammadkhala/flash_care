import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/agora_service.dart';
import '../../../../core/services/call_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Agora Call Page
//
// isCaller == true  → we started the call (chat / appointment): rings the peer
// isCaller == false → we accepted a ring, or joined an appointment session
// ──────────────────────────────────────────────────────────────────────────────

class AgoraCallPage extends StatefulWidget {
  /// Chat-based call: pass conversationId
  final int conversationId;
  /// Appointment-based call: pass appointmentId (overrides conversationId)
  final int appointmentId;
  final String peerName;
  final bool isVideo;
  final bool isCaller;
  /// Channel received with the ring (callee side)
  final String? incomingChannel;
  /// Ring-screen entry to clear once the call screen is up
  final String? callkitId;

  const AgoraCallPage({
    this.conversationId = 0,
    this.appointmentId  = 0,
    required this.peerName,
    required this.isVideo,
    required this.isCaller,
    this.incomingChannel,
    this.callkitId,
    super.key,
  });

  @override
  State<AgoraCallPage> createState() => _AgoraCallPageState();
}

class _AgoraCallPageState extends State<AgoraCallPage> {
  static const _ringbackAsset = 'assets/sounds/ringback.wav';

  RtcEngine? _engine;
  RtcEngineEventHandler? _handler;
  late final String _channel;

  // ── UI State ───────────────────────────────────────────────
  String _status      = '';
  bool _joined        = false;
  int? _remoteUid;
  bool _muted         = false;
  late bool _speakerOn = widget.isVideo;
  bool _videoEnabled  = true;
  bool _frontCamera   = true;
  bool _ringback      = false;
  bool _ended         = false;
  int  _elapsed       = 0;
  // Joining an appointment session may find the previous session's "ended"
  // row; only a status change after the call went live closes the screen.
  late bool _sawLive  = widget.isCaller || widget.callkitId != null;

  Timer? _pollTimer;
  Timer? _durationTimer;
  Timer? _ringTimeout;

  bool get _connected => _remoteUid != null;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (widget.incomingChannel != null && widget.incomingChannel!.isNotEmpty) {
      _channel = widget.incomingChannel!;
    } else if (widget.appointmentId > 0) {
      _channel = 'nabd-session-${widget.appointmentId}';
    } else {
      _channel = 'nabd-conv-${widget.conversationId}';
    }
    CallService.instance.activeChannel = _channel;
    CallService.instance.finishCallkit(widget.callkitId);
    _start();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _durationTimer?.cancel();
    _ringTimeout?.cancel();
    if (!_ended) _leaveMedia();
    if (CallService.instance.activeChannel == _channel) {
      CallService.instance.activeChannel = null;
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── Bootstrap ──────────────────────────────────────────────
  Future<void> _start() async {
    _setStatus(widget.isCaller ? 'جارٍ الاتصال...' : 'جارٍ التوصيل...');

    final perms = await [
      Permission.microphone,
      if (widget.isVideo) Permission.camera,
    ].request();
    if (perms[Permission.microphone] != PermissionStatus.granted) {
      _fail('يجب السماح باستخدام الميكروفون لإجراء المكالمة');
      return;
    }

    try {
      if (widget.isCaller) {
        final body = <String, dynamic>{'is_video': widget.isVideo};
        if (widget.appointmentId > 0) {
          body['appointment_id'] = widget.appointmentId;
        } else {
          body['conversation_id'] = widget.conversationId;
        }
        await ApiClient.instance.post('/calls/initiate', data: body);
      } else {
        await ApiClient.instance.post('/calls/$_channel/answer');
      }

      final token  = await AgoraService.instance.fetchToken(_channel);
      final engine = await AgoraService.instance.getEngine();
      if (!mounted || _ended) return;
      _engine = engine;

      _handler = RtcEngineEventHandler(
        onJoinChannelSuccess: (_, __) {
          if (!mounted) return;
          setState(() => _joined = true);
          if (widget.isCaller && !_connected) {
            _setStatus('جارٍ الرنين...');
            _startRingback();
          } else if (!_connected) {
            _setStatus('بانتظار الطرف الآخر...');
          }
          engine.setEnableSpeakerphone(_speakerOn);
        },
        onUserJoined: (_, uid, __) {
          if (!mounted) return;
          _ringTimeout?.cancel();
          _stopRingback();
          setState(() => _remoteUid = uid);
          _setStatus('متصل');
          _startDurationTimer();
        },
        onUserOffline: (_, uid, __) {
          if (uid == _remoteUid) _hangup(remote: true, reason: 'انتهت المكالمة');
        },
        onError: (err, msg) => debugPrint('Agora error $err: $msg'),
      );
      engine.registerEventHandler(_handler!);

      if (widget.isVideo) {
        await engine.enableVideo();
        await engine.startPreview();
      } else {
        await engine.disableVideo();
      }

      await engine.joinChannel(
        token: token,
        channelId: _channel,
        uid: 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishMicrophoneTrack: true,
          publishCameraTrack: widget.isVideo,
          autoSubscribeAudio: true,
          autoSubscribeVideo: widget.isVideo,
        ),
      );

      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
      if (widget.isCaller) {
        _ringTimeout = Timer(kRingDuration, _onNoAnswer);
      }
    } on DioException catch (e) {
      _fail(e.response?.statusCode == 403
          ? 'غير مصرح لك بإجراء هذه المكالمة'
          : 'تعذّر الاتصال بالخادم');
    } catch (e) {
      _fail(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Call state from the server (reject / hang-up while ringing) ──
  Future<void> _poll() async {
    if (_ended) return;
    try {
      final res    = await ApiClient.instance.get('/calls/$_channel');
      final status = (res.data as Map)['status'] as String?;
      if (status == 'ringing' || status == 'active') {
        _sawLive = true;
        return;
      }
      if (!_sawLive) return;
      switch (status) {
        case 'rejected':
          _hangup(remote: true, reason: 'تم رفض المكالمة');
        case 'missed':
          _hangup(remote: true,
              reason: widget.isCaller ? 'لم يتم الرد' : 'انتهت المكالمة');
        case 'ended':
          _hangup(remote: true, reason: 'انتهت المكالمة');
      }
    } catch (_) {}
  }

  Future<void> _onNoAnswer() async {
    if (_connected || _ended) return;
    try {
      await ApiClient.instance
          .post('/calls/$_channel/status', data: {'status': 'missed'});
    } catch (_) {}
    _hangup(remote: true, reason: 'لم يتم الرد');
  }

  // ── Ringback (only the caller hears it) ─────────────────────
  Future<void> _startRingback() async {
    final engine = _engine;
    if (engine == null || _ringback) return;
    try {
      final path = await engine.getAssetAbsolutePath(_ringbackAsset);
      if (path == null || _connected || _ended) return;
      await engine.startAudioMixing(filePath: path, loopback: true, cycle: -1);
      _ringback = true;
    } catch (_) {}
  }

  Future<void> _stopRingback() async {
    if (!_ringback) return;
    _ringback = false;
    try { await _engine?.stopAudioMixing(); } catch (_) {}
  }

  // ── Duration timer ─────────────────────────────────────────
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  String get _elapsedStr {
    final m = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _setStatus(String s) {
    if (mounted) setState(() => _status = s);
  }

  void _fail(String message) {
    _setStatus(message);
    Future.delayed(const Duration(seconds: 3), () => _hangup());
  }

  // ── Hang up ────────────────────────────────────────────────
  Future<void> _hangup({bool remote = false, String? reason}) async {
    if (_ended) return;
    _ended = true;
    _pollTimer?.cancel();
    _durationTimer?.cancel();
    _ringTimeout?.cancel();
    if (!remote) {
      try {
        await ApiClient.instance
            .post('/calls/$_channel/status', data: {'status': 'ended'});
      } catch (_) {}
    }
    await _leaveMedia();
    if (reason != null && mounted) {
      setState(() { _remoteUid = null; _status = reason; });
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    CallService.instance.activeChannel = null;
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  Future<void> _leaveMedia() async {
    final engine = _engine;
    if (engine == null) return;
    await _stopRingback();
    try {
      if (_handler != null) engine.unregisterEventHandler(_handler!);
      if (widget.isVideo) await engine.stopPreview();
      await engine.leaveChannel();
    } catch (_) {}
  }

  // ── Controls ───────────────────────────────────────────────
  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    await _engine?.muteLocalAudioStream(_muted);
  }

  Future<void> _toggleVideo() async {
    setState(() => _videoEnabled = !_videoEnabled);
    await _engine?.muteLocalVideoStream(!_videoEnabled);
    await _engine?.enableLocalVideo(_videoEnabled);
  }

  Future<void> _flipCamera() async {
    setState(() => _frontCamera = !_frontCamera);
    await _engine?.switchCamera();
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _speakerOn = !_speakerOn);
    if (_joined) await _engine?.setEnableSpeakerphone(_speakerOn);
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final engine = _engine;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _hangup();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          // ── Remote video (full screen) ──────────────────────
          if (_connected && widget.isVideo && engine != null)
            Positioned.fill(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: engine,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: _channel),
                ),
              ),
            )
          else
            _AudioBackground(name: widget.peerName, connected: _connected),

          // ── Local video (small, top-left) ───────────────────
          if (widget.isVideo && engine != null && _videoEnabled)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100, height: 140,
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),

          // ── Top bar (peer name + status/timer) ─────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  16, MediaQuery.of(context).padding.top + 12, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text(widget.peerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo')),
                const SizedBox(height: 4),
                Text(
                  _connected && !_ended ? _elapsedStr : _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _connected ? Colors.greenAccent : Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Cairo'),
                ),
              ]),
            ),
          ),

          // ── Bottom controls ─────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  16, 20, 16, MediaQuery.of(context).padding.bottom + 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallBtn(
                    icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _muted ? 'كتم' : 'صوت',
                    color: _muted ? Colors.red.shade400 : Colors.white,
                    bg: Colors.white24,
                    onTap: _toggleMute,
                  ),
                  _CallBtn(
                    icon: _speakerOn
                        ? Icons.volume_up_rounded
                        : Icons.phone_in_talk_rounded,
                    label: _speakerOn ? 'سماعة' : 'هاتف',
                    color: Colors.white,
                    bg: Colors.white24,
                    onTap: _toggleSpeaker,
                  ),
                  _CallBtn(
                    icon: Icons.call_end_rounded,
                    label: 'إنهاء',
                    color: Colors.white,
                    bg: Colors.red,
                    size: 64,
                    onTap: () => _hangup(),
                  ),
                  if (widget.isVideo)
                    _CallBtn(
                      icon: Icons.flip_camera_ios_rounded,
                      label: 'قلب',
                      color: Colors.white,
                      bg: Colors.white24,
                      onTap: _flipCamera,
                    )
                  else
                    const SizedBox(width: 60),
                  _CallBtn(
                    icon: _videoEnabled
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                    label: _videoEnabled ? 'فيديو' : 'إخفاء',
                    color: _videoEnabled ? Colors.white : Colors.red.shade400,
                    bg: Colors.white24,
                    onTap: widget.isVideo ? _toggleVideo : null,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Audio background (when video is off or audio-only call) ──────────────────
class _AudioBackground extends StatelessWidget {
  final String name;
  final bool connected;
  const _AudioBackground({required this.name, required this.connected});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
      ),
    ),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 110, height: 110,
          decoration: BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white38, width: 2),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0] : '؟',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo'),
            ),
          ),
        ),
        if (!connected) ...[
          const SizedBox(height: 24),
          const _PulsingDots(),
        ],
      ]),
    ),
  );
}

// ── Pulsing dots animation (while ringing) ───────────────────────────────────
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (i) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 10, height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(
              alpha: (0.3 + 0.7 * (((_c.value + i * 0.33) % 1.0))).clamp(0, 1)),
        ),
      ),
    )),
  );
}

// ── Control button ────────────────────────────────────────────────────────────
class _CallBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final Color    bg;
  final double   size;
  final VoidCallback? onTap;

  const _CallBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    this.size = 52,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Opacity(
      opacity: onTap == null ? 0.3 : 1.0,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: size * 0.45),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontFamily: 'Cairo')),
      ]),
    ),
  );
}
