import 'package:flutter/foundation.dart';

/// One shot sitting in the app's own album. Files live in the documents
/// directory; this record is persisted as JSON in shared_preferences.
@immutable
class CapturedPhoto {
  const CapturedPhoto({
    required this.id,
    required this.path,
    required this.cameraId,
    required this.cameraName,
    required this.takenAt,
    this.favorite = false,
    this.negative = false,
  });

  final String id;
  final String path;
  final String cameraId;
  final String cameraName;
  final DateTime takenAt;
  final bool favorite;

  /// Shot on a negative stock, so it lands in the "Phim âm bản" folder.
  final bool negative;

  /// `8 25 26` — the burned-in stamp, also shown on gallery tiles.
  String get stampText {
    final y = takenAt.year % 100;
    return '${takenAt.month} ${takenAt.day} $y';
  }

  CapturedPhoto copyWith({
    bool? favorite,
    bool? negative,
  }) => CapturedPhoto(
    id: id,
    path: path,
    cameraId: cameraId,
    cameraName: cameraName,
    takenAt: takenAt,
    favorite: favorite ?? this.favorite,
    negative: negative ?? this.negative,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'cameraId': cameraId,
    'cameraName': cameraName,
    'takenAt': takenAt.millisecondsSinceEpoch,
    'favorite': favorite,
    'negative': negative,
  };

  static CapturedPhoto fromJson(Map<String, dynamic> j) => CapturedPhoto(
    id: j['id'] as String,
    path: j['path'] as String,
    cameraId: j['cameraId'] as String? ?? 'fxn',
    cameraName: j['cameraName'] as String? ?? 'FXN',
    takenAt: DateTime.fromMillisecondsSinceEpoch((j['takenAt'] as num).toInt()),
    favorite: j['favorite'] as bool? ?? false,
    negative: j['negative'] as bool? ?? false,
  );
}

/// A row in the gallery's folder dropdown.
@immutable
class GalleryFolder {
  const GalleryFolder({
    required this.id,
    required this.label,
    required this.count,
    required this.kind,
  });

  final String id;
  final String label;
  final int count;
  final FolderKind kind;
}

enum FolderKind { all, favorite, negative, camera }
