import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morphnext/morphnext.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/bake.dart';
import '../core/palette.dart';
import '../core/photo.dart';
import '../widgets/quick_panel.dart';
import '../widgets/viewfinder.dart';
import 'gallery_screen.dart';
import 'photo_detail_screen.dart';
import 'selector_sheet.dart';

/// Which tray is showing under the viewfinder card.
enum _Tray { none, focal, exposure }

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _devices = const [];
  bool _cameraReady = false;
  bool _permissionDenied = false;

  _Tray _tray = _Tray.none;
  bool _quickPanel = false;
  bool _selector = false;

  bool _flashing = false;
  bool _capturing = false;
  int? _countdown;

  /// The first half of a double exposure, waiting for its partner.
  Uint8List? _pendingDouble;

  final _frameKey = GlobalKey();
  final _thumbKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fire and forget: the UI is usable before the sensor is.
    unawaited(_initCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (s == AppLifecycleState.inactive) {
      c.dispose();
      _controller = null;
      if (mounted) setState(() => _cameraReady = false);
    } else if (s == AppLifecycleState.resumed) {
      unawaited(_initCamera());
    }
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) setState(() => _permissionDenied = true);
        return;
      }
      if (mounted && _permissionDenied) {
        setState(() => _permissionDenied = false);
      }
      _devices = await availableCameras();
      if (_devices.isEmpty) {
        if (mounted) setState(() => _cameraReady = false);
        return;
      }
      await _openDevice();
    } catch (_) {
      // No camera (simulator, desktop, hardware in use). The mock preview
      // keeps every screen reachable.
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  Future<void> _openDevice() async {
    final state = AppScope.read(context);
    final wanted = state.frontCamera
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final device = _devices.firstWhere(
      (d) => d.lensDirection == wanted,
      orElse: () => _devices.first,
    );
    await _controller?.dispose();
    final c = CameraController(
      device,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = c;
    try {
      await c.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  Widget _rawPreview() {
    final c = _controller;
    if (!_cameraReady || c == null || !c.value.isInitialized) {
      return const MockPreview();
    }
    final size = c.value.previewSize;
    if (size == null) return CameraPreview(c);
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.height,
        height: size.width,
        child: CameraPreview(c),
      ),
    );
  }

  // --- shutter -------------------------------------------------------------

  Future<void> _shoot() async {
    final state = AppScope.read(context);
    if (_capturing) return;

    if (state.timerOn) {
      for (var i = state.timerSeconds; i > 0; i--) {
        if (!mounted) return;
        setState(() => _countdown = i);
        await HapticFeedback.selectionClick();
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      if (!mounted) return;
      setState(() => _countdown = null);
    }

    setState(() => _capturing = true);
    if (state.hapticEnabled) {
      unawaited(HapticFeedback.heavyImpact());
    }
    if (state.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
    setState(() => _flashing = true);
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _flashing = false);
    });

    try {
      var bytes = await _grabFrame();
      if (bytes == null) return;

      // Double exposure: hold the first frame, then blend the second onto it
      // and develop the pair as one shot, the way winding twice would.
      if (state.doubleExposure) {
        if (_pendingDouble == null) {
          setState(() => _pendingDouble = bytes);
          return;
        }
        final first = _pendingDouble!;
        _pendingDouble = null;
        bytes = await compute(_blendFrames, [first, bytes]);
      }

      final cam = state.camera;
      final effect = state.effect;
      final taken = DateTime.now();
      final stamp = '${taken.month} ${taken.day} ${taken.year % 100}';
      final baked = await bakePhoto(
        BakeRequest.from(bytes, effect, state.seed, stamp),
      );

      final dir = await state.albumDir();
      final file = File('${dir.path}/${taken.microsecondsSinceEpoch}.jpg');
      await file.writeAsBytes(baked, flush: true);

      final photo = await state.addPhoto(
        path: file.path,
        cam: cam,
        negative: effect.negative,
        at: taken,
      );
      if (mounted) _flyToThumbnail(photo);
    } catch (_) {
      // A failed frame should never leave the shutter stuck.
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// Real sensor when there is one, otherwise the bundled stand-in so the
  /// whole capture path stays exercisable without hardware.
  Future<Uint8List?> _grabFrame() async {
    final c = _controller;
    if (_cameraReady && c != null && c.value.isInitialized) {
      final shot = await c.takePicture();
      return shot.readAsBytes();
    }
    final data = await rootBundle.load('assets/samples/sample_street.jpg');
    return data.buffer.asUint8List();
  }

  void _flyToThumbnail(CapturedPhoto photo) {
    final fromBox = _frameKey.currentContext?.findRenderObject() as RenderBox?;
    final toBox = _thumbKey.currentContext?.findRenderObject() as RenderBox?;
    if (fromBox == null || toBox == null) return;
    final from = fromBox.localToGlobal(Offset.zero) & fromBox.size;
    final to = toBox.localToGlobal(Offset.zero) & toBox.size;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingShot(
        from: from,
        to: to,
        file: File(photo.path),
        onDone: () => entry.remove(),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  // --- navigation ----------------------------------------------------------

  void _openGallery() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GalleryScreen(
          onBackToCamera: () => Navigator.of(context).maybePop(),
          onOpenPhoto: (photo) {
            final state = AppScope.read(context);
            final all = state.photos;
            final i = all.indexWhere((p) => p.id == photo.id);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PhotoDetailScreen(
                  photos: all,
                  initialIndex: i < 0 ? 0 : i,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    _openGallery();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final media = MediaQuery.of(context);
    final h = media.size.height;
    final w = media.size.width;

    final cardW = w * 0.913;
    final cardH = h * 0.633;
    final cardTop = h * 0.0995;

    return Scaffold(
      backgroundColor: P.black,
      body: Stack(
        children: [
          // Recording indicator dot, as iOS shows while the camera is live.
          Positioned(
            top: media.padding.top + 2,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: P.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          Positioned(
            left: (w - cardW) / 2,
            top: cardTop,
            width: cardW,
            height: cardH,
            child: RepaintBoundary(
              key: _frameKey,
              child: Viewfinder(
                state: state,
                preview: LivePreview(state: state, child: _rawPreview()),
                onTapDots: () => setState(() => _quickPanel = !_quickPanel),
                onTapWhiteBalance: () {
                  HapticFeedback.selectionClick();
                  state.cycleWhiteBalance();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cân bằng trắng: ${state.whiteBalance}'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onTapFocal: () => setState(
                  () => _tray = _tray == _Tray.focal ? _Tray.none : _Tray.focal,
                ),
                onTapExposure: () => setState(
                  () => _tray = _tray == _Tray.exposure
                      ? _Tray.none
                      : _Tray.exposure,
                ),
                focalExpanded: _tray == _Tray.focal,
                exposureExpanded: _tray == _Tray.exposure,
              ),
            ),
          ),

          if (_tray == _Tray.focal)
            Positioned(
              top: cardTop + cardH + h * 0.032,
              left: 0,
              right: 0,
              child: _FocalRow(state: state),
            ),

          if (_tray == _Tray.exposure)
            Positioned(
              top: cardTop + cardH + h * 0.012,
              left: 0,
              right: 0,
              child: _ExposureTray(
                state: state,
                onBack: () => setState(() => _tray = _Tray.none),
              ),
            ),

          if (_tray == _Tray.none)
            Positioned(
              top: h * 0.775,
              left: 0,
              right: 0,
              child: _BottomDock(
                state: state,
                onImport: _pickFromGallery,
                onDouble: state.toggleDoubleExposure,
                onTimer: state.toggleTimer,
                onFlash: () => state.setFlash(!state.flashOn),
                onFlip: () async {
                  state.flipCamera();
                  await _openDevice();
                },
              ),
            ),

          Positioned(
            top: h * 0.845,
            left: 0,
            right: 0,
            child: _ActionRow(
              state: state,
              thumbKey: _thumbKey,
              onThumb: _openGallery,
              onShutter: _shoot,
              onSelector: () => setState(() => _selector = true),
            ),
          ),

          if (_quickPanel)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _quickPanel = false),
                child: Stack(
                  children: [
                    Positioned(
                      top: cardTop + h * 0.055,
                      right: w * 0.06,
                      child: QuickPanel(state: state),
                    ),
                  ],
                ),
              ),
            ),

          if (_pendingDouble != null)
            Positioned(
              top: h * 0.062,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCC2C2C2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Phơi sáng kép · 1/2',
                    style: P.t(11, w: FontWeight.w600),
                  ),
                ),
              ),
            ),

          if (_countdown != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    '$_countdown',
                    style: P.t(96, w: FontWeight.w300),
                  ),
                ),
              ),
            ),

          if (_flashing)
            const Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: Colors.white)),
            ),

          if (_permissionDenied)
            Positioned(
              left: 16,
              right: 16,
              top: media.padding.top + 8,
              child: _PermissionNote(
                onRetry: () async {
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    if (mounted) setState(() => _permissionDenied = false);
                    await _initCamera();
                  } else {
                    await openAppSettings();
                  }
                },
              ),
            ),

          if (_selector)
            Positioned.fill(
              child: SelectorSheet(
                onClose: () => setState(() => _selector = false),
                background: (_) => _rawPreview(),
              ),
            ),
        ],
      ),
    );
  }
}

// --- pieces ----------------------------------------------------------------

class _FocalRow extends StatelessWidget {
  const _FocalRow({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final f in AppState.focalOptions) ...[
          GestureDetector(
            key: Key('focal_$f'),
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              state.setFocal(f);
            },
            child: SizedBox(
              width: 62,
              height: 62,
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: state.focal == f ? P.white : const Color(0xFF2C2C2E),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$f',
                        style: P.t(
                          20,
                          w: FontWeight.w600,
                          c: state.focal == f ? Colors.black : P.white,
                        ),
                      ),
                      if (f == 26)
                        Text(
                          '1x',
                          style: P.t(
                            11,
                            c: state.focal == f ? Colors.black : P.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ExposureTray extends StatelessWidget {
  const _ExposureTray({required this.state, required this.onBack});

  final AppState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // The value label tracks the slider, not the screen: the row to its left
    // (undo + auto) is 56 + 12 + 56 + 14 = 138 wide.
    const trackInset = 18.0 + 138.0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: trackInset, right: 18),
          child: Center(
            child: Text(
              state.ev.toStringAsFixed(1),
              key: const Key('ev_value'),
              style: P.t(20, w: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              _RoundButton(
                onTap: onBack,
                fill: const Color(0xFF2C2C2E),
                child: const Icon(
                  IconsaxOutline.undo,
                  color: P.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                key: const Key('ev_auto'),
                onTap: state.setEvAuto,
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: state.evAuto ? P.white : const Color(0xFF2C2C2E),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'A',
                    style: P.t(
                      22,
                      w: FontWeight.w600,
                      c: state.evAuto ? Colors.black : P.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 30,
                    activeTrackColor: const Color(0xFF3A3A3C),
                    inactiveTrackColor: const Color(0xFF3A3A3C),
                    thumbColor: P.white,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundedRectSliderThumbShape(),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    key: const Key('ev_slider'),
                    min: -3,
                    max: 3,
                    value: state.ev.clamp(-3, 3),
                    onChanged: state.setEv,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The slider in the reference is a flat capsule with a pill thumb.
class RoundedRectSliderThumbShape extends SliderComponentShape {
  const RoundedRectSliderThumbShape();

  @override
  Size getPreferredSize(bool enabled, bool disabled) => const Size(14, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 12, height: 24),
      const Radius.circular(6),
    );
    context.canvas.drawRRect(rect, Paint()..color = P.white);
  }
}

class RoundedRectSliderTrackShape extends SliderTrackShape {
  const RoundedRectSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const h = 30.0;
    return Rect.fromLTWH(
      offset.dx,
      offset.dy + (parentBox.size.height - h) / 2,
      parentBox.size.width,
      h,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(15)),
      Paint()..color = const Color(0xFF3A3A3C),
    );
  }
}

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.state,
    required this.onImport,
    required this.onDouble,
    required this.onTimer,
    required this.onFlash,
    required this.onFlip,
  });

  final AppState state;
  final VoidCallback onImport;
  final VoidCallback onDouble;
  final VoidCallback onTimer;
  final VoidCallback onFlash;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    Widget item(String k, IconData icon, VoidCallback onTap, bool on) {
      return Expanded(
        child: GestureDetector(
          key: Key(k),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            height: 48,
            child: Center(
              child: AnimatedMorphIcon(
                icon: icon,
                size: 26,
                color: on ? P.green : P.white,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          item(
            'dock_import',
            IconsaxOutline.gallery,
            onImport,
            false,
          ),
          item(
            'dock_double',
            IconsaxOutline.copy,
            onDouble,
            state.doubleExposure,
          ),
          item(
            'dock_timer',
            !state.timerOn
                ? IconsaxOutline.timer_1
                : state.timerSeconds == 3
                ? IconsaxOutline.timer_start
                : IconsaxOutline.timer,
            onTimer,
            state.timerOn,
          ),
          item(
            'dock_flash',
            state.flashOn ? IconsaxOutline.flash_1 : IconsaxOutline.flash_slash,
            onFlash,
            state.flashOn,
          ),
          item(
            'dock_flip',
            IconsaxOutline.rotate_left_1,
            onFlip,
            state.frontCamera,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.state,
    required this.thumbKey,
    required this.onThumb,
    required this.onShutter,
    required this.onSelector,
  });

  final AppState state;
  final GlobalKey thumbKey;
  final VoidCallback onThumb;
  final VoidCallback onShutter;
  final VoidCallback onSelector;

  @override
  Widget build(BuildContext context) {
    final latest = state.latest;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            key: const Key('thumbnail'),
            onTap: onThumb,
            child: Container(
              key: thumbKey,
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: latest == null
                  ? null
                  : Image.file(
                      File(latest.path),
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                      errorBuilder: (_, e, s) => const SizedBox.shrink(),
                    ),
            ),
          ),
          GestureDetector(
            key: const Key('shutter'),
            onTap: onShutter,
            child: SizedBox(
              width: 82,
              height: 82,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: P.white, width: 2.5),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: P.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x33FFFFFF), blurRadius: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            key: const Key('open_selector'),
            onTap: onSelector,
            child: SizedBox(
              width: 66,
              height: 66,
              child: Center(
                child: CameraBadge(profile: state.camera),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.child,
    required this.onTap,
    required this.fill,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color fill;
  static const size = 56.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}

class _PermissionNote extends StatelessWidget {
  const _PermissionNote({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('permission_note_banner'),
      onTap: onRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xE61C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33FF9500)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              IconsaxOutline.camera_slash,
              color: Colors.orange,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cần quyền truy cập Camera. Chạm để cấp quyền trong Cài đặt.',
                style: P.t(13, w: FontWeight.w500, c: P.white),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: P.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Mở',
                style: P.t(12, w: FontWeight.w700, c: P.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Averages two exposures. Lighten-biased so highlights from either frame
/// survive, which is what a real double exposure looks like.
Uint8List _blendFrames(List<Uint8List> pair) {
  final a = img.decodeJpg(pair[0]);
  final b = img.decodeJpg(pair[1]);
  if (a == null || b == null) return pair[1];
  final top = (a.width == b.width && a.height == b.height)
      ? b
      : img.copyResize(b, width: a.width, height: a.height);
  for (final p in a) {
    final q = top.getPixel(p.x, p.y);
    p
      ..r = (p.r * 0.5 + q.r * 0.5 + math.max(0, q.r - p.r) * 0.18).clamp(
        0,
        255,
      )
      ..g = (p.g * 0.5 + q.g * 0.5 + math.max(0, q.g - p.g) * 0.18).clamp(
        0,
        255,
      )
      ..b = (p.b * 0.5 + q.b * 0.5 + math.max(0, q.b - p.b) * 0.18).clamp(
        0,
        255,
      );
  }
  return Uint8List.fromList(img.encodeJpg(a, quality: 94));
}

/// The captured frame sliding down into the thumbnail slot.
class _FlyingShot extends StatefulWidget {
  const _FlyingShot({
    required this.from,
    required this.to,
    required this.file,
    required this.onDone,
  });

  final Rect from;
  final Rect to;
  final File file;
  final VoidCallback onDone;

  @override
  State<_FlyingShot> createState() => _FlyingShotState();
}

class _FlyingShotState extends State<_FlyingShot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(_c.value);
        final rect = Rect.lerp(widget.from, widget.to, t)!;
        return Positioned.fromRect(
          rect: rect,
          child: Opacity(
            opacity: 1 - (t * t * 0.35),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16 + (1 - t) * 12),
              child: Image.file(
                widget.file,
                fit: BoxFit.cover,
                cacheWidth: 400,
                errorBuilder: (_, e, s) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
