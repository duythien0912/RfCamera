import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/palette.dart';

/// The tap-to-focus reticle with vertical exposure slider and sun indicator,
/// matching iOS Camera and RfCamera Cam with fluid animations and crisp styling.
class FocusReticle extends StatefulWidget {
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
  State<FocusReticle> createState() => _FocusReticleState();
}

class _FocusReticleState extends State<FocusReticle>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _pulseAnimation = Tween<double>(begin: 1.30, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.visible ? 1.0 : 0.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    if (widget.visible) {
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(FocusReticle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _fadeController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
        _pulseController.forward(from: 0.0);
      } else {
        _fadeController.reverse();
      }
    } else if (widget.visible && widget.position != oldWidget.position) {
      // Reticle moved to a new focus location: re-trigger focus pulse
      _fadeController.value = 1.0;
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _fadeAnimation]),
      builder: (context, child) {
        final currentFade = _fadeAnimation.value * widget.opacity;
        if (!widget.visible && _fadeController.isDismissed) {
          return const SizedBox.shrink();
        }
        if (currentFade <= 0.0) {
          return const SizedBox.shrink();
        }

        const boxW =
            FocusReticle.circleRadius + FocusReticle.sliderOffset + 24.0;
        const boxH =
            FocusReticle.trackHalfHeight * 2 + FocusReticle.boxPadding * 2;

        final currentScale = _pulseAnimation.value * widget.scale;

        return Positioned(
          left: widget.position.dx - FocusReticle.circleRadius,
          top:
              widget.position.dy -
              FocusReticle.trackHalfHeight -
              FocusReticle.boxPadding,
          child: IgnorePointer(
            child: Opacity(
              opacity: currentFade.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: currentScale,
                alignment: const FractionalOffset(
                  FocusReticle.circleRadius / boxW,
                  (FocusReticle.trackHalfHeight + FocusReticle.boxPadding) /
                      boxH,
                ),
                child: RepaintBoundary(
                  child: SizedBox(
                    width: boxW,
                    height: boxH,
                    child: CustomPaint(
                      painter: _FocusReticlePainter(
                        circleCenter: const Offset(
                          FocusReticle.circleRadius,
                          FocusReticle.trackHalfHeight +
                              FocusReticle.boxPadding,
                        ),
                        ev: widget.ev.clamp(-3.0, 3.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
    final shadowRingPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    final ringPaint = Paint()
      ..color = P.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Focus Ring Circle
    canvas.drawCircle(circleCenter, FocusReticle.circleRadius, shadowRingPaint);
    canvas.drawCircle(circleCenter, FocusReticle.circleRadius, ringPaint);

    // 2. Sun Position on Track
    final trackX = circleCenter.dx + FocusReticle.sliderOffset;
    final trackTop = circleCenter.dy - FocusReticle.trackHalfHeight;
    final trackBottom = circleCenter.dy + FocusReticle.trackHalfHeight;

    // ev ranges from -3.0 (bottom) to +3.0 (top)
    final travel = FocusReticle.trackHalfHeight - 16.0;
    final sunY = circleCenter.dy - (ev / 3.0) * travel;
    final sunCenter = Offset(trackX, sunY);

    // 3. Vertical Exposure Track
    final shadowTrackPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

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
        shadowTrackPaint,
      );
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
        shadowTrackPaint,
      );
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
    const discRadius = 3.6;

    // Subtle dark contrast shadow for disc & rays
    final shadowDiscPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, discRadius + 0.6, shadowDiscPaint);

    final shadowRayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    // Solid filled center disc
    final discPaint = Paint()
      ..color = P.white
      ..style = PaintingStyle.fill;

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
      canvas.drawLine(p1, p2, shadowRayPaint);
      canvas.drawLine(p1, p2, rayPaint);
    }

    canvas.drawCircle(center, discRadius, discPaint);
  }

  @override
  bool shouldRepaint(_FocusReticlePainter old) =>
      old.circleCenter != circleCenter || old.ev != ev;
}
