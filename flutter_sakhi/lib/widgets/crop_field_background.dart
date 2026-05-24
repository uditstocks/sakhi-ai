import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';

/// Deep green base with warm sunlight, soft hills, and crop-row texture.
class CropFieldBackground extends StatelessWidget {
  const CropFieldBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3A6B1F),
                SakhiColors.deepGreen,
                SakhiColors.deepGreenDark,
                Color(0xFF1A3010),
              ],
              stops: [0.0, 0.35, 0.72, 1.0],
            ),
          ),
        ),
        CustomPaint(painter: _FieldAtmospherePainter()),
        CustomPaint(painter: _CropRowPainter()),
        child,
      ],
    );
  }
}

class _FieldAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm sunrise glow behind the mic area
    final sunGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.1, -0.35),
        radius: 0.95,
        colors: [
          SakhiColors.gold.withValues(alpha: 0.18),
          SakhiColors.gold.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sunGlow);

    // Soft hill silhouettes at the bottom
    final hillPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.62,
        size.width * 0.5,
        size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.78,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      hillPath,
      Paint()..color = const Color(0xFF1E3810).withValues(alpha: 0.55),
    );

    // Gentle light rays
    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));

    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.15 + i * 0.18);
      final ray = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 40, size.height * 0.55)
        ..lineTo(x - 40, size.height * 0.55)
        ..close();
      canvas.drawPath(ray, rayPaint);
    }

    // Scattered seed dots (texture)
    final dotPaint = Paint()..color = SakhiColors.gold.withValues(alpha: 0.08);
    final random = math.Random(42);
    for (var i = 0; i < 48; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = size.height * 0.3 + random.nextDouble() * size.height * 0.55;
      canvas.drawCircle(Offset(dx, dy), 1.2 + random.nextDouble(), dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CropRowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    const rowSpacing = 26.0;
    for (double y = size.height * 0.38; y < size.height; y += rowSpacing) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 36) {
        path.lineTo(
          x,
          y + math.sin((x / size.width) * math.pi * 5 + y * 0.02) * 4,
        );
      }
      canvas.drawPath(path, rowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
