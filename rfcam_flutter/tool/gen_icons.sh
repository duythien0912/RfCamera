#!/usr/bin/env bash
# Regenerates the native launcher / splash icons from assets/icon/.
#
# assets/icon/rfcam_icon.png is the source of truth: an opaque 1254px square,
# a 3D yellow camera on a #29292B background. tool/cutout_icon.py derives the
# transparent variants from it (see that file for how the cut-out works); this
# script downscales all three into the Android res/ tree and the iOS catalog.
#
# Usage (from rfcam_flutter/):
#   ./tool/gen_icons.sh
set -euo pipefail

cd "$(dirname "$0")/.."

# numpy + PIL live in the system python here, not in the homebrew one.
/usr/bin/python3 tool/cutout_icon.py

SRC_SQ="assets/icon/rfcam_icon.png"    # opaque square, camera fills ~68%
SRC_FG="assets/icon/icon_fg.png"       # transparent cut-out, art 55% of canvas
FG_FRAC=55                             # ...in percent, for the maths below
SRC_SP="assets/icon/icon_splash.png"   # transparent cut-out, art ~92% of canvas
RES="android/app/src/main/res"

# Lanczos downscale that keeps the alpha channel intact.
scale() { # scale <src> <px> <dst>
  ffmpeg -y -loglevel error -i "$1" \
    -vf "scale=$2:$2:flags=lanczos" -pix_fmt rgba "$3"
}

# --- Android: legacy launcher icons (dp 48) ------------------------------
# The source is already a full-bleed opaque square, so it goes in unchanged.
for spec in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  d=${spec%%:*}; px=${spec##*:}
  mkdir -p "$RES/mipmap-$d"
  scale "$SRC_SQ" "$px" "$RES/mipmap-$d/ic_launcher.png"
done

# --- Android: adaptive icon foreground (dp 108) --------------------------
for spec in mdpi:108 hdpi:162 xhdpi:216 xxhdpi:324 xxxhdpi:432; do
  d=${spec%%:*}; px=${spec##*:}
  mkdir -p "$RES/mipmap-$d"
  scale "$SRC_FG" "$px" "$RES/mipmap-$d/ic_launcher_foreground.png"
done

# --- Android: splash mark (dp 120, drawn centred on black) ---------------
for spec in mdpi:120 hdpi:180 xhdpi:240 xxhdpi:360 xxxhdpi:480; do
  d=${spec%%:*}; px=${spec##*:}
  mkdir -p "$RES/drawable-$d"
  scale "$SRC_SP" "$px" "$RES/drawable-$d/ic_splash.png"
done

# --- Android: Android 12+ system splash icon (dp 288) --------------------
# The platform masks this drawable to a circle 2/3 of the canvas, so the art
# has to sit well inside: rescale icon_fg.png from FG_FRAC to 52% of canvas.
for spec in mdpi:288 hdpi:432 xhdpi:576 xxhdpi:864 xxxhdpi:1152; do
  d=${spec%%:*}; px=${spec##*:}
  inner=$(( px * 52 / FG_FRAC ))
  mkdir -p "$RES/drawable-$d"
  ffmpeg -y -loglevel error -i "$SRC_FG" \
    -vf "scale=$inner:$inner:flags=lanczos,pad=$px:$px:(ow-iw)/2:(oh-ih)/2:color=#00000000" \
    -pix_fmt rgba "$RES/drawable-$d/ic_splash_icon.png"
done

# --- iOS: AppIcon.appiconset --------------------------------------------
# App icons must be opaque, hence the square source and -pix_fmt rgb24.
IOS="ios/Runner/Assets.xcassets/AppIcon.appiconset"
if [ -d "$IOS" ]; then
  while IFS=: read -r name px; do
    [ -z "$name" ] && continue
    ffmpeg -y -loglevel error -i "$SRC_SQ" \
      -vf "scale=$px:$px:flags=lanczos" -pix_fmt rgb24 "$IOS/$name"
  done <<'EOF'
Icon-App-20x20@1x.png:20
Icon-App-20x20@2x.png:40
Icon-App-20x20@3x.png:60
Icon-App-29x29@1x.png:29
Icon-App-29x29@2x.png:58
Icon-App-29x29@3x.png:87
Icon-App-40x40@1x.png:40
Icon-App-40x40@2x.png:80
Icon-App-40x40@3x.png:120
Icon-App-60x60@2x.png:120
Icon-App-60x60@3x.png:180
Icon-App-76x76@1x.png:76
Icon-App-76x76@2x.png:152
Icon-App-83.5x83.5@2x.png:167
Icon-App-1024x1024@1x.png:1024
EOF
fi

# --- iOS: LaunchImage (centred on the black storyboard background) -------
LI="ios/Runner/Assets.xcassets/LaunchImage.imageset"
if [ -d "$LI" ]; then
  for spec in LaunchImage.png:120 LaunchImage@2x.png:240 LaunchImage@3x.png:360; do
    ffmpeg -y -loglevel error -i "$SRC_SP" \
      -vf "scale=${spec##*:}:${spec##*:}:flags=lanczos" -pix_fmt rgba \
      "$LI/${spec%%:*}"
  done
fi

echo "icons regenerated"
