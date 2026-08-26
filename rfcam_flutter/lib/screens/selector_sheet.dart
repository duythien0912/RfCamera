import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/camera_catalog.dart';
import '../core/palette.dart';
import '../widgets/camera_art.dart';
import '../widgets/film_view.dart';
import 'all_cameras_screen.dart';
import 'sample_photos_screen.dart';

/// The tray that slides up from the shutter row: the sample-photo shortcut,
/// two horizontally scrolling rows of cameras, the accessory strip, and —
/// once a camera is picked — its colour config card, all over a live,
/// already-graded preview of the scene in front of you.
///
/// Every camera and accessory here is unlocked. There is no upsell, no lock
/// badge, and nothing that can be bought.
class SelectorSheet extends StatefulWidget {
  const SelectorSheet({
    super.key,
    required this.onClose,
    required this.background,
  });

  final VoidCallback onClose;

  /// The bare camera preview. The sheet renders it full-bleed behind the
  /// strip, graded with whichever camera is currently highlighted, so tapping
  /// through the list previews each look on your actual scene.
  final WidgetBuilder background;

  @override
  State<SelectorSheet> createState() => _SelectorSheetState();
}

class _SelectorSheetState extends State<SelectorSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  bool _showConfig = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _c.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final strip = Cameras.quickStrip;
    final half = (strip.length / 2).ceil();
    final row1 = strip.sublist(0, half);
    final row2 = strip.sublist(half);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        return Opacity(opacity: t, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FilmView(
              key: ValueKey('bg_${state.camera.id}_${state.variant}'),
              effect: state.effect,
              seed: state.seed,
              showStamp: false,
              showRecBadge: false,
              child: widget.background(context),
            ),
            // Keeps the strip and labels legible over any scene.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x7A000000),
                    Color(0xF2000000),
                  ],
                  stops: [0.0, 0.45, 0.75],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  if (_showConfig)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                      child: ColorConfigCard(
                        state: state,
                        onClose: () => setState(() => _showConfig = false),
                      ),
                    ),
                  _TopActions(
                    onSamples: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SamplePhotosScreen(),
                        ),
                      );
                    },
                    onAll: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<CameraProfile?>(
                          builder: (_) => const AllCamerasScreen(),
                        ),
                      );
                      if (mounted) setState(() => _showConfig = true);
                    },
                  ),
                  const SizedBox(height: 10),
                  _CameraRow(
                    keyPrefix: 'strip1',
                    cameras: row1,
                    state: state,
                    onPick: _pick,
                  ),
                  const _Hairline(),
                  _CameraRow(
                    keyPrefix: 'strip2',
                    cameras: row2,
                    state: state,
                    onPick: _pick,
                  ),
                  const _Hairline(),
                  _AccessoryRow(state: state),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 16),
                      child: GestureDetector(
                        key: const Key('selector_close'),
                        onTap: _close,
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C2C2E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            IconsaxOutline.arrow_down_1,
                            color: P.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pick(CameraProfile p) {
    HapticFeedback.selectionClick();
    AppScope.read(context).selectCamera(p);
    setState(() => _showConfig = true);
  }
}

class _TopActions extends StatelessWidget {
  const _TopActions({required this.onSamples, required this.onAll});

  final VoidCallback onSamples;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            key: const Key('samples_button'),
            behavior: HitTestBehavior.opaque,
            onTap: onSamples,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                children: [
                  const Icon(
                    IconsaxOutline.gallery,
                    color: P.white,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'ẢNH MẪU',
                    style: P.t(12, w: FontWeight.w700, ls: 0.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            key: const Key('all_cameras_button'),
            behavior: HitTestBehavior.opaque,
            onTap: onAll,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconsaxOutline.menu_1,
                color: P.white,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraRow extends StatelessWidget {
  const _CameraRow({
    required this.keyPrefix,
    required this.cameras,
    required this.state,
    required this.onPick,
  });

  final String keyPrefix;
  final List<CameraProfile> cameras;
  final AppState state;
  final void Function(CameraProfile) onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      child: ListView.builder(
        key: Key(keyPrefix),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cameras.length,
        itemBuilder: (context, i) {
          final p = cameras[i];
          final selected = p.id == state.camera.id;
          return GestureDetector(
            key: Key('cam_${p.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onPick(p),
            child: AnimatedScale(
              // The selected camera reads as picked up off the shelf.
              scale: selected ? 1.0 : 0.92,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Opacity(
                opacity: selected ? 1.0 : 0.78,
                child: SizedBox(
                  width: 82,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CameraArt(profile: p, size: 72),
                      const SizedBox(height: 7),
                      CameraName(profile: p, fontSize: 11, pill: true),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccessoryRow extends StatelessWidget {
  const _AccessoryRow({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final items = Cameras.accessories;
    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final a = items[i];
          final on = state.accessories.contains(a.id);
          return GestureDetector(
            key: Key('acc_${a.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              state.toggleAccessory(a.id);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: on ? 1 : 0.72,
                    child: CameraArt(profile: a, size: 40),
                  ),
                  if (on)
                    Positioned(
                      right: -2,
                      top: -2,
                      // IconsaxBold.tick_circle is a solid disc with the tick
                      // punched out, so the circle behind it tints the tick.
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          IconsaxBold.tick_circle,
                          size: 16,
                          color: P.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: P.hairline);
}

/// "Cấu Hình Màu": the variant chips, their explanation, and the aspect-ratio
/// strip. Shown right after a camera is picked, as in the reference flow.
class ColorConfigCard extends StatelessWidget {
  const ColorConfigCard({
    super.key,
    required this.state,
    required this.onClose,
  });

  final AppState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final cam = state.camera;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          key: const Key('color_config'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xF01C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Cấu Hình Màu', style: P.t(15, w: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(
                    key: const Key('config_close'),
                    onTap: onClose,
                    child: const Icon(
                      IconsaxOutline.close_circle,
                      size: 18,
                      color: P.dim,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final v in cam.variants.reversed) ...[
                    _VariantChip(
                      name: v.name,
                      selected: v.name == state.variant,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        state.selectVariant(v.name);
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
              if (cam.variantDesc != null) ...[
                const SizedBox(height: 12),
                Text(cam.variantDesc!, style: P.t(11, c: P.dim)),
              ],
              const SizedBox(height: 16),
              Text('Tỷ Lệ', style: P.t(13, w: FontWeight.w600)),
              const SizedBox(height: 10),
              // Seven ratios do not fit, so the row scrolls — with a fade on
              // the right edge so it reads as scrollable rather than as the
              // end of the list.
              SizedBox(
                height: 46,
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.88, 1.0],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: ListView(
                    key: const Key('ratio_strip'),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 24),
                    children: [
                      for (final r in Cameras.ratios.keys) ...[
                        _RatioChip(
                          label: r,
                          selected: r == state.ratio,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            state.selectRatio(r);
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('variant_${name.replaceAll(' ', '_')}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? P.white : const Color(0xFF3A3A3C),
            width: 1.5,
          ),
        ),
        child: Text(name, style: P.t(13, w: FontWeight.w600)),
      ),
    );
  }
}

class _RatioChip extends StatelessWidget {
  const _RatioChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('ratio_$label'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 62,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3A3A3C) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: P.t(13, w: FontWeight.w600)),
            const SizedBox(width: 3),
            // Stacked right label.
            SizedBox(
              height: 12,
              child: selected
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        IconsaxBold.tick_circle,
                        size: 12,
                        color: P.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
