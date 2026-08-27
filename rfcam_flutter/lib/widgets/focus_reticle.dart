import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/palette.dart';

/// The tap-to-focus reticle with vertical exposure slider and sun indicator,
/// matching iOS Camera and RfCamera Cam.
class FocusReticle extends StatelessWidget {
  const FocusReticle({
    super.key,
    required this.position,
    required this.ev,
    required this.visible,
    this.scale = 1.0,
    this.opacity = 1.0,
  });

  final Offset position;
  final double ev; // Range -3.0 to +3.0
  final bool visible;
  final double scale;
  final double opacity;

  static const double circleRadius = 38.0;
  static const double sliderOffset = 52.0;
  static const double trackHalfHeight = 54.0;
  static const double boxPadding = 12.0;

  @override
  Widget build(BuildContext context) {
    if (!visible || opacity <= 0.0) {
      return const SizedBox.shrink();
    }

    final boxW = circleRadius + sliderOffset + 24.0;
    final boxH = trackHalfHeight * 2 + boxPadding * 2;

    return Positioned(
      left: position.dx - circleRadius,
      top: position.dy - trackHalfHeight - boxPadding,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: boxW,
              height: boxH,
              child: CustomPaint(
                painter: _FocusReticlePainter(
                  circleCenter: const Offset(
                    circleRadius,
                    trackHalfHeight + boxPadding,
                  ),
                  ev: ev.clamp(-3.0, 3.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusReticlePainter extends CustomPainter {
  _FocusReticlePainter({
    required this.circleCenter,
    required this.ev,
  });

  final Offset circleCenter;
  final double ev;

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = P.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Focus Ring Circle
    canvas.drawCircle(circleCenter, FocusReticle.circleRadius, ringPaint);

    // 2. Sun Position on Track
    final trackX = circleCenter.dx + FocusReticle.sliderOffset;
    final trackTop = circleCenter.dy - FocusReticle.trackHalfHeight;
    final trackBottom = circleCenter.dy + FocusReticle.trackHalfHeight;

    // ev ranges from -3.0 (bottom) to +3.0 (top)
    final travel = FocusReticle.trackHalfHeight - 16.0;
    final sunY = circleCenter.dy - (ev / 3.0) * travel;
    final sunCenter = Offset(trackX, sunY);

    // 3. Vertical Exposure Track (broken into top and bottom segments around the sun)
    final trackPaint = Paint()
      ..color = P.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const sunGap = 14.5;
    final topSegmentEnd = sunCenter.dy - sunGap;
    final bottomSegmentStart = sunCenter.dy + sunGap;

    // Top line segment (above the sun)
    if (topSegmentEnd > trackTop) {
      canvas.drawLine(
        Offset(trackX, trackTop),
        Offset(trackX, topSegmentEnd),
        trackPaint,
      );
    }

    // Bottom line segment (below the sun)
    if (bottomSegmentStart < trackBottom) {
      canvas.drawLine(
        Offset(trackX, bottomSegmentStart),
        Offset(trackX, trackBottom),
        trackPaint,
      );
    }

    // 4. Sun Icon
    _paintSun(canvas, sunCenter);
  }

  void _paintSun(Canvas canvas, Offset center) {
    // Solid filled center disc
    final discPaint = Paint()
      ..color = P.white
      ..style = PaintingStyle.fill;

    const discRadius = 3.6;
    canvas.drawCircle(center, discRadius, discPaint);

    // 8 radiating rays
    final rayPaint = Paint()
      ..color = P.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const rayInner = 5.8;
    const rayOuter = 8.6;
    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      final p1 = Offset(
        center.dx + cosA * rayInner,
        center.dy + sinA * rayInner,
      );
      final p2 = Offset(
        center.dx + cosA * rayOuter,
        center.dy + sinA * rayOuter,
      );
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  @override
  bool shouldRepaint(_FocusReticlePainter old) =>
      old.circleCenter != circleCenter || old.ev != ev;
}
