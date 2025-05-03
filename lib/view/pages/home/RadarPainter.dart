import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:radar/core/theme/app_colors.dart';

// رسام الرادار المتحرك
class RadarPainter extends CustomPainter {
  final double sweepAngle;
  final double currentRadius;

  RadarPainter({required this.sweepAngle, required this.currentRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // رسم الدوائر المتحدة المركز
    final Paint circlePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // رسم 5 دوائر بناءً على نصف القطر
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius * i / 5,
        circlePaint,
      );
    }

    // رسم خطوط تقسيم الدائرة
    final Paint linePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // رسم 8 خطوط تقسم الدائرة
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;

      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX + dx, centerY + dy),
        linePaint,
      );
    }

    // رسم الخط الدوار (شعاع الرادار)
    final Paint sweepPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // تحديد مسار الشعاع
    final sweepPath = Path()
      ..moveTo(centerX, centerY)
      ..lineTo(
        centerX + math.cos(sweepAngle) * radius,
        centerY + math.sin(sweepAngle) * radius,
      )
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        sweepAngle,
        0.4,
        false,
      )
      ..lineTo(centerX, centerY);

    canvas.drawPath(sweepPath, sweepPaint);

    // رسم نقطة المركز
    final Paint centerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      5.0,
      centerPaint,
    );

    // رسم هالة حول المركز
    final Paint glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0);

    canvas.drawCircle(
      Offset(centerX, centerY),
      20.0,
      glowPaint,
    );

    // إضافة معلومات نصية
    final textPainter = TextPainter(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        text: '${currentRadius.toStringAsFixed(1)} كم',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, centerY + radius + 10),
    );
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.currentRadius != currentRadius;
  }
}
