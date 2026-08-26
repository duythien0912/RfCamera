import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'camera_catalog.dart';
import 'film_effect.dart';
import 'photo.dart';

/// Which zoom behaviour the "Chế độ zoom" pill selects.
enum ZoomMode { frame, lens }

/// Everything the UI reads. Deliberately one object: the app is small, and a
/// single notifier keeps the viewfinder in sync with every sheet that can
/// change it.
class AppState extends ChangeNotifier {
  AppState();

  static const _kPhotos = 'dazz.photos.v1';
  static const _kCamera = 'dazz.camera';
  static const _kVariant = 'dazz.variant';
  static const _kRatio = 'dazz.ratio';
  static const _kAccessories = 'dazz.accessories';

  SharedPreferences? _prefs;
  bool _ready = false;
  bool get ready => _ready;

  // --- camera choice -------------------------------------------------------
  CameraProfile _camera = Cameras.byId('fxn');
  CameraProfile get camera => _camera;

  String? _variant;
  String get variant => _variant ?? _camera.variants.first.name;

  String _ratio = '4:3';
  String get ratio => _ratio;
  double get ratioValue => Cameras.ratios[_ratio] ?? 4 / 3;

  final Set<String> _accessories = <String>{};
  Set<String> get accessories => Set.unmodifiable(_accessories);

  /// The look currently applied to the viewfinder, accessories folded in.
  FilmEffect get effect {
    var e = _camera.effectOf(_variant);
    for (final a in _accessories) {
      e = e.withAccessory(a);
    }
    return e.copyWith(aspect: ratioValue);
  }

  /// Bumps whenever the look changes, so overlays can reseed their randomness.
  int _seed = 1;
  int get seed => _seed;

  // --- shooting settings ---------------------------------------------------
  bool flashOn = false;
  bool frameOn = true;
  bool gridOn = true;
  ZoomMode zoomMode = ZoomMode.frame;
  int focal = 35;
  static const focalOptions = [26, 35, 50];
  double ev = 0.0;
  bool evAuto = true;
  bool timerOn = false;
  int timerSeconds = 3;
  bool doubleExposure = false;
  bool frontCamera = false;
  bool soundEnabled = true;
  bool hapticEnabled = true;
  String whiteBalance = 'Auto';
  static const wbOptions = ['Auto', 'Daylight', 'Cloudy', 'Tungsten'];

  // --- gallery -------------------------------------------------------------
  final List<CapturedPhoto> _photos = [];
  List<CapturedPhoto> get photos => List.unmodifiable(_photos);
  CapturedPhoto? get latest => _photos.isEmpty ? null : _photos.first;

  /// Everything: used by tests and by any caller that wants one await.
  Future<void> load() async {
    await loadSettings();
    await loadAlbum();
  }

  /// The preferences read that decides which camera the first frame draws.
  /// Deliberately does not touch the album — see [loadAlbum].
  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    final camId = p.getString(_kCamera);
    if (camId != null) {
      final c = Cameras.tryById(camId);
      if (c != null && !c.isAccessory) _camera = c;
    }
    _variant = p.getString(_kVariant);
    _ratio = p.getString(_kRatio) ?? '4:3';
    _accessories
      ..clear()
      ..addAll(p.getStringList(_kAccessories) ?? const []);
    notifyListeners();
  }

  /// Decoding the album means a JSON parse and an `existsSync` per photo, so it
  /// is kept off the launch path — the thumbnail simply fills in a moment late.
  Future<void> loadAlbum() async {
    final p = _prefs ??= await SharedPreferences.getInstance();
    final raw = p.getStringList(_kPhotos) ?? const [];
    final found = <CapturedPhoto>[];
    for (final s in raw) {
      try {
        final photo = CapturedPhoto.fromJson(
          jsonDecode(s) as Map<String, dynamic>,
        );
        if (File(photo.path).existsSync()) found.add(photo);
      } catch (_) {
        // A corrupt row should never take the whole album down.
      }
    }
    found.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    _photos
      ..clear()
      ..addAll(found);
    _ready = true;
    notifyListeners();
  }

  Future<void> _persistPhotos() async {
    await _prefs?.setStringList(
      _kPhotos,
      _photos.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  // --- mutations -----------------------------------------------------------
  void selectCamera(CameraProfile c) {
    if (c.isAccessory) return;
    _camera = c;
    _variant = c.variants.first.name;
    _ratio = _ratioNameFor(c.effectOf(_variant).aspect);
    _seed++;
    _prefs?.setString(_kCamera, c.id);
    _prefs?.setString(_kVariant, _variant!);
    _prefs?.setString(_kRatio, _ratio);
    notifyListeners();
  }

  String _ratioNameFor(double aspect) {
    var best = '4:3';
    var bestDelta = double.infinity;
    for (final e in Cameras.ratios.entries) {
      final d = (e.value - aspect).abs();
      if (d < bestDelta) {
        bestDelta = d;
        best = e.key;
      }
    }
    return best;
  }

  void selectVariant(String name) {
    _variant = name;
    _seed++;
    _prefs?.setString(_kVariant, name);
    notifyListeners();
  }

  void selectRatio(String name) {
    _ratio = name;
    _prefs?.setString(_kRatio, name);
    notifyListeners();
  }

  void toggleAccessory(String id) {
    if (!_accessories.remove(id)) _accessories.add(id);
    _seed++;
    _prefs?.setStringList(_kAccessories, _accessories.toList());
    notifyListeners();
  }

  void setFlash(bool v) {
    flashOn = v;
    notifyListeners();
  }

  void setFrame(bool v) {
    frameOn = v;
    notifyListeners();
  }

  void setGrid(bool v) {
    gridOn = v;
    notifyListeners();
  }

  void setZoomMode(ZoomMode m) {
    zoomMode = m;
    notifyListeners();
  }

  void setFocal(int f) {
    focal = f;
    notifyListeners();
  }

  void setEv(double v) {
    ev = v;
    evAuto = false;
    notifyListeners();
  }

  void setEvAuto() {
    evAuto = true;
    ev = 0;
    notifyListeners();
  }

  void toggleTimer() {
    if (!timerOn) {
      timerOn = true;
      timerSeconds = 3;
    } else if (timerSeconds == 3) {
      timerSeconds = 10;
    } else {
      timerOn = false;
    }
    notifyListeners();
  }

  void toggleDoubleExposure() {
    doubleExposure = !doubleExposure;
    notifyListeners();
  }

  void flipCamera() {
    frontCamera = !frontCamera;
    notifyListeners();
  }

  void cycleWhiteBalance() {
    final idx = wbOptions.indexOf(whiteBalance);
    whiteBalance = wbOptions[(idx + 1) % wbOptions.length];
    notifyListeners();
  }

  void setSound(bool v) {
    soundEnabled = v;
    notifyListeners();
  }

  void setHaptic(bool v) {
    hapticEnabled = v;
    notifyListeners();
  }

  void resetSettings() {
    flashOn = false;
    frameOn = true;
    gridOn = true;
    zoomMode = ZoomMode.frame;
    focal = 35;
    ev = 0.0;
    evAuto = true;
    timerOn = false;
    timerSeconds = 3;
    doubleExposure = false;
    whiteBalance = 'Auto';
    _accessories.clear();
    _prefs?.remove(_kAccessories);
    notifyListeners();
  }

  Future<CapturedPhoto> addPhoto({
    required String path,
    required CameraProfile cam,
    required bool negative,
    DateTime? at,
  }) async {
    final photo = CapturedPhoto(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      path: path,
      cameraId: cam.id,
      cameraName: cam.name,
      takenAt: at ?? DateTime.now(),
      negative: negative,
    );
    _photos.insert(0, photo);
    await _persistPhotos();
    notifyListeners();
    return photo;
  }

  Future<void> toggleFavorite(String id) async {
    final i = _photos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    _photos[i] = _photos[i].copyWith(favorite: !_photos[i].favorite);
    await _persistPhotos();
    notifyListeners();
  }

  Future<void> toggleNegative(String id) async {
    final i = _photos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    _photos[i] = _photos[i].copyWith(negative: !_photos[i].negative);
    await _persistPhotos();
    notifyListeners();
  }

  Future<void> batchToggleNegative(Iterable<String> ids) async {
    final set = ids.toSet();
    for (var i = 0; i < _photos.length; i++) {
      if (set.contains(_photos[i].id)) {
        _photos[i] = _photos[i].copyWith(negative: !_photos[i].negative);
      }
    }
    await _persistPhotos();
    notifyListeners();
  }

  Future<void> deletePhotos(Iterable<String> ids) async {
    final set = ids.toSet();
    for (final p in _photos.where((p) => set.contains(p.id))) {
      try {
        final f = File(p.path);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {
        // Losing the file is fine; the record goes either way.
      }
    }
    _photos.removeWhere((p) => set.contains(p.id));
    await _persistPhotos();
    notifyListeners();
  }

  /// Where captures are written. Kept inside the app so the album works with
  /// no photo-library permission at all.
  Future<Directory> albumDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/dazz');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  // --- folders -------------------------------------------------------------
  List<GalleryFolder> get folders {
    final out = <GalleryFolder>[
      GalleryFolder(
        id: 'all',
        label: 'Tất cả ảnh',
        count: _photos.length,
        kind: FolderKind.all,
      ),
      GalleryFolder(
        id: 'fav',
        label: 'Yêu thích',
        count: _photos.where((p) => p.favorite).length,
        kind: FolderKind.favorite,
      ),
      GalleryFolder(
        id: 'neg',
        label: 'Phim âm bản',
        count: _photos.where((p) => p.negative).length,
        kind: FolderKind.negative,
      ),
    ];
    final byCam = <String, int>{};
    final names = <String, String>{};
    for (final p in _photos) {
      byCam[p.cameraId] = (byCam[p.cameraId] ?? 0) + 1;
      names[p.cameraId] = p.cameraName;
    }
    final ids = byCam.keys.toList()..sort();
    for (final id in ids) {
      out.add(
        GalleryFolder(
          id: id,
          label: names[id] ?? id,
          count: byCam[id]!,
          kind: FolderKind.camera,
        ),
      );
    }
    return out;
  }

  List<CapturedPhoto> photosIn(GalleryFolder f) {
    switch (f.kind) {
      case FolderKind.all:
        return photos;
      case FolderKind.favorite:
        return _photos.where((p) => p.favorite).toList();
      case FolderKind.negative:
        return _photos.where((p) => p.negative).toList();
      case FolderKind.camera:
        return _photos.where((p) => p.cameraId == f.id).toList();
    }
  }
}

/// Plain InheritedNotifier so no state-management package is needed.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above this widget');
    return scope!.notifier!;
  }

  /// Reads without subscribing — for callbacks that only mutate.
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above this widget');
    return scope!.notifier!;
  }
}
