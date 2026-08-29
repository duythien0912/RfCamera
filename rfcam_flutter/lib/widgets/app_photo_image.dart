import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';

/// Renders a captured photo path across platforms (Web & Native).
///
/// On Web: handles in-memory cache, data-URIs, and network.
/// On Native: falls back to [Image.file].
class AppPhotoImage extends StatelessWidget {
  const AppPhotoImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheWidth,
    this.errorBuilder,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || path.startsWith('data:') || path.startsWith('http')) {
      final cached = AppState.webImageStore[path];
      if (cached != null) {
        return Image.memory(
          cached,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: cacheWidth,
          errorBuilder: errorBuilder,
        );
      }
      if (path.startsWith('data:image/jpeg;base64,')) {
        try {
          final raw = path.substring('data:image/jpeg;base64,'.length);
          final bytes = base64Decode(raw);
          AppState.webImageStore[path] = bytes;
          return Image.memory(
            bytes,
            fit: fit,
            width: width,
            height: height,
            cacheWidth: cacheWidth,
            errorBuilder: errorBuilder,
          );
        } catch (_) {}
      }
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        errorBuilder: errorBuilder,
      );
    }

    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      errorBuilder: errorBuilder,
    );
  }
}
