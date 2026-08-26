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
          SizedBox(height: pad.top + 4),
          const _SampleAppBar(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 8,
                bottom: pad.bottom + 32,
              ),
              itemCount: _samples.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) return const _CreditHeader();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      _samples[i - 1],
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
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
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          GestureDetector(
            key: const Key('samples_back'),
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0x332C2C2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconsaxOutline.arrow_left,
                size: 22,
                color: P.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Ảnh Mẫu',
              textAlign: TextAlign.center,
              style: P.t(18, w: FontWeight.w600),
            ),
          ),
          // Balances the back button so the title sits optically centred.
          const SizedBox(width: 44),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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

  void _showSubmitInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 290,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E20),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  IconsaxOutline.gallery_add,
                  size: 36,
                  color: P.white,
                ),
                const SizedBox(height: 14),
                Text(
                  'Gửi Tác Phẩm',
                  style: P.t(17, w: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tính năng gửi ảnh mẫu và cộng đồng sáng tạo sẽ ra mắt trong bản cập nhật tiếp theo.',
                  textAlign: TextAlign.center,
                  style: P.t(13, c: P.dim),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: P.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Đã hiểu',
                      style: P.t(14, w: FontWeight.w700, c: P.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          _showSubmitInfo(context);
        },
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
