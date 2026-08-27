import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/palette.dart';
import '../core/toast.dart';

/// The app settings modal sheet: camera permissions, shutter sound,
/// haptic feedback, reset camera settings, and app info.
class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet>
    with WidgetsBindingObserver {
  PermissionStatus? _cameraStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.camera.status;
      if (mounted) setState(() => _cameraStatus = status);
    } catch (_) {
      if (mounted) setState(() => _cameraStatus = PermissionStatus.granted);
    }
  }

  Future<void> _requestOrOpenSettings() async {
    HapticFeedback.selectionClick();
    if (_cameraStatus?.isGranted == true) {
      await openAppSettings();
    } else {
      final res = await Permission.camera.request();
      if (!res.isGranted) {
        await openAppSettings();
      }
      _checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pad = MediaQuery.paddingOf(context);
    final isGranted = _cameraStatus?.isGranted ?? false;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141416),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, pad.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x4DFFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cài Đặt', style: P.t(22, w: FontWeight.w700)),
                  GestureDetector(
                    key: const Key('settings_close'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        IconsaxOutline.close_circle,
                        size: 20,
                        color: P.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Permission Section
              _sectionHeader('QUYỀN TRUY CẬP'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isGranted
                        ? const Color(0x3332D74B)
                        : const Color(0x33FF9500),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isGranted
                            ? P.green.withValues(alpha: 0.15)
                            : Colors.orange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isGranted
                            ? IconsaxOutline.camera
                            : IconsaxOutline.camera_slash,
                        color: isGranted ? P.green : Colors.orange,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quyền Máy Ảnh',
                            style: P.t(16, w: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isGranted
                                ? 'Đã cho phép truy cập'
                                : 'Chưa cấp quyền truy cập',
                            style: P.t(
                              13,
                              c: isGranted ? P.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      key: const Key('btn_request_permission'),
                      onTap: _requestOrOpenSettings,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isGranted ? const Color(0xFF2C2C2E) : P.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isGranted ? 'Cài đặt' : 'Cấp quyền',
                          style: P.t(
                            13,
                            w: FontWeight.w700,
                            c: isGranted ? P.white : P.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Shooting options
              _sectionHeader('CÀI ĐẶT CHỤP'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _toggleRow(
                      title: 'Âm thanh màn trập',
                      value: state.soundEnabled,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        state.setSound(v);
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFF2C2C2E)),
                    _toggleRow(
                      title: 'Rung phản hồi (Haptics)',
                      value: state.hapticEnabled,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        state.setHaptic(v);
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFF2C2C2E)),
                    _toggleRow(
                      title: 'Lật ảnh camera trước',
                      value: state.mirrorFrontCamera,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        state.setMirrorFrontCamera(v);
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFF2C2C2E)),
                    ListTile(
                      key: const Key('settings_reset'),
                      title: Text(
                        'Đặt lại thông số chụp',
                        style: P.t(15, w: FontWeight.w500, c: P.stampRed),
                      ),
                      trailing: const Icon(
                        IconsaxOutline.refresh,
                        size: 20,
                        color: P.stampRed,
                      ),
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        state.resetSettings();
                        showAppToast(
                          context,
                          'Đã khôi phục cài đặt chụp mặc định',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About Section
              _sectionHeader('THÔNG TIN ỨNG DỤNG'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'RfCamera',
                          style: P.t(16, w: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'v1.0.0',
                            style: P.t(11, w: FontWeight.w600, c: P.dim),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Máy ảnh phim cổ điển hoạt động hoàn toàn Offline, không thu thập dữ liệu, mở khóa sẵn toàn bộ máy ảnh và phụ kiện.',
                      style: P.t(13, c: P.dim),
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

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: P.t(12, w: FontWeight.w700, c: P.dim, ls: 0.8),
      ),
    );
  }

  Widget _toggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: P.t(15, w: FontWeight.w500)),
          Switch.adaptive(
            value: value,
            activeThumbColor: P.white,
            activeTrackColor: P.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
