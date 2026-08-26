# Flow recordings

Screen captures of the app's main flows, one clip per flow, recorded on
`emulator-5554` against the live camera (Android virtual scene).

Regenerate any of them with:

```
cd rfcam_flutter
tool/record_flows.sh emulator-5554          # all nine
tool/record_flows.sh emulator-5554 3 7      # just these
```

Each clip is a separate `flutter drive` run of
`integration_test/demo_flows_test.dart` with `--dart-define=FLOW=n`, so they
are independent and can be re-shot individually. Recording starts once the
app's activity is on screen and the first six seconds (Flutter splash) are
trimmed, so every clip opens on the app.

| Clip | Length | What it shows |
|---|---|---|
| `01-launch-and-shoot.mp4` | 10s | Launch straight into the viewfinder, two captures — shutter flash, then the frame flying into the thumbnail with the date already burned in |
| `02-camera-selector.mp4` | 13s | The selector strip over a live preview: VHS → 8mm → V Classic → Glow → DCR, each re-grading the scene behind it instantly |
| `03-colour-config-ratios.mp4` | 18s | Cấu Hình Màu — the GRD / GRD Pos variant pair with its comparison blurb, then 4:3 → 1:1 → 16:9 |
| `04-framing-controls.mp4` | 22s | 26 / 50 / 35 frame-zoom with the out-of-frame blur, the exposure slider and its auto button, and the quick panel toggling flash, grid and frame |
| `05-gallery-folders.mp4` | 22s | Two shots on two different cameras, then the folder dropdown filtering by camera and back to Tất cả ảnh |
| `06-photo-detail-favourite.mp4` | 21s | Photo detail, favouriting (the heart morphs), vertical paging between shots |
| `07-multiselect-delete.mp4` | 23s | Select mode, Đã chọn 0 → 3, the delete confirmation, and the album emptying |
| `08-samples-catalogue.mp4` | 21s | The Ảnh Mẫu sample feed and the full camera catalogue, both scrolled |
| `09-all-cameras-walkthrough.mp4` | 32s | Every camera in the strip, one after another, on the same scene — the clearest look at how different the grades actually are |

720×1600, H.264. Recorded 2026-08-26.
