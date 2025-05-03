import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:radar/core/theme/app_colors.dart';

class RadarPainter extends CustomPainter {
  final double sweepAngle;
  final double currentRadius;

  RadarPainter({
    required this.sweepAngle,
    required this.currentRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw radar background circles
    _drawRadarBackground(canvas, center, radius);

    // Draw radar indicator (sweeping line)
    _drawRadarIndicator(canvas, center, radius);

    // Draw radius text
    _drawRadiusText(canvas, center, radius);
  }

  void _drawRadarBackground(Canvas canvas, Offset center, double radius) {
    // Draw background glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.1));

    canvas.drawCircle(center, radius * 1.1, glowPaint);

    // Draw outer circle
    final outerCirclePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, outerCirclePaint);

    // Draw middle circle (2/3 of radius)
    final middleCirclePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 2 / 3, middleCirclePaint);

    // Draw inner circle (1/3 of radius)
    final innerCirclePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawCircle(center, radius * 1 / 3, innerCirclePaint);

    // Draw cross lines
    final linesPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linesPaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      linesPaint,
    );

    // Draw diagonal lines
    canvas.drawLine(
      Offset(center.dx - radius * 0.7, center.dy - radius * 0.7),
      Offset(center.dx + radius * 0.7, center.dy + radius * 0.7),
      linesPaint,
    );

    canvas.drawLine(
      Offset(center.dx - radius * 0.7, center.dy + radius * 0.7),
      Offset(center.dx + radius * 0.7, center.dy - radius * 0.7),
      linesPaint,
    );

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 3, centerDotPaint);
  }

  void _drawRadarIndicator(Canvas canvas, Offset center, double radius) {
    // Create the sweep gradient for the radar line
    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: sweepAngle,
      colors: [
        AppColors.primary.withOpacity(0.0),
        AppColors.primary.withOpacity(0.8),
      ],
      stops: [0.0, 0.9],
    );

    // Create a rect for the gradient
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Create the paint for the sweep
    final sweepPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw the sweep
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + radius * math.cos(sweepAngle),
        center.dy + radius * math.sin(sweepAngle),
      )
      ..arcTo(
        rect,
        sweepAngle,
        0.3,
        false,
      )
      ..lineTo(center.dx, center.dy);

    canvas.drawPath(path, sweepPaint);

    // Draw the radar line
    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * math.cos(sweepAngle),
        center.dy + radius * math.sin(sweepAngle),
      ),
      linePaint,
    );

    // Draw a small circle at the end of the line
    final circlePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        center.dx + radius * math.cos(sweepAngle),
        center.dy + radius * math.sin(sweepAngle),
      ),
      5,
      circlePaint,
    );

    // Add glow effect to the end point
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.8),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          center.dx + radius * math.cos(sweepAngle),
          center.dy + radius * math.sin(sweepAngle),
        ),
        radius: 15,
      ));

    canvas.drawCircle(
      Offset(
        center.dx + radius * math.cos(sweepAngle),
        center.dy + radius * math.sin(sweepAngle),
      ),
      15,
      glowPaint,
    );
  }

  void _drawRadiusText(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 2,
          offset: Offset(1, 1),
        ),
      ],
    );

    // Draw the current radius text at the bottom
    final textSpan = TextSpan(
      text: '${currentRadius.toStringAsFixed(1)} كم',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius + 10,
      ),
    );

    // Draw max distance text at the outer circle edge (right side)
    final maxTextSpan = TextSpan(
      text: '${currentRadius.toStringAsFixed(1)} كم',
      style: textStyle.copyWith(fontSize: 10),
    );

    final maxTextPainter = TextPainter(
      text: maxTextSpan,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    maxTextPainter.layout();
    maxTextPainter.paint(
      canvas,
      Offset(
        center.dx + radius - maxTextPainter.width / 2,
        center.dy - 15,
      ),
    );

    // Draw middle distance text (2/3 of max)
    final midTextSpan = TextSpan(
      text: '${(currentRadius * 2 / 3).toStringAsFixed(1)} كم',
      style: textStyle.copyWith(fontSize: 10),
    );

    final midTextPainter = TextPainter(
      text: midTextSpan,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    midTextPainter.layout();
    midTextPainter.paint(
      canvas,
      Offset(
        center.dx + (radius * 2 / 3) - midTextPainter.width / 2,
        center.dy - 15,
      ),
    );

    // Draw inner distance text (1/3 of max)
    final innerTextSpan = TextSpan(
      text: '${(currentRadius * 1 / 3).toStringAsFixed(1)} كم',
      style: textStyle.copyWith(fontSize: 10),
    );

    final innerTextPainter = TextPainter(
      text: innerTextSpan,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    innerTextPainter.layout();
    innerTextPainter.paint(
      canvas,
      Offset(
        center.dx + (radius * 1 / 3) - innerTextPainter.width / 2,
        center.dy - 15,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is RadarPainter) {
      return oldDelegate.sweepAngle != sweepAngle ||
          oldDelegate.currentRadius != currentRadius;
    }
    return true;
  }
}
