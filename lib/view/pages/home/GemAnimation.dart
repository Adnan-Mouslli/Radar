import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class GemModel {
  final int points;
  final String color;

  GemModel({required this.points, required this.color});
}

class ModernGemAnimation extends StatefulWidget {
  final GemModel gem;
  final VoidCallback? onAnimationComplete;

  const ModernGemAnimation({
    Key? key,
    required this.gem,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<ModernGemAnimation> createState() => _ModernGemAnimationState();
}

class _ModernGemAnimationState extends State<ModernGemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pointsMotionAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<double> _cardOffsetAnimation;

  // ألوان متنوعة للإنفجارات الصغيرة
  final List<Color> _particleColors = [
    Colors.amber,
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // تفعيل الرسوم المتحركة المختلفة
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    _backgroundOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.5)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
    ]).animate(_controller);

    // دوران بسيط للجوهرة
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // رسوم متحركة لظهور النقاط
    _pointsMotionAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 20, end: 0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 100,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 0.7),
      ),
    );

    // رسوم متحركة لارتفاع البطاقة
    _cardOffsetAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 100, end: 0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 100,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1, 0.4),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onAnimationComplete != null) {
          widget.onAnimationComplete!();
        }
      }
    });

    // تشغيل الرسوم المتحركة تلقائياً
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    
    // استخدام العرض لتحديد حجم البطاقة
    final double cardWidth = math.min(screenSize.width * 0.85, 320.0);
    
    // تحديد لون الجوهرة بناءً على لون الجوهرة المحدد
    Color gemColor;
    switch (widget.gem.color.toLowerCase()) {
      case 'blue':
        gemColor = Colors.blue;
        break;
      case 'primary':
        gemColor = Color(0xFFFF3366);
        break;  
      case 'red':
        gemColor = Colors.red;
        break;
      case 'green':
        gemColor = Colors.green;
        break;
      case 'purple':
        gemColor = Colors.purple;
        break;
      case 'gold':
        gemColor = Color(0xFFFFD700);
        break;
      default:
        gemColor = Colors.pink;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: Container(
            color: Colors.black.withOpacity(_backgroundOpacityAnimation.value),
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // جزيئات وتأثيرات حول الجوهرة
                  if (_controller.value > 0.1 && _controller.value < 0.5)
                    ..._buildParticles(gemColor),
                  
                  // بطاقة الجوهرة
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _cardOffsetAnimation.value),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: math.sin(_controller.value * 3 * math.pi) * _rotationAnimation.value,
                          child: _buildGemCard(cardWidth, gemColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // بناء بطاقة الجوهرة
  Widget _buildGemCard(double width, Color gemColor) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: gemColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: gemColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // القسم العلوي مع تأثيرات الجوهرة
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gemColor.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // تأثير لامع حول الجوهرة
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            gemColor.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          stops: [0.2, 1.0],
                        ),
                      ),
                    ),
                    
                    // أيقونة الجوهرة
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            gemColor.withOpacity(0.8),
                            gemColor,
                            Colors.white,
                            gemColor,
                          ],
                          stops: [0.0, 0.3, 0.6, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Icon(
                        Icons.diamond,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    
                    // وميض صغير
                    Positioned(
                      top: 20,
                      right: 26,
                      child: AnimatedOpacity(
                        opacity: (math.sin(_controller.value * 10 * math.pi) + 1) * 0.5,
                        duration: Duration(milliseconds: 100),
                        child: Icon(
                          Icons.star,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // القسم السفلي مع النص
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              children: [
                Text(
                  "مبروك!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "لقد حصلت على نقاط",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                
                // عرض النقاط مع تأثير حركي
                Transform.translate(
                  offset: Offset(0, _pointsMotionAnimation.value),
                  child: Opacity(
                    opacity: _controller.value < 0.3 ? 0 : 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: gemColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: gemColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: gemColor,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "${widget.gem.points} نقطة",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // إنشاء جزيئات متناثرة للتأثير
  List<Widget> _buildParticles(Color baseColor) {
    final Random random = math.Random();
    final List<Widget> particles = [];
    
    // عدد الجزيئات
    final int numParticles = 15;
    
    for (int i = 0; i < numParticles; i++) {
      // تحديد حجم الجزيء بشكل عشوائي
      final double size = random.nextDouble() * 10 + 4;
      
      // تحديد موقع الجزيء بشكل عشوائي
      final double left = random.nextDouble() * 300 - 150;
      final double top = random.nextDouble() * 300 - 150;
      
      // تحديد لون الجزيء من المجموعة
      final Color particleColor = _particleColors[random.nextInt(_particleColors.length)];
      
      // معدل الرسوم المتحركة لهذا الجزيء
      final double animationOffset = random.nextDouble() * 0.5;
      final double animationValue = ((_controller.value - animationOffset) % 1.0).clamp(0.0, 1.0);
      
      // تحريك الجزيء بشكل دائري
      final double theta = random.nextDouble() * 2 * math.pi;
      final double radius = 150 * animationValue;
      final double dx = radius * math.cos(theta);
      final double dy = radius * math.sin(theta);
      
      particles.add(
        Positioned(
          left: left + dx,
          top: top + dy,
          child: Opacity(
            opacity: 1.0 - animationValue,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: particleColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: particleColor.withOpacity(0.5),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return particles;
  }
}