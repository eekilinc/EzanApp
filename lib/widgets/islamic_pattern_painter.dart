import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  IslamicPatternPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.05 : 0.035)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double step = 64.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final center = Offset(x, y);
        const radius = step / 3.2;

        final path = Path();
        for (int i = 0; i < 8; i++) {
          final double angle = (i * 45) * math.pi / 180;
          final double r = (i % 2 == 0) ? radius : radius * 0.55;
          final px = center.dx + r * math.cos(angle);
          final py = center.dy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}
