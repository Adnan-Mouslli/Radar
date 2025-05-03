import 'package:flutter/material.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReelSkeleton extends StatefulWidget {
  const ReelSkeleton({Key? key}) : super(key: key);

  @override
  State<ReelSkeleton> createState() => _ReelSkeletonState();
}

class _ReelSkeletonState extends State<ReelSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: AppColors.primary.withOpacity(0.3),
      end: AppColors.primary.withOpacity(0.7),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // خلفية بلون التطبيق (مبسطة)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),

              // محتوى الـ Skeleton
              SafeArea(
                child: Column(
                  children: [
                    // مؤشر تقدم الوسائط المتعددة في الأعلى
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (i) => Container(
                            width: 20,
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i == 1
                                  ? AppColors.primary
                                      .withOpacity(_animation.value)
                                  : Colors.white
                                      .withOpacity(_animation.value * 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // باقي المحتوى
                    Expanded(
                      child: Stack(
                        children: [
                          // شريط تقدم الفيديو موضوع في أسفل الشاشة
                          Positioned(
                            bottom: 10,
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.3 *
                                        _animation.value,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: _colorAnimation.value,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // القسم الرئيسي للمحتوى
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // معلومات المستخدم والوصف (الجزء السفلي)
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // معلومات المستخدم
                                          Row(
                                            children: [
                                              _buildProfileCircle(radius: 20),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildShimmerLine(
                                                        width: 120, height: 16),
                                                    const SizedBox(height: 4),
                                                    _buildShimmerLine(
                                                        width: 80,
                                                        height: 12,
                                                        color: Colors.white
                                                            .withOpacity(
                                                                _animation
                                                                        .value *
                                                                    0.2)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          // وصف المحتوى
                                          _buildShimmerLine(
                                              width: double.infinity,
                                              height: 14),
                                          const SizedBox(height: 8),
                                          _buildShimmerLine(
                                              width: double.infinity * 0.8,
                                              height: 14),
                                          const SizedBox(height: 8),
                                          _buildShimmerLine(
                                              width: double.infinity * 0.6,
                                              height: 14),
                                          const SizedBox(height: 16),
                                          // الاهتمامات
                                          SizedBox(
                                            height: 30,
                                            child: Row(
                                              children: List.generate(
                                                3,
                                                (index) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: _buildShimmerTag(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // أزرار التفاعل (الجانب الأيمن في النسخة الجديدة)
                                  Container(
                                    width: 70,
                                    padding: const EdgeInsets.only(
                                        right: 8, bottom: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // زر الإعجاب
                                        _buildVerticalActionButton(
                                          icon: Icons.favorite_border,
                                          showLabel: true,
                                        ),
                                        const SizedBox(height: 16),
                                        // زر المشاهدات
                                        _buildVerticalActionButton(
                                          icon: Icons.remove_red_eye_outlined,
                                          showLabel: true,
                                        ),
                                        const SizedBox(height: 16),
                                        // زر المشاركة
                                        _buildVerticalActionButton(
                                          icon: Icons.share,
                                          showLabel: true,
                                        ),
                                        const SizedBox(height: 16),
                                        // زر الواتساب
                                        _buildVerticalActionButton(
                                          useFontAwesome: true,
                                          faIcon: FontAwesomeIcons.whatsapp,
                                          showLabel: true,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget للأزرار الجانبية بتصميم جديد
  Widget _buildVerticalActionButton({
    IconData? icon,
    bool useFontAwesome = false,
    IconData? faIcon,
    bool showLabel = false,
  }) {
    return Column(
      children: [
        // الأيقونة
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              color: Colors.white.withOpacity(_animation.value * 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: useFontAwesome && faIcon != null
                ? FaIcon(
                    faIcon,
                    color: Colors.white.withOpacity(_animation.value * 0.5),
                    size: 22,
                  )
                : Icon(
                    icon,
                    color: Colors.white.withOpacity(_animation.value * 0.5),
                    size: 22,
                  ),
          ),
        ),
        // اللابل
        if (showLabel) ...[
          const SizedBox(height: 4),
          _buildShimmerLine(
            width: 30,
            height: 10,
            color: Colors.white.withOpacity(_animation.value * 0.3),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileCircle({required double radius}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade800.withOpacity(_animation.value),
      ),
    );
  }

  Widget _buildShimmerLine({
    required double width,
    required double height,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: color ?? Colors.white.withOpacity(0.2),
      ),
    );
  }

  Widget _buildShimmerTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: _buildShimmerLine(
          width: 40, height: 10, color: Colors.white.withOpacity(0.15)),
    );
  }
}
