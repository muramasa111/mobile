import 'package:flutter/material.dart';

class StarBackground extends StatelessWidget {
  final Widget child;

  const StarBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _StarBackgroundPainter())),
        child,
      ],
    );
  }
}

class _StarBackgroundPainter extends CustomPainter {
  const _StarBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 100; index++) {
      final x = (index * 233.0) % size.width;
      final y = (index * 149.0) % size.height;
      final radius = 0.7 + (index % 3) * 0.4;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = Colors.white.withValues(alpha: 0.38),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarBackgroundPainter oldDelegate) => false;
}
