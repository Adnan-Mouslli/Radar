import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:radar/core/constant/routes.dart';
import 'package:radar/core/services/DeepLinkService.dart';
import 'package:radar/core/services/services.dart';
import 'package:radar/core/services/version_check_service.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  final MyServices myServices = Get.find();

  // متغيرات للأنيميشن
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void onInit() {
    super.onInit();
    _initAnimations();
    _navigateToNextScreen();
  }

  @override
  void onClose() {
    // Importante: Disponer de los controladores de animación antes de llamar a super.onClose()
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.onClose();
  }

  void _initAnimations() {
    // أنيميشن الدوران
    _rotationController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // أنيميشن النبض
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // أنيميشن الظهور التدريجي
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  Future<bool> checkForUpdate() async {
    // الانتظار لبضع ثوان للتأكد من تحميل التطبيق
    await Future.delayed(const Duration(seconds: 2));

    final versionService = Get.find<VersionCheckService>();
    final needsUpdate = await versionService.needsUpdate();

    return needsUpdate;
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));

    bool needsUpdate = await checkForUpdate();
    final MyServices services = MyServices.instance;
    bool isDeepLink = services.getData("isDeepLink") ?? false;
    services.saveData("isDeepLink", false);
    if (needsUpdate) {
      Get.offAllNamed(AppRoute.forceUpdate);
    }
    // تحديد الشاشة التالية بناءً على حالة المستخدم
    else if (myServices.sharedPreferences.getString("onboarding") == null) {
      Get.offAllNamed(AppRoute.onBoarding);
    } else if (myServices.sharedPreferences.getString("loggedin") != "1") {
      print("this is a splash screen in login");
      Get.offAllNamed(AppRoute.login);
    } else if (!isDeepLink) {
      Get.offAllNamed(AppRoute.main);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();

    Get.delete<SplashController>();

    super.dispose();
  }

  // توفير الأنيميشن للواجهة
  AnimationController get rotationController => _rotationController;
  Animation<double> get pulseAnimation => _pulseAnimation;
  Animation<double> get fadeAnimation => _fadeAnimation;
}

class SplashScreen extends StatelessWidget {
  // final SplashController controller = Get.put(SplashController());
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          controller.rotationController,
          controller.pulseAnimation,
          controller.fadeAnimation,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  Colors.black,
                ],
                stops: [0.1, 0.6],
              ),
            ),
            child: Stack(
              children: [
                // نقاط متحركة في الخلفية
                _buildAnimatedParticles(size),

                // أشعة متوهجة
                _buildGlowingRays(),

                // المحتوى الرئيسي
                FadeTransition(
                  opacity: controller.fadeAnimation,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),

                            // الشعار المتحرك
                            _buildAnimatedLogo(),

                            const SizedBox(height: 40),

                            // اسم التطبيق بالعربي
                            _buildAppTitle(),

                            const SizedBox(height: 20),

                            // وصف التطبيق
                            _buildAppDescription(),

                            const Spacer(flex: 2),

                            // مؤشر التحميل
                            _buildLoadingIndicator(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // شعار التطبيق المتحرك
  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: controller.pulseAnimation,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primary.withOpacity(0.2),
              Colors.transparent,
            ],
            stops: [0.2, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // حلقة دائرية متحركة
            Positioned.fill(
              child: RotationTransition(
                turns: controller.rotationController,
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.1),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // الدائرة الداخلية مع صورة اللوغو
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.7),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  // استخدام صورة اللوغو بدلاً من الأيقونة
                  child: ClipOval(
                    child: Image.asset(
                      'assets/ReelWin.png', // تأكد من تحديث المسار الصحيح للصورة
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // تأثير بريق على الحافة
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنوان التطبيق
  Widget _buildAppTitle() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.white,
            AppColors.primary,
            Colors.white,
          ],
          stops: [0.1, 0.5, 0.9],
        ).createShader(bounds);
      },
      child: Text(
        'Radar',
        style: TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: AppFonts.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // وصف التطبيق
  Widget _buildAppDescription() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        'اكتشف أفضل العروض، شاهد واربح!',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16,
          fontWeight: AppFonts.medium,
        ),
      ),
    );
  }

  // مؤشر التحميل المخصص
  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'جاري التحميل...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: AppFonts.medium,
          ),
        ),
      ],
    );
  }

  // أشعة متوهجة
  Widget _buildGlowingRays() {
    return Positioned.fill(
      child: RotationTransition(
        turns: controller.rotationController,
        child: CustomPaint(
          painter: GlowingRaysPainter(
            color: AppColors.primary.withOpacity(0.15),
          ),
        ),
      ),
    );
  }

  // نقاط متحركة في الخلفية
  Widget _buildAnimatedParticles(Size size) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlesPainter(
          controller.rotationController.value,
          AppColors.primary.withOpacity(0.3),
          size,
        ),
      ),
    );
  }
}

// رسام للأشعة المتوهجة
class GlowingRaysPainter extends CustomPainter {
  final Color color;

  GlowingRaysPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.8;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // رسم الأشعة
    for (int i = 0; i < 8; i++) {
      final angle = math.pi * 2 * i / 8;
      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + dx * 0.3, center.dy + dy * 0.3)
        ..lineTo(center.dx + dx, center.dy + dy)
        ..lineTo(center.dx + dx * 0.3, center.dy + dy * 0.3)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// رسام للنقاط المتحركة
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final Size screenSize;

  ParticlesPainter(this.animationValue, this.color, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // استخدام بذرة ثابتة للتناسق

    // رسم 50 نقطة متحركة
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * screenSize.width;
      final y = random.nextDouble() * screenSize.height;
      final particleSize = random.nextDouble() * 3 + 1;

      // حساب حركة النقطة بناءً على قيمة الأنيميشن
      final moveX = math.sin(animationValue * 2 * math.pi + i) * 10;
      final moveY = math.cos(animationValue * 2 * math.pi + i) * 10;

      canvas.drawCircle(
        Offset(x + moveX, y + moveY),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
