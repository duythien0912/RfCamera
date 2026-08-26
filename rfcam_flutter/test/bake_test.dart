import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:rfcam_flutter/core/bake.dart';
import 'package:rfcam_flutter/core/camera_catalog.dart';

/// Builds a landscape frame that is unambiguous about which way is up:
/// a red band across the top, blue across the bottom, mid grey between.
Uint8List _landscapeTestFrame({int w = 800, int h = 600}) {
  final im = img.Image(width: w, height: h);
  for (final p in im) {
    if (p.y < h * 0.15) {
      p.setRgb(220, 30, 30);
    } else if (p.y > h * 0.85) {
      p.setRgb(30, 30, 220);
    } else {
      p.setRgb(128, 128, 128);
    }
  }
  return Uint8List.fromList(img.encodeJpg(im, quality: 95));
}

({int r, int g, int b}) _avg(img.Image im, int y0, int y1) {
  var r = 0, g = 0, b = 0, n = 0;
  for (var y = y0; y < y1; y++) {
    for (var x = 0; x < im.width; x += 3) {
      final p = im.getPixel(x, y);
      r += p.r.toInt();
      g += p.g.toInt();
      b += p.b.toInt();
      n++;
    }
  }
  return (r: r ~/ n, g: g ~/ n, b: b ~/ n);
}

void main() {
  test('a baked frame is portrait but never rotated', () async {
    // Regression: an earlier fix made the file portrait by rotating the frame
    // 90°, so every photo came out shaped correctly with the scene lying on
    // its side. The viewfinder centre-crops, so the bake must crop too.
    final effect = Cameras.byId('original').effect;
    final baked = await bakePhoto(
      BakeRequest.from(_landscapeTestFrame(), effect, 1, '', maxEdge: 800),
    );
    final out = img.decodeJpg(baked)!;

    expect(out.height, greaterThan(out.width), reason: 'must be portrait');
    expect(
      out.height / out.width,
      closeTo(effect.aspect, 0.06),
      reason: 'must match the framed aspect',
    );

    // Red still on top, blue still on the bottom.
    final top = _avg(out, 0, (out.height * 0.10).round());
    final bottom = _avg(out, (out.height * 0.90).round(), out.height);
    expect(
      top.r,
      greaterThan(top.b + 40),
      reason: 'top of the frame must still be the red band',
    );
    expect(
      bottom.b,
      greaterThan(bottom.r + 40),
      reason: 'bottom of the frame must still be the blue band',
    );

    // A crop keeps the source height; a rotation would have made it the width.
    expect(out.width, lessThanOrEqualTo(800));
  });

  test('every aspect ratio bakes to that ratio, portrait', () async {
    for (final entry in Cameras.ratios.entries) {
      final effect = Cameras.byId('original').effect.copyWith(
        aspect: entry.value,
      );
      final baked = await bakePhoto(
        BakeRequest.from(_landscapeTestFrame(), effect, 1, '', maxEdge: 600),
      );
      final out = img.decodeJpg(baked)!;
      expect(
        out.height / out.width,
        closeTo(entry.value, 0.07),
        reason: '${entry.key} baked to ${out.width}x${out.height}',
      );
    }
  });

  test('the date stamp is burned into the file', () async {
    final effect = Cameras.byId('fxn').effect;
    final withStamp = img.decodeJpg(
      await bakePhoto(
        BakeRequest.from(
          _landscapeTestFrame(),
          effect,
          1,
          '8 25 26',
          maxEdge: 800,
        ),
      ),
    )!;
    final without = img.decodeJpg(
      await bakePhoto(
        BakeRequest.from(_landscapeTestFrame(), effect, 1, '', maxEdge: 800),
      ),
    )!;

    var differing = 0;
    for (var y = 0; y < withStamp.height; y++) {
      for (var x = 0; x < withStamp.width; x++) {
        final a = withStamp.getPixel(x, y);
        final b = without.getPixel(x, y);
        if ((a.r - b.r).abs() > 30) differing++;
      }
    }
    expect(differing, greaterThan(200), reason: 'stamp pixels must be present');
  });
}
