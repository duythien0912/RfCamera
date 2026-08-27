import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/camera_catalog.dart';
import '../core/palette.dart';

/// Procedurally-drawn camera illustration. No image assets.
///
/// Everything is rendered by [_CameraArtPainter] inside a virtual 100x100
/// design space that is scaled to [size], so the artwork stays crisp at any
/// resolution and reads correctly down to ~40 px.
///
/// Lighting convention, applied by every body:
///   * key light from the upper left (bodies are lit top-left, shaded
///     bottom-right, and carry a bright edge along the lit corner),
///   * a soft ground shadow offset slightly down-right,
///   * lens glass takes a tight specular in the upper left plus a faint
///     rim light along the opposite edge.
class CameraArt extends StatelessWidget {
  const CameraArt({super.key, required this.profile, this.size = 56});

  final CameraProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size.square(size),
        painter: _CameraArtPainter(profile: profile, size: size),
        isComplex: true,
      ),
    );
  }
}

/// The name label as it appears under a camera: white text, with the trailing
/// badge letter (e.g. the purple `R`) in [P.badgeR].
class CameraName extends StatelessWidget {
  const CameraName({
    super.key,
    required this.profile,
    this.fontSize = 11,
    this.pill = false,
  });

  final CameraProfile profile;
  final double fontSize;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final label = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: profile.name,
            style: P.t(fontSize, w: FontWeight.w700),
          ),
          if (profile.badge != null)
            TextSpan(
              text: ' ${profile.badge}',
              style: P.t(fontSize, w: FontWeight.w800, c: P.badgeR),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    if (!pill) return label;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: P.tile,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: P.hairline, width: 0.6),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.78,
          vertical: fontSize * 0.32,
        ),
        child: label,
      ),
    );
  }
}

// ---------------------------------------------------------------- helpers

const Color _white = Color(0xFFFFFFFF);
const Color _black = Color(0xFF000000);
const Color _red = Color(0xFFE0382C);

/// Surface finish. Only changes the specular response, never the hue:
/// metal takes a tight bright band, plastic a broad dim one, leatherette
/// almost none plus a fine matte stipple.
enum _Mat { metal, plastic, leather }

/// Mix [c] towards white.
Color _lift(Color c, double t) => Color.lerp(c, _white, t)!;

/// Mix [c] towards black.
Color _drop(Color c, double t) => Color.lerp(c, _black, t)!;

Color _fade(Color c, double a) => c.withValues(alpha: a);

/// Top-left lit / bottom-right shaded body fill.
Paint _bodyPaint(Rect r, Color c, {double lift = 0.32, double drop = 0.38}) {
  // Very dark bodies need extra lift or they vanish against the black sheet.
  final lum = c.computeLuminance();
  final l = lum < 0.02
      ? lift + 0.24
      : lum < 0.06
      ? lift + 0.14
      : lift;
  return Paint()
    ..shader = ui.Gradient.linear(
      r.topLeft,
      r.bottomRight,
      <Color>[_lift(c, l), c, _drop(c, drop)],
      const <double>[0.0, 0.52, 1.0],
    );
}

/// Horizontal cylinder shading (dark left/right edges, lit band left of centre).
Paint _tubePaint(Rect r, Color c) {
  return Paint()
    ..shader = ui.Gradient.linear(
      Offset(r.left, r.top),
      Offset(r.right, r.top),
      <Color>[_drop(c, 0.5), _lift(c, 0.34), c, _drop(c, 0.46)],
      const <double>[0.0, 0.28, 0.62, 1.0],
    );
}

/// Vertical cylinder shading (dark top/bottom, lit band above centre).
Paint _tubePaintV(Rect r, Color c) {
  return Paint()
    ..shader = ui.Gradient.linear(
      Offset(r.left, r.top),
      Offset(r.left, r.bottom),
      <Color>[_drop(c, 0.42), _lift(c, 0.30), c, _drop(c, 0.5)],
      const <double>[0.0, 0.26, 0.6, 1.0],
    );
}

RRect _rr(double l, double t, double r, double b, double radius) =>
    RRect.fromRectAndRadius(
      Rect.fromLTRB(l, t, r, b),
      Radius.circular(radius),
    );

class _CameraArtPainter extends CustomPainter {
  const _CameraArtPainter({required this.profile, required this.size});

  final CameraProfile profile;
  final double size;

  Color get _c0 =>
      profile.colors.isNotEmpty ? profile.colors[0] : const Color(0xFF3A3A3C);

  Color get _c1 =>
      profile.colors.length > 1 ? profile.colors[1] : _drop(_c0, 0.45);

  Color get _accent => profile.colors.length > 2 ? profile.colors[2] : _red;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.scale(s.width / 100, s.height / 100);

    switch (profile.body) {
      case CamBody.compact:
        _contactShadow(canvas, 51, 78, 36, 6);
        _compact(canvas);
      case CamBody.slr:
        _contactShadow(canvas, 51, 81, 38, 6);
        _slr(canvas);
      case CamBody.slrGrip:
        _contactShadow(canvas, 52, 80, 40, 6);
        _slrGrip(canvas);
      case CamBody.rangefinder:
        _contactShadow(canvas, 51, 79, 38, 6);
        _rangefinder(canvas);
      case CamBody.cineCam:
        _contactShadow(canvas, 47, 78, 34, 6);
        _cineCam(canvas);
      case CamBody.camcorder:
        _contactShadow(canvas, 53, 75, 36, 6);
        _camcorder(canvas);
      case CamBody.flipCam:
        _contactShadow(canvas, 60, 81, 34, 6);
        _flipCam(canvas);
      case CamBody.cassette:
        _contactShadow(canvas, 51, 77, 38, 6);
        _cassette(canvas);
      case CamBody.canister:
        _contactShadow(canvas, 55, 85, 24, 5);
        _canister(canvas);
      case CamBody.projector:
        _contactShadow(canvas, 51, 81, 38, 6);
        _projector(canvas);
      case CamBody.bottle:
        _contactShadow(canvas, 51, 87, 28, 5);
        _bottle(canvas);
      case CamBody.toyGun:
        _contactShadow(canvas, 41, 87, 30, 5);
        _toyGun(canvas);
      case CamBody.toyCam:
        _contactShadow(canvas, 52, 85, 32, 6);
        _toyCam(canvas);
      case CamBody.kino:
        _contactShadow(canvas, 51, 83, 34, 6);
        _kino(canvas);
      case CamBody.instant:
        _contactShadow(canvas, 51, 87, 32, 5);
        _instant(canvas);
      case CamBody.instantWide:
        _contactShadow(canvas, 51, 80, 42, 6);
        _instantWide(canvas);
      case CamBody.filmStrip:
        _contactShadow(canvas, 51, 88, 32, 5);
        _filmStrip(canvas);
      case CamBody.triLens:
        _contactShadow(canvas, 51, 75, 40, 6);
        _triLens(canvas);
      case CamBody.disposable:
        _contactShadow(canvas, 49, 79, 34, 6);
        _disposable(canvas);
      case CamBody.halfFrame:
        _contactShadow(canvas, 51, 83, 30, 5);
        _halfFrame(canvas);
      case CamBody.sphere:
        _contactShadow(canvas, 51, 87, 26, 5);
        _sphere(canvas);
      case CamBody.frame:
        _contactShadow(canvas, 51, 88, 32, 5);
        _frame(canvas);
      case CamBody.cardCompact:
        _contactShadow(canvas, 51, 73, 38, 5);
        _cardCompact(canvas);
      case CamBody.zoomCompact:
        _contactShadow(canvas, 51, 79, 40, 6);
        _zoomCompact(canvas);
      case CamBody.bridge:
        _contactShadow(canvas, 51, 83, 40, 6);
        _bridge(canvas);
      case CamBody.waterproof:
        _contactShadow(canvas, 51, 83, 38, 6);
        _waterproof(canvas);
      case CamBody.tlr:
        _contactShadow(canvas, 51, 89, 28, 5);
        _tlr(canvas);
      case CamBody.folder:
        _contactShadow(canvas, 51, 92, 36, 5);
        _folder(canvas);
      case CamBody.boxCam:
        _contactShadow(canvas, 51, 92, 30, 5);
        _boxCam(canvas);
      case CamBody.panorama:
        _contactShadow(canvas, 51, 73, 46, 5);
        _panorama(canvas);
      case CamBody.actionCube:
        _contactShadow(canvas, 51, 87, 30, 5);
        _actionCube(canvas);
      case CamBody.foldSlr:
        _contactShadow(canvas, 51, 89, 40, 5);
        _foldSlr(canvas);
      case CamBody.filterDisc:
        _contactShadow(canvas, 51, 84, 34, 5);
        _filterDisc(canvas);
      case CamBody.flashUnit:
        _contactShadow(canvas, 51, 88, 26, 5);
        _flashUnit(canvas);
      case CamBody.domeLens:
        _contactShadow(canvas, 51, 88, 30, 5);
        _domeLens(canvas);
    }

    if (profile.flashDot) _flashDot(canvas);
    if (profile.beta) _betaBadge(canvas);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CameraArtPainter oldDelegate) =>
      oldDelegate.profile != profile || oldDelegate.size != size;

  // ------------------------------------------------------------- primitives

  /// Soft ground shadow. Offset slightly down-right of the body to match the
  /// upper-left key light.
  void _contactShadow(Canvas c, double cx, double cy, double w, double h) {
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
      Paint()
        ..color = _fade(_black, 0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5),
    );
  }

  /// Rounded body block: gradient shading, a grounded bottom edge, a
  /// material-specific sheen and a lit top-left edge.
  void _block(
    Canvas c,
    RRect box,
    Color color, {
    double lift = 0.32,
    _Mat mat = _Mat.plastic,
  }) {
    final r = box.outerRect;
    c.drawRRect(box, _bodyPaint(r, color, lift: lift));

    c.save();
    c.clipRRect(box);

    // grounded bottom edge
    c.drawRect(
      Rect.fromLTRB(r.left, r.bottom - r.height * 0.20, r.right, r.bottom),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(r.left, r.bottom - r.height * 0.20),
          Offset(r.left, r.bottom),
          <Color>[_fade(_black, 0.0), _fade(_black, 0.34)],
        ),
    );

    switch (mat) {
      case _Mat.metal:
        // tight, bright band right under the lit edge
        final h = math.max(1.6, r.height * 0.13);
        c.drawRect(
          Rect.fromLTRB(r.left, r.top, r.right, r.top + h),
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(r.left, r.top),
              Offset(r.left, r.top + h),
              <Color>[_fade(_white, 0.32), _fade(_white, 0.0)],
            ),
        );
      case _Mat.plastic:
        // broad, dim sheen
        final h = r.height * 0.34;
        c.drawRect(
          Rect.fromLTRB(r.left, r.top, r.right, r.top + h),
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(r.left, r.top),
              Offset(r.left, r.top + h),
              <Color>[_fade(_white, 0.11), _fade(_white, 0.0)],
            ),
        );
      case _Mat.leather:
        final h = r.height * 0.18;
        c.drawRect(
          Rect.fromLTRB(r.left, r.top, r.right, r.top + h),
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(r.left, r.top),
              Offset(r.left, r.top + h),
              <Color>[_fade(_white, 0.06), _fade(_white, 0.0)],
            ),
        );
        _stipple(c, r);
    }
    c.restore();

    _edgeLight(c, box, mat);
  }

  /// Fine matte texture for leatherette / cardboard surfaces.
  void _stipple(Canvas c, Rect r) {
    final rnd = math.Random(9);
    final n = math.min(120, (r.width * r.height / 26).round());
    for (var i = 0; i < n; i++) {
      final x = r.left + rnd.nextDouble() * r.width;
      final y = r.top + rnd.nextDouble() * r.height;
      c.drawCircle(
        Offset(x, y),
        0.75,
        Paint()..color = _fade(i.isEven ? _black : _white, 0.075),
      );
    }
  }

  /// Bright edge along the lit (top-left) side, dark along the shaded side.
  void _edgeLight(Canvas c, RRect box, _Mat mat) {
    final r = box.outerRect;
    c.drawRRect(
      box.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = ui.Gradient.linear(
          r.topLeft,
          r.bottomRight,
          <Color>[
            _fade(_white, mat == _Mat.metal ? 0.44 : 0.22),
            _fade(_white, 0.0),
            _fade(_black, 0.26),
          ],
          const <double>[0.0, 0.44, 1.0],
        ),
    );
  }

  /// Same lit edge for a free path.
  void _edgeLightPath(Canvas c, Path p, Rect r, {double a = 0.24}) {
    c.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = ui.Gradient.linear(
          r.topLeft,
          r.bottomRight,
          <Color>[_fade(_white, a), _fade(_white, 0.0), _fade(_black, 0.26)],
          const <double>[0.0, 0.44, 1.0],
        ),
    );
  }

  /// Camera lens: metal barrel, optional concentric rings, dark glass, a tight
  /// upper-left specular and a rim light along the lower-right edge.
  void _lens(
    Canvas c,
    Offset o,
    double r, {
    int rings = 1,
    Color glass = const Color(0xFF25313D),
    Color? bezel,
  }) {
    final b = bezel ?? const Color(0xFF56565C);
    c.drawCircle(
      o,
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(o.dx - r, o.dy - r),
          Offset(o.dx + r, o.dy + r),
          <Color>[_lift(b, 0.58), b, _drop(b, 0.7)],
          const <double>[0.0, 0.44, 1.0],
        ),
    );
    c.drawCircle(
      o,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, r * 0.07)
        ..color = _fade(_black, 0.5),
    );
    // rim light on the barrel, opposite the key light
    c.drawArc(
      Rect.fromCircle(center: o, radius: r - r * 0.06),
      -0.16 * math.pi,
      0.82 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, r * 0.1)
        ..color = _fade(_white, 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9),
    );

    var rr = r;
    for (var i = 0; i < rings; i++) {
      rr *= 0.82;
      c.drawCircle(
        o,
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.6, r * 0.07)
          ..color = _fade(_white, 0.13),
      );
    }

    final g = r * (rings > 0 ? 0.62 : 0.76);
    c.drawCircle(
      o,
      g,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(o.dx - g * 0.3, o.dy - g * 0.34),
          g * 1.7,
          <Color>[_lift(glass, 0.22), glass, _black],
          const <double>[0.0, 0.4, 1.0],
        ),
    );
    // rim light along the lower-right of the glass
    c.drawArc(
      Rect.fromCircle(center: o, radius: g - g * 0.09),
      -0.1 * math.pi,
      0.72 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, g * 0.13)
        ..color = _fade(const Color(0xFFAFC9DE), 0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9),
    );
    // tight upper-left specular
    _glint(c, Offset(o.dx - g * 0.36, o.dy - g * 0.4), g * 0.42);
    c.drawCircle(
      Offset(o.dx - g * 0.38, o.dy - g * 0.42),
      math.max(0.5, g * 0.14),
      Paint()..color = _fade(_white, 0.9),
    );
    // faint cool counter-reflection
    c.drawCircle(
      Offset(o.dx + g * 0.34, o.dy + g * 0.38),
      g * 0.15,
      Paint()..color = _fade(const Color(0xFF9FD8FF), 0.26),
    );
  }

  /// Soft white specular blob.
  void _glint(Canvas c, Offset o, double r) {
    c.drawCircle(
      o,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          o,
          r,
          <Color>[_fade(_white, 0.85), _fade(_white, 0.0)],
        ),
    );
  }

  /// A small illuminated window (viewfinder / LCD / screen).
  void _window(Canvas c, RRect box, Color a, Color b) {
    final r = box.outerRect;
    c.drawRRect(
      box,
      Paint()
        ..shader = ui.Gradient.linear(r.topLeft, r.bottomRight, <Color>[a, b]),
    );
    c.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _fade(_black, 0.45),
    );
    // diagonal glass streak
    c.save();
    c.clipRRect(box);
    c.drawLine(
      Offset(r.left + r.width * 0.1, r.bottom),
      Offset(r.left + r.width * 0.55, r.top),
      Paint()
        ..strokeWidth = math.max(1.0, r.height * 0.16)
        ..color = _fade(_white, 0.22),
    );
    c.restore();
  }

  /// Knurled / ribbed grip band across [box].
  void _ribs(Canvas c, RRect box, int n, {bool vertical = true}) {
    final r = box.outerRect;
    c.save();
    c.clipRRect(box);
    for (var i = 0; i < n; i++) {
      final t = (i + 0.5) / n;
      if (vertical) {
        final x = r.left + r.width * t;
        c.drawLine(
          Offset(x, r.top),
          Offset(x, r.bottom),
          Paint()
            ..strokeWidth = math.max(0.6, r.width / n * 0.34)
            ..color = _fade(_black, 0.3),
        );
        c.drawLine(
          Offset(x + 0.8, r.top),
          Offset(x + 0.8, r.bottom),
          Paint()
            ..strokeWidth = 0.5
            ..color = _fade(_white, 0.16),
        );
      } else {
        final y = r.top + r.height * t;
        c.drawLine(
          Offset(r.left, y),
          Offset(r.right, y),
          Paint()
            ..strokeWidth = math.max(0.6, r.height / n * 0.34)
            ..color = _fade(_black, 0.3),
        );
      }
    }
    c.restore();
  }

  /// The signature RfCamera red ball on a stalk above the top-left of the body.
  void _flashDot(Canvas c) {
    c.drawLine(
      const Offset(27, 33),
      const Offset(27, 15),
      Paint()
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF9A9AA0),
    );
    const o = Offset(27, 11);
    c.drawCircle(
      o,
      7,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(24, 8),
          11,
          <Color>[const Color(0xFFFF7B6E), _red, const Color(0xFF7A140D)],
          const <double>[0.0, 0.45, 1.0],
        ),
    );
    _glint(c, const Offset(24.2, 8.2), 2.4);
  }

  void _betaBadge(Canvas c) {
    const o = Offset(15, 85);
    c.drawCircle(o, 11, Paint()..color = _fade(_black, 0.35));
    c.drawCircle(
      o,
      10,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(11, 81),
          16,
          <Color>[const Color(0xFF63D2FF), const Color(0xFF0FA3E0)],
        ),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'β',
        style: TextStyle(
          color: _white,
          fontSize: 15,
          height: 1.0,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    c.save();
    c.translate(o.dx - tp.width / 2, o.dy - tp.height / 2);
    tp.paint(c, Offset.zero);
    c.restore();
  }

  // ------------------------------------------------------------------ bodies

  void _compact(Canvas c) {
    final body = _rr(7, 32, 93, 76, 9);
    _block(c, body, _c0, mat: _Mat.plastic);
    // darker top plate
    c.save();
    c.clipRRect(body);
    c.drawRect(
      const Rect.fromLTRB(7, 32, 93, 42),
      Paint()..color = _fade(_drop(_c1, 0.1), 0.8),
    );
    c.restore();
    // shutter button
    c.drawRRect(_rr(74, 28, 86, 33, 2), Paint()..color = _lift(_c1, 0.25));
    // viewfinder window
    _window(
      c,
      _rr(66, 45, 82, 55, 2),
      const Color(0xFFBFD9E8),
      const Color(0xFF2B3B47),
    );
    // flash
    _window(
      c,
      _rr(66, 59, 84, 68, 2),
      const Color(0xFFFFF7DA),
      const Color(0xFFB9AE8C),
    );
    _lens(c, const Offset(38, 56), 16, rings: 2);
  }

  void _slr(Canvas c) {
    // pentaprism hump
    final hump = Path()
      ..moveTo(34, 40)
      ..lineTo(38, 22)
      ..lineTo(62, 22)
      ..lineTo(66, 40)
      ..close();
    const humpR = Rect.fromLTRB(34, 22, 66, 40);
    c.drawPath(hump, _bodyPaint(humpR, _c1, lift: 0.4));
    _edgeLightPath(c, hump, humpR, a: 0.3);
    // knobs
    for (final k in const <Rect>[
      Rect.fromLTRB(16, 28, 30, 38),
      Rect.fromLTRB(70, 28, 86, 38),
    ]) {
      final box = _rr(k.left, k.top, k.right, k.bottom, 3);
      c.drawRRect(box, _bodyPaint(k, _c1, lift: 0.4));
      _ribs(c, box, 5);
      _edgeLight(c, box, _Mat.metal);
    }
    final body = _rr(9, 36, 91, 80, 8);
    _block(c, body, _c0, mat: _Mat.metal);
    // leatherette covering band
    final band = _rr(9, 48, 91, 72, 2);
    c.save();
    c.clipRRect(body);
    c.drawRRect(band, Paint()..color = _fade(_black, 0.24));
    _stipple(c, band.outerRect);
    c.restore();
    _lens(c, const Offset(50, 58), 20, rings: 2);
  }

  /// 80s-90s autofocus SLR: rounded pentaprism, deep moulded hand grip on the
  /// right, top LCD, fatter zoom lens set low.
  void _slrGrip(Canvas c) {
    // rounded prism hump
    final hump = Path()
      ..moveTo(30, 40)
      ..quadraticBezierTo(32, 20, 46, 19)
      ..lineTo(56, 19)
      ..quadraticBezierTo(66, 21, 68, 40)
      ..close();
    const humpR = Rect.fromLTRB(30, 19, 68, 40);
    c.drawPath(hump, _bodyPaint(humpR, _c1, lift: 0.36));
    _edgeLightPath(c, hump, humpR);
    // hand grip on the right
    final grip = _rr(66, 34, 94, 84, 11);
    _block(c, grip, _lift(_c0, 0.05), mat: _Mat.leather);
    // body
    final body = _rr(8, 38, 80, 78, 7);
    _block(c, body, _c0, mat: _Mat.plastic);
    // top LCD panel
    _window(
      c,
      _rr(56, 41, 76, 50, 1.5),
      const Color(0xFFB9CBAF),
      const Color(0xFF5C6B55),
    );
    for (var i = 0; i < 3; i++) {
      c.drawRect(
        Rect.fromLTRB(59 + i * 5.0, 44, 62 + i * 5.0, 47),
        Paint()..color = _fade(_black, 0.4),
      );
    }
    // zoom lens, wide front ring
    c.drawCircle(
      const Offset(38, 60),
      21,
      Paint()..color = _fade(_drop(_c0, 0.4), 0.95),
    );
    _lens(c, const Offset(38, 60), 18, rings: 2);
  }

  void _rangefinder(Canvas c) {
    final body = _rr(6, 34, 94, 78, 7);
    _block(c, body, _c0, lift: 0.24, mat: _Mat.leather);
    // brighter machined top plate
    c.save();
    c.clipRRect(body);
    const topR = Rect.fromLTRB(6, 34, 94, 44);
    c.drawRect(topR, _bodyPaint(topR, _c1, lift: 0.45));
    c.drawRect(
      const Rect.fromLTRB(6, 34, 94, 36),
      Paint()..color = _fade(_white, 0.28),
    );
    c.drawRect(
      const Rect.fromLTRB(6, 44, 94, 46),
      Paint()..color = _fade(_black, 0.35),
    );
    c.restore();
    // rangefinder window + shutter release
    _window(
      c,
      _rr(70, 36, 82, 42, 1.5),
      const Color(0xFFCFE3EE),
      const Color(0xFF4E6E80),
    );
    c.drawCircle(const Offset(62, 39), 2.6, Paint()..color = _accent);
    _lens(c, const Offset(44, 58), 18, rings: 2);
  }

  void _cineCam(Canvas c) {
    // magazine / handle on top
    const magR = Rect.fromLTRB(24, 20, 52, 32);
    c.drawRRect(_rr(24, 20, 52, 32, 4), _bodyPaint(magR, _c1, lift: 0.3));
    _edgeLight(c, _rr(24, 20, 52, 32, 4), _Mat.metal);
    // lens barrel to the right
    const barrel = Rect.fromLTRB(70, 44, 94, 62);
    c.drawRRect(_rr(70, 44, 94, 62, 3), _tubePaintV(barrel, _lift(_c1, 0.1)));
    c.drawRRect(
      _rr(88, 41, 96, 65, 3),
      _tubePaintV(const Rect.fromLTRB(88, 41, 96, 65), _drop(_c1, 0.3)),
    );
    c.drawCircle(
      const Offset(92, 53),
      6.5,
      Paint()..color = const Color(0xFF10141A),
    );
    _glint(c, const Offset(90, 50.6), 2.0);
    // boxy body facing left
    final body = _rr(12, 28, 74, 76, 8);
    _block(c, body, _c0, mat: _Mat.metal);
    c.save();
    c.clipRRect(body);
    c.drawRect(
      const Rect.fromLTRB(12, 62, 74, 76),
      Paint()..color = _fade(_black, 0.24),
    );
    c.restore();
    // record dot
    c.drawCircle(
      const Offset(34, 56),
      7,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(31, 53),
          11,
          <Color>[const Color(0xFFFF7B6E), _red, const Color(0xFF6E120C)],
          const <double>[0.0, 0.45, 1.0],
        ),
    );
    _glint(c, const Offset(31.4, 53.4), 2.2);
  }

  void _camcorder(Canvas c) {
    // shoulder-mount wedge body
    final wedge = Path()
      ..moveTo(20, 44)
      ..lineTo(78, 34)
      ..lineTo(90, 40)
      ..lineTo(90, 66)
      ..lineTo(20, 72)
      ..close();
    const wedgeR = Rect.fromLTRB(20, 34, 90, 72);
    c.drawPath(wedge, _bodyPaint(wedgeR, _c0, lift: 0.26));
    // top plate
    final top = Path()
      ..moveTo(22, 43)
      ..lineTo(78, 34)
      ..lineTo(88, 39)
      ..lineTo(32, 47)
      ..close();
    c.drawPath(
      top,
      _bodyPaint(const Rect.fromLTRB(22, 34, 88, 47), _c1, lift: 0.5),
    );
    _edgeLightPath(c, wedge, wedgeR, a: 0.3);
    // eyepiece at the back
    const eyeR = Rect.fromLTRB(84, 42, 97, 52);
    c.drawRRect(_rr(84, 42, 97, 52, 3), _bodyPaint(eyeR, _drop(_c0, 0.15)));
    // lens barrel front-left, lifted so it stays legible on black bodies
    final bar = _rr(2, 42, 28, 72, 6);
    c.drawRRect(
      bar,
      _tubePaintV(const Rect.fromLTRB(2, 42, 28, 72), _lift(_c0, 0.26)),
    );
    _edgeLight(c, bar, _Mat.metal);
    _lens(c, const Offset(15, 57), 12, rings: 2);
    // grip strap hint
    c.drawRRect(_rr(44, 56, 74, 62, 3), Paint()..color = _fade(_black, 0.3));
  }

  /// Upright digital handycam with the LCD panel swung out to the left.
  void _flipCam(Canvas c) {
    // flip-out screen with its hinge
    final frame = _rr(4, 20, 42, 54, 3);
    _block(c, frame, _lift(_drop(_c0, 0.05), 0.18), lift: 0.4);
    _window(
      c,
      _rr(7, 23, 39, 51, 2),
      const Color(0xFFC8EBFF),
      const Color(0xFF2A5C80),
    );
    c.drawRRect(_rr(41, 22, 46, 52, 2), Paint()..color = _fade(_black, 0.5));

    // upright body
    final body = _rr(44, 24, 92, 82, 9);
    _block(c, body, _c0, mat: _Mat.plastic);
    // eyepiece nub top-right
    const eyeR = Rect.fromLTRB(78, 16, 96, 26);
    c.drawRRect(_rr(78, 16, 96, 26, 4), _bodyPaint(eyeR, _drop(_c0, 0.2)));
    // record button
    c.drawCircle(const Offset(84, 38), 4.4, Paint()..color = _accent);
    _glint(c, const Offset(82.7, 36.7), 1.6);
    // control ribs
    _ribs(c, _rr(62, 70, 88, 78, 3), 6);
    // lens barrel low on the front, clearly proud of the body
    c.drawRRect(
      _rr(30, 46, 60, 80, 8),
      _tubePaint(const Rect.fromLTRB(30, 46, 60, 80), _lift(_c0, 0.08)),
    );
    _lens(c, const Offset(45, 63), 14, rings: 2);
  }

  void _cassette(Canvas c) {
    final body = _rr(6, 26, 94, 76, 4);
    _block(c, body, _c0, lift: 0.22, mat: _Mat.plastic);
    // coloured label strip along the top
    const labelR = Rect.fromLTRB(10, 30, 90, 45);
    c.drawRRect(_rr(10, 30, 90, 45, 2), _bodyPaint(labelR, _c1, lift: 0.35));
    c.drawRRect(_rr(14, 34, 62, 37, 1), Paint()..color = _fade(_white, 0.55));
    c.drawRRect(_rr(14, 39, 44, 42, 1), Paint()..color = _fade(_white, 0.32));
    // two reel windows
    for (final x in const <double>[33, 67]) {
      final o = Offset(x, 59);
      c.drawCircle(o, 12, Paint()..color = _fade(_white, 0.3));
      c.drawCircle(o, 11, Paint()..color = _fade(_black, 0.7));
      c.drawCircle(
        o,
        10,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(o.dx - 3, o.dy - 3.5),
            14,
            <Color>[const Color(0xFF5A5A60), const Color(0xFF17171A)],
          ),
      );
      c.drawCircle(o, 4, Paint()..color = _fade(_white, 0.2));
      _glint(c, Offset(o.dx - 3.6, o.dy - 4), 3.0);
    }
    // bottom lip
    c.drawRRect(_rr(6, 70, 94, 76, 3), Paint()..color = _fade(_black, 0.35));
    _edgeLight(c, body, _Mat.plastic);
  }

  void _canister(Canvas c) {
    // film leader tongue sticking out to the left
    final tongue = Path()
      ..moveTo(38, 44)
      ..lineTo(10, 48)
      ..lineTo(10, 62)
      ..lineTo(38, 64)
      ..close();
    c.drawPath(
      tongue,
      _bodyPaint(const Rect.fromLTRB(10, 44, 38, 64), _drop(_c1, 0.15)),
    );
    c.drawPath(
      tongue,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _fade(_black, 0.4),
    );
    // spindle above the cap
    c.drawRRect(
      _rr(48, 8, 60, 20, 2),
      _tubePaint(const Rect.fromLTRB(48, 8, 60, 20), _drop(_c1, 0.25)),
    );
    // cylinder
    const tube = Rect.fromLTRB(34, 20, 78, 84);
    c.drawRRect(_rr(34, 20, 78, 84, 8), _tubePaint(tube, _c0));
    // rounded top cap
    c.drawRRect(
      _rr(32, 18, 80, 30, 6),
      _tubePaint(const Rect.fromLTRB(32, 18, 80, 30), _lift(_c1, 0.2)),
    );
    // label band
    c.drawRect(
      const Rect.fromLTRB(34, 36, 78, 66),
      _tubePaint(const Rect.fromLTRB(34, 36, 78, 66), _lift(_c0, 0.28)),
    );
    c.drawRRect(
      _rr(40, 42, 72, 48, 1),
      Paint()..color = _fade(_drop(_c1, 0.3), 0.9),
    );
    c.drawRRect(
      _rr(40, 53, 62, 57, 1),
      Paint()..color = _fade(_drop(_c1, 0.2), 0.7),
    );
    // bottom shade
    c.drawRRect(_rr(34, 74, 78, 84, 8), Paint()..color = _fade(_black, 0.28));
  }

  void _projector(Canvas c) {
    // low horizontal base
    c.drawRRect(
      _rr(8, 62, 92, 80, 4),
      _bodyPaint(const Rect.fromLTRB(8, 62, 92, 80), _drop(_c1, 0.15)),
    );
    // slide tray on top
    c.drawRRect(
      _rr(38, 24, 80, 38, 2),
      _bodyPaint(const Rect.fromLTRB(38, 24, 80, 38), _lift(_c1, 0.25)),
    );
    for (var i = 0; i < 5; i++) {
      final x = 41.0 + i * 8;
      c.drawRect(
        Rect.fromLTRB(x, 26, x + 5, 36),
        Paint()..color = _fade(_white, 0.55 - i * 0.07),
      );
    }
    // body
    final body = _rr(14, 36, 88, 66, 6);
    _block(c, body, _c0, lift: 0.4, mat: _Mat.metal);
    // red button
    c.drawCircle(const Offset(80, 44), 5, Paint()..color = _accent);
    _glint(c, const Offset(78.4, 42.4), 1.6);
    // big lens barrel on the left
    c.drawRRect(
      _rr(4, 42, 30, 62, 5),
      _tubePaintV(const Rect.fromLTRB(4, 42, 30, 62), _drop(_c1, 0.1)),
    );
    _lens(c, const Offset(30, 52), 15, rings: 2);
  }

  void _bottle(Canvas c) {
    // metallic cap
    c.drawRRect(
      _rr(56, 14, 84, 40, 4),
      _tubePaint(const Rect.fromLTRB(56, 14, 84, 40), const Color(0xFFBFC3C9)),
    );
    c.drawRRect(_rr(58, 22, 82, 25, 1), Paint()..color = _fade(_white, 0.6));
    // translucent flask
    final body = _rr(20, 30, 78, 86, 16);
    c.drawRRect(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(20, 30),
          const Offset(78, 86),
          <Color>[_lift(_c0, 0.42), _c0, _drop(_c0, 0.42)],
          const <double>[0.0, 0.5, 1.0],
        ),
    );
    // bright inner glow
    c.drawCircle(
      const Offset(42, 52),
      26,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(42, 52),
          26,
          <Color>[_fade(_lift(_c0, 0.75), 0.7), _fade(_c0, 0.0)],
        ),
    );
    // glass edge highlight
    c.drawRRect(
      _rr(24, 36, 34, 76, 5),
      Paint()..color = _fade(_white, 0.26),
    );
    _edgeLight(c, body, _Mat.metal);
    // small label
    c.drawRRect(_rr(28, 68, 56, 78, 2), Paint()..color = _fade(_c1, 0.85));
  }

  void _toyGun(Canvas c) {
    // angled grip below-left
    final grip = Path()
      ..moveTo(20, 52)
      ..lineTo(48, 52)
      ..lineTo(40, 88)
      ..lineTo(14, 84)
      ..close();
    const gripR = Rect.fromLTRB(14, 52, 48, 88);
    c.drawPath(grip, _bodyPaint(gripR, _c1, lift: 0.28));
    _edgeLightPath(c, grip, gripR);
    // barrel to the right
    c.drawRRect(
      _rr(66, 34, 92, 52, 4),
      _tubePaintV(const Rect.fromLTRB(66, 34, 92, 52), const Color(0xFF3A3A3E)),
    );
    // upper body
    final body = _rr(14, 24, 72, 60, 10);
    _block(c, body, _c0, lift: 0.34, mat: _Mat.plastic);
    // chip + red button on top
    c.drawRRect(_rr(20, 27, 40, 34, 2), Paint()..color = _fade(_accent, 0.9));
    c.drawCircle(const Offset(54, 33), 5, Paint()..color = _accent);
    _glint(c, const Offset(52.4, 31.4), 1.6);
    _lens(c, const Offset(46, 56), 14, rings: 2);
  }

  /// Plastic toy camera: small squat body dominated by an oversized round
  /// flash reflector bolted to the top-left.
  void _toyCam(Canvas c) {
    // oversized flash reflector
    const fo = Offset(33, 30);
    c.drawCircle(fo, 19, Paint()..color = _fade(_black, 0.35));
    c.drawCircle(
      fo,
      18,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(15, 12),
          const Offset(51, 48),
          <Color>[_lift(_c1, 0.55), _c1, _drop(_c1, 0.5)],
          const <double>[0.0, 0.45, 1.0],
        ),
    );
    c.drawCircle(
      fo,
      13.5,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(27, 24),
          20,
          <Color>[_white, const Color(0xFFFFF3C8), const Color(0xFF8E8460)],
          const <double>[0.0, 0.42, 1.0],
        ),
    );
    // fresnel rings
    for (var i = 1; i <= 3; i++) {
      c.drawCircle(
        fo,
        13.5 * i / 3.6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = _fade(_white, 0.5),
      );
    }
    _glint(c, const Offset(26.5, 23.5), 4.2);

    // squat plastic body
    final body = _rr(20, 42, 84, 84, 8);
    _block(c, body, _c0, lift: 0.3, mat: _Mat.plastic);
    // winder wheel on the right shoulder
    c.drawCircle(const Offset(76, 47), 6, Paint()..color = _drop(_c1, 0.2));
    _ribs(c, _rr(70, 41, 82, 53, 6), 5);
    // small viewfinder
    _window(
      c,
      _rr(26, 48, 38, 56, 1.5),
      const Color(0xFFCBE2F0),
      const Color(0xFF3A4C58),
    );
    _lens(c, const Offset(58, 66), 13, rings: 1, bezel: _drop(_c1, 0.1));
  }

  void _kino(Canvas c) {
    // two small stubs on top
    for (final x in const <double>[28, 60]) {
      c.drawRRect(
        _rr(x, 16, x + 12, 30, 3),
        _bodyPaint(Rect.fromLTRB(x, 16, x + 12, 30), _lift(_c0, 0.1)),
      );
    }
    // white boxy body
    final body = _rr(14, 26, 86, 82, 11);
    _block(c, body, _c0, lift: 0.36, mat: _Mat.plastic);
    // one very large dark circular lens
    _lens(
      c,
      const Offset(50, 56),
      24,
      rings: 1,
      glass: const Color(0xFF1A1A1E),
    );
    // white sweep handle across the lower-left of the lens
    final sweep = Path()
      ..moveTo(30, 52)
      ..quadraticBezierTo(20, 74, 34, 84)
      ..lineTo(44, 78)
      ..quadraticBezierTo(32, 70, 40, 56)
      ..close();
    const sweepR = Rect.fromLTRB(20, 52, 44, 84);
    c.drawPath(sweep, _bodyPaint(sweepR, _c0, lift: 0.3));
    _edgeLightPath(c, sweep, sweepR);
  }

  void _instant(Canvas c) {
    // tall rounded body
    final body = _rr(16, 16, 84, 86, 13);
    _block(c, body, _c0, mat: _Mat.plastic);
    // dark face plate
    const faceR = Rect.fromLTRB(22, 24, 78, 66);
    c.drawRRect(_rr(22, 24, 78, 66, 9), _bodyPaint(faceR, _drop(_c1, 0.05)));
    // flash + viewfinder
    _window(
      c,
      _rr(26, 28, 38, 36, 2),
      const Color(0xFFFFF9E2),
      const Color(0xFFB9AF8E),
    );
    c.drawCircle(const Offset(70, 32), 4, Paint()..color = _fade(_white, 0.5));
    // large lens circle
    _lens(c, const Offset(50, 50), 16, rings: 2);
    // white print slot slit at the bottom
    c.drawRRect(_rr(26, 72, 74, 79, 3), Paint()..color = _fade(_black, 0.5));
    c.drawRRect(
      _rr(27, 73, 73, 78, 2.5),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(27, 73),
          const Offset(27, 78),
          <Color>[_white, const Color(0xFFC9C9CE)],
        ),
    );
  }

  /// Wide-format instant: low landscape body, a flash bar across the whole
  /// top and a fresh print sliding out of the left edge.
  void _instantWide(Canvas c) {
    // print easing out of the slot on the left
    final print = _rr(0, 52, 24, 76, 2);
    c.drawRRect(
      print,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 52),
          const Offset(24, 76),
          <Color>[_white, const Color(0xFFCDCDD3)],
        ),
    );
    c.drawRect(
      const Rect.fromLTRB(2, 54, 22, 68),
      Paint()..color = const Color(0xFF3B4A57),
    );
    c.drawRRect(
      print,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = _fade(_black, 0.35),
    );

    final body = _rr(14, 28, 96, 78, 9);
    _block(c, body, _c0, mat: _Mat.plastic);
    // flash bar across the top
    _window(
      c,
      _rr(18, 32, 92, 43, 3),
      const Color(0xFFFFFAE8),
      const Color(0xFFA79C7C),
    );
    for (var i = 1; i < 6; i++) {
      c.drawLine(
        Offset(18 + i * 12.3, 32),
        Offset(18 + i * 12.3, 43),
        Paint()
          ..strokeWidth = 0.8
          ..color = _fade(_black, 0.25),
      );
    }
    // print slot lip
    c.drawRRect(_rr(14, 58, 22, 72, 2), Paint()..color = _fade(_black, 0.55));
    // shutter + viewfinder
    c.drawCircle(const Offset(86, 52), 4.5, Paint()..color = _accent);
    _glint(c, const Offset(84.7, 50.7), 1.6);
    _window(
      c,
      _rr(78, 60, 92, 69, 1.5),
      const Color(0xFFCBE2F0),
      const Color(0xFF3A4C58),
    );
    _lens(c, const Offset(50, 59), 15, rings: 2);
  }

  void _filmStrip(Canvas c) {
    final body = _rr(12, 14, 88, 88, 3);
    c.drawRRect(
      body,
      _bodyPaint(
        const Rect.fromLTRB(12, 14, 88, 88),
        _drop(_c0, 0.35),
        lift: 0.18,
      ),
    );
    // one image frame in the middle
    const frame = Rect.fromLTRB(29, 28, 71, 74);
    c.drawRect(
      frame,
      Paint()
        ..shader = ui.Gradient.linear(
          frame.topLeft,
          frame.bottomRight,
          <Color>[_lift(_c1, 0.5), _c1, _drop(_c1, 0.45)],
          const <double>[0.0, 0.5, 1.0],
        ),
    );
    // a horizon line so it reads as a photo
    c.drawRect(
      const Rect.fromLTRB(29, 58, 71, 74),
      Paint()..color = _fade(_drop(_c1, 0.55), 0.85),
    );
    c.drawCircle(const Offset(60, 40), 5, Paint()..color = _fade(_white, 0.5));
    c.drawRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _fade(_black, 0.5),
    );
    // sprocket holes down both long edges
    for (var i = 0; i < 6; i++) {
      final y = 20.0 + i * 12;
      for (final x in const <double>[16, 76]) {
        c.drawRRect(
          _rr(x, y, x + 8, y + 7, 1.6),
          Paint()..color = _fade(_white, 0.88),
        );
      }
    }
  }

  void _triLens(Canvas c) {
    // top strip / controls
    c.drawRRect(
      _rr(20, 24, 80, 36, 3),
      _bodyPaint(const Rect.fromLTRB(20, 24, 80, 36), _drop(_c1, 0.1)),
    );
    c.drawRRect(_rr(24, 27, 40, 33, 1.5), Paint()..color = _fade(_white, 0.7));
    for (var i = 0; i < 3; i++) {
      c.drawCircle(
        Offset(56 + i * 7.0, 30),
        2,
        Paint()..color = _fade(const Color(0xFF63D2FF), 0.9),
      );
    }
    // wide body
    final body = _rr(6, 32, 94, 74, 8);
    _block(c, body, _c0, mat: _Mat.plastic);
    // three lenses in a row
    for (var i = 0; i < 3; i++) {
      _lens(c, Offset(24 + i * 26.0, 53), 12, rings: 1);
    }
  }

  void _disposable(Canvas c) {
    // winder wheel on the right edge
    const wheel = Offset(84, 42);
    c.drawCircle(
      wheel,
      10,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(80, 38),
          15,
          <Color>[const Color(0xFF6E6E73), const Color(0xFF1F1F22)],
        ),
    );
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5;
      c.drawLine(
        wheel + Offset(math.cos(a) * 6.5, math.sin(a) * 6.5),
        wheel + Offset(math.cos(a) * 9.5, math.sin(a) * 9.5),
        Paint()
          ..strokeWidth = 1.1
          ..color = _fade(_black, 0.55),
      );
    }
    // boxy cardboard-wrapped body
    final body = _rr(10, 30, 80, 78, 6);
    _block(c, body, _c0, lift: 0.3, mat: _Mat.leather);
    // flash window
    _window(
      c,
      _rr(54, 36, 74, 52, 3),
      const Color(0xFFFFFBE6),
      const Color(0xFFA79E7E),
    );
    // counter window
    c.drawRRect(_rr(14, 36, 28, 44, 2), Paint()..color = _fade(_c1, 0.85));
    // small lens
    _lens(c, const Offset(36, 58), 13, rings: 1);
  }

  void _halfFrame(Canvas c) {
    final body = _rr(18, 22, 82, 82, 9);
    _block(c, body, _c0, lift: 0.26, mat: _Mat.plastic);
    // two half-frames
    c.drawRect(
      const Rect.fromLTRB(24, 30, 48, 74),
      _bodyPaint(const Rect.fromLTRB(24, 30, 48, 74), _c1, lift: 0.4),
    );
    c.drawRect(
      const Rect.fromLTRB(52, 30, 76, 74),
      _bodyPaint(const Rect.fromLTRB(52, 30, 76, 74), _drop(_c1, 0.2)),
    );
    // split down the middle
    c.drawRect(
      const Rect.fromLTRB(48, 22, 52, 82),
      Paint()..color = _fade(_black, 0.72),
    );
    c.drawLine(
      const Offset(50, 22),
      const Offset(50, 82),
      Paint()
        ..strokeWidth = 0.8
        ..color = _fade(_white, 0.24),
    );
    c.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _fade(_black, 0.4),
    );
  }

  void _sphere(Canvas c) {
    const o = Offset(50, 52);
    const r = 31.0;
    c.drawCircle(
      o,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(38, 38),
          r * 1.55,
          <Color>[_lift(_c0, 0.35), _c0, _drop(_c1, 0.35), _black],
          const <double>[0.0, 0.38, 0.8, 1.0],
        ),
    );
    // soft rim light along the lower-right
    c.drawArc(
      Rect.fromCircle(center: o, radius: r - 1.2),
      -0.55 * math.pi,
      1.15 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = _fade(_white, 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
    );
    // dark bottom
    c.drawCircle(
      o,
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(50, 40),
          const Offset(50, 83),
          <Color>[_fade(_black, 0.0), _fade(_black, 0.55)],
        ),
    );
    // strong top-left specular
    _glint(c, const Offset(38, 36), 8.5);
    c.drawCircle(
      const Offset(37, 35),
      3.0,
      Paint()..color = _fade(_white, 0.95),
    );

    switch (profile.id) {
      case 'prism':
        const dots = <Color>[
          Color(0xFFFF5A5A),
          Color(0xFFFFC15A),
          Color(0xFF63FF9A),
          Color(0xFF63D2FF),
          Color(0xFFB58CFF),
        ];
        for (var i = 0; i < dots.length; i++) {
          final a = -0.9 + i * 0.36;
          final rad = 13.0 + (i.isEven ? 4.0 : 0.0);
          c.drawCircle(
            o + Offset(math.cos(a) * rad, math.sin(a) * rad),
            2.6,
            Paint()
              ..color = _fade(dots[i], 0.85)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
          );
        }
      case 'star':
        _sparkle(c, const Offset(62, 40), 9);
        _sparkle(c, const Offset(44, 60), 7);
        _sparkle(c, const Offset(66, 62), 5.5);
        _sparkle(c, const Offset(52, 32), 4.5);
      default:
        break;
    }
  }

  /// A small white 4-point sparkle.
  void _sparkle(Canvas c, Offset o, double r) {
    final p = Path()
      ..moveTo(o.dx, o.dy - r)
      ..quadraticBezierTo(o.dx + r * 0.16, o.dy - r * 0.16, o.dx + r, o.dy)
      ..quadraticBezierTo(o.dx + r * 0.16, o.dy + r * 0.16, o.dx, o.dy + r)
      ..quadraticBezierTo(o.dx - r * 0.16, o.dy + r * 0.16, o.dx - r, o.dy)
      ..quadraticBezierTo(o.dx - r * 0.16, o.dy - r * 0.16, o.dx, o.dy - r)
      ..close();
    c.drawPath(p, Paint()..color = _fade(_white, 0.92));
    c.drawCircle(
      o,
      r * 0.34,
      Paint()
        ..color = _fade(_white, 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );
  }

  void _frame(Canvas c) {
    final outer = _rr(12, 18, 88, 86, 9);
    _block(c, outer, _c0, lift: 0.3, mat: _Mat.leather);
    // bevel
    c.drawRRect(
      _rr(18, 24, 82, 80, 6),
      Paint()..color = _fade(_black, 0.32),
    );
    // lighter inner window
    c.drawRRect(
      _rr(20, 26, 80, 78, 5),
      _bodyPaint(
        const Rect.fromLTRB(20, 26, 80, 78),
        _lift(_c1, 0.12),
        lift: 0.4,
      ),
    );
    c.drawRRect(
      _rr(20, 26, 80, 78, 5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _fade(_white, 0.25),
    );
    // corner registration notches, so it reads as a mount not a plain box
    for (final p in const <Offset>[
      Offset(16, 22),
      Offset(84, 22),
      Offset(16, 82),
      Offset(84, 82),
    ]) {
      c.drawCircle(p, 2.2, Paint()..color = _fade(_black, 0.42));
    }
    c.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _fade(_black, 0.35),
    );
  }

  // -------------------------------------------------------------- new bodies

  /// Slim credit-card compact: a thin slab with a visible top face, a sliding
  /// lens cover seam and a small lens tucked to the left.
  void _cardCompact(Canvas c) {
    // thin top face, so the slab reads as shallow
    final topFace = Path()
      ..moveTo(12, 36)
      ..lineTo(90, 36)
      ..lineTo(94, 41)
      ..lineTo(8, 41)
      ..close();
    const topR = Rect.fromLTRB(8, 36, 94, 41);
    c.drawPath(topFace, _bodyPaint(topR, _lift(_c1, 0.3), lift: 0.4));
    _edgeLightPath(c, topFace, topR, a: 0.4);

    final body = _rr(8, 40, 94, 72, 5);
    _block(c, body, _c0, lift: 0.28, mat: _Mat.metal);

    // sliding cover seam across the whole face
    c.drawLine(
      const Offset(8, 62),
      const Offset(94, 62),
      Paint()
        ..strokeWidth = 1.0
        ..color = _fade(_black, 0.4),
    );
    c.drawLine(
      const Offset(8, 63),
      const Offset(94, 63),
      Paint()
        ..strokeWidth = 0.6
        ..color = _fade(_white, 0.2),
    );
    // shutter button on the top face
    c.drawRRect(_rr(78, 32, 88, 37, 2), Paint()..color = _lift(_c1, 0.4));
    // flash + finder to the right
    _window(
      c,
      _rr(74, 44, 88, 52, 1.5),
      const Color(0xFFFFF7DA),
      const Color(0xFFB9AE8C),
    );
    // fine control ribs bottom-right
    _ribs(c, _rr(70, 65, 90, 70, 2), 5);
    _lens(
      c,
      const Offset(32, 55),
      12,
      rings: 2,
      bezel: const Color(0xFF8C8C93),
    );
  }

  /// Wide-body point-and-shoot dominated by a long, multi-stage zoom barrel.
  void _zoomCompact(Canvas c) {
    final body = _rr(6, 34, 94, 76, 7);
    _block(c, body, _c0, lift: 0.3, mat: _Mat.metal);
    // top plate
    c.save();
    c.clipRRect(body);
    c.drawRect(
      const Rect.fromLTRB(6, 34, 94, 43),
      Paint()..color = _fade(_drop(_c1, 0.05), 0.75),
    );
    c.restore();
    // mode dial + shutter on the shoulder
    c.drawCircle(const Offset(80, 32), 7, Paint()..color = _lift(_c1, 0.25));
    _ribs(c, _rr(73, 25, 87, 39, 7), 7);
    c.drawCircle(const Offset(80, 32), 3, Paint()..color = _fade(_black, 0.35));
    // finder + flash on the right of the face
    _window(
      c,
      _rr(74, 46, 90, 55, 1.5),
      const Color(0xFFCBE2F0),
      const Color(0xFF3A4C58),
    );
    _window(
      c,
      _rr(74, 59, 90, 68, 1.5),
      const Color(0xFFFFF7DA),
      const Color(0xFFB9AE8C),
    );

    // extended zoom barrel: three telescoping stages
    const bc = Offset(40, 57);
    c.drawCircle(bc, 25, Paint()..color = _fade(_black, 0.3));
    c.drawCircle(
      bc,
      24,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(16, 33),
          const Offset(64, 81),
          <Color>[_lift(_c1, 0.5), _c1, _drop(_c1, 0.55)],
          const <double>[0.0, 0.45, 1.0],
        ),
    );
    c.drawCircle(
      bc,
      19.5,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(20, 37),
          const Offset(60, 77),
          <Color>[_lift(_c1, 0.34), _drop(_c1, 0.12), _drop(_c1, 0.62)],
          const <double>[0.0, 0.45, 1.0],
        ),
    );
    _lens(c, bc, 15, rings: 2);
  }

  /// Boxy 90s bridge camera: big EVF hump, deep right-hand grip, top LCD and
  /// a fat fixed superzoom.
  void _bridge(Canvas c) {
    // EVF hump with eyecup
    const humpR = Rect.fromLTRB(26, 16, 62, 36);
    c.drawRRect(_rr(26, 16, 62, 36, 4), _bodyPaint(humpR, _c1, lift: 0.38));
    _edgeLight(c, _rr(26, 16, 62, 36, 4), _Mat.plastic);
    c.drawRRect(
      _rr(28, 19, 42, 31, 3),
      Paint()..color = _fade(_black, 0.6),
    );
    // top LCD panel
    _window(
      c,
      _rr(64, 22, 92, 36, 2),
      const Color(0xFFC3D2B4),
      const Color(0xFF667058),
    );
    for (var i = 0; i < 4; i++) {
      c.drawRect(
        Rect.fromLTRB(67 + i * 6.0, 26, 71 + i * 6.0, 32),
        Paint()..color = _fade(_black, 0.35),
      );
    }
    // deep grip on the right
    final grip = _rr(70, 34, 94, 86, 10);
    _block(c, grip, _lift(_c0, 0.04), lift: 0.3, mat: _Mat.leather);
    // body
    final body = _rr(8, 34, 80, 80, 5);
    _block(c, body, _c0, lift: 0.28, mat: _Mat.plastic);
    // fat superzoom with a squared hood
    c.drawRRect(
      _rr(16, 40, 64, 78, 6),
      _bodyPaint(const Rect.fromLTRB(16, 40, 64, 78), _drop(_c1, 0.25)),
    );
    _lens(c, const Offset(40, 59), 17, rings: 2);
  }

  /// Chunky waterproof body: thick rounded shell, ribbed grip lump, sealed
  /// bumper ring around a recessed lens and visible corner screws.
  void _waterproof(Canvas c) {
    // ribbed grip lump on the right
    final grip = _rr(70, 34, 94, 80, 12);
    _block(c, grip, _drop(_c0, 0.18), lift: 0.3, mat: _Mat.plastic);
    _ribs(c, _rr(74, 40, 92, 74, 8), 5);

    final body = _rr(8, 30, 80, 84, 15);
    _block(c, body, _c0, lift: 0.3, mat: _Mat.plastic);
    // sealed seam around the shell
    c.drawRRect(
      _rr(12, 34, 76, 80, 12),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = _fade(_black, 0.32),
    );
    // corner screws
    for (final p in const <Offset>[
      Offset(17, 39),
      Offset(71, 39),
      Offset(17, 75),
      Offset(71, 75),
    ]) {
      c.drawCircle(p, 2.4, Paint()..color = _fade(_black, 0.4));
      c.drawCircle(p, 1.6, Paint()..color = _fade(_white, 0.3));
    }
    // flash + finder along the top
    _window(
      c,
      _rr(48, 38, 68, 47, 2),
      const Color(0xFFFFF7DA),
      const Color(0xFFB9AE8C),
    );
    // bumper ring + recessed lens
    c.drawCircle(const Offset(40, 60), 21, Paint()..color = _drop(_c1, 0.1));
    c.drawCircle(
      const Offset(40, 60),
      21,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _fade(_white, 0.22),
    );
    _lens(
      c,
      const Offset(40, 60),
      15,
      rings: 1,
      bezel: const Color(0xFF3E4249),
    );
  }

  /// Twin-lens reflex: tall narrow box, open waist-level hood on top, two
  /// stacked lenses and a focus knob on the side.
  void _tlr(Canvas c) {
    // open waist-level hood
    final hood = Path()
      ..moveTo(28, 30)
      ..lineTo(31, 8)
      ..lineTo(69, 8)
      ..lineTo(72, 30)
      ..close();
    const hoodR = Rect.fromLTRB(28, 8, 72, 30);
    c.drawPath(hood, _bodyPaint(hoodR, _lift(_c1, 0.1), lift: 0.4));
    // dark interior of the hood
    final inner = Path()
      ..moveTo(33, 26)
      ..lineTo(35, 12)
      ..lineTo(65, 12)
      ..lineTo(67, 26)
      ..close();
    c.drawPath(inner, Paint()..color = _fade(_black, 0.62));
    c.drawRRect(
      _rr(36, 14, 64, 24, 1),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(36, 14),
          const Offset(64, 24),
          <Color>[_fade(_white, 0.5), _fade(_white, 0.08)],
        ),
    );
    _edgeLightPath(c, hood, hoodR, a: 0.32);

    // focus knob on the right flank
    c.drawCircle(const Offset(82, 58), 9, Paint()..color = _drop(_c1, 0.15));
    _ribs(c, _rr(73, 49, 91, 67, 9), 7);
    c.drawCircle(const Offset(82, 58), 3, Paint()..color = _fade(_white, 0.22));

    // tall body
    final body = _rr(24, 28, 76, 88, 5);
    _block(c, body, _c0, lift: 0.28, mat: _Mat.leather);
    // front panel joining both lenses
    c.drawRRect(
      _rr(28, 34, 72, 82, 4),
      Paint()..color = _fade(_drop(_c1, 0.1), 0.85),
    );
    // stacked lenses: viewing on top, taking below
    _lens(c, const Offset(50, 46), 13, rings: 1);
    _lens(c, const Offset(50, 70), 13, rings: 2);
  }

  /// Folding bellows camera: leatherette body lying flat, a dark square
  /// bellows rising out of it to a chrome front standard carrying the lens.
  void _folder(Canvas c) {
    // struts either side of the bellows
    for (final pair in const <List<double>>[
      [16, 64, 28, 22],
      [84, 64, 72, 22],
    ]) {
      c.drawLine(
        Offset(pair[0], pair[1]),
        Offset(pair[2], pair[3]),
        Paint()
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFA8ACB4),
      );
    }

    // dark bellows, wider at the base
    final bel = Path()
      ..moveTo(28, 66)
      ..lineTo(36, 34)
      ..lineTo(64, 34)
      ..lineTo(72, 66)
      ..close();
    const belR = Rect.fromLTRB(28, 34, 72, 66);
    c.drawPath(bel, _bodyPaint(belR, _drop(_c1, 0.05), lift: 0.3));
    for (var i = 1; i < 7; i++) {
      final t = i / 7.0;
      final y = 34 + 32 * t;
      final x0 = 36 - 8 * t;
      final x1 = 64 + 8 * t;
      c.drawLine(
        Offset(x0, y),
        Offset(x1, y),
        Paint()
          ..strokeWidth = 1.5
          ..color = _fade(_black, 0.5),
      );
      c.drawLine(
        Offset(x0, y - 1.3),
        Offset(x1, y - 1.3),
        Paint()
          ..strokeWidth = 0.8
          ..color = _fade(_white, 0.2),
      );
    }
    _edgeLightPath(c, bel, belR, a: 0.2);

    // chrome front standard with the shutter and lens
    final std = _rr(26, 12, 74, 36, 3);
    _block(c, std, const Color(0xFFAEB2B9), lift: 0.42, mat: _Mat.metal);
    _lens(c, const Offset(50, 24), 11, rings: 2);

    // leatherette body lying flat
    final body = _rr(8, 62, 92, 90, 5);
    _block(c, body, _c0, lift: 0.26, mat: _Mat.leather);
    // chrome trim along the top of the body
    c.drawRRect(
      _rr(8, 62, 92, 69, 3),
      _bodyPaint(
        const Rect.fromLTRB(8, 62, 92, 69),
        const Color(0xFFB4B7BD),
        lift: 0.45,
      ),
    );
    // fold-out finder + winder knob on the body
    _window(
      c,
      _rr(14, 71, 30, 80, 1.5),
      const Color(0xFFCBE2F0),
      const Color(0xFF3A4C58),
    );
    c.drawCircle(const Offset(80, 58), 7, Paint()..color = _drop(_c1, 0.1));
    _ribs(c, _rr(73, 51, 87, 65, 7), 7);
    c.drawCircle(
      const Offset(80, 58),
      2.4,
      Paint()..color = _fade(_white, 0.2),
    );
  }

  /// Vintage box camera: tall upright leatherette box with a brilliant finder
  /// on the top plate, a small centred lens and a winding key on the flank.
  void _boxCam(Canvas c) {
    // winding key on the right flank
    c.drawRRect(
      _rr(78, 46, 92, 52, 3),
      _tubePaint(const Rect.fromLTRB(78, 46, 92, 52), const Color(0xFF9DA1A8)),
    );
    c.drawCircle(const Offset(90, 49), 5, Paint()..color = _drop(_c1, 0.15));

    // upright box
    final body = _rr(22, 18, 78, 90, 4);
    _block(c, body, _c0, lift: 0.26, mat: _Mat.leather);
    // top plate with the brilliant finder
    c.drawRRect(
      _rr(22, 18, 78, 30, 3),
      _bodyPaint(
        const Rect.fromLTRB(22, 18, 78, 30),
        _lift(_c1, 0.1),
        lift: 0.42,
      ),
    );
    _window(
      c,
      _rr(28, 20, 46, 28, 1.5),
      const Color(0xFFDDEEF7),
      const Color(0xFF44606F),
    );
    // shutter lever
    c.drawRRect(_rr(56, 22, 72, 26, 2), Paint()..color = _fade(_black, 0.45));
    // front panel
    c.drawRRect(
      _rr(27, 36, 73, 84, 3),
      _bodyPaint(
        const Rect.fromLTRB(27, 36, 73, 84),
        _lift(_c1, 0.05),
        lift: 0.36,
      ),
    );
    c.drawRRect(
      _rr(27, 36, 73, 84, 3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = _fade(_black, 0.4),
    );
    _lens(c, const Offset(50, 60), 13, rings: 2);
  }

  /// Panoramic body: very wide, very short, twin end windows and a wide strip
  /// of exposed film across the face.
  void _panorama(Canvas c) {
    // side hand grips
    for (final r in const <Rect>[
      Rect.fromLTRB(0, 42, 14, 70),
      Rect.fromLTRB(86, 42, 100, 70),
    ]) {
      final box = _rr(r.left, r.top, r.right, r.bottom, 4);
      c.drawRRect(box, _bodyPaint(r, _drop(_c0, 0.3)));
    }
    final body = _rr(4, 40, 96, 68, 5);
    _block(c, body, _c0, lift: 0.3, mat: _Mat.metal);
    // wide dark viewfinder band across the top
    c.drawRRect(_rr(9, 43, 91, 50, 2), Paint()..color = _fade(_black, 0.45));
    _window(
      c,
      _rr(11, 44, 33, 49, 1),
      const Color(0xFFCBE2F0),
      const Color(0xFF3A4C58),
    );
    _window(
      c,
      _rr(67, 44, 89, 49, 1),
      const Color(0xFFCBE2F0),
      const Color(0xFF3A4C58),
    );
    // shutter buttons at both ends
    c.drawRRect(_rr(12, 35, 24, 40, 2), Paint()..color = _lift(_c1, 0.35));
    c.drawRRect(_rr(76, 35, 88, 40, 2), Paint()..color = _lift(_c1, 0.35));
    // wide short lens
    c.drawRRect(
      _rr(36, 52, 64, 74, 4),
      _bodyPaint(const Rect.fromLTRB(36, 52, 64, 74), _drop(_c1, 0.2)),
    );
    _lens(c, const Offset(50, 62), 11, rings: 1);
  }

  /// Rugged action cube drawn in light isometric: front face, top face and a
  /// sliver of the right flank, with a big accent-ringed lens.
  void _actionCube(Canvas c) {
    // top face
    final top = Path()
      ..moveTo(22, 38)
      ..lineTo(32, 26)
      ..lineTo(86, 26)
      ..lineTo(78, 38)
      ..close();
    c.drawPath(
      top,
      _bodyPaint(
        const Rect.fromLTRB(22, 26, 86, 38),
        _lift(_c0, 0.2),
        lift: 0.4,
      ),
    );
    // right flank
    final side = Path()
      ..moveTo(78, 38)
      ..lineTo(86, 26)
      ..lineTo(86, 74)
      ..lineTo(78, 84)
      ..close();
    c.drawPath(
      side,
      _bodyPaint(const Rect.fromLTRB(78, 26, 86, 84), _drop(_c0, 0.35)),
    );
    // front face
    final face = _rr(22, 36, 78, 84, 7);
    _block(c, face, _c0, lift: 0.3, mat: _Mat.plastic);
    // record button on the top face
    c.drawOval(
      const Rect.fromLTRB(60, 28, 74, 35),
      Paint()..color = _fade(_accent, 0.95),
    );
    // corner screws
    for (final p in const <Offset>[
      Offset(27, 41),
      Offset(73, 41),
      Offset(27, 79),
      Offset(73, 79),
    ]) {
      c.drawCircle(p, 2.0, Paint()..color = _fade(_black, 0.45));
    }
    // status lamp
    c.drawCircle(const Offset(66, 74), 3, Paint()..color = _fade(_c1, 0.9));
    // accent bezel + lens
    c.drawCircle(const Offset(46, 60), 18, Paint()..color = _drop(_c1, 0.05));
    c.drawCircle(
      const Offset(46, 60),
      18,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _fade(_white, 0.2),
    );
    _lens(c, const Offset(46, 60), 14, rings: 1);
  }

  /// Polaroid-style folding SLR: flat deck, a raked rear viewfinder housing
  /// and a forward-leaning front standard carrying the lens, joined by a
  /// bellows — the classic wedge silhouette.
  void _foldSlr(Canvas c) {
    // rear viewfinder housing, raked back
    final rear = Path()
      ..moveTo(60, 72)
      ..lineTo(70, 26)
      ..lineTo(94, 34)
      ..lineTo(94, 72)
      ..close();
    const rearR = Rect.fromLTRB(60, 26, 94, 72);
    c.drawPath(rear, _bodyPaint(rearR, _drop(_c0, 0.05), lift: 0.34));
    _edgeLightPath(c, rear, rearR, a: 0.3);
    // eyepiece
    c.drawOval(
      const Rect.fromLTRB(78, 34, 94, 44),
      Paint()..color = _fade(_black, 0.65),
    );
    c.drawOval(
      const Rect.fromLTRB(80, 36, 92, 42),
      Paint()..color = _fade(_white, 0.16),
    );

    // bellows between the two standards
    final bel = Path()
      ..moveTo(36, 72)
      ..lineTo(46, 30)
      ..lineTo(70, 27)
      ..lineTo(60, 72)
      ..close();
    c.drawPath(
      bel,
      _bodyPaint(
        const Rect.fromLTRB(36, 27, 70, 72),
        _drop(_c0, 0.5),
        lift: 0.18,
      ),
    );
    for (var i = 1; i < 6; i++) {
      final t = i / 6.0;
      c.drawLine(
        Offset(46 - 10 * t, 30 + 42 * t),
        Offset(70 - 10 * t, 27 + 45 * t),
        Paint()
          ..strokeWidth = 1.4
          ..color = _fade(_black, 0.45),
      );
    }

    // front standard, leaning forward, carrying the lens
    final std = Path()
      ..moveTo(8, 72)
      ..lineTo(20, 20)
      ..lineTo(48, 24)
      ..lineTo(36, 72)
      ..close();
    const stdR = Rect.fromLTRB(8, 20, 48, 72);
    c.drawPath(std, _bodyPaint(stdR, _c1, lift: 0.42));
    _edgeLightPath(c, std, stdR, a: 0.42);
    _lens(c, const Offset(28, 47), 14, rings: 2);

    // flat deck / base
    final deck = _rr(6, 70, 96, 88, 5);
    _block(c, deck, _c0, lift: 0.28, mat: _Mat.leather);
    // chrome strip along the deck
    c.drawRRect(
      _rr(6, 70, 96, 75, 3),
      _bodyPaint(
        const Rect.fromLTRB(6, 70, 96, 75),
        const Color(0xFFAFB3B9),
        lift: 0.45,
      ),
    );
    // print slot at the front edge
    c.drawRRect(_rr(26, 82, 84, 86, 2), Paint()..color = _fade(_black, 0.55));
  }

  /// Screw-in ND filter: a knurled metal ring seen slightly from above, with
  /// dark glass and a second ring below giving it thickness.
  void _filterDisc(Canvas c) {
    const outer = Rect.fromLTRB(12, 26, 88, 78);
    // lower ring (thickness)
    c.drawOval(
      outer.shift(const Offset(0, 8)),
      Paint()..color = _drop(_c1, 0.45),
    );
    // main ring
    c.drawOval(
      outer,
      Paint()
        ..shader = ui.Gradient.linear(
          outer.topLeft,
          outer.bottomRight,
          <Color>[
            _lift(const Color(0xFFB6B9BF), 0.4),
            const Color(0xFF7E8188),
            const Color(0xFF23262B),
          ],
          const <double>[0.0, 0.42, 1.0],
        ),
    );
    // knurl ticks around the rim
    for (var i = 0; i < 34; i++) {
      final a = i * math.pi * 2 / 34;
      final cx = 50 + math.cos(a) * 36;
      final cy = 52 + math.sin(a) * 24;
      final cx2 = 50 + math.cos(a) * 32;
      final cy2 = 52 + math.sin(a) * 21;
      c.drawLine(
        Offset(cx, cy),
        Offset(cx2, cy2),
        Paint()
          ..strokeWidth = 0.9
          ..color = _fade(_black, 0.3),
      );
    }
    // glass
    const glass = Rect.fromLTRB(23, 34, 77, 70);
    c.drawOval(
      glass,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(38, 42),
          46,
          <Color>[_lift(_c0, 0.3), _c0, _black],
          const <double>[0.0, 0.42, 1.0],
        ),
    );
    c.drawOval(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = _fade(_black, 0.5),
    );
    // rim light along the lower-right of the glass
    c.drawArc(
      glass.deflate(1.6),
      -0.12 * math.pi,
      0.7 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _fade(_white, 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    _glint(c, const Offset(38, 43), 7);
    c.drawCircle(
      const Offset(37, 42),
      2.4,
      Paint()..color = _fade(_white, 0.9),
    );
  }

  /// Hot-shoe flash gun: big fresnel head over a slim foot.
  void _flashUnit(Canvas c) {
    // foot / mount
    final foot = _rr(38, 56, 62, 88, 3);
    _block(c, foot, _drop(_c0, 0.25), lift: 0.3, mat: _Mat.plastic);
    c.drawRRect(_rr(34, 82, 66, 90, 2), Paint()..color = _fade(_black, 0.5));
    // ready lamp
    c.drawCircle(const Offset(50, 66), 3.4, Paint()..color = _fade(_red, 0.95));
    _glint(c, const Offset(48.9, 64.9), 1.4);

    // head
    final head = _rr(18, 12, 82, 58, 5);
    _block(c, head, _c0, lift: 0.32, mat: _Mat.plastic);
    // fresnel panel
    const pane = Rect.fromLTRB(23, 17, 77, 50);
    c.drawRRect(
      _rr(23, 17, 77, 50, 3),
      Paint()
        ..shader = ui.Gradient.linear(
          pane.topLeft,
          pane.bottomRight,
          <Color>[_white, const Color(0xFFFFF3C8), const Color(0xFF8A8264)],
          const <double>[0.0, 0.4, 1.0],
        ),
    );
    for (var i = 1; i < 6; i++) {
      final y = 17 + 33 * i / 6.0;
      c.drawLine(
        Offset(23, y),
        Offset(77, y),
        Paint()
          ..strokeWidth = 0.9
          ..color = _fade(_black, 0.2),
      );
    }
    for (var i = 1; i < 5; i++) {
      final x = 23 + 54 * i / 5.0;
      c.drawLine(
        Offset(x, 17),
        Offset(x, 50),
        Paint()
          ..strokeWidth = 0.9
          ..color = _fade(_black, 0.2),
      );
    }
    _glint(c, const Offset(35, 27), 8);
    c.drawRRect(
      _rr(23, 17, 77, 50, 3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = _fade(_black, 0.35),
    );
  }

  /// Wide-angle dome lens attachment: a fat glass hemisphere over a knurled
  /// screw mount.
  void _domeLens(Canvas c) {
    // mount barrel
    final mount = _rr(28, 58, 72, 88, 4);
    c.drawRRect(
      mount,
      _tubePaint(const Rect.fromLTRB(28, 58, 72, 88), const Color(0xFF6B6E75)),
    );
    _ribs(c, _rr(30, 66, 70, 82, 2), 11);
    _edgeLight(c, mount, _Mat.metal);

    // glass dome
    const o = Offset(50, 50);
    const r = 28.0;
    c.drawCircle(o, r + 2, Paint()..color = _fade(_black, 0.4));
    c.drawCircle(
      o,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(38, 36),
          r * 1.7,
          <Color>[_lift(_c0, 0.45), _c0, _drop(_c1, 0.3), _black],
          const <double>[0.0, 0.32, 0.76, 1.0],
        ),
    );
    // fisheye reflection ring
    c.drawCircle(
      o,
      r * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = _fade(const Color(0xFF8FD0FF), 0.22),
    );
    // rim light lower-right
    c.drawArc(
      Rect.fromCircle(center: o, radius: r - 1.6),
      -0.14 * math.pi,
      0.78 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _fade(_white, 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );
    _glint(c, const Offset(38, 36), 9);
    c.drawCircle(
      const Offset(37, 35),
      3.0,
      Paint()..color = _fade(_white, 0.95),
    );
  }
}
