import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rfcam_flutter/core/app_state.dart';
import 'package:rfcam_flutter/core/camera_catalog.dart';
import 'package:rfcam_flutter/core/film_effect.dart';
import 'package:rfcam_flutter/main.dart';
import 'package:rfcam_flutter/widgets/film_view.dart';

/// A screen-recordable walkthrough of the app's main flows.
///
/// Unlike `app_flow_test.dart` this is not asserting behaviour — it exists so
/// a camera can be pointed at it. Every step is paced for a human watching,
/// and one flow runs per invocation:
///
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/demo_flows_test.dart \
///     --dart-define=FLOW=3 -d `device`
const flow = int.fromEnvironment('FLOW', defaultValue: 0);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppState state;

  /// Real time passes on the device, so the recording has something to show.
  Future<void> beat(WidgetTester tester, [int ms = 900]) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 32));
    }
  }

  Future<void> pumpApp(WidgetTester tester, {bool wipe = true}) async {
    // Motion stays ON here: the grain crawl is part of what we are showing.
    // Nothing in this file uses pumpAndSettle, so it cannot hang on it.
    FilmView.motionEnabled = true;
    await NoiseTexture.ensure();
    await FilmView.warmUp();
    state = AppState();
    await state.load();
    if (wipe) {
      await state.deletePhotos(state.photos.map((p) => p.id).toList());
    }
    await tester.pumpWidget(RfCamApp(state: state));
    await beat(tester, 1800);
  }

  Future<void> tap(WidgetTester tester, String key, [int settle = 900]) async {
    final f = find.byKey(Key(key));
    if (f.evaluate().isEmpty) return;
    await tester.tap(f, warnIfMissed: false);
    await beat(tester, settle);
  }

  Future<void> shoot(WidgetTester tester) async {
    final before = state.photos.length;
    await tester.tap(find.byKey(const Key('shutter')), warnIfMissed: false);
    for (var i = 0; i < 80 && state.photos.length == before; i++) {
      await beat(tester, 120);
    }
    await beat(tester, 1400);
  }

  /// Flings a camera strip until [id] is actually built, since the strips are
  /// lazy and a tap on an unbuilt tile silently does nothing.
  Future<void> revealCam(WidgetTester tester, String id, String strip) async {
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('cam_$id')).evaluate().isNotEmpty) return;
      final s = find.byKey(Key(strip));
      if (s.evaluate().isEmpty) return;
      await tester.fling(s, const Offset(-430, 0), 950);
      await beat(tester, 650);
    }
  }

  Future<void> swipe(WidgetTester tester, String key, Offset by) async {
    final f = find.byKey(Key(key));
    if (f.evaluate().isEmpty) return;
    await tester.fling(f, by, 900);
    await beat(tester, 1100);
  }

  void demo(int n, String name, Future<void> Function(WidgetTester) body) {
    testWidgets(
      '$n $name',
      body,
      skip: flow != 0 && flow != n,
    );
  }

  demo(1, 'launch and shoot', (tester) async {
    await pumpApp(tester);
    await beat(tester, 1600);
    await shoot(tester);
    await beat(tester, 1200);
    await shoot(tester);
    await beat(tester, 1600);
  });

  demo(2, 'camera selector', (tester) async {
    await pumpApp(tester, wipe: false);
    await tap(tester, 'open_selector', 1400);
    // Each tap re-grades the full-bleed preview behind the strip.
    for (final id in ['vhs', 'eightmm', 'v_classic', 'glow']) {
      await tap(tester, 'cam_$id', 1500);
    }
    await swipe(tester, 'strip1', const Offset(-460, 0));
    await tap(tester, 'cam_dcr', 1500);
    await swipe(tester, 'strip2', const Offset(-460, 0));
    await beat(tester, 900);
    await tap(tester, 'selector_close', 1400);
  });

  demo(3, 'colour config and ratios', (tester) async {
    await pumpApp(tester, wipe: false);
    await tap(tester, 'open_selector', 1200);
    await revealCam(tester, 'grd_r', 'strip1');
    await tap(tester, 'cam_grd_r', 1500);
    await beat(tester, 1000);
    // Two variants of the same camera, side by side.
    await tap(tester, 'variant_GRD_Pos', 1600);
    await tap(tester, 'variant_GRD', 1600);
    for (final r in ['1:1', '16:9', '4:3']) {
      final f = find.byKey(Key('ratio_$r'));
      final strip = find.descendant(
        of: find.byKey(const Key('ratio_strip')),
        matching: find.byType(Scrollable),
      );
      if (f.evaluate().isEmpty && strip.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          f,
          120,
          scrollable: strip,
          maxScrolls: 20,
        );
        await beat(tester, 500);
      }
      await tap(tester, 'ratio_$r', 1400);
    }
    await tap(tester, 'selector_close', 1200);
  });

  demo(4, 'framing controls', (tester) async {
    await pumpApp(tester, wipe: false);
    await beat(tester, 1000);
    await tap(tester, 'vf_focal', 1200);
    for (final f in ['26', '50', '35']) {
      await tap(tester, 'focal_$f', 1500);
    }
    await tap(tester, 'vf_focal', 1000);

    await tap(tester, 'vf_ev', 1200);
    await tester.drag(find.byKey(const Key('ev_slider')), const Offset(70, 0));
    await beat(tester, 1200);
    await tester.drag(
      find.byKey(const Key('ev_slider')),
      const Offset(-130, 0),
    );
    await beat(tester, 1200);
    await tap(tester, 'ev_auto', 1300);
    await tap(tester, 'vf_ev', 1000);

    await tap(tester, 'vf_dots', 1200);
    await tap(tester, 'qp_flash', 1100);
    await tap(tester, 'qp_grid', 1100);
    await tap(tester, 'qp_frame', 1100);
    await tap(tester, 'qp_frame', 1100);
    await tap(tester, 'qp_grid', 1100);
    await beat(tester, 1200);
  });

  demo(5, 'gallery and folders', (tester) async {
    await pumpApp(tester);
    await shoot(tester);
    await tap(tester, 'open_selector', 900);
    await tap(tester, 'cam_vhs', 1100);
    await tap(tester, 'selector_close', 900);
    await shoot(tester);
    await tap(tester, 'thumbnail', 1500);
    await tap(tester, 'folder_dropdown', 1500);
    await beat(tester, 1200);
    await tap(tester, 'folder_vhs', 1500);
    await tap(tester, 'folder_dropdown', 1200);
    await tap(tester, 'folder_all', 1500);
    await beat(tester, 1000);
  });

  demo(6, 'photo detail and favourite', (tester) async {
    await pumpApp(tester);
    await shoot(tester);
    await shoot(tester);
    await tap(tester, 'thumbnail', 1400);
    final first = state.photos.first;
    await tap(tester, 'tile_${first.id}', 1600);
    await beat(tester, 1200);
    await tap(tester, 'detail_favorite', 1500);
    await swipe(tester, 'detail_pager', const Offset(0, -420));
    await beat(tester, 1200);
    await tap(tester, 'detail_close', 1400);
    await tap(tester, 'folder_dropdown', 1400);
    await beat(tester, 1400);
  });

  demo(7, 'multi-select delete', (tester) async {
    await pumpApp(tester);
    await shoot(tester);
    await shoot(tester);
    await shoot(tester);
    await tap(tester, 'thumbnail', 1400);
    await tap(tester, 'gallery_select_toggle', 1200);
    for (final p in state.photos) {
      await tap(tester, 'tile_${p.id}', 800);
    }
    await beat(tester, 1000);
    await tap(tester, 'sel_delete', 1600);
    await beat(tester, 1800);
    await tester.tap(find.text('Xóa'), warnIfMissed: false);
    await beat(tester, 2000);
  });

  demo(8, 'samples and full catalogue', (tester) async {
    await pumpApp(tester, wipe: false);
    await tap(tester, 'open_selector', 1200);
    await tap(tester, 'samples_button', 1800);
    for (var i = 0; i < 3; i++) {
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, -520),
        900,
      );
      await beat(tester, 1100);
    }
    await beat(tester, 800);
    await tester.tap(find.byIcon(Icons.close).last, warnIfMissed: false);
    await beat(tester, 1400);

    await tap(tester, 'all_cameras_button', 1800);
    for (var i = 0; i < 4; i++) {
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, -560),
        900,
      );
      await beat(tester, 1000);
    }
    await beat(tester, 1400);
  });

  demo(9, 'every camera, one after another', (tester) async {
    await pumpApp(tester, wipe: false);
    await tap(tester, 'open_selector', 1000);
    // Walk the strip so the recording shows each look on the same scene.
    final strip = Cameras.quickStrip;
    for (var i = 0; i < strip.length; i++) {
      final f = find.byKey(Key('cam_${strip[i].id}'));
      if (f.evaluate().isEmpty) continue;
      await tester.tap(f, warnIfMissed: false);
      await beat(tester, 700);
      if (i % 5 == 4) {
        await swipe(
          tester,
          i < strip.length / 2 ? 'strip1' : 'strip2',
          const Offset(-420, 0),
        );
      }
    }
    await beat(tester, 1200);
  });
}
