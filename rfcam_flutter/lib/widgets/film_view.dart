import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../core/camera_catalog.dart';
import '../core/film_effect.dart';
import '../core/film_textures.dart';
import 'seven_segment.dart';

/// Wraps any widget — the live camera preview, a still, a placeholder — in the
/// currently selected film look. The same [FilmEffect] drives the baked JPEG,
/// so the viewfinder is an honest preview.
class FilmView extends StatefulWidget {
  const FilmView({
    super.key,
    required this.effect,
    required this.seed,
    required this.child,
    this.animate = true,
    this.stampDate,
    this.showStamp = true,
    this.showRecBadge = true,
  });

  final FilmEffect effect;
  final int seed;
  final Widget child;
  final bool animate;
  final DateTime? stampDate;
  final bool showStamp;
  final bool showRecBadge;

  static ui.FragmentProgram? _program;
  static bool _programFailed = false;

  /// Turned off by the automated flow checks: a repainting overlay never lets
  /// `pumpAndSettle` finish. Has no effect on the shipped app.
  static bool motionEnabled = true;

  /// Loads the optics shader and the film plates once. Neither failure is
  /// fatal — the widget just skips distortion, or falls back to the procedural
  /// grain, instead of blowing up the camera.
  static Future<void> warmUp() async {
    await NoiseTexture.ensure();
    await FilmTextures.warmUp();
    if (_program != null || _programFailed) return;
    try {
      _program = await ui.FragmentProgram.fromAsset('shaders/film.frag');
    } catch (_) {
      _programFailed = true;
    }
  }

  @override
  State<FilmView> createState() => _FilmViewState();
}

class _FilmViewState extends State<FilmView> {
  /// Driven by a plain timer rather than a Ticker on purpose: a repeating
  /// AnimationController registers transient frame callbacks forever, which
  /// makes flutter_driver (and any `pumpAndSettle`) wait for a settle that
  /// never comes. A timer keeps the grain crawling without that.
  final _phase = ValueNotifier<double>(0);
  Timer? _timer;

  bool get _needsMotion {
    final e = widget.effect;
    return FilmView.motionEnabled &&
        widget.animate &&
        (e.grain > 0 || e.leak > 0 || e.scanlines > 0 || e.showRec);
  }

  @override
  void initState() {
    super.initState();
    _sync();
    // The first frame renders with whatever is decoded so far; this swaps in
    // the real plates the moment they finish loading.
    if (!FilmTextures.ready) {
      FilmTextures.revision.addListener(_onTexturesReady);
    }
  }

  void _onTexturesReady() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(FilmView old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (_needsMotion && _timer == null) {
      _timer = Timer.periodic(const Duration(milliseconds: 66), (_) {
        _phase.value = (_phase.value + 0.011) % 1.0;
      });
    } else if (!_needsMotion && _timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    FilmTextures.revision.removeListener(_onTexturesReady);
    _timer?.cancel();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.effect;
    Widget content = widget.child;

    if (e.blurSigma > 0) {
      content = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: e.blurSigma,
          sigmaY: e.blurSigma,
          tileMode: TileMode.decal,
        ),
        child: content,
      );
    }

    final program = FilmView._program;
    if (program != null && (e.distort > 0.001 || e.chroma > 0.001)) {
      final shader = program.fragmentShader();
      content = AnimatedSampler(
        (image, size, canvas) {
          shader
            ..setFloat(0, size.width)
            ..setFloat(1, size.height)
            ..setFloat(2, e.distort)
            ..setFloat(3, e.chroma)
            ..setImageSampler(0, image);
          canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint()..shader = shader,
          );
        },
        child: content,
      );
    }

    content = _grade(content, e);

    final overlay = IgnorePointer(
      child: ValueListenableBuilder<double>(
        valueListenable: _phase,
        builder: (context, t, _) => CustomPaint(
          painter: FilmOverlayPainter(
            effect: e,
            seed: widget.seed,
            t: t,
            stampDate: widget.showStamp ? widget.stampDate : null,
            showRecBadge: widget.showRecBadge,
          ),
        ),
      ),
    );

    if (e.halation <= 0 && e.star <= 0) {
      return RepaintBoundary(
        child: Stack(fit: StackFit.expand, children: [content, overlay]),
      );
    }

    // Halation and the star flare are the two effects that have to *read* the
    // frame, so they cannot live in the painter — a CustomPainter never sees
    // what is underneath it. They go in as BackdropFilters instead, stacked
    // between the graded content and the painter, which is exactly where the
    // bake applies them.
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, c) {
          final size = Size(
            c.hasBoundedWidth ? c.maxWidth : 1080.0,
            c.hasBoundedHeight ? c.maxHeight : 1080.0,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              content,
              if (e.halation > 0) _halationLayer(size, e.halation),
              if (e.star > 0) ..._starLayers(size, e.star),
              overlay,
            ],
          );
        },
      ),
    );
  }

  /// Colour matrix, split tone and the highlight shoulder.
  ///
  /// Three passes, and the order is load bearing:
  ///
  /// 1. the stock's own matrix, with the negative flip, the split tone and a
  ///    [FilmEffect.shoulderScale] pull-down all folded in — folded, because
  ///    `ColorFilter.matrix` clamps its output, and anything that clips here is
  ///    gone before the shoulder can roll it off;
  /// 2. `BlendMode.overlay` against [FilmEffect.shoulderPivotColor], the only
  ///    non-linear tone curve Skia will give a constant source;
  /// 3. the linear restore that puts the below-knee segment back at unity.
  ///
  /// [FilmEffect.shoulder] is the same curve in closed form, and that is what
  /// the bake runs per pixel.
  Widget _grade(Widget content, FilmEffect e) {
    var matrix = e.matrix;
    if (e.negative) matrix = FilmEffect.mul(FilmEffect.matNegative(), matrix);
    if (e.splitTone > 0) {
      matrix = FilmEffect.mul(FilmEffect.matSplitTone(e.splitTone), matrix);
    }
    const s = FilmEffect.shoulderScale;
    const r = FilmEffect.shoulderRestore;
    matrix = FilmEffect.mul(FilmEffect.matTint(s, s, s), matrix);
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(FilmEffect.matTint(r, r, r)),
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          FilmEffect.shoulderPivotColor,
          BlendMode.overlay,
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(matrix),
          child: content,
        ),
      ),
    );
  }

  /// The red halo a thin film base throws around a blown highlight.
  ///
  /// Threshold the frame's luma, blur it, screen it back in warm. The
  /// threshold is the inner half of the filter and the blur the outer half, so
  /// Skia does the whole thing in one pass over the backdrop.
  Widget _halationLayer(Size size, double amount) {
    final sigma = FilmEffect.halationSigma * size.longestSide / 1080.0;
    return ClipRect(
      child: BackdropFilter(
        blendMode: BlendMode.screen,
        filter: ui.ImageFilter.compose(
          outer: ui.ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
            tileMode: TileMode.clamp,
          ),
          inner: ColorFilter.matrix(
            FilmEffect.matHighlightMask(
              FilmEffect.halationThreshold,
              FilmEffect.halationColor,
              FilmEffect.halationStrength * amount,
            ),
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  /// A star filter, as a pair of directional blurs of the specular highlights.
  ///
  /// This replaces the four-point stars that used to be stamped at random
  /// positions: because the streaks are a blur *of the frame's own
  /// highlights*, a flare can only appear where there is genuinely something
  /// specular, and its length and brightness come out proportional to how
  /// bright and how large that highlight is. Nothing lands on a tree branch.
  List<Widget> _starLayers(Size size, double amount) {
    final long = FilmEffect.starSigma * size.shortestSide;
    final short = 0.6 * size.longestSide / 1080.0;
    final mask = ColorFilter.matrix(
      FilmEffect.matHighlightMask(
        FilmEffect.starThreshold,
        const Color(0xFFFFFFFF),
        FilmEffect.starGain * amount,
      ),
    );
    Widget streak(double sx, double sy) => ClipRect(
      child: BackdropFilter(
        blendMode: BlendMode.plus,
        filter: ui.ImageFilter.compose(
          outer: ui.ImageFilter.blur(
            sigmaX: sx,
            sigmaY: sy,
            tileMode: TileMode.clamp,
          ),
          inner: mask,
        ),
        child: const SizedBox.expand(),
      ),
    );
    return <Widget>[streak(long, short), streak(short, long)];
  }
}

/// Grain, dust, vignette, leaks, tracking lines and the date stamp. Kept in
/// one painter so the ordering matches [bakePhoto] exactly.
///
/// Halation and the star flare are deliberately *not* here: both have to read
/// the pixels underneath, which a painter cannot do. [FilmView] stacks them as
/// BackdropFilters directly beneath this painter, so the full running order is
/// still grade -> halation -> flare -> bloom -> leak -> grain -> dust ->
/// scanlines -> vignette -> stamp, in the viewfinder and in the bake alike.
class FilmOverlayPainter extends CustomPainter {
  FilmOverlayPainter({
    required this.effect,
    required this.seed,
    required this.t,
    this.stampDate,
    this.showRecBadge = true,
  });

  final FilmEffect effect;
  final int seed;
  final double t;
  final DateTime? stampDate;
  final bool showRecBadge;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final e = effect;

    if (e.bloom > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            rect.center,
            size.longestSide * 0.6,
            [
              Colors.white.withValues(alpha: 0.16 * e.bloom),
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
      );
    }

    if (e.leak > 0) {
      _paintLeak(canvas, size, e);
    }

    if (e.grain > 0) {
      _paintGrain(canvas, rect, size, e);
    }

    if (e.dust > 0) {
      _paintDust(canvas, size, e);
    }

    if (e.scanlines > 0) {
      _paintScanlines(canvas, size, e);
    }

    if (e.vignette > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(
            rect.center,
            size.longestSide * 0.62,
            [
              const Color(0x00000000),
              Colors.black.withValues(alpha: 0.85 * e.vignette),
            ],
            const [0.55, 1.0],
          ),
      );
    }

    if (e.showRec && showRecBadge) {
      _paintRec(canvas, size);
    }

    if (stampDate != null && e.stamp != StampStyle.none) {
      _paintStamp(canvas, size, e.stamp, stampDate!);
    }
  }

  /// Real emulsion grain, tiled from a plate lifted out of the original app.
  ///
  /// The plate is scaled so one tile covers the frame — the scale it was shot
  /// at — and jittered a few pixels per frame so the grain crawls. Tiling is
  /// mirrored rather than plain repeat: at cover scale the jitter only ever
  /// exposes a thin band of the neighbouring tile, and mirroring makes that
  /// band continuous instead of a visible seam.
  void _paintGrain(Canvas canvas, Rect rect, Size size, FilmEffect e) {
    final setId = Cameras.plateSetFor(e);
    final plate = setId == FilmTextures.vhsSetId
        ? FilmTextures.vhsPlate(seed + (t * 15).floor())
        : FilmTextures.grainPlate(e.grain, prefer: setId);

    // Jitter the tile per frame so the grain crawls like real emulsion.
    final rnd = math.Random(seed * 31 + (t * 24).floor());

    if (plate == null) {
      // Plates have not finished decoding. Fall back to the procedural noise
      // so the viewfinder never renders a bare frame.
      final noise = NoiseTexture.image;
      if (noise == null) return;
      final m = Matrix4.identity()
        ..setEntry(0, 3, rnd.nextDouble() * 64)
        ..setEntry(1, 3, rnd.nextDouble() * 64);
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.overlay
          ..color = Colors.white.withValues(alpha: 0.05 + 0.17 * e.grain)
          ..shader = ui.ImageShader(
            noise,
            TileMode.repeated,
            TileMode.repeated,
            m.storage,
          ),
      );
      return;
    }

    final image = plate.image;
    final scale = math.max(
      size.width / image.width,
      size.height / image.height,
    );
    final m = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, rnd.nextDouble() * 24 - 12)
      ..setEntry(1, 3, rnd.nextDouble() * 24 - 12);
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = plate.blend == PlateBlend.plus
            ? BlendMode.plus
            : BlendMode.overlay
        ..color = Colors.white.withValues(
          alpha: FilmTextures.grainAlpha(e.grain, plate),
        )
        ..shader = ui.ImageShader(
          image,
          TileMode.mirror,
          TileMode.mirror,
          m.storage,
        ),
    );
  }

  /// A real light-leak plate, scaled to cover and re-tinted to
  /// [FilmEffect.leakColor]. The source plates are near-pure red, so they are
  /// read as brightness and repainted rather than used as-is — one plate can
  /// then serve a warm, magenta or green leak.
  void _paintLeak(Canvas canvas, Size size, FilmEffect e) {
    final plate = FilmTextures.leakPlate(
      seed,
      prefer: Cameras.plateSetFor(e),
    );
    final drift = math.sin(t * math.pi * 2) * 0.06;
    if (plate == null) {
      _paintLeakFallback(canvas, size, e, drift);
      return;
    }
    final image = plate.image;
    // A little over cover, so the slow drift never pulls an edge into frame.
    final scale =
        math.max(size.width / image.width, size.height / image.height) * 1.12;
    final w = image.width * scale;
    final h = image.height * scale;
    final dst = Rect.fromLTWH(
      (size.width - w) / 2 + drift * size.width * 0.30,
      (size.height - h) / 2 - drift * size.height * 0.22,
      w,
      h,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      Paint()
        ..blendMode = BlendMode.plus
        ..filterQuality = FilterQuality.low
        ..colorFilter = ColorFilter.matrix(FilmTextures.leakTint(e.leakColor))
        ..color = Colors.white.withValues(
          alpha: FilmTextures.leakAlpha(e.leak),
        ),
    );
  }

  /// The original synthetic leak, kept for the window before the plates land.
  void _paintLeakFallback(
    Canvas canvas,
    Size size,
    FilmEffect e,
    double drift,
  ) {
    final rnd = math.Random(seed);
    final from = Offset(size.width * (1.02 + drift), size.height * 0.12);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.radial(
          from,
          size.width * (0.7 + rnd.nextDouble() * 0.25),
          [
            e.leakColor.withValues(alpha: 0.52 * e.leak),
            e.leakColor.withValues(alpha: 0.0),
          ],
          const [0.0, 1.0],
        ),
    );
    final from2 = Offset(-size.width * 0.08, size.height * (0.85 - drift));
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.radial(
          from2,
          size.width * 0.55,
          [
            e.leakColor.withValues(alpha: 0.28 * e.leak),
            e.leakColor.withValues(alpha: 0.0),
          ],
          const [0.0, 1.0],
        ),
    );
  }

  /// Scanned dust and hairs, dropped on the frame in [FilmTextures.dustPatches].
  ///
  /// Not tiled any more. Tiling the plate at a fixed reference scale put four
  /// copies of it on a 2048px frame, which is twenty-odd hairs at one opacity
  /// and one width, evenly scattered — the single loudest tell that this was
  /// a filter and not a strip of film. Now it is 0..3 windows of the plate,
  /// clustered, each at its own opacity, and some of them dark.
  void _paintDust(Canvas canvas, Size size, FilmEffect e) {
    final patches = FilmTextures.dustPatches(seed, e.dust);
    if (patches.isEmpty) return;
    final plate = FilmTextures.dustPlate(seed);
    if (plate == null) {
      _paintDustFallback(canvas, size, patches);
      return;
    }
    final image = plate.image;
    final plateShort = math.min(image.width, image.height).toDouble();
    final long = size.longestSide;
    for (final p in patches) {
      final side = p.size * long;
      final dst = Rect.fromCenter(
        center: Offset(p.cx * size.width, p.cy * size.height),
        width: side,
        height: side,
      );
      final srcSide = p.srcSize * plateShort;
      final src = Rect.fromLTWH(
        p.srcX * (image.width - srcSide),
        p.srcY * (image.height - srcSide),
        srcSide,
        srcSide,
      );
      final paint = Paint()
        ..filterQuality = FilterQuality.low
        ..color = Colors.white.withValues(alpha: p.alpha);
      if (p.dark) {
        // A speck that printed through: invert the plate and multiply, so the
        // bright hairs on it come out as dark ones on the frame.
        paint
          ..blendMode = BlendMode.multiply
          ..colorFilter = ColorFilter.matrix(FilmEffect.matNegative());
      } else {
        paint.blendMode = BlendMode.plus;
      }
      canvas.drawImageRect(image, src, dst, paint);
    }
  }

  /// Procedural specks, kept as the pre-load fallback. Same patches, drawn as
  /// single hairs because there is no plate to cut a window out of yet.
  void _paintDustFallback(
    Canvas canvas,
    Size size,
    List<DustPatch> patches,
  ) {
    final long = size.longestSide;
    for (final p in patches) {
      final len = p.size * long * 0.5;
      final paint = Paint()
        ..blendMode = p.dark ? BlendMode.multiply : BlendMode.plus
        ..strokeWidth = 0.6 + p.srcSize * 2.4
        ..color = (p.dark ? Colors.black : Colors.white).withValues(
          alpha: p.alpha,
        );
      final from = Offset(p.cx * size.width, p.cy * size.height);
      canvas.drawLine(from, from + Offset(len * 0.08, len), paint);
    }
  }

  void _paintScanlines(Canvas canvas, Size size, FilmEffect e) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16 * e.scanlines)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // The tracking band that keeps sliding down a worn tape.
    final bandY = ((t * 1.6) % 1.2 - 0.1) * size.height;
    final band = Rect.fromLTWH(0, bandY, size.width, size.height * 0.055);
    canvas.drawRect(
      band,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.linear(
          band.topLeft,
          band.bottomLeft,
          [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.20 * e.scanlines),
            Colors.white.withValues(alpha: 0.0),
          ],
          const [0.0, 0.5, 1.0],
        ),
    );
    final rnd = math.Random((t * 12).floor() + seed);
    for (var i = 0; i < 3; i++) {
      final y = rnd.nextDouble() * size.height;
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 1.6),
        Paint()..color = Colors.white.withValues(alpha: 0.10 * e.scanlines),
      );
    }
  }

  void _paintRec(Canvas canvas, Size size) {
    final blink = (t * 6) % 1 < 0.6;
    final p = Paint()..color = const Color(0xFFE0382C);
    final left = size.width * 0.06;
    final top = size.height * 0.06;
    if (blink) canvas.drawCircle(Offset(left + 6, top + 6), 6, p);
    final tp = TextPainter(
      text: TextSpan(
        text: 'REC',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: size.shortestSide * 0.055,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(left + 20, top - tp.height / 2 + 6));
  }

  void _paintStamp(
    Canvas canvas,
    Size size,
    StampStyle style,
    DateTime date,
  ) {
    final text = '${date.month} ${date.day} ${date.year % 100}';
    switch (style) {
      case StampStyle.none:
        return;
      case StampStyle.orangeRight:
        SevenSegment.paint(
          canvas,
          text,
          origin: Offset(size.width * 0.94, size.height * 0.94),
          digitHeight: size.shortestSide * 0.055,
          color: const Color(0xFFFF8A3D),
          alignRight: true,
          glow: true,
        );
      case StampStyle.orangeLeft:
        SevenSegment.paintVertical(
          canvas,
          text,
          origin: Offset(size.width * 0.06, size.height * 0.62),
          digitHeight: size.shortestSide * 0.05,
          color: const Color(0xFFFF8A3D),
          glow: true,
        );
      case StampStyle.redSmall:
        SevenSegment.paint(
          canvas,
          text,
          origin: Offset(size.width * 0.95, size.height * 0.95),
          digitHeight: size.shortestSide * 0.038,
          color: const Color(0xFFE02020),
          alignRight: true,
          glow: true,
        );
    }
  }

  @override
  bool shouldRepaint(FilmOverlayPainter old) =>
      old.t != t ||
      old.seed != seed ||
      old.effect != effect ||
      old.stampDate != stampDate;
}
