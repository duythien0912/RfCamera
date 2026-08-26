import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver half of the integration run. Its only job is to write the
/// screenshots the app-side test asks for into `screenshots/`, so the UI can
/// be reviewed frame by frame after a run.
Future<void> main() async {
  final dir = Directory('screenshots');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('${dir.path}/$name.png');
      await file.writeAsBytes(bytes, flush: true);
      return true;
    },
  );
}
