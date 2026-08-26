import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../widgets/seven_segment.dart';
import 'camera_catalog.dart';
import 'film_effect.dart';
import 'film_textures.dart';

/// Everything the isolate needs. [FilmEffect] holds a `Color`, which is not
/// worth shipping across, so the request carries plain numbers instead.
@immutable
class BakeRequest {
  const BakeRequest({
    required this.jpeg,
    required this.matrix,
    required this.grain,
    required this.vignette,
    required this.leak,
    required this.leakR,
    required this.leakG,
    required this.leakB,
    required this.scanlines,
    required this.bloom,
    required this.chroma,
    required this.distort,
    required this.dust,
    required this.star,
    required this.stamp,
    required this.aspect,
    required this.negative,
    required this.halfFrame,
    required this.seed,
    required this.stampText,
    required this.maxEdge,
    this.halation = 0,
    this.splitTone = 0,
    this.grainPlate,
    this.grainPlateBlend = 0,
    this.grainPlateAlpha = 0,
    this.leakPlate,
    this.leakPlateAlpha = 0,
    this.dustPlate,
    this.dustPlateAlpha = 0,
  });

  /// Pulls the same plates the viewfinder is using and precomputes their
  /// opacities here, on the main isolate, where [FilmTextures] lives. The
  /// isolate only ever sees plain bytes and doubles — which is also the only
  /// reason the saved JPEG can match what the preview showed.
  factory BakeRequest.from(
    Uint8List jpeg,
    FilmEffect e,
    int seed,
    String stampText, {
    int maxEdge = 2048,
  }) {
    final setId = Cameras.plateSetFor(e);
    final grainPlate = e.grain > 0
        ? (setId == FilmTextures.vhsSetId
              ? FilmTextures.vhsPlate(seed)
              : FilmTextures.grainPlate(e.grain, prefer: setId))
        : null;
    final leakPlate = e.leak > 0
        ? FilmTextures.leakPlate(seed, prefer: setId)
        : null;
    final dustPlate = e.dust > 0 ? FilmTextures.dustPlate(seed) : null;

    return BakeRequest(
      grainPlate: grainPlate?.bytes,
      grainPlateBlend: grainPlate?.blend.index ?? 0,
      grainPlateAlpha: grainPlate == null
          ? 0
          : FilmTextures.grainAlpha(e.grain, grainPlate),
      leakPlate: leakPlate?.bytes,
      leakPlateAlpha: leakPlate == null ? 0 : FilmTextures.leakAlpha(e.leak),
      dustPlate: dustPlate?.bytes,
      dustPlateAlpha: dustPlate == null ? 0 : FilmTextures.dustAlpha(e.dust),
      jpeg: jpeg,
      matrix: e.matrix,
      grain: e.grain,
      vignette: e.vignette,
      leak: e.leak,
      leakR: (e.leakColor.r * 255).round(),
      leakG: (e.leakColor.g * 255).round(),
      leakB: (e.leakColor.b * 255).round(),
      scanlines: e.scanlines,
      bloom: e.bloom,
      chroma: e.chroma,
      distort: e.distort,
      dust: e.dust,
      star: e.star,
      halation: e.halation,
      splitTone: e.splitTone,
      stamp: e.stamp.index,
      aspect: e.aspect,
      negative: e.negative,
      halfFrame: e.halfFrame,
      seed: seed,
      stampText: stampText,
      maxEdge: maxEdge,
    );
  }

  final Uint8List jpeg;
  final List<double> matrix;
  final double grain;
  final double vignette;
  final double leak;
  final int leakR;
  final int leakG;
  final int leakB;
  final double scanlines;
  final double bloom;
  final double chroma;
  final double distort;
  final double dust;
  final double star;
  final double halation;
  final double splitTone;
  final int stamp;
  final double aspect;
  final bool negative;
  final bool halfFrame;
  final int seed;
  final String stampText;
  final int maxEdge;

  /// Undecoded plate files. `Uint8List` crosses the isolate boundary cheaply,
  /// while the `ui.Image` the painter uses cannot cross at all.
  final Uint8List? grainPlate;

  /// Index into [PlateBlend] — the grain plates want `overlay`, the VHS
  /// plates want `plus`.
  final int grainPlateBlend;
  final double grainPlateAlpha;
  final Uint8List? leakPlate;
  final double leakPlateAlpha;
  final Uint8List? dustPlate;
  final double dustPlateAlpha;
}

/// Applies the selected look to a captured JPEG, off the UI thread.
///
/// Order matches [FilmView] and [FilmOverlayPainter] so the saved file looks
/// like the viewfinder did: optics -> colour+split tone -> shoulder ->
/// halation -> star flare -> bloom -> leak -> grain -> dust -> scanlines ->
/// vignette -> stamp.
Future<Uint8List> bakePhoto(BakeRequest r) => compute(_bake, r);

Uint8List _bake(BakeRequest r) {
  var src = img.decodeJpg(r.jpeg);
  if (src == null) return r.jpeg;

  // Keep processing time predictable regardless of sensor resolution.
  final longEdge = math.max(src.width, src.height);
  if (longEdge > r.maxEdge) {
    final scale = r.maxEdge / longEdge;
    src = img.copyResize(
      src,
      width: (src.width * scale).round(),
      height: (src.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
  }

  src = _cropToAspect(_orientPortrait(src), r.aspect);

  if (r.distort > 0.001 || r.chroma > 0.001) {
    src = _optics(src, r.distort, r.chroma);
  }

  // The whole grade in one matrix, pulled down by FilmEffect.shoulderScale so
  // nothing clips on the way out, then rolled back off by the shoulder — the
  // same three steps FilmView stacks as ColorFiltered widgets.
  var matrix = r.matrix;
  if (r.negative) {
    matrix = FilmEffect.mul(FilmEffect.matNegative(), matrix);
  }
  if (r.splitTone > 0) {
    matrix = FilmEffect.mul(FilmEffect.matSplitTone(r.splitTone), matrix);
  }
  const scale = FilmEffect.shoulderScale;
  _applyMatrix(
    src,
    FilmEffect.mul(FilmEffect.matTint(scale, scale, scale), matrix),
  );
  _applyShoulder(src);

  if (r.halation > 0) {
    _halation(src, r.halation);
  }

  if (r.star > 0) {
    _starFlare(src, r.star);
  }

  final w = src.width;
  final h = src.height;
  final cx = w / 2, cy = h / 2;
  final maxR = math.sqrt(cx * cx + cy * cy);
  final rnd = math.Random(r.seed);

  if (r.bloom > 0) {
    _screenRadial(src, cx, cy, maxR * 0.6, 255, 255, 255, 0.16 * r.bloom);
  }

  if (r.leak > 0) {
    final plate = _decodePlate(r.leakPlate);
    if (plate != null) {
      // Centred, 1.12x cover — the same placement the painter uses with its
      // drift at rest.
      _plateLeak(src, plate, r.leakPlateAlpha, r.leakR, r.leakG, r.leakB);
    } else {
      _screenRadial(
        src,
        w * 1.02,
        h * 0.12,
        w * 0.8,
        r.leakR,
        r.leakG,
        r.leakB,
        0.52 * r.leak,
      );
      _screenRadial(
        src,
        -w * 0.08,
        h * 0.85,
        w * 0.55,
        r.leakR,
        r.leakG,
        r.leakB,
        0.28 * r.leak,
      );
    }
  }

  if (r.grain > 0) {
    final plate = _decodePlate(r.grainPlate);
    if (plate != null) {
      _plateGrain(
        src,
        plate,
        r.grainPlateAlpha,
        r.grainPlateBlend == PlateBlend.plus.index,
      );
    } else {
      _grain(src, r.grain, rnd);
    }
  }

  if (r.dust > 0) {
    final patches = FilmTextures.dustPatches(r.seed, r.dust);
    final plate = _decodePlate(r.dustPlate);
    if (plate != null) {
      _patchDust(src, plate, patches);
    } else {
      _drawnDust(src, patches);
    }
  }

  if (r.scanlines > 0) {
    _scanlines(src, r.scanlines);
  }

  if (r.vignette > 0) {
    _vignette(src, r.vignette);
  }

  if (r.stamp != StampStyle.none.index && r.stampText.isNotEmpty) {
    _stamp(src, r);
  }

  return Uint8List.fromList(img.encodeJpg(src, quality: 94));
}

/// Puts the frame the way up the viewfinder framed it.
///
/// [Viewfinder] builds its frame `fw` wide by `fw * aspect` tall, so what the
/// user composes is always portrait. The sensor, however, hands back whatever
/// its native orientation is — landscape, on every phone — and the saved file
/// used to keep it, so every single shot came out rotated a quarter turn from
/// what was framed. EXIF is applied first when the capture carried any; if the
/// frame is still lying down after that it gets stood up.
/// Applies the sensor's EXIF orientation and nothing else.
///
/// It must NOT rotate a landscape frame upright: the viewfinder shows the
/// sensor frame `BoxFit.cover`-ed into a portrait window, i.e. a centre crop.
/// Rotating instead of cropping produced portrait-shaped files with the scene
/// lying on its side — shaped right, content wrong.
img.Image _orientPortrait(img.Image src) => img.bakeOrientation(src);

img.Image _cropToAspect(img.Image src, double aspect) {
  // [aspect] is the long:short ratio and the frame is portrait, so the target
  // width:height is its reciprocal — 4/3 means a 3:4 frame, not a 4:3 one.
  final target = 1 / aspect;
  final current = src.width / src.height;
  if ((current - target).abs() < 0.005) return src;
  int w, h;
  if (current > target) {
    h = src.height;
    w = (h * target).round();
  } else {
    w = src.width;
    h = (w / target).round();
  }
  return img.copyCrop(
    src,
    x: ((src.width - w) / 2).round(),
    y: ((src.height - h) / 2).round(),
    width: w,
    height: h,
  );
}

img.Image _optics(img.Image src, double distort, double chroma) {
  final out = img.Image(width: src.width, height: src.height);
  final w = src.width, h = src.height;
  final chromaPx = chroma * (w / 1080.0);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final u = x / w - 0.5;
      final v = y / h - 0.5;
      final r2 = (u * u + v * v) * 4.0;
      final f = 1.0 + distort * r2;
      final su = u / f + 0.5;
      final sv = v / f + 0.5;
      if (su < 0 || su > 1 || sv < 0 || sv > 1) {
        out.setPixelRgba(x, y, 0, 0, 0, 255);
        continue;
      }
      final bx = su * w, by = sv * h;
      final g = _sampleAt(src, bx, by);
      var rr = g.$1, bb = g.$3;
      if (chromaPx > 0.001) {
        final dx = (su - 0.5) * chromaPx * 2;
        final dy = (sv - 0.5) * chromaPx * 2;
        rr = _sampleAt(src, bx + dx, by + dy).$1;
        bb = _sampleAt(src, bx - dx, by - dy).$3;
      }
      out.setPixelRgba(x, y, rr, g.$2, bb, 255);
    }
  }
  return out;
}

(int, int, int) _sampleAt(img.Image src, double x, double y) {
  final xi = x.clamp(0, src.width - 1).toInt();
  final yi = y.clamp(0, src.height - 1).toInt();
  final p = src.getPixel(xi, yi);
  return (p.r.toInt(), p.g.toInt(), p.b.toInt());
}

void _applyMatrix(img.Image src, List<double> m) {
  for (final p in src) {
    final r = p.r.toDouble(), g = p.g.toDouble(), b = p.b.toDouble();
    p
      ..r = (m[0] * r + m[1] * g + m[2] * b + m[4]).clamp(0, 255)
      ..g = (m[5] * r + m[6] * g + m[7] * b + m[9]).clamp(0, 255)
      ..b = (m[10] * r + m[11] * g + m[12] * b + m[14]).clamp(0, 255);
  }
}

/// The compressive highlight roll-off, as a 256-entry LUT.
///
/// Identical maths to the `BlendMode.overlay` + restore pair the viewfinder
/// paints — see [FilmEffect.shoulder]. Without it, anything the grade pushed
/// past white came out of [_applyMatrix] pinned at 255 and a sky went to one
/// flat value; with it, the top of the range is a slope-0.6 segment and the
/// clouds survive.
void _applyShoulder(img.Image src) {
  final lut = Uint8List(256);
  for (var i = 0; i < 256; i++) {
    lut[i] = (FilmEffect.shoulder(i / 255.0) * 255).round();
  }
  for (final p in src) {
    p
      ..r = lut[p.r.toInt()]
      ..g = lut[p.g.toInt()]
      ..b = lut[p.b.toInt()];
  }
}

void _screenRadial(
  img.Image src,
  double cx,
  double cy,
  double radius,
  int cr,
  int cg,
  int cb,
  double strength,
) {
  if (strength <= 0 || radius <= 0) return;
  for (final p in src) {
    final dx = p.x - cx, dy = p.y - cy;
    final d = math.sqrt(dx * dx + dy * dy) / radius;
    if (d >= 1) continue;
    final a = (1 - d) * strength;
    p
      ..r = (p.r + cr * a).clamp(0, 255)
      ..g = (p.g + cg * a).clamp(0, 255)
      ..b = (p.b + cb * a).clamp(0, 255);
  }
}

// -------------------------------------------------------------- highlights
// Halation and the star flare are the same two steps: threshold the luma, blur
// what is left, add it back. The viewfinder does it with an
// `ImageFilter.compose` of a `ColorFilter.matrix` and an `ImageFilter.blur`
// inside a `BackdropFilter`; this is that written out.

/// Downsample factor for the highlight passes.
///
/// A threshold followed by a wide blur is a low pass, so building the mask on
/// a quarter-size grid by averaging — which is itself a box blur — and
/// resampling it back bilinearly is visually the same thing and sixteen times
/// cheaper. That is what pays for two extra full-frame effects inside the
/// existing time budget.
const _maskStep = 4;

class _Mask {
  _Mask(this.w, this.h) : v = Float32List(w * h);

  final int w;
  final int h;
  final Float32List v;
}

/// How far each pixel sits above [threshold], scaled by [gain] and clamped:
/// [FilmEffect.matHighlightMask] plus the clamp every `ColorFilter.matrix`
/// finishes with.
_Mask _highlightMask(img.Image src, double threshold, double gain) {
  final mw = (src.width / _maskStep).ceil();
  final mh = (src.height / _maskStep).ceil();
  final m = _Mask(mw, mh);
  final k = gain / (1 - threshold);
  const norm = 1.0 / (_maskStep * _maskStep);
  for (final p in src) {
    final l = FilmEffect.luma(p.r, p.g, p.b);
    if (l <= threshold) continue;
    var t = (l - threshold) * k;
    if (t > 1.0) t = 1.0;
    m.v[(p.y ~/ _maskStep) * mw + (p.x ~/ _maskStep)] += t * norm;
  }
  return m;
}

/// Radius of one box pass whose triple convolution has variance `sigma^2`.
int _boxRadius(double sigma) {
  if (sigma <= 0.35) return 0;
  return ((math.sqrt(1 + 4 * sigma * sigma) - 1) / 2).round();
}

/// Three box passes per axis — the usual stand-in for a gaussian, and what
/// Skia's own blur does underneath.
void _blur(_Mask m, double sigmaX, double sigmaY) {
  final rx = _boxRadius(sigmaX);
  final ry = _boxRadius(sigmaY);
  for (var i = 0; i < 3; i++) {
    if (rx > 0) _boxH(m, rx);
    if (ry > 0) _boxV(m, ry);
  }
}

void _boxH(_Mask m, int r) {
  final w = m.w, h = m.h, v = m.v;
  final row = Float32List(w);
  final inv = 1.0 / (2 * r + 1);
  for (var y = 0; y < h; y++) {
    final o = y * w;
    var sum = 0.0;
    for (var i = -r; i <= r; i++) {
      sum += v[o + i.clamp(0, w - 1)];
    }
    for (var x = 0; x < w; x++) {
      row[x] = sum * inv;
      sum -= v[o + (x - r).clamp(0, w - 1)];
      sum += v[o + (x + r + 1).clamp(0, w - 1)];
    }
    v.setRange(o, o + w, row);
  }
}

void _boxV(_Mask m, int r) {
  final w = m.w, h = m.h, v = m.v;
  final col = Float32List(h);
  final inv = 1.0 / (2 * r + 1);
  for (var x = 0; x < w; x++) {
    var sum = 0.0;
    for (var i = -r; i <= r; i++) {
      sum += v[i.clamp(0, h - 1) * w + x];
    }
    for (var y = 0; y < h; y++) {
      col[y] = sum * inv;
      sum -= v[(y - r).clamp(0, h - 1) * w + x];
      sum += v[(y + r + 1).clamp(0, h - 1) * w + x];
    }
    for (var y = 0; y < h; y++) {
      v[y * w + x] = col[y];
    }
  }
}

/// Bilinear read-back of a [_maskStep]-downsampled mask, with the per-axis
/// indices and weights built once instead of per pixel.
class _MaskSampler {
  _MaskSampler(this.m, int w, int h)
    : i0 = Int32List(w),
      i1 = Int32List(w),
      fx = Float32List(w),
      j0 = Int32List(h),
      j1 = Int32List(h),
      fy = Float32List(h) {
    _axis(m.w, i0, i1, fx);
    _axis(m.h, j0, j1, fy);
  }

  static void _axis(int n, Int32List a, Int32List b, Float32List f) {
    for (var x = 0; x < a.length; x++) {
      final s = (x - (_maskStep - 1) / 2) / _maskStep;
      var i = s.floor();
      var t = s - i;
      if (i < 0) {
        i = 0;
        t = 0;
      } else if (i > n - 2) {
        i = math.max(0, n - 2);
        t = n > 1 ? 1.0 : 0.0;
      }
      a[x] = i;
      b[x] = math.min(i + 1, n - 1);
      f[x] = t;
    }
  }

  final _Mask m;
  final Int32List i0, i1, j0, j1;
  final Float32List fx, fy;

  double at(int x, int y) {
    final v = m.v;
    final r0 = j0[y] * m.w, r1 = j1[y] * m.w;
    final t = fx[x], u = fy[y];
    final a0 = i0[x], a1 = i1[x];
    final top = v[r0 + a0] + (v[r0 + a1] - v[r0 + a0]) * t;
    final bot = v[r1 + a0] + (v[r1 + a1] - v[r1 + a0]) * t;
    return top + (bot - top) * u;
  }
}

/// The red halo a thin film base throws back around a blown highlight.
///
/// Without this, a bright area meets a dark one on a clean hard edge, which is
/// the single most obvious way a digital frame gives itself away.
void _halation(img.Image src, double amount) {
  final sigma =
      FilmEffect.halationSigma * math.max(src.width, src.height) / 1080.0;
  final m = _highlightMask(
    src,
    FilmEffect.halationThreshold,
    FilmEffect.halationStrength * amount,
  );
  _blur(m, sigma / _maskStep, sigma / _maskStep);
  final s = _MaskSampler(m, src.width, src.height);
  const c = FilmEffect.halationColor;
  final tr = c.r, tg = c.g, tb = c.b;
  for (final p in src) {
    final v = s.at(p.x, p.y);
    if (v <= 0.0005) continue;
    // BlendMode.screen, which is what the BackdropFilter is set to.
    p
      ..r = 255 - (255 - p.r) * (1 - v * tr)
      ..g = 255 - (255 - p.g) * (1 - v * tg)
      ..b = 255 - (255 - p.b) * (1 - v * tb);
  }
}

/// A star filter, as two directional blurs of the frame's own speculars.
///
/// The flares used to be five identical four-point stars dropped at random
/// positions, which landed on tree branches and walls. Deriving them from a
/// 92%-luma mask means one can only appear over something genuinely specular,
/// and because a blur conserves energy its length and brightness scale
/// themselves by how bright and how large that highlight is.
void _starFlare(img.Image src, double amount) {
  final long = FilmEffect.starSigma * math.min(src.width, src.height);
  final short = 0.6 * math.max(src.width, src.height) / 1080.0;
  // Two passes, in the order the two BackdropFilters are stacked — the second
  // reads the frame the first one already brightened.
  _streak(src, amount, long, short);
  _streak(src, amount, short, long);
}

void _streak(img.Image src, double amount, double sigmaX, double sigmaY) {
  final m = _highlightMask(
    src,
    FilmEffect.starThreshold,
    FilmEffect.starGain * amount,
  );
  _blur(m, sigmaX / _maskStep, sigmaY / _maskStep);
  final s = _MaskSampler(m, src.width, src.height);
  for (final p in src) {
    final v = s.at(p.x, p.y) * 255;
    if (v <= 0.5) continue;
    p
      ..r = (p.r + v).clamp(0, 255)
      ..g = (p.g + v).clamp(0, 255)
      ..b = (p.b + v).clamp(0, 255);
  }
}

/// A plate flattened to raw RGBA once, so the composite loop below is a plain
/// array index instead of an `img.Image.getPixel` call per pixel per plate.
class _Plate {
  _Plate(img.Image im)
    : w = im.width,
      h = im.height,
      px = im.convert(numChannels: 4).getBytes(order: img.ChannelOrder.rgba);

  final int w;
  final int h;
  final Uint8List px;
}

_Plate? _decodePlate(Uint8List? bytes) {
  if (bytes == null || bytes.isEmpty) return null;
  try {
    final im = img.decodeImage(bytes);
    return im == null ? null : _Plate(im);
  } catch (_) {
    return null;
  }
}

/// Nearest-neighbour cover mapping from working-image pixels to plate pixels.
///
/// Built once per plate — this is what keeps the bake inside its time budget.
/// Resampling the plate up to the working size instead would mean an extra
/// multi-megapixel resize and allocation per plate.
class _Cover {
  _Cover(
    _Plate plate,
    int w,
    int h, {
    double extra = 1.0,
    bool centre = true,
  }) : xs = Int32List(w),
       ys = Int32List(h) {
    final scale = math.max(w / plate.w, h / plate.h) * extra;
    final ox = centre ? (w - plate.w * scale) / 2 : 0.0;
    final oy = centre ? (h - plate.h * scale) / 2 : 0.0;
    for (var x = 0; x < w; x++) {
      xs[x] = ((x - ox) / scale).floor().clamp(0, plate.w - 1);
    }
    for (var y = 0; y < h; y++) {
      ys[y] = ((y - oy) / scale).floor().clamp(0, plate.h - 1);
    }
  }

  final Int32List xs;
  final Int32List ys;
}

/// Real emulsion grain, composited exactly as `FilmOverlayPainter._paintGrain`
/// does it: cover scale anchored top-left, `overlay` for the mid-grey plates
/// and `plus` for the near-black VHS plates.
void _plateGrain(img.Image src, _Plate plate, double a, bool plus) {
  if (a <= 0) return;
  final map = _Cover(plate, src.width, src.height, centre: false);
  final px = plate.px;
  final pw = plate.w;
  for (final p in src) {
    final i = (map.ys[p.y] * pw + map.xs[p.x]) * 4;
    if (plus) {
      p
        ..r = (p.r + px[i] * a).clamp(0, 255)
        ..g = (p.g + px[i + 1] * a).clamp(0, 255)
        ..b = (p.b + px[i + 2] * a).clamp(0, 255);
    } else {
      // Real grain peaks in the midtones and vanishes into the toe and the
      // shoulder; a constant amplitude across the frame is what makes it read
      // as added noise. `overlay` already tapers its own deviation to zero at
      // both ends of each channel — that is the weighting the viewfinder gets
      // for free — and this parabola on the pixel's luma sharpens the peak on
      // top of it.
      final l = FilmEffect.luma(p.r, p.g, p.b);
      final wa = a * (0.30 + 2.80 * l * (1 - l));
      p
        ..r = _overlay(p.r.toDouble(), px[i].toDouble(), wa)
        ..g = _overlay(p.g.toDouble(), px[i + 1].toDouble(), wa)
        ..b = _overlay(p.b.toDouble(), px[i + 2].toDouble(), wa);
    }
  }
}

/// `BlendMode.overlay` on 0..255 channels, lerped by the plate's opacity.
double _overlay(double b, double s, double a) {
  final o = b < 127.5
      ? 2 * b * s / 255.0
      : 255.0 - 2 * (255.0 - b) * (255.0 - s) / 255.0;
  return (b + (o - b) * a).clamp(0.0, 255.0);
}

/// A light-leak plate read as brightness and repainted in the leak colour,
/// matching the `ColorFilter.matrix` the painter hands to Skia.
void _plateLeak(img.Image src, _Plate plate, double a, int cr, int cg, int cb) {
  if (a <= 0) return;
  final map = _Cover(plate, src.width, src.height, extra: 1.12);
  final px = plate.px;
  final pw = plate.w;
  final fr = cr / 255.0, fg = cg / 255.0, fb = cb / 255.0;
  for (final p in src) {
    final i = (map.ys[p.y] * pw + map.xs[p.x]) * 4;
    final lum =
        FilmTextures.leakWeightR * px[i] +
        FilmTextures.leakWeightG * px[i + 1] +
        FilmTextures.leakWeightB * px[i + 2];
    if (lum <= 0) continue;
    p
      ..r = (p.r + (lum * fr).clamp(0.0, 255.0) * a).clamp(0, 255)
      ..g = (p.g + (lum * fg).clamp(0.0, 255.0) * a).clamp(0, 255)
      ..b = (p.b + (lum * fb).clamp(0.0, 255.0) * a).clamp(0, 255);
  }
}

/// Scanned dust and hairs, cut out of the plate in [FilmTextures.dustPatches]
/// and dropped on the frame — the same windows the painter draws.
///
/// The plate used to be tiled across the whole frame at a fixed reference
/// scale, which on a 2048px frame meant four copies of it: twenty-odd hairs,
/// all one opacity, all one width, evenly scattered. Real 35mm carries none
/// most of the time and two or three clustered specks when it has been
/// handled, about as often dark as light.
void _patchDust(img.Image src, _Plate plate, List<DustPatch> patches) {
  if (patches.isEmpty) return;
  final w = src.width, h = src.height;
  final long = math.max(w, h).toDouble();
  final plateShort = math.min(plate.w, plate.h).toDouble();
  final px = plate.px;
  for (final patch in patches) {
    final side = patch.size * long;
    if (side < 1) continue;
    final left = patch.cx * w - side / 2;
    final top = patch.cy * h - side / 2;
    final srcSide = patch.srcSize * plateShort;
    final sx0 = patch.srcX * (plate.w - srcSide);
    final sy0 = patch.srcY * (plate.h - srcSide);
    final x0 = left.floor().clamp(0, w);
    final x1 = (left + side).ceil().clamp(0, w);
    final y0 = top.floor().clamp(0, h);
    final y1 = (top + side).ceil().clamp(0, h);
    for (var y = y0; y < y1; y++) {
      final sy = (sy0 + (y + 0.5 - top) / side * srcSide).floor().clamp(
        0,
        plate.h - 1,
      );
      for (var x = x0; x < x1; x++) {
        final sx = (sx0 + (x + 0.5 - left) / side * srcSide).floor().clamp(
          0,
          plate.w - 1,
        );
        final i = (sy * plate.w + sx) * 4;
        final a = px[i + 3] / 255.0 * patch.alpha;
        if (a <= 0) continue;
        final p = src.getPixel(x, y);
        if (patch.dark) {
          // The painter's inverted plate under BlendMode.multiply:
          // dst * (1 - srcAlpha * plateBrightness).
          p
            ..r = p.r * (1 - a * px[i] / 255.0)
            ..g = p.g * (1 - a * px[i + 1] / 255.0)
            ..b = p.b * (1 - a * px[i + 2] / 255.0);
        } else {
          p
            ..r = (p.r + a * px[i]).clamp(0, 255)
            ..g = (p.g + a * px[i + 1]).clamp(0, 255)
            ..b = (p.b + a * px[i + 2]).clamp(0, 255);
        }
      }
    }
  }
}

/// Drawn specks, for the window before the dust plates have decoded. Mirrors
/// `FilmOverlayPainter._paintDustFallback`.
void _drawnDust(img.Image src, List<DustPatch> patches) {
  final long = math.max(src.width, src.height).toDouble();
  for (final patch in patches) {
    final len = patch.size * long * 0.5;
    final x = patch.cx * src.width;
    final y = patch.cy * src.height;
    final v = patch.dark ? 0 : 255;
    img.drawLine(
      src,
      x1: x.round(),
      y1: y.round(),
      x2: (x + len * 0.08).round(),
      y2: (y + len).round(),
      color: img.ColorRgba8(v, v, v, (patch.alpha * 255).round()),
      thickness: math.max(1, (0.6 + patch.srcSize * 2.4).round()),
    );
  }
}

void _grain(img.Image src, double amount, math.Random rnd) {
  final k = 46 * amount;
  for (final p in src) {
    final n =
        (rnd.nextDouble() + rnd.nextDouble() + rnd.nextDouble()) / 3 - 0.5;
    // Same midtone weighting as the plate path above.
    final l = FilmEffect.luma(p.r, p.g, p.b);
    final d = n * k * (0.30 + 2.80 * l * (1 - l));
    p
      ..r = (p.r + d).clamp(0, 255)
      ..g = (p.g + d).clamp(0, 255)
      ..b = (p.b + d).clamp(0, 255);
  }
}

void _scanlines(img.Image src, double amount) {
  final step = math.max(2, (src.height / 320).round());
  final a = 0.16 * amount;
  for (var y = 0; y < src.height; y += step) {
    for (var x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      p
        ..r = p.r * (1 - a)
        ..g = p.g * (1 - a)
        ..b = p.b * (1 - a);
    }
  }
}

void _vignette(img.Image src, double amount) {
  final cx = src.width / 2, cy = src.height / 2;
  final maxR = math.sqrt(cx * cx + cy * cy) * 0.62 * 2;
  for (final p in src) {
    final dx = p.x - cx, dy = p.y - cy;
    final d = math.sqrt(dx * dx + dy * dy) / maxR;
    if (d <= 0.55) continue;
    final t = ((d - 0.55) / 0.45).clamp(0.0, 1.0);
    final k = 1 - 0.85 * amount * t;
    p
      ..r = p.r * k
      ..g = p.g * k
      ..b = p.b * k;
  }
}

void _stamp(img.Image src, BakeRequest r) {
  final style = StampStyle.values[r.stamp];
  final short = math.min(src.width, src.height).toDouble();
  final double digitHeight;
  final int cr, cg, cb;
  switch (style) {
    case StampStyle.none:
      return;
    case StampStyle.orangeRight:
      digitHeight = short * 0.055;
      cr = 0xFF;
      cg = 0x8A;
      cb = 0x3D;
    case StampStyle.orangeLeft:
      digitHeight = short * 0.05;
      cr = 0xFF;
      cg = 0x8A;
      cb = 0x3D;
    case StampStyle.redSmall:
      digitHeight = short * 0.038;
      cr = 0xE0;
      cg = 0x20;
      cb = 0x20;
  }

  if (style == StampStyle.orangeLeft) {
    // Reads bottom-to-top up the left edge, mirroring
    // `SevenSegment.paintVertical`: lay the digits out flat, then rotate them
    // a quarter turn counter-clockwise by hand, because here we are writing
    // pixels rather than driving a Canvas.
    //
    //   canvas.translate(ox, oy); canvas.rotate(-pi / 2)
    //   =>  (x, y) -> (ox + y, oy - x)
    //
    // A 90 degree turn keeps every rect axis aligned, so this stays exact.
    final ox = src.width * 0.06;
    final oy = src.height * 0.62;
    final rects = SevenSegment.layout(
      r.stampText,
      originX: 0,
      originY: -digitHeight,
      digitHeight: digitHeight,
    );
    for (final rect in rects) {
      _burn(
        src,
        ox + rect.top,
        oy - rect.right,
        ox + rect.bottom,
        oy - rect.left,
        cr,
        cg,
        cb,
      );
    }
    return;
  }

  final width = SevenSegment.measure(r.stampText) * digitHeight;
  final left = src.width * 0.94 - width;
  final top = src.height * 0.94 - digitHeight;
  final rects = SevenSegment.layout(
    r.stampText,
    originX: left,
    originY: top,
    digitHeight: digitHeight,
  );
  for (final rect in rects) {
    _burn(src, rect.left, rect.top, rect.right, rect.bottom, cr, cg, cb);
  }
}

/// Adds one LED segment into the frame, the way the painter's `BlendMode.plus`
/// does.
void _burn(
  img.Image src,
  double left,
  double top,
  double right,
  double bottom,
  int cr,
  int cg,
  int cb,
) {
  final x0 = left.round();
  final y0 = top.round();
  final x1 = right.round();
  final y1 = bottom.round();
  for (var y = y0; y < y1; y++) {
    if (y < 0 || y >= src.height) continue;
    for (var x = x0; x < x1; x++) {
      if (x < 0 || x >= src.width) continue;
      final p = src.getPixel(x, y);
      p
        ..r = (p.r + cr * 0.92).clamp(0, 255)
        ..g = (p.g + cg * 0.92).clamp(0, 255)
        ..b = (p.b + cb * 0.92).clamp(0, 255);
    }
  }
}
