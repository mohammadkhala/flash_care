import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// NABD CARE logo rendered in code — matches the brand identity:
/// - "NABD" in navy bold
/// - "CARE" in red bold
/// - heartbeat line in red
/// - wheelchair icon in gray + navy
class NabdLogo extends StatelessWidget {
  final double size;
  final bool onDark; // true → white NABD text instead of navy

  const NabdLogo({super.key, this.size = 120, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final navyColor = onDark ? Colors.white : AppColors.primary;
    return SizedBox(
      width: size * 1.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Heartbeat line ──────────────────────────────────────────
          SizedBox(
            height: size * 0.28,
            child: CustomPaint(
              painter: _HeartbeatPainter(color: AppColors.accent),
              size: Size(size * 1.8, size * 0.28),
            ),
          ),
          const SizedBox(height: 4),
          // ── NABD + CARE + wheelchair ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NABD',
                    style: TextStyle(
                      color: navyColor,
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1,
                    ),
                  ),
                  Text(
                    'CARE',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              // Wheelchair icon
              CustomPaint(
                painter: _WheelchairPainter(
                  bodyColor: AppColors.brandGray,
                  wheelColor: AppColors.primary,
                ),
                size: Size(size * 0.42, size * 0.52),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Heartbeat line painter ────────────────────────────────────────────────
class _HeartbeatPainter extends CustomPainter {
  final Color color;
  _HeartbeatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final h = size.height;
    final w = size.width;

    final path = Path()
      ..moveTo(0, h * 0.5)
      ..lineTo(w * 0.25, h * 0.5)
      ..lineTo(w * 0.35, h * 0.05)
      ..lineTo(w * 0.42, h * 0.95)
      ..lineTo(w * 0.5, h * 0.2)
      ..lineTo(w * 0.57, h * 0.7)
      ..lineTo(w * 0.63, h * 0.5)
      ..lineTo(w, h * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartbeatPainter old) => old.color != color;
}

// ── Wheelchair icon painter ───────────────────────────────────────────────
class _WheelchairPainter extends CustomPainter {
  final Color bodyColor;
  final Color wheelColor;
  _WheelchairPainter({required this.bodyColor, required this.wheelColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = bodyColor..style = PaintingStyle.fill;
    final wheelPaint = Paint()
      ..color = wheelColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12;

    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.55, h * 0.1), w * 0.13, bodyPaint);

    // Torso + arm + seat
    final bodyPath = Path()
      ..moveTo(w * 0.55, h * 0.24)
      ..lineTo(w * 0.45, h * 0.55)
      ..lineTo(w * 0.85, h * 0.55)
      ..lineTo(w * 0.85, h * 0.68)
      ..lineTo(w * 0.48, h * 0.68)
      ..lineTo(w * 0.55, h * 0.24);
    canvas.drawPath(bodyPath, bodyPaint);

    // Big wheel (arc)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.42, h * 0.82), width: w * 0.7, height: w * 0.7),
      math.pi * 0.2, math.pi * 1.6, false, wheelPaint,
    );

    // Small front wheel
    canvas.drawCircle(Offset(w * 0.82, h * 0.88), w * 0.09,
        wheelPaint..strokeWidth = size.width * 0.1);
  }

  @override
  bool shouldRepaint(_WheelchairPainter old) => false;
}

/// Compact text-only brand mark  e.g. for AppBar
class NabdBrandText extends StatelessWidget {
  final double fontSize;
  final bool onDark;
  const NabdBrandText({super.key, this.fontSize = 20, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final navyColor = onDark ? Colors.white : AppColors.primary;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'NABD',
            style: TextStyle(
              color: navyColor, fontSize: fontSize,
              fontWeight: FontWeight.w900, fontFamily: 'Cairo', letterSpacing: 1,
            ),
          ),
          TextSpan(
            text: ' CARE',
            style: TextStyle(
              color: AppColors.accent, fontSize: fontSize,
              fontWeight: FontWeight.w900, fontFamily: 'Cairo', letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
