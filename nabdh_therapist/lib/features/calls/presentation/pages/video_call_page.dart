import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/l10n/s.dart';
import '../../../../core/services/agora_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Full-screen Agora RTC call page for the therapist app.
class VideoCallPage extends StatefulWidget {
  final String channel;
  final String appId;
  final String token;
  final int    uid;
  final String peerName;
  final bool   isVideo;

  const VideoCallPage({
    required this.channel,
    required this.appId,
    this.token    = '',
    this.uid      = 0,
    this.peerName = 'المريض',
    this.isVideo  = true,
    super.key,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RtcEngine? _engine;
  String?    _token;

  // ── State ──────────────────────────────────────────────────────────
  bool _joining               = true;
  bool _joined                = false;

  // Separate permission vs connection errors
  bool _permError             = false;
  bool _permPermanentlyDenied = false;
  bool _connectionError       = false;
  String _connectionErrorMsg  = '';

  bool _mutedMic              = false;
  bool _mutedSpeaker          = false;
  bool _cameraOff             = false;

  int? _remoteUid;
  int  _callSeconds = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _init();
  }

  // ── Init ───────────────────────────────────────────────────────────
  Future<void> _init() async {
    // Always clean up any stale engine FIRST to avoid ERR_JOIN_CHANNEL_REJECTED (-17)
    if (_engine != null) {
      try { await _engine!.leaveChannel(); } catch (_) {}
      try { await _engine!.release();      } catch (_) {}
      _engine = null;
    }

    if (!mounted) return;
    setState(() {
      _joining          = true;
      _permError        = false;
      _connectionError  = false;
      _connectionErrorMsg = '';
      _joined           = false;
      _remoteUid        = null;
      _callSeconds      = 0;
    });

    // 1. Check / request permissions
    final needed = widget.isVideo
        ? [Permission.microphone, Permission.camera]
        : [Permission.microphone];

    // Check current status without triggering dialog
    for (final p in needed) {
      final status = await p.status;
      if (status.isPermanentlyDenied) {
        if (mounted) setState(() {
          _joining = false;
          _permError = true;
          _permPermanentlyDenied = true;
        });
        return;
      }
    }

    // Request if not granted
    bool allGranted = true;
    for (final p in needed) {
      if (!(await p.status).isGranted) { allGranted = false; break; }
    }

    if (!allGranted) {
      final statuses = await needed.request();
      if (statuses.values.any((s) => !s.isGranted)) {
        final anyPerm = statuses.values.any((s) => s.isPermanentlyDenied);
        if (mounted) setState(() {
          _joining = false;
          _permError = true;
          _permPermanentlyDenied = anyPerm;
        });
        return;
      }
    }

    // 2. Fetch token from backend
    try {
      _token = await AgoraService.instance.fetchToken(channel: widget.channel);
    } catch (e) {
      if (mounted) setState(() {
        _joining = false;
        _connectionError = true;
        _connectionErrorMsg = e.toString().replaceFirst('Exception: ', '');
      });
      return;
    }

    // 3. Create engine
    try {
      _engine = await AgoraService.instance.createEngine();
    } catch (e) {
      if (mounted) setState(() {
        _joining = false;
        _connectionError = true;
        _connectionErrorMsg = e.toString();
      });
      return;
    }

    // 4. Register event handlers
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        if (mounted) setState(() { _joining = false; _joined = true; });
        _startTimer();
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        if (mounted) setState(() => _remoteUid = remoteUid);
      },
      onUserOffline: (connection, remoteUid, reason) {
        if (mounted) setState(() => _remoteUid = null);
        _hangup();
      },
      onError: (err, msg) {
        // Error 17 = ERR_INVALID_TOKEN
        // Could mean certificate is disabled in Agora Console — retry without token
        if (err == ErrorCodeType.errInvalidToken && (_token?.isNotEmpty ?? false)) {
          _token = '';
          _engine!.joinChannel(
            token: '',
            channelId: widget.channel,
            uid: 0,
            options: ChannelMediaOptions(
              autoSubscribeAudio: true,
              autoSubscribeVideo: widget.isVideo,
              publishMicrophoneTrack: true,
              publishCameraTrack: widget.isVideo,
              clientRoleType: ClientRoleType.clientRoleBroadcaster,
            ),
          );
          return;
        }
        if (mounted) setState(() {
          _joining = false;
          _connectionError = true;
          _connectionErrorMsg = 'كود الخطأ: ${err.index} — $msg';
        });
      },
    ));

    // 5. Configure audio/video
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableAudio();
    if (widget.isVideo) {
      await _engine!.enableVideo();
      await _engine!.startPreview();
    }

    // 6. Join channel
    final joinOpts = ChannelMediaOptions(
      autoSubscribeAudio: true,
      autoSubscribeVideo: widget.isVideo,
      publishMicrophoneTrack: true,
      publishCameraTrack: widget.isVideo,
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
    );

    Future<void> doJoin(String token) async {
      await _engine!.joinChannel(
        token: token,
        channelId: widget.channel,
        uid: 0,
        options: joinOpts,
      );
    }

    try {
      await doJoin(_token ?? '');
    } catch (e) {
      final msg = e.toString();
      // -17 = ERR_JOIN_CHANNEL_REJECTED: engine may still be settling, retry after delay
      if (msg.contains('-17') || msg.contains('join_channel_rejected')) {
        try {
          await Future.delayed(const Duration(milliseconds: 1200));
          await doJoin(_token ?? '');
          return;
        } catch (e2) {
          // If still -17 and we have a token, retry without token
          if (e2.toString().contains('-17') && (_token?.isNotEmpty ?? false)) {
            try {
              await doJoin('');
              return;
            } catch (_) {}
          }
          if (mounted) setState(() {
            _joining = false; _connectionError = true;
            _connectionErrorMsg = 'خطأ في الانضمام: ${e2.toString()}';
          });
          return;
        }
      }
      if (mounted) setState(() {
        _joining = false; _connectionError = true;
        _connectionErrorMsg = e.toString();
      });
    }
  }

  // ── Timer ──────────────────────────────────────────────────────────
  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_joined) return;
      setState(() => _callSeconds++);
      _startTimer();
    });
  }

  String get _duration {
    final m = _callSeconds ~/ 60;
    final s = _callSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Controls ───────────────────────────────────────────────────────
  Future<void> _toggleMic() async {
    _mutedMic = !_mutedMic;
    await _engine?.muteLocalAudioStream(_mutedMic);
    if (mounted) setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _mutedSpeaker = !_mutedSpeaker;
    await _engine?.setEnableSpeakerphone(!_mutedSpeaker);
    if (mounted) setState(() {});
  }

  Future<void> _toggleCamera() async {
    _cameraOff = !_cameraOff;
    await _engine?.muteLocalVideoStream(_cameraOff);
    if (mounted) setState(() {});
  }

  Future<void> _flipCamera() async {
    await _engine?.switchCamera();
    if (mounted) setState(() {});
  }

  Future<void> _hangup() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_permError)       return _buildPermError();
    if (_connectionError) return _buildConnectionError();
    if (_joining)         return _buildConnecting();
    return widget.isVideo ? _buildVideoCall() : _buildAudioCall();
  }

  // ── Video call UI ──────────────────────────────────────────────────
  Widget _buildVideoCall() => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(children: [
      if (_remoteUid != null)
        SizedBox.expand(
          child: AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine!,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: widget.channel),
            ),
          ),
        )
      else
        _buildWaiting(),
      if (!_cameraOff)
        Positioned(
          top: 60, right: 16,
          width: 100, height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine!,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),
        ),
      _buildTopBar(),
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: _buildControls(isVideo: true),
      ),
    ]),
  );

  // ── Audio call UI ──────────────────────────────────────────────────
  Widget _buildAudioCall() => Scaffold(
    backgroundColor: const Color(0xFF0A1628),
    body: Stack(children: [
      Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 24, spreadRadius: 4)],
            ),
            child: Center(child: Text(
              widget.peerName.isNotEmpty ? widget.peerName[0] : '؟',
              style: const TextStyle(color: Colors.white,
                  fontSize: 40, fontWeight: FontWeight.w700),
            )),
          ),
          const SizedBox(height: 20),
          Text(widget.peerName,
              style: const TextStyle(color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            _remoteUid != null ? _duration : 'جارٍ الاتصال...',
            style: TextStyle(
              color: _remoteUid != null ? AppColors.success : Colors.white54,
              fontSize: 15,
            ),
          ),
        ]),
      ),
      _buildTopBar(),
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: _buildControls(isVideo: false),
      ),
    ]),
  );

  Widget _buildTopBar() => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        if (widget.isVideo && _remoteUid != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_duration,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
      ]),
    ),
  );

  Widget _buildControls({required bool isVideo}) => Container(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Colors.black87, Colors.transparent],
      ),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _CtrlBtn(
        icon: _mutedMic ? Icons.mic_off_rounded : Icons.mic_rounded,
        label: _mutedMic ? 'كتم' : 'ميكروفون',
        onTap: _toggleMic,
        active: !_mutedMic,
      ),
      if (!isVideo)
        _CtrlBtn(
          icon: _mutedSpeaker ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          label: 'سماعة',
          onTap: _toggleSpeaker,
          active: !_mutedSpeaker,
        )
      else
        _CtrlBtn(
          icon: _cameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
          label: 'كاميرا',
          onTap: _toggleCamera,
          active: !_cameraOff,
        ),
      _CtrlBtn(
        icon: Icons.call_end_rounded,
        label: 'إنهاء',
        onTap: _hangup,
        isEndCall: true,
      ),
      if (isVideo)
        _CtrlBtn(
          icon: Icons.flip_camera_ios_rounded,
          label: 'قلب',
          onTap: _flipCamera,
          active: true,
        )
      else
        const SizedBox(width: 56),
    ]),
  );

  Widget _buildWaiting() => Container(
    color: const Color(0xFF0A1628),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        const SizedBox(height: 16),
        Text('في انتظار ${widget.peerName}...',
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ]),
    ),
  );

  Widget _buildConnecting() => const Scaffold(
    backgroundColor: Color(0xFF0A1628),
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 20),
        Text('جارٍ الاتصال...', style: TextStyle(color: Colors.white70)),
      ]),
    ),
  );

  // ── Permission error ───────────────────────────────────────────────
  Widget _buildPermError() => Scaffold(
    backgroundColor: const Color(0xFF0A1628),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.mic_off_rounded, color: Colors.redAccent, size: 64),
          const SizedBox(height: 20),
          const Text('إذن الميكروفون مطلوب',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            _permPermanentlyDenied
                ? 'تم رفض أذونات الميكروفون والكاميرا بشكل دائم.\nافتح إعدادات التطبيق لمنح الأذونات يدوياً.'
                : 'يرجى السماح للتطبيق باستخدام الميكروفون${widget.isVideo ? " والكاميرا" : ""}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () async { await openAppSettings(); },
            icon: const Icon(Icons.settings_rounded),
            label: const Text('فتح إعدادات التطبيق'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _init,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            label: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white70)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              minimumSize: const Size(220, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white38),
            label: Text(S.back, style: const TextStyle(color: Colors.white38)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white12),
              minimumSize: const Size(220, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ]),
      ),
    ),
  );

  // ── Connection error ───────────────────────────────────────────────
  Widget _buildConnectionError() => Scaffold(
    backgroundColor: const Color(0xFF0A1628),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.orangeAccent, size: 64),
          const SizedBox(height: 20),
          const Text('تعذّر الاتصال بالمكالمة',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          const Text(
            'تحقق من اتصالك بالإنترنت وحاول مجدداً.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
          ),
          if (_connectionErrorMsg.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _connectionErrorMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white24, fontSize: 11),
              ),
            ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _init,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
            label: Text(S.back, style: const TextStyle(color: Colors.white70)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              minimumSize: const Size(220, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ]),
      ),
    ),
  );
}

// ── Control button ─────────────────────────────────────────────────
class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final VoidCallback onTap;
  final bool active;
  final bool isEndCall;

  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active    = true,
    this.isEndCall = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: isEndCall
              ? Colors.red
              : (active ? Colors.white24 : Colors.white12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: isEndCall ? Colors.white
                : (active ? Colors.white : Colors.white38),
            size: 26),
      ),
      const SizedBox(height: 6),
      Text(label,
          style: const TextStyle(color: Colors.white60, fontSize: 11)),
    ]),
  );
}
