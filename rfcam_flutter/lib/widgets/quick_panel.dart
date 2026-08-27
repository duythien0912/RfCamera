import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morphnext/morphnext.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/app_state.dart';
import '../core/camera_catalog.dart';
import '../core/palette.dart';
import '../screens/settings_sheet.dart';
import 'camera_art.dart';

/// The frosted tray that drops out of the "..." button: flash, frame, grid,
/// and the zoom-mode pill.
class QuickPanel extends StatelessWidget {
  const QuickPanel({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(P.rPanel),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          width: 276,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0x8A6B6259),
            borderRadius: BorderRadius.circular(P.rPanel),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleToggle(
                    id: 'qp_flash',
                    icon: state.flashOn
                        ? IconsaxOutline.flash_1
                        : IconsaxOutline.flash_slash,
                    active: state.flashOn,
                    onTap: () => state.setFlash(!state.flashOn),
                  ),
                  _CircleToggle(
                    id: 'qp_frame',
                    icon: state.frameOn
                        ? IconsaxOutline.scan
                        : IconsaxOutline.maximize_21,
                    active: state.frameOn,
                    onTap: () => state.setFrame(!state.frameOn),
                  ),
                  _CircleToggle(
                    id: 'qp_grid',
                    icon: IconsaxOutline.grid_1,
                    active: state.gridOn,
                    onTap: () => state.setGrid(!state.gridOn),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      key: const Key('qp_zoom_mode'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        state.setZoomMode(
                          state.zoomMode == ZoomMode.frame
                              ? ZoomMode.lens
                              : ZoomMode.frame,
                        );
                      },
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0x66FFFFFF,
                          ).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(37),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              IconsaxOutline.maximize_4,
                              color: P.white,
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chế độ zoom',
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.visible,
                                    style: P.t(15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.zoomMode == ZoomMode.frame
                                        ? 'Khung'
                                        : 'Ống kính',
                                    maxLines: 1,
                                    softWrap: false,
                                    style: P.t(15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CircleToggle(
                    id: 'qp_settings',
                    icon: IconsaxOutline.setting_2,
                    active: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      SettingsSheet.show(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleToggle extends StatelessWidget {
  const _CircleToggle({
    required this.id,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String id;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key(id),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          shape: BoxShape.circle,
        ),
        child: AnimatedMorphIcon(icon: icon, color: P.white, size: 30),
      ),
    );
  }
}

/// The small camera illustration on the shutter row that opens the selector.
class CameraBadge extends StatelessWidget {
  const CameraBadge({super.key, required this.profile});

  final CameraProfile profile;

  @override
  Widget build(BuildContext context) {
    return CameraArt(profile: profile, size: 70);
  }
}
