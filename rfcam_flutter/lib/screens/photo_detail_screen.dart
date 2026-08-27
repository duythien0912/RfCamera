import 'dart:io';
import 'dart:ui' as ui;

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:gal/gal.dart';
import 'package:morphnext/morphnext.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_state.dart';
import '../core/camera_catalog.dart';
import '../core/palette.dart';
import '../core/photo.dart';
import '../core/toast.dart';
import '../widgets/camera_art.dart';

/// Full-screen viewer for the album. Swiping horizontally walks the roll.
class PhotoDetailScreen extends StatefulWidget {
  const PhotoDetailScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  final List<CapturedPhoto> photos;
  final int initialIndex;

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late final PageController _pager;
  bool _chromeVisible = true;

  @override
  void initState() {
    super.initState();
    _pager = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  /// The ids this screen opened with, re-read from [AppState] so a tapped heart
  /// or a delete shows up immediately. Rows that vanished are dropped.
  List<CapturedPhoto> _live(AppState app) {
    final byId = {for (final p in app.photos) p.id: p};
    final out = <CapturedPhoto>[];
    for (final p in widget.photos) {
      final cur = byId[p.id];
      if (cur != null) out.add(cur);
    }
    return out;
  }

  Future<void> _confirmDelete(CapturedPhoto p, int remaining) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (_) => const _DeleteAlert(),
    );
    if (ok != true || !mounted) return;
    await AppScope.read(context).deletePhotos([p.id]);
    if (!mounted) return;
    if (remaining <= 1) Navigator.of(context).pop();
  }

  void _onApplyCamera(CapturedPhoto photo) {
    HapticFeedback.selectionClick();
    final cam = Cameras.tryById(photo.cameraId);
    if (cam != null) {
      AppScope.read(context).selectCamera(cam);
      showAppToast(context, 'Đã áp dụng máy ảnh #${cam.name}');
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onShare(CapturedPhoto photo) async {
    HapticFeedback.selectionClick();
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? (box.localToGlobal(Offset.zero) & box.size)
        : null;
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(photo.path)],
          subject: 'RfCamera #${photo.cameraName}',
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onFire(CapturedPhoto photo) async {
    HapticFeedback.selectionClick();
    await AppScope.read(context).toggleNegative(photo.id);
    if (!mounted) return;
    setState(() {});
    showAppToast(
      context,
      photo.negative
          ? 'Đã chuyển về ảnh dương bản'
          : 'Đã chuyển sang hiệu ứng phim âm bản',
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _onDownload(CapturedPhoto photo) async {
    HapticFeedback.selectionClick();
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          if (!mounted) return;
          showAppToast(
            context,
            'Vui lòng cấp quyền Thư viện ảnh trong Cài đặt để lưu ảnh.',
          );
          return;
        }
      }
      await Gal.putImage(photo.path, album: 'RfCamera');
      if (!mounted) return;
      showAppToast(
        context,
        'Đã lưu ảnh #${photo.cameraName} vào Thư viện của máy',
      );
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Không thể lưu ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final photos = _live(app);

    return DismissiblePage(
      dragSensitivity: 0.9,
      onDismissed: () => Navigator.of(context).pop(),
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: true,
      backgroundColor: P.black,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: photos.isEmpty
            ? const SizedBox.shrink()
            : Stack(
                children: [
                  PageView.builder(
                    key: const Key('detail_pager'),
                    controller: _pager,
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, i) => _Page(
                      photo: photos[i],
                      chromeVisible: _chromeVisible,
                      onTapPhoto: () =>
                          setState(() => _chromeVisible = !_chromeVisible),
                      onApplyCamera: () => _onApplyCamera(photos[i]),
                      onShare: () => _onShare(photos[i]),
                      onFire: () => _onFire(photos[i]),
                      onDownload: () => _onDownload(photos[i]),
                      onFavorite: () =>
                          AppScope.read(context).toggleFavorite(photos[i].id),
                      onDelete: () => _confirmDelete(photos[i], photos.length),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.photo,
    required this.chromeVisible,
    required this.onTapPhoto,
    required this.onApplyCamera,
    required this.onShare,
    required this.onFire,
    required this.onDownload,
    required this.onFavorite,
    required this.onDelete,
  });

  final CapturedPhoto photo;
  final bool chromeVisible;
  final VoidCallback onTapPhoto;
  final VoidCallback onApplyCamera;
  final VoidCallback onShare;
  final VoidCallback onFire;
  final VoidCallback onDownload;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapPhoto,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: photo.negative
                  ? const ColorFilter.matrix(<double>[
                      -1,
                      0,
                      0,
                      0,
                      255,
                      0,
                      -1,
                      0,
                      0,
                      255,
                      0,
                      0,
                      -1,
                      0,
                      255,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ])
                  : const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.dst,
                    ),
              child: Image.file(
                File(photo.path),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            top: 32,
            right: 16,
            child: GestureDetector(
              key: const Key('detail_apply_camera'),
              behavior: HitTestBehavior.opaque,
              onTap: onApplyCamera,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x6618181A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0x33FFFFFF),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (Cameras.tryById(photo.cameraId) != null) ...[
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Center(
                              child: CameraArt(
                                profile: Cameras.tryById(photo.cameraId)!,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          '#${photo.cameraName}',
                          style: P.t(12, w: FontWeight.w600, c: P.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: pad.bottom + 96,
            child: AnimatedOpacity(
              opacity: chromeVisible ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !chromeVisible,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleAction(
                      key: const Key('detail_share'),
                      icon: IconsaxOutline.export,
                      onTap: onShare,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0x6618181A),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: const Color(0x33FFFFFF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PillButton(
                                key: const Key('detail_fire'),
                                icon: photo.negative
                                    ? IconsaxBold.moon
                                    : IconsaxOutline.moon,
                                color: photo.negative ? Colors.orange : P.white,
                                onTap: onFire,
                              ),
                              const SizedBox(width: 16),
                              _PillButton(
                                key: const Key('detail_copy'),
                                icon: IconsaxOutline.gallery_import,
                                onTap: onDownload,
                              ),
                              const SizedBox(width: 16),
                              _PillButton(
                                key: const Key('detail_favorite'),
                                icon: photo.favorite
                                    ? IconsaxBold.heart
                                    : IconsaxOutline.heart,
                                color: photo.favorite ? P.red : P.white,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onFavorite();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _CircleAction(
                      key: const Key('detail_delete'),
                      icon: IconsaxOutline.trash,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onDelete();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stays put while the rest of the chrome fades.
          Positioned(
            right: 24,
            bottom: MediaQuery.paddingOf(context).bottom + 24,
            child: _CloseButton(
              key: const Key('detail_close'),
              background: P.white,
              iconColor: P.black,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x6618181A),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x33FFFFFF), width: 1),
            ),
            child: AnimatedMorphIcon(icon: icon, size: 24, color: P.white),
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 52,
        child: Center(
          child: AnimatedMorphIcon(
            icon: icon,
            size: 24,
            color: color ?? P.white,
          ),
        ),
      ),
    );
  }
}

/// The iOS-style destructive alert the gallery uses, repeated here so the two
/// screens read identically.
class _DeleteAlert extends StatelessWidget {
  const _DeleteAlert();

  static const _card = Color(0xFFE8E8E8);
  static const _rule = Color(0xFFBFBFBF);
  static const _ink = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 270,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                child: Text(
                  'Các mục đã xóa khỏi album RfCamera không thể khôi phục.',
                  textAlign: TextAlign.center,
                  style: P
                      .t(13, w: FontWeight.w500, c: _ink)
                      .copyWith(height: 1.35),
                ),
              ),
              const Divider(height: 0.5, thickness: 0.5, color: _rule),
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: _AlertAction(
                        label: 'Hủy',
                        color: P.dim,
                        weight: FontWeight.w500,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const VerticalDivider(
                      width: 0.5,
                      thickness: 0.5,
                      color: _rule,
                    ),
                    Expanded(
                      child: _AlertAction(
                        label: 'Xóa',
                        color: P.red,
                        weight: FontWeight.w600,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertAction extends StatelessWidget {
  const _AlertAction({
    required this.label,
    required this.color,
    required this.weight,
    required this.onTap,
  });

  final String label;
  final Color color;
  final FontWeight weight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          style: P.t(17, w: weight, c: color),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({
    super.key,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x9918181A),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x4DFFFFFF),
                width: 1.2,
              ),
            ),
            child: const Icon(
              IconsaxOutline.close_circle,
              size: 24,
              color: P.white,
            ),
          ),
        ),
      ),
    );
  }
}
