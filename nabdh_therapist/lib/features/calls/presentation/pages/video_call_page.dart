import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/jitsi_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Wrapper page — launches Jitsi Meet embedded call then pops when done.
class VideoCallPage extends StatefulWidget {
  final String channel;
  final String appId;     // kept for route compat (ignored)
  final String token;     // kept for route compat (ignored)
  final int    uid;       // kept for route compat (ignored)
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
  bool _launching = true;
  bool _error     = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await JitsiService.startCall(
        room: 'nabdh-${widget.channel}',
        displayName: widget.peerName,
        videoMuted: !widget.isVideo,
      );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) setState(() { _launching = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primaryDark,
    body: Center(
      child: _error
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 56),
              const SizedBox(height: 16),
              const Text('تعذّر بدء المكالمة',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => context.pop(), child: const Text('رجوع')),
            ])
          : const Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text('جارٍ فتح المكالمة...',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
    ),
  );
}
