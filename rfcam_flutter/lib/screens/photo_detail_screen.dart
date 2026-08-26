import 'dart:io';

import 'package:flutter/material.dart';
import 'package:morphnext/morphnext.dart';
import 'package:flutter/services.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/palette.dart';
import '../core/photo.dart';

/// Full-screen viewer for the album. Swiping vertically walks the roll, exactly
/// like the reference app's photo feed.
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

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final photos = _live(app);

    return Scaffold(
      backgroundColor: P.black,
      body: photos.isEmpty
          ? const SizedBox.shrink()
          : Stack(
              children: [
                PageView.builder(
                  key: const Key('detail_pager'),
                  controller: _pager,
                  scrollDirection: Axis.vertical,
                  itemCount: photos.length,
                  itemBuilder: (context, i) => _Page(
                    photo: photos[i],
                    chromeVisible: _chromeVisible,
                    onTapPhoto: () =>
                        setState(() => _chromeVisible = !_chromeVisible),
                    onFavorite: () =>
                        AppScope.read(context).toggleFavorite(photos[i].id),
                    onDelete: () => _confirmDelete(photos[i], photos.length),
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

class _Page extends StatelessWidget {
  const _Page({
    required this.photo,
    required this.chromeVisible,
    required this.onTapPhoto,
    required this.onFavorite,
    required this.onDelete,
  });

  final CapturedPhoto photo;
  final bool chromeVisible;
  final VoidCallback onTapPhoto;
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
            child: Image.file(
              File(photo.path),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          // No stamp overlay here on purpose: the date is burned into the
          // JPEG at capture time, so drawing it again would double it up.
          Positioned(
            top: pad.top + 20,
            right: 20,
            child: Text(
              '#${photo.cameraName}',
              style: P
                  .t(13, w: FontWeight.w600)
                  .copyWith(
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: pad.bottom + 24 + 56 + 18,
            child: AnimatedOpacity(
              opacity: chromeVisible ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !chromeVisible,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ToolIcon(
                      key: const Key('detail_share'),
                      icon: IconsaxOutline.export,
                      onTap: HapticFeedback.selectionClick,
                    ),
                    _ToolIcon(
                      key: const Key('detail_fire'),
                      icon: IconsaxOutline.magicpen,
                      onTap: HapticFeedback.selectionClick,
                    ),
                    _ToolIcon(
                      key: const Key('detail_copy'),
                      icon: IconsaxOutline.copy,
                      onTap: HapticFeedback.selectionClick,
                    ),
                    _ToolIcon(
                      key: const Key('detail_favorite'),
                      icon: photo.favorite
                          ? IconsaxBold.heart
                          : IconsaxOutline.heart,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onFavorite();
                      },
                    ),
                    _ToolIcon(
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
        ],
      ),
    );
  }
}

/// The burned-in LED date, running bottom-to-top up the left edge.

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: AnimatedMorphIcon(
          icon: icon,
          size: 30,
          color: P.white,
          shadows: const [Shadow(color: Colors.black87, blurRadius: 2)],
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
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(IconsaxOutline.close_circle, size: 26, color: iconColor),
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
