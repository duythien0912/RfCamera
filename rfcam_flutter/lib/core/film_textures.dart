import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// How a plate is composited over the frame.
///
/// The plates were authored two different ways in the original bundle: the
/// emulsion grain sits around mid grey (mean 128) and wants `overlay`, while
/// the VHS plates are near black with bright dropouts and want `plus`. Getting
/// this wrong turns a VHS frame almost solid black, so it travels with the
/// plate rather than being assumed by the caller.
enum PlateBlend { overlay, plus }

/// One texture on disk, plus the numbers needed to composite it consistently.
@immutable
class FilmPlate {
  const FilmPlate(
    this.id,
    this.asset, {
    this.blend = PlateBlend.overlay,
    this.gain = 1.0,
  });

  final String id;
  final String asset;
  final PlateBlend blend;

  /// Amplitude normaliser. The curated plates range from std 2.2 (the CCD
  /// plate) to std 11.2 (S Classic); [gain] pulls them all onto a common
  /// footing so `FilmEffect.grain` alone decides how loud the grain is and the
  /// plate only decides what it looks like. Measured off the shipped files.
  final double gain;
}

/// A plate that has finished loading: the decoded handle for the live overlay
/// and the original bytes for the bake isolate, which cannot touch [ui.Image].
@immutable
class LoadedPlate {
  const LoadedPlate(this.spec, this.image, this.bytes);

  final FilmPlate spec;
  final ui.Image image;
  final Uint8List bytes;

  String get id => spec.id;
  PlateBlend get blend => spec.blend;
  double get gain => spec.gain;
}

/// One window of the dust plate, dropped somewhere on the frame.
///
/// Every field is a fraction of the frame or of the plate, so the painter and
/// the bake place the identical speck in the identical spot whatever pixel
/// size they happen to be working at.
@immutable
class DustPatch {
  const DustPatch({
    required this.cx,
    required this.cy,
    required this.size,
    required this.srcX,
    required this.srcY,
    required this.srcSize,
    required this.alpha,
    required this.dark,
  });

  /// Patch centre, 0..1 of the frame.
  final double cx;
  final double cy;

  /// Patch edge, as a fraction of the frame's long edge.
  final double size;

  /// Top-left of the source window, 0..1 of the room left over in the plate.
  final double srcX;
  final double srcY;

  /// Source window edge, as a fraction of the plate's short edge.
  final double srcSize;

  /// 0.30..0.70 — real specks vary wildly in density.
  final double alpha;

  /// A dark speck (printed through) rather than a light one (scanned over).
  final bool dark;
}

/// The real film plates lifted from the original app bundle, decoded once and
/// held for the life of the process.
///
/// Every consumer goes through here, so the live viewfinder
/// ([FilmOverlayPainter]) and the saved JPEG ([bakePhoto]) always pick the same
/// plate and scale it by the same alpha.
class FilmTextures {
  FilmTextures._();

  /// Sentinel plate id meaning "cycle the VHS plates" rather than naming a
  /// single grain plate.
  static const vhsSetId = 'vhs';

  /// Fine -> coarse. [grainPlate] walks this by `FilmEffect.grain`, so the
  /// order is load bearing. Gains normalise each plate to an effective std of
  /// about 9 levels at full strength.
  static const grainPlates = <FilmPlate>[
    FilmPlate('grain_01_ccd', 'assets/film/grain_01_ccd.jpg', gain: 2.50),
    FilmPlate('grain_02_slide', 'assets/film/grain_02_slide.jpg', gain: 2.50),
    FilmPlate('grain_03_s67', 'assets/film/grain_03_s67.jpg', gain: 1.93),
    FilmPlate('grain_04_8mm', 'assets/film/grain_04_8mm.jpg', gain: 1.84),
    FilmPlate('grain_05_super8', 'assets/film/grain_05_super8.jpg', gain: 1.70),
    FilmPlate('grain_06_16mm', 'assets/film/grain_06_16mm.jpg', gain: 1.41),
    FilmPlate(
      'grain_07_instant',
      'assets/film/grain_07_instant.jpg',
      gain: 1.29,
    ),
    FilmPlate(
      'grain_08_classic',
      'assets/film/grain_08_classic.jpg',
      gain: 0.80,
    ),
  ];

  /// Upper bound of `FilmEffect.grain` for each entry of [grainPlates]. The
  /// catalog spans 0.12 to 0.62, so the ladder is spread over that, not 0..1.
  static const _grainSteps = <double>[0.17, 0.23, 0.29, 0.34, 0.40, 0.46, 0.55];

  /// Near-black tape noise with occasional bright dropouts; composited with
  /// `plus`. Cycled per frame so the tape hiss actually moves.
  static const vhsPlates = <FilmPlate>[
    FilmPlate('vhs_01', 'assets/film/vhs_01.jpg', blend: PlateBlend.plus),
    FilmPlate('vhs_02', 'assets/film/vhs_02.jpg', blend: PlateBlend.plus),
    FilmPlate('vhs_03', 'assets/film/vhs_03.jpg', blend: PlateBlend.plus),
    FilmPlate('vhs_04', 'assets/film/vhs_04.jpg', blend: PlateBlend.plus),
  ];

  static const leakPlates = <FilmPlate>[
    FilmPlate(
      'leak_01_edge',
      'assets/film/leak_01_edge.jpg',
      blend: PlateBlend.plus,
    ),
    FilmPlate(
      'leak_02_streak',
      'assets/film/leak_02_streak.jpg',
      blend: PlateBlend.plus,
    ),
    FilmPlate(
      'leak_03_wash',
      'assets/film/leak_03_wash.jpg',
      blend: PlateBlend.plus,
    ),
    FilmPlate(
      'leak_04_band',
      'assets/film/leak_04_band.jpg',
      blend: PlateBlend.plus,
    ),
    FilmPlate(
      'leak_05_rise',
      'assets/film/leak_05_rise.jpg',
      blend: PlateBlend.plus,
    ),
    FilmPlate(
      'leak_06_fog',
      'assets/film/leak_06_fog.jpg',
      blend: PlateBlend.plus,
    ),
  ];

  static const dustPlates = <FilmPlate>[
    FilmPlate('dust_01', 'assets/film/dust_01.png', blend: PlateBlend.plus),
    FilmPlate('dust_02', 'assets/film/dust_02.png', blend: PlateBlend.plus),
    FilmPlate('dust_03', 'assets/film/dust_03.png', blend: PlateBlend.plus),
    FilmPlate('dust_04', 'assets/film/dust_04.png', blend: PlateBlend.plus),
  ];

  static const vignettePlate = FilmPlate(
    'vignette_01',
    'assets/film/vignette_01.jpg',
  );

  static final Map<String, LoadedPlate> _loaded = <String, LoadedPlate>{};
  static Future<void>? _warming;
  static bool _ready = false;

  /// True once [warmUp] has finished and at least one plate decoded. Callers
  /// use it to decide whether to bother asking for a plate at all; every
  /// accessor is null safe regardless.
  static bool get ready => _ready;

  /// Bumped once the plates are decoded. Anything already on screen listens to
  /// this so it can repaint with the real film grain the moment it arrives,
  /// instead of the first frame having to wait for it.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Decodes every plate once. Safe to call repeatedly and from several places
  /// at once — later calls join the first one.
  ///
  /// A plate that fails to load is skipped rather than thrown: the painter
  /// falls back to the procedural noise, which is far better than a camera
  /// that will not open.
  static Future<void> warmUp() {
    return _warming ??= _load();
  }

  static Future<void> _load() async {
    final specs = <FilmPlate>[
      ...grainPlates,
      ...vhsPlates,
      ...leakPlates,
      ...dustPlates,
      vignettePlate,
    ];
    await Future.wait(specs.map(_loadOne));
    _ready = _loaded.isNotEmpty;
    revision.value++;
  }

  static Future<void> _loadOne(FilmPlate spec) async {
    if (_loaded.containsKey(spec.id)) return;
    try {
      final data = await rootBundle.load(spec.asset);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      _loaded[spec.id] = LoadedPlate(spec, frame.image, bytes);
    } catch (e) {
      debugPrint('FilmTextures: could not load ${spec.asset}: $e');
    }
  }

  // ------------------------------------------------------------------ lookup

  /// The grain plate for [strength], or the one named by [prefer] when a
  /// camera asks for a specific look. Returns null until [warmUp] completes.
  static LoadedPlate? grainPlate(double strength, {String? prefer}) {
    if (prefer != null && prefer != vhsSetId) {
      final named = _loaded[prefer];
      if (named != null) return named;
    }
    var i = 0;
    while (i < _grainSteps.length && strength >= _grainSteps[i]) {
      i++;
    }
    return _loaded[grainPlates[i].id];
  }

  /// Cycles the VHS plates so the tape noise changes every frame.
  static LoadedPlate? vhsPlate(int frame) =>
      _loaded[vhsPlates[frame.abs() % vhsPlates.length].id];

  static LoadedPlate? leakPlate(int seed, {String? prefer}) {
    if (prefer != null) {
      final named = _loaded[prefer];
      if (named != null && named.id.startsWith('leak_')) return named;
    }
    return _loaded[leakPlates[seed.abs() % leakPlates.length].id];
  }

  static LoadedPlate? dustPlate(int seed) =>
      _loaded[dustPlates[seed.abs() % dustPlates.length].id];

  static LoadedPlate? plateById(String id) => _loaded[id];

  // ----------------------------------------------------- required image API

  static ui.Image? grain(double strength, {String? prefer}) =>
      grainPlate(strength, prefer: prefer)?.image;

  static ui.Image? vhsGrain(int frame) => vhsPlate(frame)?.image;

  static ui.Image? leak(int seed, {String? prefer}) =>
      leakPlate(seed, prefer: prefer)?.image;

  static ui.Image? dust(int seed) => dustPlate(seed)?.image;

  static ui.Image? vignette() => _loaded[vignettePlate.id]?.image;

  // ------------------------------------------------------------- raw bytes
  // The bake runs in a `compute` isolate, where a ui.Image cannot travel but a
  // Uint8List can. These hand out the undecoded file so the isolate can decode
  // it with the `image` package instead.

  static Uint8List? grainBytes(double strength, {String? prefer}) =>
      grainPlate(strength, prefer: prefer)?.bytes;

  static Uint8List? vhsBytes(int frame) => vhsPlate(frame)?.bytes;

  static Uint8List? leakBytes(int seed, {String? prefer}) =>
      leakPlate(seed, prefer: prefer)?.bytes;

  static Uint8List? dustBytes(int seed) => dustPlate(seed)?.bytes;

  // ------------------------------------------------- shared strength maths
  // Both the painter and the bake call these, which is the only reason the
  // saved JPEG matches what the viewfinder showed.

  /// Opacity for a grain plate at [g], accounting for the plate's own
  /// amplitude. Tuned so an overlay plate lands near the same standard
  /// deviation the old procedural grain produced (`46 * g` uniform noise).
  static double grainAlpha(double g, LoadedPlate plate) {
    if (plate.blend == PlateBlend.plus) {
      return (0.35 + 0.65 * g).clamp(0.0, 1.0);
    }
    return ((0.12 + 0.78 * g) * plate.gain).clamp(0.0, 1.0);
  }

  static double leakAlpha(double leak) => (0.90 * leak).clamp(0.0, 1.0);

  static double dustAlpha(double dust) => (0.18 + 0.52 * dust).clamp(0.0, 1.0);

  /// Frame size the dust plates are scaled against, in pixels of the frame's
  /// long edge.
  ///
  /// Dust is tiled at this scale rather than stretched to cover. Two of the
  /// four plates are only 250x500, and stretching those over a 2048px frame
  /// turned every hair into a fat white arc across the sky. Tiling keeps the
  /// specks the size they were scanned at whatever the frame is.
  static const dustReferenceEdge = 1080.0;

  /// Weights that collapse a leak plate to a single brightness before it is
  /// re-tinted. Deliberately not luminance: the source plates are almost pure
  /// red, and true luminance weights (0.21/0.72/0.07) would throw most of that
  /// away and leave the leak invisible once tinted to another hue.
  static const leakWeightR = 0.60;
  static const leakWeightG = 0.45;
  static const leakWeightB = 0.25;

  /// Where the dust actually goes.
  ///
  /// The plate used to be tiled across the whole frame at a fixed reference
  /// scale, which on a 2048px frame meant four tiles and twenty-odd identical
  /// hairs at identical opacity — nothing like a real strip of 35mm, which
  /// carries none most of the time and two or three clustered specks when it
  /// has been handled. So: 0..3 windows of the plate, clustered, each at its
  /// own random opacity, and about as often dark as light. A speck that
  /// blocked the enlarger prints dark; one that sat on the negative during the
  /// scan prints light.
  static List<DustPatch> dustPatches(int seed, double dust) {
    if (dust <= 0) return const <DustPatch>[];
    final rnd = math.Random(seed * 7 + 13);
    final n = (3.2 * dust).round().clamp(0, 3);
    if (n == 0) return const <DustPatch>[];
    // One cluster per frame; the specks scatter a little around it.
    final clusterX = 0.16 + rnd.nextDouble() * 0.68;
    final clusterY = 0.16 + rnd.nextDouble() * 0.68;
    return <DustPatch>[
      for (var i = 0; i < n; i++)
        DustPatch(
          cx: (clusterX + (rnd.nextDouble() - 0.5) * 0.30).clamp(0.05, 0.95),
          cy: (clusterY + (rnd.nextDouble() - 0.5) * 0.30).clamp(0.05, 0.95),
          size: 0.09 + rnd.nextDouble() * 0.15,
          srcX: rnd.nextDouble(),
          srcY: rnd.nextDouble(),
          srcSize: 0.16 + rnd.nextDouble() * 0.22,
          alpha: 0.30 + rnd.nextDouble() * 0.40,
          dark: rnd.nextDouble() < 0.45,
        ),
    ];
  }

  /// A [ColorFilter.matrix] payload that reads the plate's brightness and
  /// paints it in [color]. Lets one red plate serve a warm, magenta or green
  /// leak without shipping a plate per hue.
  static List<double> leakTint(ui.Color color) {
    final cr = color.r, cg = color.g, cb = color.b;
    const wr = leakWeightR, wg = leakWeightG, wb = leakWeightB;
    return <double>[
      wr * cr, wg * cr, wb * cr, 0, 0, //
      wr * cg, wg * cg, wb * cg, 0, 0, //
      wr * cb, wg * cb, wb * cb, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }
}
