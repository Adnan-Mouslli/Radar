import 'package:flutter/material.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'dart:math' as math;

class NetworkErrorSkeleton extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;

  const NetworkErrorSkeleton({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  State<NetworkErrorSkeleton> createState() => _NetworkErrorSkeletonState();
}

class _NetworkErrorSkeletonState extends State<NetworkErrorSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // تأثير متحرك للشبكة المفقودة
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // دائرة تأثير الموجات
                      ...List.generate(3, (index) {
                        return Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                painter: CircleWavePainter(
                                  animation: _animation.value,
                                  waveIndex: index,
                                  maxRadius: constraints.maxWidth / 2,
                                ),
                                child: Container(),
                              );
                            },
                          ),
                        );
                      }),

                      // رمز الشبكة في المنتصف
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              color: Colors.red.shade300,
                              size: 50,
                            ),
                            CustomPaint(
                              painter: CrossLinePainter(
                                progress: _animation.value,
                                color: Colors.red.shade300,
                              ),
                              child: Container(
                                width: 70,
                                height: 70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // رسالة الخطأ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 10),
            // نص توضيحي إضافي
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "تأكد من اتصالك بالإنترنت وحاول مرة أخرى",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),
            // زر إعادة المحاولة مع تأثير متموج
            GestureDetector(
              onTap: widget.onRetry,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pulseValue =
                      1 + (math.sin(_controller.value * math.pi * 2) * 0.05);
                  return Transform.scale(
                    scale: pulseValue,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "إعادة المحاولة",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// رسام دوائر الموجات المتحركة
class CircleWavePainter extends CustomPainter {
  final double animation;
  final int waveIndex;
  final double maxRadius;

  CircleWavePainter({
    required this.animation,
    required this.waveIndex,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final delay = waveIndex * 0.3; // تأخير بين كل موجة
    final waveProgress = (animation + delay) % 1.0;

    // حساب نصف القطر المتنامي
    final radius = maxRadius * waveProgress;

    // تلاشي الشفافية كلما ابتعدت الموجة
    final opacity = (1.0 - waveProgress);

    final paint = Paint()
      ..color = Colors.red.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CircleWavePainter oldDelegate) => true;
}

// رسام الخط المتقاطع على الأيقونة
class CrossLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  CrossLinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // رسم خط متحرك عبر الأيقونة
    final angle = progress * 2 * math.pi;
    final x1 = center.dx + radius * math.cos(angle);
    final y1 = center.dy + radius * math.sin(angle);
    final x2 = center.dx + radius * math.cos(angle + math.pi);
    final y2 = center.dy + radius * math.sin(angle + math.pi);

    final lineProgress = (progress * 2) % 1.0;

    if (lineProgress < 0.5) {
      // الخط في طور الظهور
      final growProgress = lineProgress * 2; // 0 -> 1
      final startX = center.dx + (x1 - center.dx) * growProgress;
      final startY = center.dy + (y1 - center.dy) * growProgress;
      canvas.drawLine(center, Offset(startX, startY), paint);
    } else {
      // الخط في طور الاكتمال
      final growProgress = (lineProgress - 0.5) * 2; // 0 -> 1
      final endX = center.dx + (x2 - center.dx) * growProgress;
      final endY = center.dy + (y2 - center.dy) * growProgress;
      canvas.drawLine(Offset(x1, y1), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(CrossLinePainter oldDelegate) => true;
}
