import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morphnext/morphnext.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/bake.dart';
import '../core/palette.dart';
import '../core/photo.dart';
import '../core/toast.dart';
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
  bool _processingImport = false;
  int? _countdown;
  Uint8List? _frozenFrame;

  /// The first half of a double exposure, waiting for its partner.
  Uint8List? _pendingDouble;

  final _frameKey = GlobalKey();
  final _thumbKey = GlobalKey();

  // Focus & exposure reticle state
  Offset? _focusPos;
  bool _focusVisible = false;
  double _focusScale = 1.0;
  double _focusOpacity = 0.0;
  Timer? _focusHideTimer;
  Timer? _focusAnimTimer;

  // Zoom state
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 5.0;
  bool _showZoomBadge = false;
  Timer? _zoomBadgeTimer;
  bool _isPinching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initCamera());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    final c = _controller;
    if (_cameraReady && c != null && c.value.isInitialized) {
      try {
        c.setFlashMode(state.flashOn ? FlashMode.always : FlashMode.off);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusHideTimer?.cancel();
    _focusAnimTimer?.cancel();
    _zoomBadgeTimer?.cancel();
    final c = _controller;
    _controller = null;
    c?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.inactive || s == AppLifecycleState.paused) {
      final c = _controller;
      _controller = null;
      if (mounted) setState(() => _cameraReady = false);
      c?.dispose();
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
    final old = _controller;
    _controller = null;
    if (mounted) setState(() => _cameraReady = false);
    await old?.dispose();

    final c = CameraController(
      device,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      _controller = c;
      try {
        _minZoom = await c.getMinZoomLevel();
        final maxZ = await c.getMaxZoomLevel();
        _maxZoom = math.min(maxZ, 8.0);
      } catch (_) {
        _minZoom = 1.0;
        _maxZoom = 5.0;
      }
      _currentZoom = 1.0;

      if (state.flashOn) {
        try {
          await c.setFlashMode(FlashMode.always);
        } catch (_) {}
      } else {
        try {
          await c.setFlashMode(FlashMode.off);
        } catch (_) {}
      }

      if (!state.evAuto && state.ev != 0.0) {
        unawaited(_updateCameraExposure(state.ev));
      }

      setState(() => _cameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  Future<void> _updateCameraExposure(double ev) async {
    final c = _controller;
    if (_cameraReady && c != null && c.value.isInitialized) {
      try {
        final minOffset = await c.getMinExposureOffset();
        final maxOffset = await c.getMaxExposureOffset();
        final step = await c.getExposureOffsetStepSize();
        final clamped = ev.clamp(minOffset, maxOffset);
        final adjusted = step > 0 ? (clamped / step).round() * step : clamped;
        await c.setExposureOffset(adjusted);
      } catch (_) {}
    }
  }

  Future<void> _setZoom(double zoom) async {
    final state = AppScope.read(context);
    final clamped = state.zoomMode == ZoomMode.frame
        ? zoom.clamp(1.0, 3.5)
        : zoom.clamp(_minZoom, _maxZoom);
    setState(() {
      _currentZoom = clamped;
      _showZoomBadge = true;
    });
    _zoomBadgeTimer?.cancel();
    _zoomBadgeTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showZoomBadge = false);
    });
    final c = _controller;
    if (_cameraReady && c != null && c.value.isInitialized) {
      try {
        if (state.zoomMode == ZoomMode.frame) {
          await c.setZoomLevel(1.0);
        } else {
          await c.setZoomLevel(clamped);
        }
      } catch (_) {}
    }
  }

  void _handleTapFocus(Offset localPos, Size size) {
    HapticFeedback.selectionClick();
    final clampedX = localPos.dx.clamp(42.0, size.width - 76.0);
    final clampedY = localPos.dy.clamp(
      size.height * 0.14 + 56.0,
      size.height * 0.85 - 56.0,
    );
    final clampedPos = Offset(clampedX, clampedY);

    final normX = (localPos.dx / size.width).clamp(0.0, 1.0);
    final normY = (localPos.dy / size.height).clamp(0.0, 1.0);
    final normPoint = Offset(normX, normY);

    final c = _controller;
    if (_cameraReady && c != null && c.value.isInitialized) {
      try {
        c.setFocusPoint(normPoint);
        c.setFocusMode(FocusMode.auto);
        c.setExposurePoint(normPoint);
        c.setExposureMode(ExposureMode.auto);
      } catch (_) {}
    }

    _focusHideTimer?.cancel();
    _focusAnimTimer?.cancel();
    setState(() {
      _focusPos = clampedPos;
      _focusVisible = true;
      _focusOpacity = 1.0;
      _focusScale = 1.25;
    });

    _focusAnimTimer = Timer(const Duration(milliseconds: 20), () {
      if (mounted) setState(() => _focusScale = 1.0);
    });

    _focusHideTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _focusOpacity = 0.0);
    });
  }

  void _handleDoubleTapZoom() {
    HapticFeedback.selectionClick();
    final target = _currentZoom > 1.2 ? 1.0 : math.min(2.0, _maxZoom);
    _setZoom(target);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _isPinching = details.pointerCount >= 2;
    _baseZoom = _currentZoom;
    _focusHideTimer?.cancel();
    if (_focusVisible) {
      setState(() => _focusOpacity = 1.0);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final state = AppScope.read(context);
    if (details.pointerCount >= 2 ||
        _isPinching ||
        (details.scale - 1.0).abs() > 0.04) {
      _isPinching = true;
      _setZoom(_baseZoom * details.scale);
    } else if (_focusVisible && details.focalPointDelta.dy.abs() > 0.1) {
      final deltaEv = -details.focalPointDelta.dy / 40.0;
      final newEv = (state.ev + deltaEv).clamp(-3.0, 3.0);
      state.setEv(newEv);
      _updateCameraExposure(newEv);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _isPinching = false;
    if (_focusVisible) {
      _focusHideTimer?.cancel();
      _focusHideTimer = Timer(const Duration(milliseconds: 3500), () {
        if (mounted) setState(() => _focusOpacity = 0.0);
      });
    }
    if (_showZoomBadge) {
      _zoomBadgeTimer?.cancel();
      _zoomBadgeTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _showZoomBadge = false);
      });
    }
  }

  Widget _rawPreview() {
    if (_frozenFrame != null) {
      final state = AppScope.read(context);
      final mirror = state.frontCamera && state.mirrorFrontCamera;
      Widget imgWidget = Image.memory(
        _frozenFrame!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
      if (mirror) {
        imgWidget = Transform.flip(flipX: true, child: imgWidget);
      }
      return imgWidget;
    }
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
    if (state.flashOn) {
      if (state.frontCamera) {
        setState(() => _flashing = true);
        Timer(const Duration(milliseconds: 120), () {
          if (mounted) setState(() => _flashing = false);
        });
      } else {
        try {
          await _controller?.setFlashMode(FlashMode.always);
        } catch (_) {}
      }
    }

    try {
      try {
        await _controller?.pausePreview();
      } catch (_) {}

      var bytes = await _grabFrame();
      if (bytes == null) return;
      if (mounted) {
        setState(() => _frozenFrame = bytes);
      }

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
        BakeRequest.from(
          bytes,
          effect,
          state.seed,
          stamp,
          flipHorizontal: state.frontCamera && state.mirrorFrontCamera,
          cropZoom: state.zoomMode == ZoomMode.frame ? _currentZoom : 1.0,
        ),
      );

      final dir = await state.albumDir();
      final file = File('${dir.path}/${taken.microsecondsSinceEpoch}.jpg');
      await file.writeAsBytes(baked, flush: true);
      unawaited(_saveToSystemGallery(file.path));

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
      if (mounted) {
        setState(() {
          _capturing = false;
          _frozenFrame = null;
        });
      }
      try {
        await _controller?.resumePreview();
      } catch (_) {}
    }
  }

  /// Real sensor when there is one, otherwise a solid camera frame stand-in.
  Future<Uint8List?> _grabFrame() async {
    final c = _controller;
    if (_cameraReady && c != null && c.value.isInitialized) {
      final shot = await c.takePicture();
      return shot.readAsBytes();
    }
    final image = img.Image(width: 1080, height: 1440);
    img.fill(image, color: img.ColorRgb8(22, 22, 24));
    return Uint8List.fromList(img.encodeJpg(image));
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
    context.pushTransparentRoute(
      GalleryScreen(
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
    );
  }

  Future<void> _pickFromGallery() async {
    await HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    setState(() => _processingImport = true);
    try {
      await _controller?.pausePreview();
    } catch (_) {}

    try {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      final state = AppScope.read(context);
      final cam = state.camera;
      final effect = state.effect;
      final taken = DateTime.now();
      final stamp = '${taken.month} ${taken.day} ${taken.year % 100}';

      final baked = await bakePhoto(
        BakeRequest.from(
          bytes,
          effect,
          state.seed,
          stamp,
          cropZoom: state.zoomMode == ZoomMode.frame ? _currentZoom : 1.0,
        ),
      );

      final dir = await state.albumDir();
      final file = File('${dir.path}/${taken.microsecondsSinceEpoch}.jpg');
      await file.writeAsBytes(baked, flush: true);
      unawaited(_saveToSystemGallery(file.path));

      await state.addPhoto(
        path: file.path,
        cam: cam,
        negative: effect.negative,
        at: taken,
      );

      if (!mounted) return;
      _openGallery();
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Không thể xử lý ảnh: $e');
      }
    } finally {
      try {
        await _controller?.resumePreview();
      } catch (_) {}
      if (mounted) {
        setState(() => _processingImport = false);
      }
    }
  }

  Future<void> _saveToSystemGallery(String filePath) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) return;
      }
      await Gal.putImage(filePath, album: 'RfCamera');
    } catch (_) {}
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
                focusPos: _focusPos,
                focusVisible: _focusVisible,
                focusScale: _focusScale,
                focusOpacity: _focusOpacity,
                zoomLevel: _currentZoom,
                zoomBadgeVisible: _showZoomBadge,
                onTapFocus: _handleTapFocus,
                onDoubleTapZoom: _handleDoubleTapZoom,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                onTapDots: () => setState(() => _quickPanel = !_quickPanel),
                onTapWhiteBalance: () {
                  HapticFeedback.selectionClick();
                  state.cycleWhiteBalance();
                  showAppToast(
                    context,
                    'Cân bằng trắng: ${state.whiteBalance}',
                    duration: const Duration(seconds: 1),
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
                onChanged: (v) {
                  state.setEv(v);
                  _updateCameraExposure(v);
                },
                onAuto: () {
                  state.setEvAuto();
                  _updateCameraExposure(0.0);
                },
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
                onFlash: () async {
                  state.setFlash(!state.flashOn);
                  final c = _controller;
                  if (c != null && c.value.isInitialized) {
                    try {
                      await c.setFlashMode(
                        state.flashOn ? FlashMode.always : FlashMode.off,
                      );
                    } catch (_) {}
                  }
                },
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
            Positioned(
              left: (w - cardW) / 2,
              top: cardTop,
              width: cardW,
              height: cardH,
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

          if (_processingImport)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: const Color(0x66000000),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xB31C1C1E),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0x26FFFFFF),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CupertinoActivityIndicator(
                                radius: 14,
                                color: P.white,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Đang xử lý ảnh...',
                                style: P.t(
                                  14,
                                  w: FontWeight.w600,
                                  c: P.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
  const _ExposureTray({
    required this.state,
    required this.onBack,
    this.onChanged,
    this.onAuto,
  });

  final AppState state;
  final VoidCallback onBack;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onAuto;

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
                onTap: () {
                  if (onAuto != null) {
                    onAuto!();
                  } else {
                    state.setEvAuto();
                  }
                },
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
                    onChanged: (v) {
                      if (onChanged != null) {
                        onChanged!(v);
                      } else {
                        state.setEv(v);
                      }
                    },
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
  final a = img.decodeImage(pair[0]);
  final b = img.decodeImage(pair[1]);
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
