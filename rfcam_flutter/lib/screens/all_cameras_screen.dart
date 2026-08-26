import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/camera_catalog.dart';
import '../core/palette.dart';
import '../widgets/camera_art.dart';

/// The full catalogue sheet: every shooter and every accessory, grouped.
///
/// This build of the app ships everything free, so each tile carries a
/// blue check instead of the original's gating badge, and the banner at the
/// top states that plainly rather than selling anything.
class AllCamerasScreen extends StatelessWidget {
  const AllCamerasScreen({super.key});

  static const _sections = <CamGroup>[
    CamGroup.digital,
    CamGroup.video,
    CamGroup.vintage135,
    CamGroup.instant,
    CamGroup.accessory,
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    final slivers = <Widget>[
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];

    // Room under the last row so the floating close button never covers a card.
    const floor = SliverToBoxAdapter(child: SizedBox(height: 96));

    for (final group in _sections) {
      slivers.add(_SectionTitle(title: Cameras.groupTitles[group]!));
      slivers.add(_CameraGrid(profiles: Cameras.group(group), state: state));
    }

    slivers.add(const SliverToBoxAdapter(child: _LegacyRow()));

    slivers.add(floor);

    return Scaffold(
      backgroundColor: P.black,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(slivers: slivers),
            const Positioned(
              right: 20,
              bottom: 20,
              child: _CloseButton(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- the banner

/// Pinned card that replaces the original upsell strip.
// -------------------------------------------------------------- the sections

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 26, bottom: 14),
        child: Text(
          title,
          style: P.t(17, w: FontWeight.w700, ls: 0.6),
        ),
      ),
    );
  }
}

class _CameraGrid extends StatelessWidget {
  const _CameraGrid({required this.profiles, required this.state});

  final List<CameraProfile> profiles;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _CameraTile(profile: profiles[i], state: state),
          childCount: profiles.length,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ the tile

class _CameraTile extends StatelessWidget {
  const _CameraTile({required this.profile, required this.state});

  final CameraProfile profile;
  final AppState state;

  bool get _selected => profile.isAccessory
      ? state.accessories.contains(profile.id)
      : profile.id == state.camera.id;

  void _onTap(BuildContext context) {
    HapticFeedback.selectionClick();
    if (profile.isAccessory) {
      state.toggleAccessory(profile.id);
      return;
    }
    state.selectCamera(profile);
    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return GestureDetector(
      key: Key('all_${profile.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: P.tile,
          borderRadius: BorderRadius.circular(18),
          border: selected ? Border.all(color: P.blue, width: 1.5) : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CameraArt(profile: profile, size: 62),
                        const SizedBox(height: 8),
                        CameraName(
                          profile: profile,
                          fontSize: 12,
                          pill: selected,
                        ),
                        const SizedBox(height: 8),
                        _CapabilityGlyphs(profile: profile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The little pair of glyphs under the name: stills, plus video or photo-in.
class _CapabilityGlyphs extends StatelessWidget {
  const _CapabilityGlyphs({required this.profile});

  final CameraProfile profile;

  @override
  Widget build(BuildContext context) {
    final color = P.dim.withValues(alpha: 0.55);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(IconsaxOutline.record_circle, size: 15, color: color),
        const SizedBox(width: 10),
        Icon(
          profile.supportsVideo ? IconsaxOutline.video : IconsaxOutline.gallery,
          size: 15,
          color: color,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- the footer

class _LegacyRow extends StatelessWidget {
  const _LegacyRow();

  void _showLegacyInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 290,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E20),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(IconsaxOutline.camera, size: 36, color: P.white),
                const SizedBox(height: 14),
                Text(
                  'Camera Đời Cũ',
                  style: P.t(17, w: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tất cả 5 dòng máy ảnh cổ điển và phụ kiện đặc biệt đã được mở khóa đầy đủ trong danh mục bên trên.',
                  textAlign: TextAlign.center,
                  style: P.t(13, c: P.dim),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: P.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Đã hiểu',
                      style: P.t(14, w: FontWeight.w700, c: P.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        _showLegacyInfo(context);
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 28, bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text('Camera đời cũ', style: P.t(19, w: FontWeight.w400)),
            const Spacer(),
            Text(
              '5',
              style: P.t(19, w: FontWeight.w400, c: P.dim),
            ),
            const SizedBox(width: 6),
            const Icon(IconsaxOutline.arrow_right_3, size: 24, color: P.dim),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).maybePop();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2E),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          IconsaxOutline.close_circle,
          size: 28,
          color: P.white,
        ),
      ),
    );
  }
}
