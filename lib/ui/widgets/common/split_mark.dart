import 'package:flutter/material.dart';

/// Split mark: a receipt/bill with a soft split seam.
/// Custom-drawn so it follows the active theme color and stays crisp at 20–28 dp.
class SplitMark extends StatelessWidget {
  const SplitMark({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return CustomPaint(
      size: Size.square(size),
      painter: _SplitMarkPainter(c),
    );
  }
}

class _SplitMarkPainter extends CustomPainter {
  _SplitMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Back bill: a soft, translucent card.
    final back = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.22, w * 0.54, h * 0.56),
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(
      back,
      Paint()..color = color.withValues(alpha: 0.16),
    );
    canvas.drawRRect(
      back,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055,
    );

    // Front bill: crisp outline, offset like it was pulled apart.
    final front = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.36, h * 0.10, w * 0.54, h * 0.56),
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(
      front,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.085,
    );

    // Two shares inside the front bill.
    final dot = Paint()..color = color;
    canvas.drawCircle(Offset(w * 0.52, h * 0.36), w * 0.055, dot);
    canvas.drawCircle(Offset(w * 0.75, h * 0.36), w * 0.055, dot);
    canvas.drawLine(
      Offset(w * 0.52, h * 0.52),
      Offset(w * 0.75, h * 0.52),
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = w * 0.06
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SplitMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
