import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ficonsax/ficonsax.dart';

import '../core/palette.dart';

/// The "Ảnh Mẫu" feed: a scroll of the shots that ship with the app, each with
/// the Dazz credit block underneath. Everything here is bundled — no network.
class SamplePhotosScreen extends StatelessWidget {
  const SamplePhotosScreen({super.key});

  static const _samples = <String>[
    'assets/samples/sample_train.jpg',
    'assets/samples/sample_traindoor.jpg',
    'assets/samples/sample_street.jpg',
    'assets/samples/sample_field.jpg',
    'assets/samples/sample_beach.jpg',
    'assets/samples/sample_leaf.jpg',
    'assets/samples/sample_palm.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: P.black,
      body: Column(
        children: [
          SizedBox(height: pad.top),
          const _SampleAppBar(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: pad.bottom + 32),
              // The credit and the submit call sit once, above the feed —
              // repeating them under all seven shots was just noise.
              itemCount: _samples.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) return const _CreditHeader();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    _samples[i - 1],
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleAppBar extends StatelessWidget {
  const _SampleAppBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          GestureDetector(
            key: const Key('samples_back'),
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                IconsaxOutline.arrow_left,
                size: 24,
                color: P.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Ảnh Mẫu',
              textAlign: TextAlign.center,
              style: P.t(17, w: FontWeight.w600),
            ),
          ),
          // Balances the back button so the title sits optically centred.
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}

class _CreditHeader extends StatelessWidget {
  const _CreditHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ảnh mẫu của',
            style: P.t(13, w: FontWeight.w500, c: P.dim),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CustomPaint(painter: _DazzMarkPainter()),
              ),
              const SizedBox(width: 10),
              Text('Dazz', style: P.t(17, w: FontWeight.w600)),
              const SizedBox(width: 14),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: P.dim,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              const SizedBox(
                width: 30,
                height: 30,
                child: CustomPaint(painter: _InstagramPainter()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SubmitPill(),
        ],
      ),
    );
  }
}

class _SubmitPill extends StatelessWidget {
  const _SubmitPill();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: HapticFeedback.selectionClick,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(IconsaxOutline.add, size: 14, color: P.white),
              const SizedBox(width: 7),
              Text(
                'GỬI TÁC PHẨM CỦA TÔI',
                style: P.t(10, w: FontWeight.w600, ls: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Dazz app mark: a black disc with three coloured stripes swooping across
/// it, plus a white highlight.
class _DazzMarkPainter extends CustomPainter {
  const _DazzMarkPainter();

  static const _stripes = <Color>[
    Color(0xFF2E7BFF),
    Color(0xFF25D07A),
    Color(0xFFFF3B30),
    Color(0xFFFFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: s / 2)));
    canvas.drawCircle(c, s / 2, Paint()..color = const Color(0xFF0B0B0B));

    // Four parallel S-curves sweeping from bottom-left to top-right.
    final stroke = s * 0.13;
    for (var i = 0; i < _stripes.length; i++) {
      final shift = (i - 1.5) * s * 0.19;
      final path = Path()
        ..moveTo(c.dx - s * 0.42 + shift, c.dy + s * 0.40)
        ..cubicTo(
          c.dx - s * 0.05 + shift,
          c.dy + s * 0.28,
          c.dx - s * 0.02 + shift,
          c.dy - s * 0.24,
          c.dx + s * 0.40 + shift,
          c.dy - s * 0.40,
        );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = _stripes[i],
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DazzMarkPainter oldDelegate) => false;
}

/// Instagram glyph — rounded square, lens circle, top-right dot — filled with
/// the brand gradient.
class _InstagramPainter extends CustomPainter {
  const _InstagramPainter();

  static const _grad = <Color>[
    Color(0xFFFEDA75),
    Color(0xFFFA7E1E),
    Color(0xFFD62976),
    Color(0xFF962FBF),
    Color(0xFF4F5BD5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Rect.fromLTWH(0, 0, s, s);
    final shader = ui.Gradient.linear(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.top),
      _grad,
      const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
    final stroke = s * 0.085;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = shader;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(stroke / 2),
        Radius.circular(s * 0.27),
      ),
      paint,
    );
    canvas.drawCircle(rect.center, s * 0.215, paint);
    canvas.drawCircle(
      Offset(rect.left + s * 0.735, rect.top + s * 0.265),
      stroke * 0.62,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_InstagramPainter oldDelegate) => false;
}
