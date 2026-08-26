import 'package:flutter/material.dart';

/// Design tokens lifted from the reference screenshots.
class P {
  P._();

  static const black = Color(0xFF000000);
  static const sheet = Color(0xFF2A2A2A);
  static const tile = Color(0xFF141414);
  static const chip = Color(0xFF2C2C2E);
  static const chipSolid = Color(0xFF3A3A3C);
  static const hairline = Color(0xFF2E2E2E);
  static const white = Color(0xFFFFFFFF);
  static const dim = Color(0xFF8E8E93);
  static const blue = Color(0xFF0A93E4);
  static const green = Color(0xFF32D74B);
  static const red = Color(0xFFFF3B30);
  static const stampOrange = Color(0xFFFF8A3D);
  static const stampRed = Color(0xFFE02020);
  static const badgeR = Color(0xFF5B4BFF);

  /// Radius of the viewfinder card and the folder / config sheets.
  static const rCard = 28.0;
  static const rInner = 16.0;
  static const rPanel = 32.0;

  /// The app ships Nunito Sans and names it explicitly here, so text painted
  /// straight onto a canvas — which has no ambient DefaultTextStyle — matches
  /// the widget tree.
  static const family = 'NunitoSans';

  static TextStyle t(
    double size, {
    FontWeight w = FontWeight.w500,
    Color c = white,
    double? ls,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: w,
    color: c,
    letterSpacing: ls,
    height: 1.2,
    decoration: TextDecoration.none,
  );
}
