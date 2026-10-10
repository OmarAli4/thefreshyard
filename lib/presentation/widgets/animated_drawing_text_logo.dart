import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class AnimatedDrawingTextLogo extends StatefulWidget {
  final double height;
  final Color strokeColor;
  final Color fillColor;
  final Duration duration;

  const AnimatedDrawingTextLogo({
    super.key,
    this.height = 40.0,
    this.strokeColor = Colors.white,
    this.fillColor = Colors.white,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedDrawingTextLogo> createState() =>
      _AnimatedDrawingTextLogoState();
}

class _AnimatedDrawingTextLogoState extends State<AnimatedDrawingTextLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Path _textPath;

  // The generated SVG path for "The Fresh Yard" using Figtree font
  final String svgPathString =
      "M11.9 0.0V-32.1H0.5V-35.0H26.5V-32.1H15.100000000000001V0.0ZM30.75 0.0V-35.0H33.75V-21.150000000000002Q35.0 -23.3 37.05 -24.450000000000003Q39.1 -25.6 41.85 -25.6Q44.75 -25.6 46.975 -24.425Q49.2 -23.25 50.475 -20.700000000000003Q51.75 -18.150000000000002 51.7 -13.950000000000001V0.0H48.7V-12.8Q48.7 -16.95 47.725 -19.1Q46.75 -21.25 45.075 -22.025Q43.400000000000006 -22.8 41.3 -22.8Q37.75 -22.8 35.75 -20.175Q33.75 -17.55 33.75 -12.850000000000001V0.0ZM69.25 0.6000000000000001Q65.65 0.6000000000000001 62.875 -1.075Q60.1 -2.75 58.525000000000006 -5.7Q56.95 -8.65 56.95 -12.5Q56.95 -16.35 58.5 -19.3Q60.050000000000004 -22.25 62.775000000000006 -23.925Q65.5 -25.6 69.0 -25.6Q72.55000000000001 -25.6 75.025 -23.875Q77.5 -22.150000000000002 78.80000000000001 -19.125Q80.10000000000001 -16.1 80.10000000000001 -12.15H59.900000000000006Q60.150000000000006 -7.4 62.675000000000004 -4.775Q65.2 -2.15 69.25 -2.15Q72.15 -2.15 74.17500000000001 -3.575Q76.2 -5.0 77.35000000000001 -7.25L79.85000000000001 -5.7Q78.9 -3.85 77.375 -2.425Q75.85000000000001 -1.0 73.80000000000001 -0.19999999999999996Q71.75 0.6000000000000001 69.25 0.6000000000000001ZM60.2 -14.9H76.85000000000001Q76.7 -17.3 75.7 -19.075000000000003Q74.7 -20.85 73.0 -21.85Q71.30000000000001 -22.85 69.0 -22.85Q66.75 -22.85 64.8 -21.85Q62.85 -20.85 61.625 -19.05Q60.400000000000006 -17.25 60.2 -14.9ZM101.85000000000001 0.0V-35.0H122.00000000000001V-32.1H105.05000000000001V-18.75H120.30000000000001V-15.850000000000001H105.05000000000001V0.0ZM127.55000000000001 0.0V-25.0H130.55V-20.6Q132.0 -22.950000000000003 134.4 -24.025000000000002Q136.8 -25.1 139.4 -25.1V-22.35Q137.20000000000002 -22.35 135.175 -21.575000000000003Q133.15 -20.8 131.85000000000002 -18.975Q130.55 -17.150000000000002 130.55 -14.0V0.0ZM154.45000000000002 0.6000000000000001Q150.85 0.6000000000000001 148.075 -1.075Q145.3 -2.75 143.72500000000002 -5.7Q142.15 -8.65 142.15 -12.5Q142.15 -16.35 143.7 -19.3Q145.25 -22.25 147.97500000000002 -23.925Q150.70000000000002 -25.6 154.20000000000002 -25.6Q157.75 -25.6 160.22500000000002 -23.875Q162.70000000000002 -22.150000000000002 164.0 -19.125Q165.3 -16.1 165.3 -12.15H145.1Q145.35 -7.4 147.875 -4.775Q150.4 -2.15 154.45000000000002 -2.15Q157.35 -2.15 159.375 -3.575Q161.4 -5.0 162.55 -7.25L165.05 -5.7Q164.10000000000002 -3.85 162.57500000000002 -2.425Q161.05 -1.0 159.0 -0.19999999999999996Q156.95000000000002 0.6000000000000001 154.45000000000002 0.6000000000000001ZM145.4 -14.9H162.05Q161.9 -17.3 160.9 -19.075000000000003Q159.9 -20.85 158.2 -21.85Q156.5 -22.85 154.20000000000002 -22.85Q151.95000000000002 -22.85 150.0 -21.85Q148.05 -20.85 146.825 -19.05Q145.6 -17.25 145.4 -14.9ZM179.3 0.6000000000000001Q176.45000000000002 0.6000000000000001 174.40000000000003 -0.25Q172.35000000000002 -1.1 171.07500000000002 -2.45Q169.8 -3.8000000000000003 169.3 -5.25L172.0 -6.25Q172.85000000000002 -4.4 174.72500000000002 -3.2750000000000004Q176.60000000000002 -2.15 178.75 -2.15Q181.4 -2.15 183.25 -3.25Q185.10000000000002 -4.3500000000000005 185.10000000000002 -6.3500000000000005Q185.10000000000002 -8.15 183.75 -9.3Q182.4 -10.450000000000001 179.75 -11.15L177.3 -11.8Q173.95000000000002 -12.700000000000001 172.125 -14.425Q170.3 -16.150000000000002 170.3 -18.3Q170.3 -21.75 172.57500000000002 -23.675Q174.85000000000002 -25.6 179.45000000000002 -25.6Q181.60000000000002 -25.6 183.32500000000002 -24.975Q185.05 -24.35 186.275 -23.200000000000003Q187.5 -22.05 188.10000000000002 -20.450000000000003L185.4 -19.3Q184.60000000000002 -21.25 183.05 -22.05Q181.5 -22.85 179.0 -22.85Q176.35000000000002 -22.85 174.82500000000002 -21.725Q173.3 -20.6 173.3 -18.55Q173.3 -17.45 174.525 -16.375Q175.75 -15.3 178.20000000000002 -14.65L180.35000000000002 -14.100000000000001Q182.8 -13.5 184.525 -12.375Q186.25 -11.25 187.175 -9.8Q188.10000000000002 -8.35 188.10000000000002 -6.6000000000000005Q188.10000000000002 -4.3500000000000005 186.95000000000002 -2.7250000000000005Q185.8 -1.1 183.82500000000002 -0.25Q181.85000000000002 0.6000000000000001 179.3 0.6000000000000001ZM194.10000000000002 0.0V-35.0H197.10000000000002V-21.150000000000002Q198.35000000000002 -23.3 200.40000000000003 -24.450000000000003Q202.45000000000002 -25.6 205.20000000000002 -25.6Q208.10000000000002 -25.6 210.32500000000002 -24.425Q212.55 -23.25 213.82500000000002 -20.700000000000003Q215.10000000000002 -18.150000000000002 215.05 -13.950000000000001V0.0H212.05V-12.8Q212.05 -16.95 211.07500000000002 -19.1Q210.10000000000002 -21.25 208.425 -22.025Q206.75000000000003 -22.8 204.65000000000003 -22.8Q201.10000000000002 -22.8 199.10000000000002 -20.175Q197.10000000000002 -17.55 197.10000000000002 -12.850000000000001V0.0ZM246.15 0.0V-14.600000000000001L233.55 -35.0H237.3L247.75 -17.95L258.2 -35.0H261.95L249.35000000000002 -14.600000000000001V0.0ZM274.05 0.6000000000000001Q269.65 0.6000000000000001 267.17499999999995 -1.425Q264.7 -3.45 264.7 -7.050000000000001Q264.7 -10.75 267.17499999999995 -12.8Q269.65 -14.850000000000001 274.05 -14.850000000000001H281.45Q281.25 -18.85 279.6 -20.85Q277.95 -22.85 274.55 -22.85Q272.3 -22.85 270.775 -21.950000000000003Q269.25 -21.05 268.25 -19.150000000000002L265.55 -20.35Q266.59999999999997 -22.150000000000002 267.92499999999995 -23.300000000000004Q269.25 -24.450000000000003 270.9 -25.025000000000002Q272.55 -25.6 274.55 -25.6Q277.9 -25.6 280.1 -24.25Q282.3 -22.900000000000002 283.4 -20.200000000000003Q284.5 -17.5 284.5 -13.4V0.0H281.75L281.5 -3.5Q280.34999999999997 -1.55 278.45 -0.475Q276.55 0.6000000000000001 274.05 0.6000000000000001ZM273.84999999999997 -2.15Q276.25 -2.15 277.975 -3.125Q279.7 -4.1000000000000005 280.6 -6.0Q281.5 -7.9 281.5 -10.700000000000001V-12.100000000000001H274.45Q270.84999999999997 -12.100000000000001 269.275 -10.775000000000002Q267.7 -9.450000000000001 267.7 -7.050000000000001Q267.7 -4.75 269.325 -3.45Q270.95 -2.15 273.84999999999997 -2.15ZM291.25 0.0V-25.0H294.25V-20.6Q295.7 -22.950000000000003 298.1 -24.025000000000002Q300.5 -25.1 303.1 -25.1V-22.35Q300.9 -22.35 298.875 -21.575000000000003Q296.85 -20.8 295.55 -18.975Q294.25 -17.150000000000002 294.25 -14.0V0.0ZM317.15000000000003 0.6000000000000001Q313.85 0.6000000000000001 311.3 -1.075Q308.75 -2.75 307.3 -5.7250000000000005Q305.85 -8.700000000000001 305.85 -12.5Q305.85 -16.35 307.3 -19.3Q308.75 -22.25 311.3 -23.925Q313.85 -25.6 317.15000000000003 -25.6Q320.0 -25.6 322.275 -24.225Q324.55 -22.85 325.95000000000005 -20.450000000000003V-35.0H328.95000000000005V0.0H326.1L325.95000000000005 -4.55Q324.55 -2.15 322.275 -0.7749999999999999Q320.0 0.6000000000000001 317.15000000000003 0.6000000000000001ZM317.75 -2.1Q320.15000000000003 -2.1 322.0 -3.425Q323.85 -4.75 324.90000000000003 -7.1000000000000005Q325.95000000000005 -9.450000000000001 325.95000000000005 -12.450000000000001V-12.5Q325.95000000000005 -15.55 324.90000000000003 -17.9Q323.85 -20.25 322.0 -21.575000000000003Q320.15000000000003 -22.900000000000002 317.70000000000005 -22.900000000000002Q315.1 -22.900000000000002 313.1 -21.575000000000003Q311.1 -20.25 309.975 -17.9Q308.85 -15.55 308.85 -12.5Q308.85 -9.450000000000001 310.0 -7.1000000000000005Q311.15000000000003 -4.75 313.15000000000003 -3.425Q315.15000000000003 -2.1 317.75 -2.1Z";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // 1. Parse the SVG path data
    _textPath = parseSvgPathData(svgPathString);

    // 2. Normalize path to bounds starting at (0,0)
    final Rect bounds = _textPath.getBounds();
    final Matrix4 matrix = Matrix4.identity();
    matrix.setTranslationRaw(-bounds.left, -bounds.top, 0.0);
    _textPath = _textPath.transform(matrix.storage);

    // Run animation once and stay permanently drawn
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Rect bounds = _textPath.getBounds();
    final double aspectRatio = bounds.width / bounds.height;
    final double width = widget.height * aspectRatio;

    return SizedBox(
      width: width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LogoPainter(
              path: _textPath,
              progress: _controller.value,
              strokeColor: widget.strokeColor,
              fillColor: widget.fillColor,
            ),
          );
        },
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Path path;
  final double progress;
  final Color strokeColor;
  final Color fillColor;

  _LogoPainter({
    required this.path,
    required this.progress,
    required this.strokeColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = path.getBounds();
    // In case bounds are 0 to prevent division by zero
    if (bounds.width == 0 || bounds.height == 0) return;

    final double scaleX = size.width / bounds.width;
    final double scaleY = size.height / bounds.height;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Dynamically size the stroke based on scaling
    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 / scaleY
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // The stroke animation will take up the first 80% of the total animation duration
    final double strokeAnimationProgress = (progress / 0.8).clamp(0.0, 1.0);

    // The fill animation will smoothly fade in during the last 30% of the animation
    final double fillOpacity = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
    final Paint fillPaint = Paint()
      ..color = fillColor.withValues(alpha: fillOpacity)
      ..style = PaintingStyle.fill;

    // We extract the partial paths from each contour based on the total path length
    final List<PathMetric> metrics = path.computeMetrics().toList();

    // Sequential Drawing Implementation:
    double totalLength = 0;
    for (final metric in metrics) {
      totalLength += metric.length;
    }

    double currentLength = 0;
    final double targetLength = totalLength * strokeAnimationProgress;

    for (final metric in metrics) {
      if (currentLength >= targetLength) {
        break;
      }

      final double remainingLength = targetLength - currentLength;
      final double extractLength = remainingLength > metric.length
          ? metric.length
          : remainingLength;

      final Path extractedSegment = metric.extractPath(0.0, extractLength);

      // Draw glow
      final Paint glowPaint = Paint()
        ..color = strokeColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 / scaleY
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      canvas.drawPath(extractedSegment, glowPaint);
      // Draw actual stroke
      canvas.drawPath(extractedSegment, strokePaint);

      currentLength += metric.length;
    }

    // Fill Drawing Implementation
    if (fillOpacity > 0.0) {
      canvas.drawPath(path, fillPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor;
  }
}
