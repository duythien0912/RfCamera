import 'package:flutter/material.dart';

import 'palette.dart';

/// Shows a floating toast message pinned to the top area of the screen.
void showAppToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  final media = MediaQuery.of(context);
  final h = media.size.height;
  final safeTop = media.padding.top;
  final topOffset = safeTop + 16;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: P.t(14, w: FontWeight.w600, c: P.white),
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xE61C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      margin: EdgeInsets.only(
        bottom: h - topOffset - 52,
        left: 16,
        right: 16,
      ),
    ),
  );
}
