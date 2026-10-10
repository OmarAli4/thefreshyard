import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TheFreshYardBrandLogo extends StatelessWidget {
  final double height;
  final Color color;

  const TheFreshYardBrandLogo({
    super.key,
    this.height = 46.0,
    this.color = AppColors.brandGold,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Sprout Leaves Vector
            CustomPaint(
              size: const Size(28, 14),
              painter: _SproutLeavesPainter(color: color),
            ),
            const SizedBox(height: 1.0),

            // 2. "THE"
            Text(
              'THE',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 3.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 1.5),

            // 3. "FRESH"
            Text(
              'FRESH',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 17.5,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 2.0,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 1.5),

            // 4. "YARD"
            Text(
              'YARD',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 17.5,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 2.5,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SproutLeavesPainter extends CustomPainter {
  final Color color;

  _SproutLeavesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.brandDarkGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Center base
    final baseX = w * 0.5;
    final baseY = h * 0.98;

    // Left leaf path
    final leftLeaf = Path();
    leftLeaf.moveTo(baseX, baseY);
    // Outer lower curve to tip
    leftLeaf.cubicTo(
      w * 0.22, baseY * 0.9,
      w * 0.04, h * 0.45,
      w * 0.02, h * 0.22,
    );
    // Outer upper curve from tip back to base
    leftLeaf.cubicTo(
      w * 0.16, h * 0.04,
      w * 0.40, h * 0.45,
      baseX, baseY,
    );
    leftLeaf.close();
    canvas.drawPath(leftLeaf, fillPaint);

    // Right leaf path (larger, per brand logo)
    final rightLeaf = Path();
    rightLeaf.moveTo(baseX, baseY);
    // Outer lower curve to tip
    rightLeaf.cubicTo(
      w * 0.72, baseY * 0.85,
      w * 0.94, h * 0.35,
      w * 0.98, h * 0.08,
    );
    // Outer upper curve from tip back to base
    rightLeaf.cubicTo(
      w * 0.82, h * 0.01,
      w * 0.58, h * 0.40,
      baseX, baseY,
    );
    rightLeaf.close();
    canvas.drawPath(rightLeaf, fillPaint);

    // Left leaf vein
    final leftVein = Path();
    leftVein.moveTo(baseX, baseY);
    leftVein.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.08, h * 0.24);
    canvas.drawPath(leftVein, linePaint);

    // Right leaf vein
    final rightVein = Path();
    rightVein.moveTo(baseX, baseY);
    rightVein.quadraticBezierTo(w * 0.76, h * 0.38, w * 0.92, h * 0.12);
    canvas.drawPath(rightVein, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SproutLeavesPainter oldDelegate) =>
      oldDelegate.color != color;
}
