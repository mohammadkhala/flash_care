import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/network/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// WebRTC Call Page
//
// isCaller == true  → we initiated the call (from chat page)
// isCaller == false → we received a call (from FCM notification)
// ──────────────────────────────────────────────────────────────────────────────

class WebRtcCallPage extends StatefulWidget {
  /// Chat-based call: pass conversationId
  final int conversationId;
  /// Appointment-based call: pass appointmentId (overrides conversationId)
  final int appointmentId;
  final String peerName;
  final bool isVideo;
  final bool isCaller;
  /// Provided by FCM or appointment when isCaller == false
  final String? incomingChannel;

  const WebRtcCallPage({
    this.conversationId = 0,
    this.appointmentId  = 0,
    required this.peerName,
    required this.isVideo,
    required this.isCaller,
    this.incomingChannel,
    super.key,
  });

  @override
  State<WebRtcCallPage> createState() => _WebRtcCallPageState();
}

class _WebRtcCallPageState extends State<WebRtcCallPage> {
  // ── Renderers ──────────────────────────────────────────────
  final _localRenderer  = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  // ── WebRTC ─────────────────────────────────────────────────
  RTCPeerConnection? _pc;
  MediaStream?       _localStream;
  String?            _channel;

  // ── UI State ───────────────────────────────────────────────
  String _status      = '';
  bool _connected     = false;
  bool _muted         = false;
  bool _speakerOn     = true;
  bool _videoEnabled  = true;
  bool _frontCamera   = true;
  int  _elapsed       = 0;   // call seconds

  // ── Polling ────────────────────────────────────────────────
  Timer? _pollTimer;
  Timer? _durationTimer;
  int    _appliedRemoteIce = 0;

  // ── ICE/STUN config ────────────────────────────────────────
  static const _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
  };

  // ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Keep screen awake + full-screen immersive during call
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _start();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _durationTimer?.cancel();
    _pc?.close();
    for (final t in _localStream?.getTracks() ?? []) t.stop();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── Bootstrap ──────────────────────────────────────────────
  Future<void> _start() async {
    if (widget.incomingChannel != null) {
      _channel = widget.incomingChannel!;
    } else if (widget.appointmentId > 0) {
      _channel = 'webrtc-session-${widget.appointmentId}';
    } else {
      _channel = 'webrtc-conv-${widget.conversationId}';
    }

    setState(() => _status = widget.isCaller ? 'جارٍ الاتصال...' : 'جارٍ التوصيل...');

    try {
      // 1. Get local camera / mic
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': widget.isVideo
            ? {'facingMode': 'user', 'width': 640, 'height': 480}
            : false,
      });
      _localRenderer.srcObject = _localStream;
      if (mounted) setState(() {});

      // 2. Create RTCPeerConnection
      _pc = await createPeerConnection(_iceConfig);

      // 3. Add local tracks
      for (final t in _localStream!.getTracks()) {
        await _pc!.addTrack(t, _localStream!);
      }

      // 4. Handle remote stream
      _pc!.onTrack = (event) {
        if (event.streams.isNotEmpty && mounted) {
          _remoteRenderer.srcObject = event.streams.first;
          setState(() { _connected = true; _status = 'متصل'; });
          _startDurationTimer();
        }
      };

      // 5. Collect ICE candidates → send to backend
      _pc!.onIceCandidate = (c) {
        if (c.candidate != null) _sendIce(c.toMap());
      };

      // 6. Watch connection state
      _pc!.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          if (mounted) {
            setState(() => _status = 'فشل الاتصال');
            Future.delayed(const Duration(seconds: 2), () => _hangup());
          }
        }
      };

      // 7. Caller vs Callee flow
      if (widget.isCaller) {
        await _callerFlow();
      } else {
        await _calleeFlow();
      }
    } catch (e) {
      if (mounted) setState(() => _status = 'خطأ: $e');
    }
  }

  // ── Caller Flow ────────────────────────────────────────────
  Future<void> _callerFlow() async {
    setState(() => _status = 'جارٍ الرنين...');

    final offer = await _pc!.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': widget.isVideo,
    });
    await _pc!.setLocalDescription(offer);

    final body = <String, dynamic>{
      'offer':    jsonEncode(offer.toMap()),
      'is_video': widget.isVideo,
    };
    if (widget.appointmentId > 0) {
      body['appointment_id'] = widget.appointmentId;
    } else {
      body['conversation_id'] = widget.conversationId;
    }
    await ApiClient.instance.post('/calls/initiate', data: body);

    _startPolling();
  }

  // ── Callee Flow ────────────────────────────────────────────
  Future<void> _calleeFlow() async {
    setState(() => _status = 'جارٍ قبول المكالمة...');

    final res    = await ApiClient.instance.get('/calls/$_channel');
    final signal = res.data as Map<String, dynamic>;

    // Apply offer
    final offerRaw = jsonDecode(signal['offer'] as String) as Map<String, dynamic>;
    await _pc!.setRemoteDescription(
      RTCSessionDescription(offerRaw['sdp'] as String, offerRaw['type'] as String),
    );

    // Create answer
    final answer = await _pc!.createAnswer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': widget.isVideo,
    });
    await _pc!.setLocalDescription(answer);

    await ApiClient.instance.post('/calls/$_channel/answer', data: {
      'answer': jsonEncode(answer.toMap()),
    });

    // Apply any ICE candidates already sent by caller
    await _applyRemoteIce(signal);

    _startPolling();
  }

  // ── Polling ────────────────────────────────────────────────
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final res    = await ApiClient.instance.get('/calls/$_channel');
      final signal = res.data as Map<String, dynamic>;

      final status = signal['status'] as String?;
      if (status == 'ended' || status == 'rejected' || status == 'missed') {
        _pollTimer?.cancel();
        if (mounted) _hangup(remote: true);
        return;
      }

      // Caller: wait for callee's answer
      if (widget.isCaller && !_connected && signal['answer'] != null) {
        final answerRaw = jsonDecode(signal['answer'] as String) as Map<String, dynamic>;
        await _pc!.setRemoteDescription(
          RTCSessionDescription(answerRaw['sdp'] as String, answerRaw['type'] as String),
        );
      }

      await _applyRemoteIce(signal);
    } catch (_) {}
  }

  Future<void> _applyRemoteIce(Map<String, dynamic> signal) async {
    // Caller applies callee_ice; callee applies caller_ice
    final key  = widget.isCaller ? 'callee_ice' : 'caller_ice';
    final list = (signal[key] as List? ?? []);

    for (int i = _appliedRemoteIce; i < list.length; i++) {
      final c = list[i] as Map<String, dynamic>;
      try {
        await _pc!.addCandidate(RTCIceCandidate(
          c['candidate'] as String?,
          c['sdpMid']    as String?,
          c['sdpMLineIndex'] as int?,
        ));
      } catch (_) {}
    }
    _appliedRemoteIce = list.length;
  }

  Future<void> _sendIce(Map<String, dynamic> candidate) async {
    try {
      await ApiClient.instance.post('/calls/$_channel/ice',
          data: {'candidate': candidate});
    } catch (_) {}
  }

  // ── Duration timer ─────────────────────────────────────────
  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  String get _elapsedStr {
    final m = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Hang up ────────────────────────────────────────────────
  Future<void> _hangup({bool remote = false}) async {
    _pollTimer?.cancel();
    _durationTimer?.cancel();
    if (!remote) {
      try {
        await ApiClient.instance.post('/calls/$_channel/status',
            data: {'status': 'ended'});
      } catch (_) {}
    }
    for (final t in _localStream?.getTracks() ?? []) t.stop();
    await _pc?.close();
    _localRenderer.srcObject  = null;
    _remoteRenderer.srcObject = null;
    if (mounted) Navigator.of(context).pop();
  }

  // ── Controls ───────────────────────────────────────────────
  Future<void> _toggleMute() async {
    _muted = !_muted;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !_muted);
    setState(() {});
  }

  Future<void> _toggleVideo() async {
    _videoEnabled = !_videoEnabled;
    _localStream?.getVideoTracks().forEach((t) => t.enabled = _videoEnabled);
    setState(() {});
  }

  Future<void> _flipCamera() async {
    _frontCamera = !_frontCamera;
    final tracks = _localStream?.getVideoTracks() ?? [];
    if (tracks.isNotEmpty) {
      await Helper.switchCamera(tracks.first);
    }
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await Helper.setSpeakerphoneOn(_speakerOn);
    setState(() {});
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // ── Remote video (full screen) ──────────────────────
        if (_connected && widget.isVideo)
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          )
        else
          _AudioBackground(name: widget.peerName, connected: _connected),

        // ── Local video (small, top-left) ───────────────────
        if (widget.isVideo)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100, height: 140,
                child: RTCVideoView(
                  _localRenderer,
                  mirror: _frontCamera,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
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
                _connected ? _elapsedStr : _status,
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
                // Mute
                _CallBtn(
                  icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: _muted ? 'كتم' : 'صوت',
                  color: _muted ? Colors.red.shade400 : Colors.white,
                  bg: Colors.white24,
                  onTap: _toggleMute,
                ),
                // Speaker
                _CallBtn(
                  icon: _speakerOn
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  label: _speakerOn ? 'سماعة' : 'هاتف',
                  color: Colors.white,
                  bg: Colors.white24,
                  onTap: _toggleSpeaker,
                ),
                // Hang up
                _CallBtn(
                  icon: Icons.call_end_rounded,
                  label: 'إنهاء',
                  color: Colors.white,
                  bg: Colors.red,
                  size: 64,
                  onTap: () => _hangup(),
                ),
                // Flip camera (video only)
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
                // Toggle video
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
