import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedWalkingMan extends StatefulWidget {
  final double height;
  final Color color;
  final Duration duration;

  const AnimatedWalkingMan({
    super.key,
    this.height = 40,
    this.color = Colors.white,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedWalkingMan> createState() => _AnimatedWalkingManState();
}

class _AnimatedWalkingManState extends State<AnimatedWalkingMan> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.height * 1.5, widget.height),
          painter: _WalkingManPainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _WalkingManPainter extends CustomPainter {
  final double progress;
  final Color color;

  _WalkingManPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Phase angle for cyclic animation (0 to 2PI)
    final double phase = progress * 2 * math.pi;

    // Bobbing offset (moves up and down twice per cycle)
    final double bobbing = math.sin(phase * 2) * (h * 0.03);

    // Root position (Hip)
    final Offset hip = Offset(size.width * 0.35, h * 0.55 + bobbing);
    final Offset shoulder = Offset(hip.dx + h * 0.1, hip.dy - h * 0.3);
    final Offset head = Offset(shoulder.dx + h * 0.05, shoulder.dy - h * 0.15);

    // Leg dimensions
    final double thighLen = h * 0.22;
    final double shinLen = h * 0.22;

    // Max rotation angles for joints
    final double maxHipAngle = math.pi / 4;
    final double maxKneeAngle = math.pi / 2;

    // Calculate angles for Leg 1 (Front)
    double hipAngle1 = math.sin(phase) * maxHipAngle;
    double kneeAngle1 = (math.cos(phase) > 0) ? -math.cos(phase) * maxKneeAngle : 0.0;

    // Calculate angles for Leg 2 (Back, offset by PI)
    double hipAngle2 = math.sin(phase + math.pi) * maxHipAngle;
    double kneeAngle2 = (math.cos(phase + math.pi) > 0) ? -math.cos(phase + math.pi) * maxKneeAngle : 0.0;

    void drawLeg(double hipAngle, double kneeAngle, Paint p) {
      final Offset knee = Offset(
        hip.dx + thighLen * math.sin(hipAngle),
        hip.dy + thighLen * math.cos(hipAngle),
      );
      final double shinTotalAngle = hipAngle + kneeAngle;
      final Offset foot = Offset(
        knee.dx + shinLen * math.sin(shinTotalAngle),
        knee.dy + shinLen * math.cos(shinTotalAngle),
      );
      
      final Path legPath = Path()
        ..moveTo(hip.dx, hip.dy)
        ..lineTo(knee.dx, knee.dy)
        ..lineTo(foot.dx, foot.dy)
        ..lineTo(foot.dx + h * 0.08, foot.dy); // foot segment
      canvas.drawPath(legPath, p);
    }

    // Draw back leg with slight opacity for depth illusion
    final Paint backPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    drawLeg(hipAngle2, kneeAngle2, backPaint);

    // Draw Cart
    final Offset cartBase = Offset(shoulder.dx + h * 0.4, h * 0.75 + bobbing * 0.3);
    final Offset hand = Offset(shoulder.dx + h * 0.25, shoulder.dy + h * 0.05); // Handle position
    
    final Path cartPath = Path()
      ..moveTo(hand.dx, hand.dy) // connecting handle to cart
      ..lineTo(cartBase.dx - h * 0.05, cartBase.dy - h * 0.25)
      ..lineTo(cartBase.dx - h * 0.05, cartBase.dy) // back wall
      ..lineTo(cartBase.dx + h * 0.3, cartBase.dy) // bottom
      ..lineTo(cartBase.dx + h * 0.35, cartBase.dy - h * 0.25) // front wall
      ..lineTo(cartBase.dx - h * 0.05, cartBase.dy - h * 0.25); // top frame
    
    // Grid lines on cart basket
    cartPath.moveTo(cartBase.dx + h * 0.08, cartBase.dy);
    cartPath.lineTo(cartBase.dx + h * 0.08, cartBase.dy - h * 0.25);
    cartPath.moveTo(cartBase.dx + h * 0.2, cartBase.dy);
    cartPath.lineTo(cartBase.dx + h * 0.2, cartBase.dy - h * 0.25);
    cartPath.moveTo(cartBase.dx - h * 0.05, cartBase.dy - h * 0.12);
    cartPath.lineTo(cartBase.dx + h * 0.32, cartBase.dy - h * 0.12);

    canvas.drawPath(cartPath, paint);
    
    // Cart wheels
    canvas.drawCircle(Offset(cartBase.dx, cartBase.dy + h * 0.08), h * 0.05, fillPaint);
    canvas.drawCircle(Offset(cartBase.dx + h * 0.25, cartBase.dy + h * 0.08), h * 0.05, fillPaint);

    // Draw Torso
    final Path torsoPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy)
      ..lineTo(hip.dx, hip.dy);
    canvas.drawPath(torsoPath, paint);

    // Draw Arms
    // A simple FK IK: elbow bends slightly downwards
    final Offset elbow = Offset(shoulder.dx + h * 0.12, shoulder.dy + h * 0.15);
    final Path armPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(hand.dx, hand.dy);
    canvas.drawPath(armPath, paint);

    // Draw Head
    canvas.drawCircle(head, h * 0.1, fillPaint);

    // Draw front leg (drawn last so it appears in front)
    drawLeg(hipAngle1, kneeAngle1, paint);
  }

  @override
  bool shouldRepaint(covariant _WalkingManPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
