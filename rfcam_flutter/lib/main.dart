import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_state.dart';
import 'core/palette.dart';
import 'screens/camera_screen.dart';
import 'widgets/film_view.dart';

/// Open and shoot.
///
/// Nothing heavy is awaited before the first frame. Decoding the film plates,
/// compiling the optics shader and reading the album all happen *after*
/// `runApp`, because none of them are needed to draw the viewfinder — the
/// overlay falls back to procedural noise until the plates land, the shader is
/// skipped entirely when it is not loaded yet, and the thumbnail is empty for
/// the first moment either way. Awaiting them cost roughly a second of black
/// screen on a cold start.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Fire and forget: these are platform round-trips, and the app is portrait
  // and black regardless of when they land.
  unawaited(
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final state = AppState();

  // Settings are a single synchronous-ish preferences read, and they decide
  // which camera the very first frame renders — so they are the one thing
  // worth having early. Everything else is chased down afterwards.
  state.loadSettings().whenComplete(() {
    unawaited(state.loadAlbum());
    unawaited(FilmView.warmUp());
  });

  runApp(RfCameraApp(state: state));
}

class RfCameraApp extends StatelessWidget {
  const RfCameraApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'RfCamera',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: P.black,
          colorScheme: const ColorScheme.dark(
            surface: P.black,
            primary: P.white,
          ),
          fontFamily: P.family,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        home: const CameraScreen(),
      ),
    );
  }
}
