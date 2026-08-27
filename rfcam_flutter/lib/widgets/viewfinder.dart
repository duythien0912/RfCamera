import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/palette.dart';
import 'film_view.dart';
import 'focus_reticle.dart';

/// The rangefinder card: a dim, blurred view of everything the sensor sees,
/// with a crisp, framed crop of what will actually be captured.
///
/// [preview] is built twice — once behind the scrim and once inside the frame —
/// so both layers stay pixel-aligned.
class Viewfinder extends StatelessWidget {
  const Viewfinder({
    super.key,
    required this.preview,
    required this.state,
    required this.onTapDots,
    required this.onTapWhiteBalance,
    required this.onTapFocal,
    required this.onTapExposure,
    this.focalExpanded = false,
    this.exposureExpanded = false,
    this.frameKey,
    this.focusPos,
    this.focusVisible = false,
    this.focusScale = 1.0,
    this.focusOpacity = 1.0,
    this.zoomLevel = 1.0,
    this.zoomBadgeVisible = false,
    this.onTapFocus,
    this.onDoubleTapZoom,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
  });

  final Widget preview;
  final AppState state;
  final VoidCallback onTapDots;
  final VoidCallback onTapWhiteBalance;
  final VoidCallback onTapFocal;
  final VoidCallback onTapExposure;
  final bool focalExpanded;
  final bool exposureExpanded;
  final GlobalKey? frameKey;

  final Offset? focusPos;
  final bool focusVisible;
  final double focusScale;
  final double focusOpacity;
  final double zoomLevel;
  final bool zoomBadgeVisible;
  final void Function(Offset localPos, Size size)? onTapFocus;
  final VoidCallback? onDoubleTapZoom;
  final void Function(ScaleStartDetails details)? onScaleStart;
  final void Function(ScaleUpdateDetails details)? onScaleUpdate;
  final void Function(ScaleEndDetails details)? onScaleEnd;

  /// Width of the inner frame as a fraction of the card, derived from the
  /// focal length. 26mm fills the card (1x); longer lenses crop into it.
  static double frameWidthFraction(int focal) =>
      math.min(1.0, (35 / focal) * 0.74);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        // Reserve the bands the label and the chip row live in, so the frame
        // can never grow underneath them. The aspect ratio is honoured
        // exactly: whichever axis runs out first decides the size.
        const topBand = 0.135;
        const bottomBand = 0.165;
        final frameZoom = state.zoomMode == ZoomMode.frame ? zoomLevel : 1.0;
        final maxW = (w * frameWidthFraction(state.focal)) / frameZoom;
        final maxH = (h * (1 - topBand - bottomBand)) / frameZoom;
        var fw = maxW;
        var fh = fw * state.ratioValue;
        if (fh > maxH) {
          fh = maxH;
          fw = fh / state.ratioValue;
        }
        final frame = Rect.fromCenter(
          center: Offset(w / 2, h * (topBand + (1 - topBand - bottomBand) / 2)),
          width: fw,
          height: fh,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(P.rCard),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              onTapFocus?.call(details.localPosition, Size(w, h));
            },
            onDoubleTap: onDoubleTapZoom,
            onScaleStart: onScaleStart,
            onScaleUpdate: onScaleUpdate,
            onScaleEnd: onScaleEnd,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Outside the frame: blurred and knocked back, the way a real
                // rangefinder shows you what is just out of shot.
                ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: preview,
                ),
                const ColoredBox(color: Color(0x6B000000)),

                if (state.frameOn)
                  ClipRRect(
                    clipper: _RRectClipper(
                      frame,
                      const Radius.circular(P.rInner),
                    ),
                    child: preview,
                  )
                else
                  preview,

                if (state.frameOn)
                  Positioned.fromRect(
                    rect: frame,
                    child: Container(
                      key: frameKey,
                      decoration: BoxDecoration(
                        border: Border.all(color: P.white, width: 2),
                        borderRadius: BorderRadius.circular(P.rInner),
                      ),
                      child: state.gridOn
                          ? CustomPaint(painter: _GridPainter())
                          : null,
                    ),
                  )
                else if (state.gridOn)
                  CustomPaint(painter: _GridPainter()),

                // Focus reticle with exposure slider & sun
                if (focusPos != null)
                  FocusReticle(
                    position: focusPos!,
                    ev: state.ev,
                    visible: focusVisible,
                    scale: focusScale,
                    opacity: focusOpacity,
                  ),

                // "35mm" sits just above the frame, centred on the card.
                if (state.frameOn)
                  Positioned(
                    top: 22,
                    left: 0,
                    right: 0,
                    child: Text(
                      '${state.focal}mm',
                      textAlign: TextAlign.center,
                      style: P
                          .t(17, w: FontWeight.w700)
                          .copyWith(
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 4),
                            ],
                          ),
                    ),
                  ),

                // Floating Zoom Badge
                if (zoomBadgeVisible)
                  Positioned(
                    top: 24,
                    left: 16,
                    // right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC2C2C2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0x44FFFFFF),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${zoomLevel.toStringAsFixed(1)}x',
                          style: P.t(13, w: FontWeight.w700, c: P.white),
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 12,
                  right: 10,
                  child: _TapTarget(
                    key: const Key('vf_dots'),
                    onTap: onTapDots,
                    size: 44,
                    child: const Icon(
                      IconsaxOutline.more,
                      color: P.white,
                      size: 26,
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: h * 0.045,
                  child: _ChipRow(
                    state: state,
                    focalExpanded: focalExpanded,
                    exposureExpanded: exposureExpanded,
                    onTapWhiteBalance: onTapWhiteBalance,
                    onTapFocal: onTapFocal,
                    onTapExposure: onTapExposure,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RRectClipper extends CustomClipper<RRect> {
  _RRectClipper(this.rect, this.radius);
  final Rect rect;
  final Radius radius;
  @override
  RRect getClip(Size size) => RRect.fromRectAndRadius(rect, radius);
  @override
  bool shouldReclip(_RRectClipper old) =>
      old.rect != rect || old.radius != radius;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = P.white.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    for (var i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      final y = size.height * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

/// White balance / focal length / exposure, floating over the bottom of the
/// card. The middle and right chips collapse to a chevron while their tray is
/// open, exactly as in the reference.
class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.state,
    required this.focalExpanded,
    required this.exposureExpanded,
    required this.onTapWhiteBalance,
    required this.onTapFocal,
    required this.onTapExposure,
  });

  final AppState state;
  final bool focalExpanded;
  final bool exposureExpanded;
  final VoidCallback onTapWhiteBalance;
  final VoidCallback onTapFocal;
  final VoidCallback onTapExposure;

  static const _fill = Color(0xCC3A3632);
  static const _h = 34.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Chip(
          key: const Key('vf_wb'),
          onTap: onTapWhiteBalance,
          child: const Icon(
            IconsaxOutline.blend,
            color: P.white,
            size: 19,
          ),
        ),
        const SizedBox(width: 8),
        if (focalExpanded)
          _Chip(
            key: const Key('vf_focal'),
            onTap: onTapFocal,
            transparent: true,
            child: const Icon(
              IconsaxOutline.arrow_down_1,
              color: P.white,
              size: 22,
            ),
          )
        else
          _Chip(
            key: const Key('vf_focal'),
            onTap: onTapFocal,
            child: Text('${state.focal}', style: P.t(15, w: FontWeight.w600)),
          ),
        const SizedBox(width: 8),
        if (exposureExpanded)
          _Chip(
            key: const Key('vf_ev'),
            onTap: onTapExposure,
            transparent: true,
            child: const Icon(
              IconsaxOutline.arrow_down_1,
              color: P.white,
              size: 22,
            ),
          )
        else
          _Chip(
            key: const Key('vf_ev'),
            onTap: onTapExposure,
            width: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _SunAuto(),
                const SizedBox(width: 6),
                Text(
                  state.ev == 0 ? '0' : state.ev.toStringAsFixed(1),
                  style: P.t(15, w: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The little sun with a subscript A that marks auto exposure.
class _SunAuto extends StatelessWidget {
  const _SunAuto();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 1,
            child: Icon(IconsaxOutline.sun_1, color: P.white, size: 16),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text('A', style: P.t(8, w: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.child,
    required this.onTap,
    this.width,
    this.transparent = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final double? width;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: _ChipRow._h,
        width: width ?? _ChipRow._h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: transparent ? Colors.transparent : _ChipRow._fill,
          borderRadius: BorderRadius.circular(_ChipRow._h / 2),
        ),
        child: child,
      ),
    );
  }
}

class _TapTarget extends StatelessWidget {
  const _TapTarget({
    super.key,
    required this.child,
    required this.onTap,
    required this.size,
  });

  final Widget child;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

/// Stand-in preview for devices with no usable camera (simulators, desktop,
/// or a denied permission). Keeps every screen reachable and testable.
class MockPreview extends StatelessWidget {
  const MockPreview({
    super.key,
    this.color = const Color(0xFF161618),
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('mock_preview'),
      color: color,
    );
  }
}

/// Applies the current look to whatever preview is available.
class LivePreview extends StatelessWidget {
  const LivePreview({super.key, required this.state, required this.child});

  final AppState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FilmView(
      effect: state.effect,
      seed: state.seed,
      showStamp: false,
      child: child,
    );
  }
}
