import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// How the burned-in date stamp looks on a frame.
enum StampStyle { none, orangeRight, redSmall, orangeLeft }

/// A complete look. One instance drives both the live viewfinder and the
/// baked JPEG, so what you see really is what you get.
@immutable
class FilmEffect {
  const FilmEffect({
    this.matrix = identityMatrix,
    this.grain = 0.0,
    this.vignette = 0.0,
    this.leak = 0.0,
    this.leakColor = const Color(0xFFFF7A2F),
    this.scanlines = 0.0,
    this.bloom = 0.0,
    this.blurSigma = 0.0,
    this.chroma = 0.0,
    this.distort = 0.0,
    this.star = 0.0,
    this.dust = 0.0,
    this.stamp = StampStyle.none,
    this.aspect = 4 / 3,
    this.showRec = false,
    this.halfFrame = false,
    this.negative = false,
    double? halation,
    double? splitTone,
  }) : _halation = halation,
       _splitTone = splitTone;

  /// 4x5 colour matrix, row-major, as [ColorFilter.matrix] wants it.
  final List<double> matrix;
  final double grain;
  final double vignette;
  final double leak;
  final Color leakColor;
  final double scanlines;
  final double bloom;
  final double blurSigma;
  final double chroma;
  final double distort;
  final double star;
  final double dust;
  final StampStyle stamp;
  final double aspect;
  final bool showRec;
  final bool halfFrame;
  final bool negative;

  final double? _halation;
  final double? _splitTone;

  /// How much the emulsion scatters light back around a blown highlight, 0..1.
  ///
  /// Left unset it derives itself from [leak]: a stock that leaks is a warm
  /// stock on a thin base, and those are exactly the ones that halate. That
  /// keeps the camera catalog out of it — every warm profile (fxn, ct2f, dcr,
  /// d_classic, sr135, eightmm, v_funs, d_funs) picks up a real amount without
  /// a single entry being edited — while still letting a camera dial it
  /// explicitly, including down to zero.
  double get halation =>
      _halation ?? (leak > 0 ? (0.35 + 0.9 * leak).clamp(0.0, 1.0) : 0.0);

  /// Shadow/highlight hue separation, 0..1. Shadows drift toward
  /// [splitShadow], highlights toward [splitHighlight].
  ///
  /// Defaults to a mild always-on amount, because a single warm brown across
  /// the whole tonal range is the thing that makes a grade read as a colour
  /// filter rather than as film. Inverted looks opt out — split-toning a
  /// negative just muddies it.
  double get splitTone => _splitTone ?? (negative ? 0.0 : 0.5);

  FilmEffect copyWith({
    List<double>? matrix,
    double? grain,
    double? vignette,
    double? leak,
    Color? leakColor,
    double? scanlines,
    double? bloom,
    double? blurSigma,
    double? chroma,
    double? distort,
    double? star,
    double? dust,
    StampStyle? stamp,
    double? aspect,
    bool? showRec,
    bool? halfFrame,
    bool? negative,
    double? halation,
    double? splitTone,
  }) {
    return FilmEffect(
      halation: halation ?? _halation,
      splitTone: splitTone ?? _splitTone,
      matrix: matrix ?? this.matrix,
      grain: grain ?? this.grain,
      vignette: vignette ?? this.vignette,
      leak: leak ?? this.leak,
      leakColor: leakColor ?? this.leakColor,
      scanlines: scanlines ?? this.scanlines,
      bloom: bloom ?? this.bloom,
      blurSigma: blurSigma ?? this.blurSigma,
      chroma: chroma ?? this.chroma,
      distort: distort ?? this.distort,
      star: star ?? this.star,
      dust: dust ?? this.dust,
      stamp: stamp ?? this.stamp,
      aspect: aspect ?? this.aspect,
      showRec: showRec ?? this.showRec,
      halfFrame: halfFrame ?? this.halfFrame,
      negative: negative ?? this.negative,
    );
  }

  /// Layers an accessory (ND filter, fisheye, prism, flash, star) on top.
  FilmEffect withAccessory(String id) {
    switch (id) {
      case 'nd':
        return copyWith(matrix: mul(matExposure(-0.55), matrix));
      case 'fisheye_f':
        return copyWith(distort: math.max(distort, 0.55));
      case 'fisheye_w':
        return copyWith(distort: math.max(distort, 0.34));
      case 'prism':
        return copyWith(chroma: math.max(chroma, 3.0), bloom: bloom + 0.18);
      case 'flash_c':
        return copyWith(
          matrix: mul(matExposure(0.28), mul(matContrast(1.12), matrix)),
          vignette: math.max(vignette, 0.42),
        );
      case 'star':
        return copyWith(star: 1.0, bloom: bloom + 0.14);
      default:
        return this;
    }
  }

  static const identityMatrix = <double>[
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  /// Multiplies two 4x5 colour matrices (a applied after b).
  static List<double> mul(List<double> a, List<double> b) {
    final out = List<double>.filled(20, 0);
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 5; c++) {
        var sum = 0.0;
        for (var k = 0; k < 4; k++) {
          sum += a[r * 5 + k] * b[k * 5 + c];
        }
        if (c == 4) sum += a[r * 5 + 4];
        out[r * 5 + c] = sum;
      }
    }
    return out;
  }

  static List<double> matSaturation(double s) {
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final ir = (1 - s) * lr, ig = (1 - s) * lg, ib = (1 - s) * lb;
    return <double>[
      ir + s, ig, ib, 0, 0, //
      ir, ig + s, ib, 0, 0, //
      ir, ig, ib + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }

  /// [c] == 1 is neutral. Pivots around mid grey.
  static List<double> matContrast(double c) {
    final t = (1 - c) * 127.5;
    return <double>[
      c, 0, 0, 0, t, //
      0, c, 0, 0, t, //
      0, 0, c, 0, t, //
      0, 0, 0, 1, 0, //
    ];
  }

  /// Stops of exposure, positive brightens.
  static List<double> matExposure(double stops) {
    final g = math.pow(2, stops).toDouble();
    return <double>[
      g, 0, 0, 0, 0, //
      0, g, 0, 0, 0, //
      0, 0, g, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }

  /// Per-channel gain plus a lift (film base fog) that crushes the blacks up.
  static List<double> matTint(
    double r,
    double g,
    double b, {
    double lift = 0,
    double liftR = 0,
    double liftG = 0,
    double liftB = 0,
  }) {
    return <double>[
      r, 0, 0, 0, lift + liftR, //
      0, g, 0, 0, lift + liftG, //
      0, 0, b, 0, lift + liftB, //
      0, 0, 0, 1, 0, //
    ];
  }

  static List<double> matNegative() => const <double>[
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ];

  static List<double> compose(List<List<double>> steps) {
    var m = identityMatrix;
    for (final s in steps) {
      m = mul(s, m);
    }
    return m;
  }

  // ------------------------------------------------------------- split tone

  /// Where the shadows go. A cool, slightly green black is what a warm stock
  /// actually prints; a warm black is what a colour filter prints.
  static const splitShadow = Color(0xFF1E2A26);

  /// Where the highlights go.
  static const splitHighlight = Color(0xFFF2E4D2);

  /// How hard the shadow tint is pushed relative to the highlight tint. The
  /// shadow colour only carries about 5% chroma, which is invisible at 1:1.
  static const splitLiftGain = 3.0;

  /// Shadows toward [splitShadow], highlights toward [splitHighlight].
  ///
  /// Deliberately a lift/gain pair rather than a hard luma window: the live
  /// painter has no way to threshold on per-pixel luma, and a lift/gain is the
  /// one formulation the viewfinder can reproduce *exactly* rather than
  /// approximately. The shadow tint is a lift, so it fades out as a pixel
  /// brightens; the highlight tint is a gain, so it fades out as a pixel
  /// darkens. Net effect: the two ends of the range end up different hues and
  /// the middle stays where the stock put it.
  static List<double> matSplitTone(double amount) {
    if (amount <= 0) return identityMatrix;
    const s = splitShadow;
    const h = splitHighlight;
    final sMin = math.min(s.r, math.min(s.g, s.b));
    final hMax = math.max(h.r, math.max(h.g, h.b));
    double lift(double c) => (c - sMin) * splitLiftGain * amount;
    double gain(double c) => 1 - (1 - c / hMax) * amount;
    final lr = lift(s.r), lg = lift(s.g), lb = lift(s.b);
    return <double>[
      gain(h.r) - lr, 0, 0, 0, lr * 255, //
      0, gain(h.g) - lg, 0, 0, lg * 255, //
      0, 0, gain(h.b) - lb, 0, lb * 255, //
      0, 0, 0, 1, 0, //
    ];
  }

  // --------------------------------------------------------------- shoulder

  /// The grade is scaled by this before the shoulder runs.
  ///
  /// Two jobs. It stops [ColorFilter.matrix] clipping the sky flat before the
  /// roll-off ever sees it — everything up to 1/[shoulderScale] survives the
  /// matrix — and it moves the knee of the [BlendMode.overlay] curve below,
  /// which is always at 0.5 of whatever reaches it, up to 0.8 of the original
  /// range. That is the top ~20% the shoulder is supposed to act on.
  static const shoulderScale = 0.625;

  /// The constant grey the overlay blend is run against. Above 0.5 it
  /// compresses the top segment and expands the bottom one.
  static const shoulderPivot = 0.625;

  /// Puts the below-knee segment back at unity gain: `1 / (2 * pivot * scale)`.
  static const shoulderRestore = 1.28;

  /// The overlay pivot as a colour, for `ColorFilter.mode`.
  static const shoulderPivotColor = Color.from(
    alpha: 1.0,
    red: shoulderPivot,
    green: shoulderPivot,
    blue: shoulderPivot,
  );

  /// The compressive highlight shoulder, as a curve on an already
  /// [shoulderScale]-scaled 0..1 value.
  ///
  /// This is exactly `BlendMode.overlay` against [shoulderPivotColor] followed
  /// by a [shoulderRestore] gain, which is what the viewfinder paints. Below
  /// 0.8 of the original range it is the identity; above it the slope drops to
  /// 0.6, so 1.0 lands at 0.92 and the frame does not go flat white until
  /// about 1.13. Blown skies keep their structure instead of clipping to one
  /// value.
  static double shoulder(double v) {
    final u = v <= 0.5
        ? 2 * shoulderPivot * v
        : (2 * v - 1) * (1 - shoulderPivot) + shoulderPivot;
    final o = u * shoulderRestore;
    return o < 0.0 ? 0.0 : (o > 1.0 ? 1.0 : o);
  }

  // --------------------------------------------------------------- halation

  /// Luma above which the emulsion starts scattering light back into the
  /// frame.
  static const halationThreshold = 0.85;

  /// The colour that scatter comes back as — the red-sensitive layer sits
  /// deepest, so the halo is orange-red.
  static const halationColor = Color(0xFFFF4A1E);

  /// Peak strength of the halo at `halation == 1`.
  static const halationStrength = 0.18;

  /// Blur radius of the halo, in pixels of a 1080px frame.
  static const halationSigma = 3.0;

  /// Luma above which a star filter throws a flare. Only a genuine specular
  /// highlight gets one — a lit tree branch or a bright wall does not.
  static const starThreshold = 0.92;

  /// Flare length, as a fraction of the frame's short side.
  static const starSigma = 0.055;

  static const starGain = 1.6;

  static const _lumR = 0.2126, _lumG = 0.7152, _lumB = 0.0722;

  /// A [ColorFilter.matrix] payload that turns a frame into "how far each
  /// pixel is above [threshold], painted in [tint] and scaled by [strength]".
  ///
  /// The subtraction happens before the filter's own clamp to 0, which is what
  /// makes this a threshold at all. Both the viewfinder (as the inner half of
  /// an [ImageFilter.compose]) and the bake drive their highlight effects off
  /// this, so the two agree on which pixels are "bright".
  static List<double> matHighlightMask(
    double threshold,
    Color tint,
    double strength,
  ) {
    final k = strength / (1 - threshold);
    final t = threshold * 255;
    List<double> row(double c) => <double>[
      c * k * _lumR,
      c * k * _lumG,
      c * k * _lumB,
      0,
      -c * k * t,
    ];
    return <double>[
      ...row(tint.r),
      ...row(tint.g),
      ...row(tint.b),
      0, 0, 0, 1, 0, //
    ];
  }

  /// Luma of an 8-bit triple, 0..1. Same weights as [matHighlightMask].
  static double luma(num r, num g, num b) =>
      (_lumR * r + _lumG * g + _lumB * b) / 255.0;
}

/// A tileable monochrome noise texture, generated once and reused by every
/// grain overlay so the live preview stays cheap.
class NoiseTexture {
  NoiseTexture._();

  static ui.Image? _image;
  static ui.Image? get image => _image;

  static Future<void> ensure() async {
    if (_image != null) return;
    const size = 192;
    final rnd = math.Random(7);
    final pixels = Uint8List(size * size * 4);
    for (var i = 0; i < size * size; i++) {
      // Slightly gaussian-ish noise so it reads like emulsion, not TV static.
      final v =
          ((rnd.nextDouble() + rnd.nextDouble() + rnd.nextDouble()) / 3 * 255)
              .clamp(0, 255)
              .toInt();
      pixels[i * 4] = v;
      pixels[i * 4 + 1] = v;
      pixels[i * 4 + 2] = v;
      pixels[i * 4 + 3] = 255;
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      size,
      size,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    _image = await completer.future;
  }
}
