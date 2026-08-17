import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Incoming Call Page — shown to callee before they accept/reject
// ──────────────────────────────────────────────────────────────────────────────

class IncomingCallPage extends StatefulWidget {
  final String channel;
  final String callerName;
  final bool   isVideo;

  const IncomingCallPage({
    required this.channel,
    required this.callerName,
    required this.isVideo,
    super.key,
  });

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Auto-reject after 60 s if no answer
    _timeout = Timer(const Duration(seconds: 60), () {
      if (mounted) _reject(silent: true);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _timeout?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── Accept ─────────────────────────────────────────────────────────────────
  void _accept() {
    _timeout?.cancel();
    context.pushReplacement('/call', extra: {
      'conversationId': 0,
      'peerName':       widget.callerName,
      'isVideo':        widget.isVideo,
      'isCaller':       false,
      'channel':        widget.channel,
    });
  }

  // ── Reject ─────────────────────────────────────────────────────────────────
  Future<void> _reject({bool silent = false}) async {
    _timeout?.cancel();
    if (!silent) {
      try {
        await ApiClient.instance.post(
          '/calls/${widget.channel}/status',
          data: {'status': 'rejected'},
        );
      } catch (_) {}
    }
    if (mounted) context.pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [

        // ── Gradient background ─────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1B2A), Color(0xFF1B2A4A), Color(0xFF0F3460)],
            ),
          ),
        ),

        // ── Pulsing rings ───────────────────────────────────────────────────
        Center(
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Stack(alignment: Alignment.center, children: [
              for (final (i, r) in [1.9, 1.55, 1.2].indexed)
                Transform.scale(
                  scale: r - (_pulse.value * 0.08),
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03 + i * 0.02),
                    ),
                  ),
                ),
              // Avatar circle
              Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white38, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    widget.callerName.isNotEmpty ? widget.callerName[0] : '؟',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),

        // ── Caller info (top) ───────────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 56,
          left: 0, right: 0,
          child: Column(children: [
            Text(
              widget.callerName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 10),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                widget.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                color: Colors.white70, size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isVideo ? 'مكالمة فيديو واردة...' : 'مكالمة صوتية واردة...',
                style: const TextStyle(
                  color: Colors.white70, fontSize: 16, fontFamily: 'Cairo',
                ),
              ),
            ]),
          ]),
        ),

        // ── Accept / Reject buttons (bottom) ───────────────────────────────
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 60,
          left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionBtn(
                icon: Icons.call_end_rounded,
                label: 'رفض',
                color: const Color(0xFFE53935),
                onTap: _reject,
              ),
              _ActionBtn(
                icon: widget.isVideo
                    ? Icons.videocam_rounded
                    : Icons.call_rounded,
                label: 'قبول',
                color: const Color(0xFF43A047),
                onTap: _accept,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 76, height: 76,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
        ),
        child: Icon(icon, color: Colors.white, size: 34),
      ),
      const SizedBox(height: 12),
      Text(label,
        style: const TextStyle(
          color: Colors.white, fontSize: 15,
          fontFamily: 'Cairo', fontWeight: FontWeight.w600,
        ),
      ),
    ]),
  );
}
