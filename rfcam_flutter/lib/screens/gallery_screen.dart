import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morphnext/morphnext.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/palette.dart';
import '../core/photo.dart';
import 'settings_sheet.dart';

/// The album. Folder dropdown, 3-up grid of captures, and a multi-select mode
/// with share / negative / delete actions along the bottom.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, this.onOpenPhoto, this.onBackToCamera});

  /// Tapping a tile outside select mode.
  final void Function(CapturedPhoto photo)? onOpenPhoto;

  /// The big pale shutter button at the bottom-left.
  final VoidCallback? onBackToCamera;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const _barH = 56.0;
  static const _btn = Color(0xFF1F1F1F);
  static const _fab = Color(0xFFD9D9D9);
  static const _actionBg = Color(0xFF1A1A1A);

  String _folderId = 'all';
  bool _selectMode = false;
  bool _dropdownOpen = false;
  final Set<String> _selected = <String>{};

  /// Null until the check comes back; the gallery itself needs no permission,
  /// but if the camera is blocked then "back to camera" leads nowhere useful,
  /// so the empty state says so instead of inviting a dead end.
  bool? _cameraAllowed;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.camera.status;
      if (mounted) setState(() => _cameraAllowed = status.isGranted);
    } catch (_) {
      if (mounted) setState(() => _cameraAllowed = true);
    }
  }

  void _setSelectMode(bool on) {
    setState(() {
      _selectMode = on;
      if (!on) _selected.clear();
    });
  }

  void _pickFolder(GalleryFolder f) {
    setState(() {
      if (_folderId != f.id) _selected.clear();
      _folderId = f.id;
      _dropdownOpen = false;
    });
  }

  void _tapTile(CapturedPhoto photo) {
    if (!_selectMode) {
      widget.onOpenPhoto?.call(photo);
      return;
    }
    setState(() {
      if (!_selected.remove(photo.id)) _selected.add(photo.id);
    });
  }

  /// Resolves the visible folder, falling back to "all" when the chosen one
  /// has emptied out (a camera folder only exists while it holds photos).
  GalleryFolder _current(List<GalleryFolder> folders) {
    for (final f in folders) {
      if (f.id == _folderId) return f;
    }
    return folders.first;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final folders = state.folders;
    final folder = _current(folders);
    final photos = state.photosIn(folder);

    return Scaffold(
      backgroundColor: P.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _topBar(folder),
                Expanded(child: _grid(state, folder, photos)),
              ],
            ),
            // The reference keeps the shutter button visible in select mode
            // too — it just rides above the action bar.
            Positioned(
              left: 16,
              bottom: _selectMode ? 132 : 40,
              child: _cameraFab(),
            ),
            if (_selectMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: _actionBar(state),
              ),
            if (_dropdownOpen) ..._dropdown(folders),
          ],
        ),
      ),
    );
  }

  // --- top bar ---------------------------------------------------------------

  Widget _topBar(GalleryFolder folder) {
    return SizedBox(
      height: _barH,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _round(
              key: const Key('gallery_settings'),
              icon: IconsaxOutline.setting_2,
              onTap: () {
                HapticFeedback.selectionClick();
                SettingsSheet.show(context);
              },
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  key: const Key('folder_dropdown'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
                  child: Container(
                    height: _barH,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: _btn,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            folder.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: P.t(19, w: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          IconsaxOutline.arrow_down_1,
                          size: 26,
                          color: P.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _round(
              key: const Key('gallery_select_toggle'),
              icon: _selectMode
                  ? IconsaxOutline.close_circle
                  : IconsaxOutline.tick_square,
              onTap: () => _setSelectMode(!_selectMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _round({
    required IconData icon,
    required VoidCallback onTap,
    Key? key,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: _barH,
        height: _barH,
        decoration: const BoxDecoration(color: _btn, shape: BoxShape.circle),
        child: AnimatedMorphIcon(icon: icon, size: 26, color: P.white),
      ),
    );
  }

  // --- folder dropdown -------------------------------------------------------

  List<Widget> _dropdown(List<GalleryFolder> folders) {
    final width = MediaQuery.sizeOf(context).width * 0.78;
    return [
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _dropdownOpen = false),
          child: const SizedBox.expand(),
        ),
      ),
      Positioned(
        top: _barH + 4,
        left: 16,
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(P.rCard),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: P.sheet.withValues(alpha: 0.92),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final f in folders) _folderRow(f),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _folderRow(GalleryFolder f) {
    return GestureDetector(
      key: Key('folder_${f.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _pickFolder(f),
      child: SizedBox(
        height: 66,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(_folderIcon(f.kind), size: 26, color: P.white),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  f.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: P.t(18, w: FontWeight.w400),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${f.count}',
                style: P.t(18, w: FontWeight.w400, c: P.dim),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _folderIcon(FolderKind kind) {
    switch (kind) {
      case FolderKind.all:
        return IconsaxOutline.grid_2;
      case FolderKind.favorite:
        return IconsaxOutline.heart;
      case FolderKind.negative:
        return IconsaxOutline.video_horizontal;
      case FolderKind.camera:
        return IconsaxOutline.camera;
    }
  }

  // --- grid ------------------------------------------------------------------

  Widget _grid(AppState state, GalleryFolder folder, List<CapturedPhoto> p) {
    if (!state.ready) return const _GalleryPlaceholder.loading();
    if (p.isEmpty) {
      if (_cameraAllowed == false) {
        return _GalleryPlaceholder.permission(
          onOpenSettings: () => openAppSettings(),
        );
      }
      if (folder.kind != FolderKind.all || state.photos.isEmpty) {
        return _GalleryPlaceholder.empty(
          folder: folder,
          allEmpty: state.photos.isEmpty,
          onShoot: widget.onBackToCamera,
        );
      }
    }
    return _photoGrid(p);
  }

  Widget _photoGrid(List<CapturedPhoto> photos) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 200),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) => _tile(photos[i]),
    );
  }

  Widget _tile(CapturedPhoto photo) {
    final selected = _selected.contains(photo.id);
    return GestureDetector(
      key: Key('tile_${photo.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _tapTile(photo),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(photo.path),
            fit: BoxFit.cover,
            cacheWidth: 400,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const ColoredBox(color: P.tile),
          ),
          if (photo.favorite)
            const Positioned(
              left: 8,
              bottom: 8,
              child: Icon(IconsaxBold.heart, size: 20, color: P.white),
            )
          else
            Positioned(
              left: 6,
              bottom: 8,
              child: Opacity(
                opacity: 0.9,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    photo.stampText,
                    style: P.t(9, w: FontWeight.w700, c: P.stampRed, ls: 1),
                  ),
                ),
              ),
            ),
          if (_selectMode)
            Positioned(
              right: 6,
              top: 6,
              // Iconsax has no bare checkmark: IconsaxBold.tick_circle is a
              // solid disc with the tick punched out of it, so the fill behind
              // the icon is what colours the tick.
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? P.black : Colors.transparent,
                  border: Border.all(color: P.white, width: 2),
                ),
                child: selected
                    ? const Icon(
                        IconsaxBold.tick_circle,
                        size: 22,
                        color: P.white,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  // --- bottom ----------------------------------------------------------------

  Widget _cameraFab() {
    return GestureDetector(
      key: const Key('gallery_back_to_camera'),
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onBackToCamera?.call(),
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(color: _fab, shape: BoxShape.circle),
        child: const Icon(
          IconsaxOutline.camera,
          size: 28,
          color: P.black,
        ),
      ),
    );
  }

  Widget _actionBar(AppState state) {
    final any = _selected.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Đã chọn ${_selected.length}',
          style: P.t(
            17,
            w: FontWeight.w500,
            c: _selected.isEmpty ? P.dim : P.white,
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _action(
                IconsaxOutline.export,
                any,
                () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã sẵn sàng chia sẻ ${_selected.length} ảnh',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                key: const Key('sel_share'),
              ),
              _action(
                IconsaxOutline.video_horizontal,
                any,
                () async {
                  HapticFeedback.selectionClick();
                  await state.batchToggleNegative(_selected);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã chuyển đổi hiệu ứng cho ${_selected.length} ảnh',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                key: const Key('sel_film'),
              ),
              _action(
                IconsaxOutline.trash,
                any,
                () => _confirmDelete(state),
                key: const Key('sel_delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _action(
    IconData icon,
    bool enabled,
    VoidCallback onTap, {
    Key? key,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: _actionBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: P.white),
        ),
      ),
    );
  }

  // --- delete confirmation ---------------------------------------------------

  Future<void> _confirmDelete(AppState state) async {
    if (_selected.isEmpty) return;
    const line = Color(0x4D3C3C43);
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 270,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8).withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                  child: Text(
                    'Các mục đã xóa khỏi album RfCamera không thể khôi phục.',
                    textAlign: TextAlign.center,
                    style: P.t(
                      13,
                      w: FontWeight.w400,
                      c: const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: line),
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: _dialogButton(
                          'Hủy',
                          const Color(0xFF3A3A3C),
                          FontWeight.w400,
                          () => Navigator.of(ctx).pop(false),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: line,
                      ),
                      Expanded(
                        child: _dialogButton(
                          'Xóa',
                          P.red,
                          FontWeight.w600,
                          () => Navigator.of(ctx).pop(true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok != true) return;
    final ids = _selected.toList();
    await state.deletePhotos(ids);
    if (!mounted) return;
    _setSelectMode(false);
  }

  Widget _dialogButton(
    String label,
    Color color,
    FontWeight weight,
    VoidCallback onTap,
  ) {
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

/// Everything the grid shows when it has no photos to show: still loading,
/// nothing shot yet, an empty folder, or the camera blocked at the OS level.
class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder.loading()
    : _kind = _PlaceholderKind.loading,
      folder = null,
      allEmpty = false,
      onShoot = null,
      onOpenSettings = null;

  const _GalleryPlaceholder.empty({
    required this.folder,
    required this.allEmpty,
    required this.onShoot,
  }) : _kind = _PlaceholderKind.empty,
       onOpenSettings = null;

  const _GalleryPlaceholder.permission({required this.onOpenSettings})
    : _kind = _PlaceholderKind.permission,
      folder = null,
      allEmpty = true,
      onShoot = null;

  final _PlaceholderKind _kind;
  final GalleryFolder? folder;
  final bool allEmpty;
  final VoidCallback? onShoot;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    if (_kind == _PlaceholderKind.loading) {
      return const Center(
        key: Key('gallery_loading'),
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2, color: P.dim),
        ),
      );
    }

    final permission = _kind == _PlaceholderKind.permission;
    final String title;
    final String body;
    if (permission) {
      title = 'Chưa có quyền Camera';
      body = 'Dazz cần quyền Camera để chụp. Mở Cài đặt để cấp quyền.';
    } else if (allEmpty) {
      title = 'Chưa có ảnh nào';
      body = 'Những tấm bạn chụp sẽ xuất hiện ở đây.';
    } else {
      title = 'Mục này chưa có ảnh';
      body = 'Chụp bằng ${folder?.label ?? 'máy này'} để lấp đầy nó.';
    }

    return Center(
      key: Key(permission ? 'gallery_permission' : 'gallery_empty'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              permission ? IconsaxOutline.lock : IconsaxOutline.camera,
              size: 44,
              color: P.dim.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 18),
            Text(title, style: P.t(17, w: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: P.t(13, c: P.dim),
            ),
            if (permission || (allEmpty && onShoot != null)) ...[
              const SizedBox(height: 22),
              GestureDetector(
                key: const Key('gallery_empty_action'),
                behavior: HitTestBehavior.opaque,
                onTap: permission ? onOpenSettings : onShoot,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: P.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    permission ? 'Mở Cài đặt' : 'Chụp tấm đầu tiên',
                    style: P.t(14, w: FontWeight.w700, c: Colors.black),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _PlaceholderKind { loading, empty, permission }
