import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/constants.dart';

class CategoryNav extends StatelessWidget {
  const CategoryNav({super.key});

  static const _items = [
    (_CategoryIconType.grid, 'Kategori'),
    (_CategoryIconType.smartphone, 'Handphone & Tablet'),
    (_CategoryIconType.receipt, 'Top-Up & Tagihan'),
    (_CategoryIconType.headphones, 'Elektronik'),
    (_CategoryIconType.paw, 'Perawatan Hewan'),
    (_CategoryIconType.wallet, 'Keuangan'),
    (_CategoryIconType.monitor, 'Komputer & Laptop'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Center(
            child: _CategoryChip(icon: item.$1, label: item.$2),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _CategoryIconType icon;
  final String label;

  const _CategoryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD4DBE5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CategoryIcon(type: icon),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

enum _CategoryIconType {
  grid,
  smartphone,
  receipt,
  headphones,
  paw,
  wallet,
  monitor,
}

class _CategoryIcon extends StatelessWidget {
  final _CategoryIconType type;

  const _CategoryIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _CategoryIconPainter(type)),
    );
  }
}

class _CategoryIconPainter extends CustomPainter {
  static const _green = AppColors.green;
  static const _greenDark = AppColors.greenDark;
  static const _red = Color(0xFFFF3D57);
  static const _orange = Color(0xFFFFB020);
  static const _blue = Color(0xFF2489FF);
  static const _teal = Color(0xFF168B92);
  static const _yellow = Color(0xFFF4B400);
  static const _ink = Color(0xFF4A5568);

  final _CategoryIconType type;

  const _CategoryIconPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 20;
    canvas.save();
    canvas.scale(scale);

    switch (type) {
      case _CategoryIconType.grid:
        _paintGrid(canvas);
      case _CategoryIconType.smartphone:
        _paintSmartphone(canvas);
      case _CategoryIconType.receipt:
        _paintReceipt(canvas);
      case _CategoryIconType.headphones:
        _paintHeadphones(canvas);
      case _CategoryIconType.paw:
        _paintPaw(canvas);
      case _CategoryIconType.wallet:
        _paintWallet(canvas);
      case _CategoryIconType.monitor:
        _paintMonitor(canvas);
    }

    canvas.restore();
  }

  Paint _stroke(Color color, {double width = 1.55}) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  Paint _fill(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  void _paintGrid(Canvas canvas) {
    const rects = [
      (Offset(2.6, 2.9), _green),
      (Offset(10.9, 2.9), _red),
      (Offset(2.6, 11.0), _orange),
      (Offset(10.9, 11.0), _greenDark),
    ];

    for (final item in rects) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(item.$1.dx, item.$1.dy, 6.0, 6.0),
        const Radius.circular(2.0),
      );
      canvas.drawRRect(rect, _stroke(item.$2, width: 1.45));
    }

    canvas.drawCircle(const Offset(5.6, 5.9), 1.0, _fill(_green));
    canvas.drawCircle(const Offset(13.9, 14.0), 1.0, _fill(_greenDark));
  }

  void _paintSmartphone(Canvas canvas) {
    canvas.save();
    canvas.translate(10, 10);
    canvas.rotate(-0.26);

    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-4.4, -8.0, 8.8, 16.0),
      const Radius.circular(1.9),
    );
    final screen = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-2.9, -5.7, 5.8, 10.5),
      const Radius.circular(1.2),
    );

    canvas.drawRRect(body, _stroke(_blue, width: 1.55));
    canvas.drawRRect(screen, _fill(const Color(0xFFEAF8EE)));
    canvas.drawRRect(screen, _stroke(_green, width: 1.15));
    canvas.drawLine(
      const Offset(-1.2, 6.3),
      const Offset(1.2, 6.3),
      _stroke(_orange, width: 1.2),
    );

    canvas.restore();
  }

  void _paintReceipt(Canvas canvas) {
    final outline = Path()
      ..moveTo(5.0, 2.8)
      ..lineTo(14.5, 2.8)
      ..quadraticBezierTo(15.7, 2.8, 15.7, 4.0)
      ..lineTo(15.7, 16.8)
      ..lineTo(13.8, 15.6)
      ..lineTo(11.8, 16.8)
      ..lineTo(9.8, 15.6)
      ..lineTo(7.8, 16.8)
      ..lineTo(5.8, 15.6)
      ..lineTo(4.0, 16.8)
      ..lineTo(4.0, 4.0)
      ..quadraticBezierTo(4.0, 2.8, 5.0, 2.8);

    canvas.drawPath(outline, _stroke(_teal));
    canvas.drawLine(
      const Offset(6.4, 6.5),
      const Offset(13.2, 6.5),
      _stroke(_ink, width: 1.25),
    );
    canvas.drawLine(
      const Offset(6.4, 9.4),
      const Offset(12.1, 9.4),
      _stroke(_teal, width: 1.25),
    );
    canvas.drawLine(
      const Offset(6.4, 12.3),
      const Offset(10.4, 12.3),
      _stroke(_ink, width: 1.25),
    );
  }

  void _paintHeadphones(Canvas canvas) {
    final bandRect = const Rect.fromLTWH(3.6, 3.6, 12.8, 12.0);
    canvas.drawArc(
      bandRect,
      math.pi,
      math.pi,
      false,
      _stroke(_red, width: 1.7),
    );
    canvas.drawLine(
      const Offset(3.6, 10.0),
      const Offset(3.6, 13.0),
      _stroke(_red, width: 1.6),
    );
    canvas.drawLine(
      const Offset(16.4, 10.0),
      const Offset(16.4, 13.0),
      _stroke(_red, width: 1.6),
    );

    final leftPad = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.3, 10.7, 3.3, 5.4),
      const Radius.circular(1.3),
    );
    final rightPad = RRect.fromRectAndRadius(
      const Rect.fromLTWH(14.4, 10.7, 3.3, 5.4),
      const Radius.circular(1.3),
    );

    canvas.drawRRect(leftPad, _fill(_red));
    canvas.drawRRect(rightPad, _fill(_red));
    canvas.drawCircle(const Offset(5.1, 5.2), 0.9, _fill(_yellow));
    canvas.drawCircle(const Offset(15.0, 5.2), 0.9, _fill(_green));
  }

  void _paintPaw(Canvas canvas) {
    final toePaint = _stroke(_yellow, width: 1.35);
    canvas.drawOval(const Rect.fromLTWH(4.0, 5.0, 3.2, 4.3), toePaint);
    canvas.drawOval(const Rect.fromLTWH(7.2, 3.6, 3.5, 4.7), toePaint);
    canvas.drawOval(const Rect.fromLTWH(10.7, 3.6, 3.5, 4.7), toePaint);
    canvas.drawOval(const Rect.fromLTWH(13.7, 5.0, 3.2, 4.3), toePaint);

    final pad = Path()
      ..moveTo(6.0, 14.8)
      ..cubicTo(6.4, 10.8, 8.0, 8.7, 10.0, 8.7)
      ..cubicTo(12.0, 8.7, 13.6, 10.8, 14.0, 14.8)
      ..cubicTo(14.2, 17.0, 12.1, 17.5, 10.0, 16.4)
      ..cubicTo(7.9, 17.5, 5.8, 17.0, 6.0, 14.8);

    canvas.drawPath(pad, _stroke(_yellow, width: 1.45));
    canvas.drawCircle(const Offset(10.0, 12.7), 1.0, _fill(_green));
  }

  void _paintWallet(Canvas canvas) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.6, 6.1, 14.8, 9.8),
      const Radius.circular(2.0),
    );
    final flap = Path()
      ..moveTo(4.5, 6.0)
      ..lineTo(12.3, 3.7)
      ..quadraticBezierTo(13.7, 3.3, 14.2, 4.7)
      ..lineTo(14.8, 6.1);

    canvas.drawPath(flap, _stroke(_ink, width: 1.35));
    canvas.drawRRect(body, _stroke(_yellow, width: 1.55));
    canvas.drawLine(
      const Offset(5.6, 9.2),
      const Offset(10.2, 9.2),
      _stroke(_ink, width: 1.2),
    );
    canvas.drawLine(
      const Offset(5.6, 12.5),
      const Offset(8.8, 12.5),
      _stroke(_green, width: 1.2),
    );
    canvas.drawCircle(const Offset(14.4, 11.0), 1.0, _fill(_yellow));
  }

  void _paintMonitor(Canvas canvas) {
    final screen = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.7, 4.0, 14.6, 10.2),
      const Radius.circular(1.4),
    );

    canvas.drawRRect(screen, _stroke(_green, width: 1.55));
    canvas.drawLine(
      const Offset(7.7, 16.6),
      const Offset(12.3, 16.6),
      _stroke(_greenDark, width: 1.45),
    );
    canvas.drawLine(
      const Offset(10.0, 14.4),
      const Offset(10.0, 16.4),
      _stroke(_greenDark, width: 1.45),
    );
    canvas.drawLine(
      const Offset(5.4, 7.0),
      const Offset(9.4, 7.0),
      _stroke(_green, width: 1.15),
    );
    canvas.drawLine(
      const Offset(5.4, 9.8),
      const Offset(11.9, 9.8),
      _stroke(_green, width: 1.15),
    );
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
