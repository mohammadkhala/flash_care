import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/jitsi_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Wrapper page — launches Jitsi Meet embedded call then pops when done.
class CallScreen extends StatefulWidget {
  final String channel;
  final String appId;       // kept for route compat (ignored)
  final bool   isVideo;
  final String partnerName;
  final int    uid;         // kept for route compat (ignored)

  const CallScreen({
    required this.channel,
    required this.appId,
    required this.isVideo,
    required this.partnerName,
    required this.uid,
    super.key,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await JitsiService.startCall(
        room: 'nabdh-${widget.channel}',
        displayName: widget.partnerName,
        videoMuted: !widget.isVideo,
      );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0F1D48),
    body: Center(
      child: _error
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 56),
              const SizedBox(height: 16),
              const Text('تعذّر بدء المكالمة',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('رجوع'),
              ),
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
