import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfcam_flutter/core/app_state.dart';
import 'package:rfcam_flutter/widgets/focus_reticle.dart';
import 'package:rfcam_flutter/widgets/viewfinder.dart';

void main() {
  testWidgets('FocusReticle paints correctly with given EV', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FocusReticle(
                position: Offset(100, 100),
                ev: 1.5,
                visible: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(FocusReticle), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FocusReticle),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('FocusReticle smoothly fades out when visible becomes false', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FocusReticle(
                position: Offset(100, 100),
                ev: 0.0,
                visible: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(FocusReticle),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );

    // Update to invisible
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FocusReticle(
                position: Offset(100, 100),
                ev: 0.0,
                visible: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(FocusReticle),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'Viewfinder triggers focus callback and renders reticle and zoom badge',
    (tester) async {
      final state = AppState();
      Offset? tappedPos;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 600,
              child: Viewfinder(
                state: state,
                preview: const SizedBox(),
                focusPos: const Offset(150, 200),
                focusVisible: true,
                zoomLevel: 2.0,
                zoomBadgeVisible: true,
                onTapDots: () {},
                onTapWhiteBalance: () {},
                onTapFocal: () {},
                onTapExposure: () {},
                onTapFocus: (pos, size) {
                  tappedPos = pos;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FocusReticle), findsOneWidget);
      expect(find.text('2.0x'), findsOneWidget);

      await tester.tap(find.byType(Viewfinder));
      expect(tappedPos, isNotNull);
      await tester.pumpAndSettle();
    },
  );
}
