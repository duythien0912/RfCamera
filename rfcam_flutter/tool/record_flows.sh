#!/usr/bin/env bash
# Records one screen-capture per demo flow.
#
#   tool/record_flows.sh [device] [flow ...]
#
# Each flow is a separate `flutter drive` run, so each clip is self-contained.
# Recording starts only once the app's activity is actually on screen, so the
# clips open on the camera rather than on thirty seconds of install.
set -uo pipefail

DEVICE="${1:-emulator-5554}"
shift || true

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$(cd "$ROOT/.." && pwd)/.output/e2e"
PKG="com.example.rfcam_flutter"
mkdir -p "$OUT"

names=(
  ""
  "01-launch-and-shoot"
  "02-camera-selector"
  "03-colour-config-ratios"
  "04-framing-controls"
  "05-gallery-folders"
  "06-photo-detail-favourite"
  "07-multiselect-delete"
  "08-samples-catalogue"
  "09-all-cameras-walkthrough"
)

flows=("$@")
if [ ${#flows[@]} -eq 0 ]; then flows=(1 2 3 4 5 6 7 8 9); fi

cd "$ROOT"

for n in "${flows[@]}"; do
  name="${names[$n]}"
  echo "=== flow $n — $name ==="
  adb -s "$DEVICE" shell rm -f /sdcard/flow.mp4 >/dev/null 2>&1
  adb -s "$DEVICE" shell am force-stop "$PKG" >/dev/null 2>&1

  flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/demo_flows_test.dart \
    --dart-define=FLOW="$n" \
    -d "$DEVICE" >"/tmp/flow_$n.log" 2>&1 &
  DRIVE_PID=$!

  # `flutter drive` reinstalls the app, which revokes the runtime camera
  # grant — so keep re-granting until the run ends, and dismiss the system
  # prompt if it wins the race anyway. Without this every clip records the
  # fallback preview sitting behind a permission dialog.
  (
    while kill -0 $DRIVE_PID 2>/dev/null; do
      adb -s "$DEVICE" shell pm grant "$PKG" android.permission.CAMERA >/dev/null 2>&1
      sleep 0.4
    done
  ) &
  GRANT_PID=$!

  (
    for _ in $(seq 1 25); do
      kill -0 $DRIVE_PID 2>/dev/null || break
      # Only dump when a permission dialog is actually up: `uiautomator dump`
      # turns semantics on in the app under test, and the test framework then
      # fails teardown with "A SemanticsHandle was active at the end".
      if ! adb -s "$DEVICE" shell "dumpsys window 2>/dev/null | grep -qi permissioncontroller"; then
        sleep 1
        continue
      fi
      if adb -s "$DEVICE" shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1; then
        b=$(adb -s "$DEVICE" shell cat /sdcard/ui.xml 2>/dev/null \
          | tr '>' '\n' | grep -i 'while using the app' \
          | grep -o 'bounds="\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]"' | head -1)
        if [ -n "$b" ]; then
          c=$(echo "$b" | grep -o '[0-9][0-9]*')
          set -- $c
          adb -s "$DEVICE" shell input tap $(( ($1 + $3) / 2 )) $(( ($2 + $4) / 2 )) >/dev/null 2>&1
        fi
      fi
      sleep 1
    done
  ) &
  DISMISS_PID=$!

  # Roll as soon as the activity is up — not before.
  for _ in $(seq 1 180); do
    if adb -s "$DEVICE" shell "dumpsys activity activities | grep -c $PKG" 2>/dev/null | grep -qv '^0'; then
      break
    fi
    kill -0 $DRIVE_PID 2>/dev/null || break
    sleep 1
  done

  adb -s "$DEVICE" shell "screenrecord --bit-rate 10000000 --size 720x1600 --time-limit 180 /sdcard/flow.mp4" &
  REC_PID=$!
  sleep 1

  wait $DRIVE_PID
  DRIVE_RC=$?
  kill $GRANT_PID $DISMISS_PID 2>/dev/null

  # SIGINT lets screenrecord finalise the container; a plain kill corrupts it.
  adb -s "$DEVICE" shell pkill -SIGINT screenrecord >/dev/null 2>&1
  wait $REC_PID 2>/dev/null
  sleep 2

  adb -s "$DEVICE" pull /sdcard/flow.mp4 "/tmp/flow_$n.mp4" >/dev/null 2>&1
  if [ -s "/tmp/flow_$n.mp4" ]; then
    # Remux so the container carries a real duration and seeks cleanly.
    ffmpeg -v error -ss 6.0 -i "/tmp/flow_$n.mp4" -c:v libx264 -crf 20 \
      -preset veryfast -pix_fmt yuv420p -movflags +faststart \
      "$OUT/$name.mp4" -y
    dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/$name.mp4" 2>/dev/null)
    printf 'saved %s (%.0fs, drive rc=%s)\n' "$name.mp4" "${dur:-0}" "$DRIVE_RC"
  else
    echo "!! flow $n produced no video (drive rc=$DRIVE_RC), see /tmp/flow_$n.log"
  fi
done

echo "=== done ==="
ls -la "$OUT"
