import 'package:flutter/material.dart';
import 'package:radar/core/theme/app_colors.dart';

class FavoritesScreenSkeleton extends StatefulWidget {
  const FavoritesScreenSkeleton({Key? key}) : super(key: key);

  @override
  State<FavoritesScreenSkeleton> createState() =>
      _FavoritesScreenSkeletonState();
}

class _FavoritesScreenSkeletonState extends State<FavoritesScreenSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // _colorAnimation = ColorTween(
    //   begin: AppColors.primary.withOpacity(0.3),
    //   end: AppColors.primary.withOpacity(0.6),
    // ).animate(CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.easeInOut,
    // ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              children: [
                // رأس الصفحة (الهيدر)
                _buildHeader(),

                // قائمة المفضلة
                Expanded(
                  child: _buildFavoriteListSkeleton(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // سكيلتون لقسم الهيدر
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildShimmerLine(width: 80, height: 22),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_animation.value * 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.refresh,
              color: Colors.white.withOpacity(_animation.value * 0.2),
            ),
          ),
        ],
      ),
    );
  }

  // سكيلتون لقائمة المفضلة
  Widget _buildFavoriteListSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5, // عدد العناصر الوهمية
      itemBuilder: (context, index) {
        return _buildFavoriteItemSkeleton();
      },
    );
  }

  // سكيلتون لعنصر مفضل واحد
  Widget _buildFavoriteItemSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_animation.value * 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(_animation.value * 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // صورة مصغرة للريل
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Container(
              width: 120,
              height: 120,
              color: Colors.grey.withOpacity(_animation.value * 0.2),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white.withOpacity(_animation.value * 0.3),
                  size: 40,
                ),
              ),
            ),
          ),

          // معلومات الريل
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المستخدم والتاريخ
                  Row(
                    children: [
                      _buildShimmerLine(width: 80, height: 14),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withOpacity(_animation.value * 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildShimmerLine(
                          width: 30,
                          height: 10,
                          color: AppColors.primary
                              .withOpacity(_animation.value * 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // وصف الريل
                  _buildShimmerLine(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white.withOpacity(_animation.value * 0.15),
                  ),
                  const SizedBox(height: 4),
                  _buildShimmerLine(
                    width: double.infinity * 0.8,
                    height: 12,
                    color: Colors.white.withOpacity(_animation.value * 0.15),
                  ),
                  const SizedBox(height: 8),

                  // إحصائيات الريل
                  Row(
                    children: [
                      _buildStatItemSkeleton(),
                      const SizedBox(width: 12),
                      _buildStatItemSkeleton(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // زر الحذف
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(_animation.value * 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline,
              color: Colors.red.withOpacity(_animation.value * 0.3),
            ),
          ),
        ],
      ),
    );
  }

  // سكيلتون لعنصر إحصائية
  Widget _buildStatItemSkeleton() {
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: Colors.white.withOpacity(_animation.value * 0.2),
          size: 14,
        ),
        const SizedBox(width: 4),
        _buildShimmerLine(width: 20, height: 12),
      ],
    );
  }

  // دوال مساعدة لإنشاء أشكال الـ Skeleton
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
