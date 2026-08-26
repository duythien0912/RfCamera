import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rfcam_flutter/core/app_state.dart';
import 'package:rfcam_flutter/core/camera_catalog.dart';
import 'package:rfcam_flutter/core/film_effect.dart';
import 'package:rfcam_flutter/main.dart';
import 'package:rfcam_flutter/widgets/film_view.dart';

/// End-to-end checks over the eight flows the app is specified against.
///
/// These run on a real device, against the real camera, the real filesystem
/// and real preferences — the only thing stubbed is the grain animation, which
/// otherwise never lets `pumpAndSettle` finish.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppState state;

  // convertFlutterSurfaceToImage throws if called twice for the same surface,
  // but the surface is rebuilt per test — so convert once *per test*, reset in
  // pumpApp.
  var surfaceConverted = false;

  /// Writes a PNG into `screenshots/` when run through `flutter drive`;
  /// a no-op under a plain `flutter test`, so the suite works either way.
  Future<void> shot(WidgetTester tester, String name) async {
    try {
      if (!surfaceConverted) {
        await binding.convertFlutterSurfaceToImage();
        surfaceConverted = true;
      }
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    } catch (_) {
      // No driver attached — skip silently rather than fail the flow check.
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    surfaceConverted = false;
    FilmView.motionEnabled = false;
    await NoiseTexture.ensure();
    await FilmView.warmUp();
    state = AppState();
    await state.load();
    // Start every run from an empty album so counts are deterministic.
    await state.deletePhotos(state.photos.map((p) => p.id).toList());
    await tester.pumpWidget(RfCameraApp(state: state));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Brings a chip in one of the horizontally scrolling strips into view.
  Future<void> reveal(WidgetTester tester, String key, String strip) async {
    await tester.scrollUntilVisible(
      find.byKey(Key(key)),
      120,
      scrollable: find.descendant(
        of: find.byKey(Key(strip)),
        matching: find.byType(Scrollable),
      ),
      maxScrolls: 30,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget, reason: 'expected a widget keyed "$key"');
    await tester.tap(finder, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Shoots one frame and waits for the bake to land on disk.
  Future<void> shoot(WidgetTester tester) async {
    final before = state.photos.length;
    await tester.tap(find.byKey(const Key('shutter')), warnIfMissed: false);
    for (var i = 0; i < 60 && state.photos.length == before; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // A silent no-op here would make every later assertion lie.
    expect(
      state.photos.length,
      before + 1,
      reason: 'the shutter did not produce a photo',
    );
  }

  group('flow 1 — open and shoot', () {
    testWidgets('launches straight into the camera, with no account gate', (
      tester,
    ) async {
      await pumpApp(tester);

      await shot(tester, '01-camera');
      expect(find.byKey(const Key('shutter')), findsOneWidget);
      expect(find.byKey(const Key('open_selector')), findsOneWidget);
      expect(find.byKey(const Key('thumbnail')), findsOneWidget);

      // Nothing anywhere may ask the user to identify themselves.
      for (final word in [
        'Sign in',
        'Đăng nhập',
        'Log in',
        'Email',
        'Password',
        'Mật khẩu',
        'Tài khoản',
      ]) {
        expect(find.text(word), findsNothing, reason: '"$word" must not exist');
      }
    });

    testWidgets('the whole catalogue is unlocked', (tester) async {
      await pumpApp(tester);

      expect(Cameras.shooters.length, greaterThanOrEqualTo(20));
      expect(Cameras.accessories.length, 6);

      await tap(tester, 'open_selector');
      await shot(tester, '02-selector');
      // No paywall copy of any kind survives in the selector.
      expect(find.textContaining('Pro'), findsNothing);
      expect(find.textContaining('Mở khóa'), findsNothing);
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });
  });

  group('flow 2 — camera selector and colour config', () {
    testWidgets('picking a camera swaps the look and opens Cấu Hình Màu', (
      tester,
    ) async {
      await pumpApp(tester);
      final before = state.effect;

      await tap(tester, 'open_selector');
      await tap(tester, 'cam_vhs');

      expect(state.camera.id, 'vhs');
      expect(state.effect.matrix, isNot(equals(before.matrix)));
      expect(state.effect.scanlines, greaterThan(0));
      await tap(tester, 'config_toggle_button');
      await shot(tester, '03-color-config');
      expect(find.byKey(const Key('color_config')), findsOneWidget);
      expect(find.text('Cấu Hình Màu'), findsOneWidget);
    });

    testWidgets('variants and aspect ratios apply', (tester) async {
      await pumpApp(tester);
      await tap(tester, 'open_selector');
      await tap(tester, 'cam_eightmm');
      await tap(tester, 'config_toggle_button');

      // Every camera exposes the full ratio strip.
      await tap(tester, 'ratio_1:1');
      expect(state.ratio, '1:1');
      expect(state.ratioValue, 1.0);

      await reveal(tester, 'ratio_16:9', 'ratio_strip');
      await tap(tester, 'ratio_16:9');
      expect(state.ratio, '16:9');
    });

    testWidgets('FXN carries both variants and the comparison blurb', (
      tester,
    ) async {
      final fxn = Cameras.byId('fxn');
      expect(fxn.variants.map((v) => v.name), ['FXN', 'FXN 2']);
      expect(fxn.variantDesc, contains('FXN2'));
      // FXN 2 is the softer of the pair.
      final one = fxn.effectOf('FXN');
      final two = fxn.effectOf('FXN 2');
      expect(two.grain, lessThan(one.grain));
      expect(two.leak, lessThan(one.leak));
    });

    testWidgets('accessories layer on top of the selected camera', (
      tester,
    ) async {
      await pumpApp(tester);
      await tap(tester, 'open_selector');

      await tap(tester, 'acc_fisheye_f');
      expect(state.accessories, contains('fisheye_f'));
      expect(state.effect.distort, greaterThan(0));

      await tap(tester, 'acc_star');
      expect(state.effect.star, greaterThan(0));

      await tap(tester, 'acc_fisheye_f');
      expect(state.accessories, isNot(contains('fisheye_f')));
    });
  });

  group('flow 3 — framing controls', () {
    testWidgets('the focal tray crops the frame', (tester) async {
      await pumpApp(tester);

      await tap(tester, 'vf_focal');
      await shot(tester, '04-focal-tray');
      expect(find.byKey(const Key('focal_26')), findsOneWidget);
      expect(find.byKey(const Key('focal_35')), findsOneWidget);
      expect(find.byKey(const Key('focal_50')), findsOneWidget);

      await tap(tester, 'focal_50');
      expect(state.focal, 50);

      await tap(tester, 'focal_26');
      expect(state.focal, 26);
    });

    testWidgets('the exposure tray exposes a slider and an auto button', (
      tester,
    ) async {
      await pumpApp(tester);

      await tap(tester, 'vf_ev');
      await shot(tester, '05-exposure-tray');
      expect(find.byKey(const Key('ev_value')), findsOneWidget);
      expect(find.byKey(const Key('ev_slider')), findsOneWidget);
      expect(find.byKey(const Key('ev_auto')), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('ev_slider')),
        const Offset(60, 0),
      );
      await tester.pumpAndSettle();
      expect(state.evAuto, isFalse);
      expect(state.ev, isNot(0.0));

      await tap(tester, 'ev_auto');
      expect(state.evAuto, isTrue);
      expect(state.ev, 0.0);
    });

    testWidgets('the quick panel toggles flash, frame and grid', (
      tester,
    ) async {
      await pumpApp(tester);
      final frame = state.frameOn;
      final grid = state.gridOn;

      await tap(tester, 'vf_dots');
      await shot(tester, '06-quick-panel');
      await tap(tester, 'qp_flash');
      expect(state.flashOn, isTrue);

      await tap(tester, 'qp_frame');
      expect(state.frameOn, !frame);

      await tap(tester, 'qp_grid');
      expect(state.gridOn, !grid);
    });
  });

  group('flow 4 — shooting', () {
    testWidgets('the shutter bakes a file and updates the album', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(state.photos, isEmpty);

      await shoot(tester);

      expect(state.photos, hasLength(1));
      final shot = state.photos.first;
      expect(File(shot.path).existsSync(), isTrue);
      expect(File(shot.path).lengthSync(), greaterThan(1000));
      expect(shot.cameraId, state.camera.id);

      // The viewfinder frames portrait, so the file must be portrait too —
      // this shipped backwards once and every shot came out landscape.
      final decoded = await decodeImageFromList(
        await File(shot.path).readAsBytes(),
      );
      expect(
        decoded.height,
        greaterThan(decoded.width),
        reason: 'saved frame must match the portrait crop that was framed',
      );
      final ratio = decoded.height / decoded.width;
      expect(ratio, closeTo(state.ratioValue, 0.06));
      // The stamp is what the gallery and the burned-in date both read from.
      expect(shot.stampText.split(' '), hasLength(3));
    });

    testWidgets('each shot is filed under the camera that took it', (
      tester,
    ) async {
      await pumpApp(tester);

      await tap(tester, 'open_selector');
      await tap(tester, 'cam_glow');
      await tap(tester, 'selector_close');
      await shoot(tester);

      expect(state.photos.first.cameraId, 'glow');
      final folders = state.folders.map((f) => f.id);
      expect(folders, contains('glow'));
    });
  });

  group('flow 5 — gallery, folders and favourites', () {
    testWidgets('the folder sheet lists every bucket with live counts', (
      tester,
    ) async {
      await pumpApp(tester);
      await shoot(tester);

      await tap(tester, 'thumbnail');
      await tap(tester, 'folder_dropdown');
      await shot(tester, '08-folder-menu');

      expect(find.text('Tất cả ảnh'), findsWidgets);
      expect(find.text('Yêu thích'), findsOneWidget);
      expect(find.text('Phim âm bản'), findsOneWidget);

      final all = state.folders.firstWhere((f) => f.id == 'all');
      final fav = state.folders.firstWhere((f) => f.id == 'fav');
      expect(all.count, 1);
      expect(fav.count, 0);
    });

    testWidgets('favouriting moves a shot into Yêu thích', (tester) async {
      await pumpApp(tester);
      await shoot(tester);
      final id = state.photos.first.id;

      await tap(tester, 'thumbnail');
      await shot(tester, '07-gallery');
      await tap(tester, 'tile_$id');
      await shot(tester, '09-photo-detail');
      await tap(tester, 'detail_favorite');

      expect(state.photos.first.favorite, isTrue);
      expect(state.folders.firstWhere((f) => f.id == 'fav').count, 1);

      await tap(tester, 'detail_favorite');
      expect(state.photos.first.favorite, isFalse);
    });

    testWidgets('switching folders filters the grid', (tester) async {
      await pumpApp(tester);
      await shoot(tester);
      await state.toggleFavorite(state.photos.first.id);
      await tester.pumpAndSettle();

      await tap(tester, 'thumbnail');
      await tap(tester, 'folder_dropdown');
      await tap(tester, 'folder_fav');

      final fav = state.folders.firstWhere((f) => f.id == 'fav');
      expect(state.photosIn(fav), hasLength(1));

      await tap(tester, 'folder_dropdown');
      await tap(tester, 'folder_neg');
      final neg = state.folders.firstWhere((f) => f.id == 'neg');
      expect(state.photosIn(neg), isEmpty);
    });
  });

  group('flow 6 — multi-select delete', () {
    testWidgets('selecting and confirming removes the shots and their files', (
      tester,
    ) async {
      await pumpApp(tester);
      await shoot(tester);
      await shoot(tester);
      expect(state.photos, hasLength(2));
      final paths = state.photos.map((p) => p.path).toList();

      await tap(tester, 'thumbnail');
      await tap(tester, 'gallery_select_toggle');
      expect(find.text('Đã chọn 0'), findsOneWidget);

      for (final p in state.photos) {
        await tap(tester, 'tile_${p.id}');
      }
      expect(find.text('Đã chọn 2'), findsOneWidget);
      await shot(tester, '10-multi-select');

      await tap(tester, 'sel_delete');
      await shot(tester, '11-delete-confirm');
      expect(
        find.text('Các mục đã xóa khỏi album RfCamera không thể khôi phục.'),
        findsOneWidget,
      );
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Xóa'), findsOneWidget);

      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(state.photos, isEmpty);
      for (final path in paths) {
        expect(File(path).existsSync(), isFalse, reason: 'file must be gone');
      }
    });

    testWidgets('cancelling keeps everything', (tester) async {
      await pumpApp(tester);
      await shoot(tester);

      await tap(tester, 'thumbnail');
      await tap(tester, 'gallery_select_toggle');
      await tap(tester, 'tile_${state.photos.first.id}');
      await tap(tester, 'sel_delete');

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(state.photos, hasLength(1));
    });
  });

  group('flow 7 — samples and the full catalogue', () {
    testWidgets('Ảnh Mẫu opens the offline sample feed', (tester) async {
      await pumpApp(tester);
      await tap(tester, 'open_selector');
      await tap(tester, 'samples_button');

      await shot(tester, '12-samples');
      expect(find.textContaining('Ảnh mẫu của'), findsWidgets);
      expect(find.textContaining('GỬI TÁC PHẨM CỦA TÔI'), findsWidgets);
      // The feed is bundled, never fetched.
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('the full list shows every camera, all selectable', (
      tester,
    ) async {
      await pumpApp(tester);
      await tap(tester, 'open_selector');
      await tap(tester, 'all_cameras_button');

      await shot(tester, '13-all-cameras');
      expect(find.text('DIGITAL'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('ACCESSORY'),
        400,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 60,
      );
      expect(find.text('ACCESSORY'), findsWidgets);
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(find.textContaining('Dazz Pro'), findsNothing);
    });
  });

  group('flow 8 — offline and persistence', () {
    testWidgets('state survives a cold restart', (tester) async {
      await pumpApp(tester);
      await tap(tester, 'open_selector');
      await tap(tester, 'cam_glow');
      await tap(tester, 'config_toggle_button');
      await reveal(tester, 'ratio_2.35:1', 'ratio_strip');
      await tap(tester, 'ratio_2.35:1');
      await tap(tester, 'selector_close');
      await shoot(tester);

      final reloaded = AppState();
      await reloaded.load();
      expect(reloaded.camera.id, 'glow');
      expect(reloaded.ratio, '2.35:1');
      expect(reloaded.photos, hasLength(1));
    });

    testWidgets('every look is distinct', (tester) async {
      // If two cameras graded identically the carousel would be a lie.
      final seen = <String>{};
      for (final c in Cameras.shooters) {
        final e = c.effect;
        final sig = [
          e.matrix.map((v) => v.toStringAsFixed(3)).join(','),
          e.grain,
          e.vignette,
          e.leak,
          e.scanlines,
          e.chroma,
          e.aspect,
        ].join('|');
        expect(seen.add(sig), isTrue, reason: '${c.name} duplicates another');
      }
    });
  });
}
