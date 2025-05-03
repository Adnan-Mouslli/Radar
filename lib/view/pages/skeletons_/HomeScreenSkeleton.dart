import 'package:flutter/material.dart';
import 'package:radar/core/theme/app_colors.dart';

class HomeScreenSkeleton extends StatefulWidget {
  const HomeScreenSkeleton({Key? key}) : super(key: key);

  @override
  State<HomeScreenSkeleton> createState() => _HomeScreenSkeletonState();
}

class _HomeScreenSkeletonState extends State<HomeScreenSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // تحديث الألوان لتكون أكثر راحة للعين مع خلفية سوداء
  final Color bgColor = Colors.black; // لون خلفية أسود
  final Color cardBgColor =
      const Color(0xFF1A1A1A); // لون بطاقات أسود فاتح قليلا

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // رأس الصفحة المميز
                SliverToBoxAdapter(
                  child: _buildHeaderSkeleton(),
                ),

                // قسم الإحصائيات
                // SliverToBoxAdapter(
                //   child: _buildStatsSkeleton(),
                // ),

                // قسم الاهتمامات
                SliverToBoxAdapter(
                  child: _buildInterestsSkeleton(),
                ),

                // زر تسجيل الخروج
                SliverToBoxAdapter(
                  child: _buildLogoutButtonSkeleton(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // سكيلتون لقسم الهيدر
  Widget _buildHeaderSkeleton() {
    // إنشاء تدرج لطيف من مشتقات اللون الأساسي مع الخلفية السوداء
    final List<Color> gradientColors = [
      AppColors.primary.withOpacity(0.65 * _animation.value),
      Color.lerp(AppColors.primary, AppColors.primaryLight, 0.5)!
          .withOpacity(0.5 * _animation.value),
      AppColors.primaryLight.withOpacity(0.4 * _animation.value),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15 * _animation.value),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // صورة البروفايل
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardBgColor.withOpacity(_animation.value),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.7 * _animation.value),
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2 * _animation.value),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // معلومات المستخدم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerLine(width: 150, height: 22),
                    const SizedBox(height: 8),
                    // مؤشر النقاط
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2 * _animation.value),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.points
                                .withOpacity(0.95 * _animation.value),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          _buildShimmerLine(width: 50, height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // الاهتمامات المفضلة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerLine(width: 120, height: 16),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withOpacity(0.2 * _animation.value),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              Colors.white.withOpacity(0.15 * _animation.value),
                          width: 1,
                        ),
                      ),
                      child: _buildShimmerLine(
                          width: 50 + (index * 5), height: 13),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // سكيلتون لقسم الإحصائيات
  // Widget _buildStatsSkeleton() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     padding: EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: cardBgColor.withOpacity(_animation.value),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.15 * _animation.value),
  //           blurRadius: 8,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.analytics_outlined,
  //               color: AppColors.primary.withOpacity(0.85 * _animation.value),
  //               size: 20,
  //             ),
  //             const SizedBox(width: 8),
  //             _buildShimmerLine(width: 100, height: 18),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             _buildStatCardSkeleton(
  //               icon: Icons.remove_red_eye,
  //               color: Color.lerp(AppColors.accent1, Colors.white, 0.1)!,
  //             ),
  //             const SizedBox(width: 12),
  //             _buildStatCardSkeleton(
  //               icon: Icons.favorite,
  //               color: Color.lerp(AppColors.like, Colors.white, 0.05)!,
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             _buildStatCardSkeleton(
  //               icon: Icons.share,
  //               color: Color.lerp(AppColors.share, Colors.white, 0.05)!,
  //             ),
  //             const SizedBox(width: 12),
  //             _buildStatCardSkeleton(
  //               icon: Icons.campaign,
  //               color: Color.lerp(AppColors.accent2, Colors.white, 0.1)!,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // سكيلتون لبطاقة إحصائية
  Widget _buildStatCardSkeleton({
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1 * _animation.value),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2 * _animation.value),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15 * _animation.value),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color.withOpacity(0.9 * _animation.value),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            _buildShimmerLine(width: 40, height: 18),
            const SizedBox(height: 4),
            _buildShimmerLine(
              width: 50,
              height: 12,
              color: Colors.white.withOpacity(0.6 * _animation.value),
            ),
          ],
        ),
      ),
    );
  }

  // سكيلتون لقسم الاهتمامات
  Widget _buildInterestsSkeleton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor.withOpacity(_animation.value),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15 * _animation.value),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.interests,
                    color:
                        AppColors.primary.withOpacity(0.85 * _animation.value),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  _buildShimmerLine(width: 80, height: 18),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12 * _animation.value),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: AppColors.primary
                          .withOpacity(0.85 * _animation.value),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    _buildShimmerLine(width: 40, height: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // قائمة الاهتمامات
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              8,
              (index) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF222222).withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        AppColors.primary.withOpacity(0.25 * _animation.value),
                    width: 1,
                  ),
                ),
                child:
                    _buildShimmerLine(width: 50 + (index % 5) * 10, height: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // سكيلتون لزر تسجيل الخروج
  Widget _buildLogoutButtonSkeleton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12 * _animation.value),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25 * _animation.value),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            color: Colors.white.withOpacity(0.9 * _animation.value),
            size: 20,
          ),
          const SizedBox(width: 8),
          _buildShimmerLine(width: 100, height: 16),
        ],
      ),
    );
  }

  // دالة مساعدة لإنشاء خطوط السكيلتون
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
        color: color ?? Colors.white.withOpacity(_animation.value * 0.2),
      ),
    );
  }
}
