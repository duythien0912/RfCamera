# RfCamera — offline film camera

A pixel-targeted clone of the Dazz Cam iOS app, built in Flutter and living
entirely in `rfcam_flutter/`. Vietnamese UI.

**It is deliberately free, accountless and offline.** There is no sign-in, no
paywall, no IAP, no cloud sync and no analytics. Every camera and accessory is
unlocked. The app declares no `INTERNET` permission in release builds and
depends on nothing that talks to a network — if you are about to add a package
that does, that is a design change, not a detail.

The repo still contains `rfcam_server/` and `rfcam_client/` from the Serverpod
scaffold. **They are unused and must stay that way**; the app imports neither.

## What it does

Launch goes straight to the viewfinder — no splash, no gate.

- **Camera** (`screens/camera_screen.dart`) — a rangefinder card: the scene
  blurred and dimmed outside the frame, crisp inside it. `35mm` label, 3×3
  grid, and three chips: white balance, focal length, exposure. Tapping the
  focal chip opens a 26/35/50 tray that crops the frame (26mm = 1×); tapping
  the exposure chip opens a slider with an `A` auto button. The `...` button
  drops a frosted panel for flash / frame / grid / zoom mode.
- **Selector** (`screens/selector_sheet.dart`) — two horizontally scrolling
  rows over a live, already-graded preview of your scene, plus the accessory
  strip and the `Cấu Hình Màu` card (variants + aspect ratio).
- **Full catalogue** (`screens/all_cameras_screen.dart`) — every camera by
  section, all selectable.
- **Gallery** (`screens/gallery_screen.dart`) — folder dropdown (Tất cả ảnh /
  Yêu thích / Phim âm bản / one per camera used), multi-select, delete with
  confirmation.
- **Detail** (`screens/photo_detail_screen.dart`) — vertical page view, share /
  fire / copy / favourite / delete.
- **Samples** (`screens/sample_photos_screen.dart`) — bundled feed, never
  fetched.

## How the looks work

One `FilmEffect` (`core/film_effect.dart`) drives both the live viewfinder and
the saved JPEG, so the preview is honest.

- `widgets/film_view.dart` renders it live: colour matrix, optics shader
  (`shaders/film.frag` — barrel distortion + chromatic aberration), then grain,
  leak, dust, scanlines, vignette and the date stamp as overlays.
- `core/bake.dart` replays the *same* pipeline in the same order over the
  captured JPEG, in a `compute()` isolate, and that baked file is what lands in
  the album.
- The grain / leak / dust plates in `assets/film/` are real film scans.
- `core/camera_catalog.dart` is the single source of truth for the camera list.
  Changing an id, a name or the ordering will break the flow checks.

Photos are written to the app's own documents directory, not the system photo
library — that is why the album works with no storage permission at all.

## Gotchas that have already cost time

- **`ui.Gradient` with more than two colours must be given explicit
  `colorStops`**, or it throws at paint time — every frame, silently blanking
  whatever subtree is painting. This has bitten this codebase three times.
- **Never drive a permanent overlay animation with an `AnimationController`.**
  A repeating controller registers transient frame callbacks forever, so
  `flutter_driver` and `pumpAndSettle` hang. `FilmView` uses a `Timer` plus a
  `ValueNotifier` instead, and honours `FilmView.motionEnabled` so tests can
  switch the motion off entirely.
- `hot_restart` does not always pick up edits. If a fix does not seem to apply,
  stop the app and relaunch it rather than debugging a stale binary.

## Working on this

The app is named **RfCamera**; the original it clones is Dazz Cam.

The user starts things with `serverpod start`. NEVER start the server yourself —
STOP and ask the user to start it. When it is running, interact through the
`serverpod` MCP. `serverpod start` handles hot reload for both server and app.

ALWAYS use the MCP server instead of the command line. Use it to:

- `create_migration` and `apply_migrations` for the database (after model
  changes). Not applicable while the server stays unused.
- `tail_server_logs` to read server logs.
- `tail_flutter_logs` to read raw stdout/stderr from the Flutter app.
- `hot_restart` after Flutter changes that plain hot reload cannot apply.
- `get_flutter_app_dtd` for connecting to the app through the `dart` MCP.

Checklist after doing changes:

1. `dart analyze` (CLI)
2. `dart format` (CLI)
3. `create_migration` and `apply_migrations` (MCP - only if necessary)
4. Do `serverpod` MCP `hot_restart` if required (hot reload is done
   automatically). Will also hot restart Flutter app
5. Run tests, if applicable (`dart` CLI)
6. Check `serverpod` MCP `tail_server_logs` and `tail_flutter_logs` for issues.

If the user asks you to test the app:

1. Use `get_flutter_app_dtd` (`serverpod` MCP) to get the Flutter app's DTD
2. Pass the DTD to `connect_dart_tooling_daemon` (`dart` MCP)
3. Use `flutter_driver` (`dart` MCP) to navigate through the app

## Flow checks

`integration_test/app_flow_test.dart` covers the eight specified flows against
a real device, real camera and real filesystem. It also writes a screenshot per
screen into `screenshots/` when driven:

```
cd rfcam_flutter
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart -d <device>
```

Widget keys are part of the contract those checks rely on (`shutter`,
`open_selector`, `thumbnail`, `cam_<id>`, `ratio_<label>`, `folder_<id>`,
`tile_<photoId>`, `sel_delete`, `detail_favorite`, …). Renaming one means
updating the check that uses it.
