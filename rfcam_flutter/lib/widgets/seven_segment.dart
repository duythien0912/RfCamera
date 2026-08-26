import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The LED date back every point-and-shoot burned into the corner of a frame.
///
/// Geometry lives in unit space so the live overlay (dart:ui Canvas) and the
/// baked JPEG (image package, plain rectangles) can render the exact same
/// digits.
class SevenSegment {
  SevenSegment._();

  /// Bit order: a b c d e f g (bit 0 = a).
  static const _glyphs = <String, int>{
    '0': 0x3F,
    '1': 0x06,
    '2': 0x5B,
    '3': 0x4F,
    '4': 0x66,
    '5': 0x6D,
    '6': 0x7D,
    '7': 0x07,
    '8': 0x7F,
    '9': 0x6F,
  };

  /// Width of one digit cell relative to its height.
  static const cellWidth = 0.62;

  /// Gap between digits, relative to height.
  static const gap = 0.16;

  /// Extra gap where the string has a space.
  static const spaceWidth = 0.30;

  static const _thick = 0.15;

  /// Unit rects (origin top-left of the digit cell, height 1.0) for one glyph.
  static List<Rect> segmentsFor(String ch) {
    final mask = _glyphs[ch];
    if (mask == null) return const [];
    const w = cellWidth;
    const t = _thick;
    const half = 0.5 - t * 0.75;
    final out = <Rect>[];
    if (mask & 0x01 != 0) out.add(const Rect.fromLTWH(t / 2, 0, w - t, t));
    if (mask & 0x02 != 0) out.add(const Rect.fromLTWH(w - t, t / 2, t, half));
    if (mask & 0x04 != 0) {
      out.add(const Rect.fromLTWH(w - t, 0.5 + t / 4, t, half));
    }
    if (mask & 0x08 != 0) out.add(const Rect.fromLTWH(t / 2, 1 - t, w - t, t));
    if (mask & 0x10 != 0) out.add(const Rect.fromLTWH(0, 0.5 + t / 4, t, half));
    if (mask & 0x20 != 0) out.add(const Rect.fromLTWH(0, t / 2, t, half));
    if (mask & 0x40 != 0) {
      out.add(const Rect.fromLTWH(t / 2, 0.5 - t / 2, w - t, t));
    }
    return out;
  }

  /// Total advance width of [text] in units of digit height.
  static double measure(String text) {
    var w = 0.0;
    for (var i = 0; i < text.length; i++) {
      w += text[i] == ' ' ? spaceWidth : cellWidth + gap;
    }
    return w <= 0 ? 0 : w - gap;
  }

  /// Emits (x, y, w, h) rects in pixels for [text] laid out left to right from
  /// [originX], [originY] (top-left), with digits [digitHeight] tall.
  static List<Rect> layout(
    String text, {
    required double originX,
    required double originY,
    required double digitHeight,
  }) {
    final out = <Rect>[];
    var x = originX;
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == ' ') {
        x += spaceWidth * digitHeight;
        continue;
      }
      for (final r in segmentsFor(ch)) {
        out.add(
          Rect.fromLTWH(
            x + r.left * digitHeight,
            originY + r.top * digitHeight,
            r.width * digitHeight,
            r.height * digitHeight,
          ),
        );
      }
      x += (cellWidth + gap) * digitHeight;
    }
    return out;
  }

  static void paint(
    Canvas canvas,
    String text, {
    required Offset origin,
    required double digitHeight,
    required Color color,
    bool alignRight = false,
    bool glow = false,
  }) {
    final width = measure(text) * digitHeight;
    final left = alignRight ? origin.dx - width : origin.dx;
    final top = origin.dy - digitHeight;
    final rects = layout(
      text,
      originX: left,
      originY: top,
      digitHeight: digitHeight,
    );
    _drawRects(canvas, rects, color, glow);
  }

  /// The stamp reads bottom-to-top down the left edge, as on the photo detail
  /// screen in the reference.
  static void paintVertical(
    Canvas canvas,
    String text, {
    required Offset origin,
    required double digitHeight,
    required Color color,
    bool glow = false,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(-1.5707963267948966);
    final rects = layout(
      text,
      originX: 0,
      originY: -digitHeight,
      digitHeight: digitHeight,
    );
    _drawRects(canvas, rects, color, glow);
    canvas.restore();
  }

  static void _drawRects(
    Canvas canvas,
    List<Rect> rects,
    Color color,
    bool glow,
  ) {
    if (glow) {
      final g = Paint()
        ..color = color.withValues(alpha: 0.45)
        ..blendMode = BlendMode.plus
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 3);
      for (final r in rects) {
        canvas.drawRect(r, g);
      }
    }
    final p = Paint()
      ..color = color
      ..blendMode = BlendMode.plus;
    for (final r in rects) {
      canvas.drawRect(r, p);
    }
  }
}
