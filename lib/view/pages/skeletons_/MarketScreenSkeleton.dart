import 'package:flutter/material.dart';
import 'package:radar/core/theme/app_colors.dart';

class MarketScreenSkeleton extends StatefulWidget {
  const MarketScreenSkeleton({Key? key}) : super(key: key);

  @override
  State<MarketScreenSkeleton> createState() => _MarketScreenSkeletonState();
}

class _MarketScreenSkeletonState extends State<MarketScreenSkeleton>
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
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // رأس الصفحة
                SliverToBoxAdapter(
                  child: _buildHeaderSkeleton(),
                ),

                // قائمة الفئات والمكافآت
                SliverToBoxAdapter(
                  child: _buildCategoriesListSkeleton(),
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
    // قائمة ألوان متدرجة متشابهة للتي تستخدم في الهيدر الحقيقي
    final List<Color> gradientColors = [
      AppColors.primary.withOpacity(0.65),
      Color.lerp(AppColors.primary, AppColors.primaryLight, 0.5)!
          .withOpacity(0.5),
      AppColors.primaryLight.withOpacity(0.4),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.white.withOpacity(_animation.value * 0.9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerLine(
                      width: 120,
                      height: 22,
                      color: Colors.white.withOpacity(_animation.value * 0.8),
                    ),
                    const SizedBox(height: 4),
                    _buildShimmerLine(
                      width: 200,
                      height: 14,
                      color: Colors.white.withOpacity(_animation.value * 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // بطاقة رصيد النقاط
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.points.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.star,
                      color:
                          AppColors.points.withOpacity(_animation.value * 0.9),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerLine(
                      width: 80,
                      height: 14,
                      color: Colors.white.withOpacity(_animation.value * 0.6),
                    ),
                    const SizedBox(height: 4),
                    _buildShimmerLine(
                      width: 100,
                      height: 20,
                      color: Colors.white.withOpacity(_animation.value * 0.8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // سكيلتون لقائمة الفئات
  Widget _buildCategoriesListSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySkeleton(productsCount: 2),
          const SizedBox(height: 24),
          _buildCategorySkeleton(productsCount: 3),
          const SizedBox(height: 24),
          _buildCategorySkeleton(productsCount: 2),
        ],
      ),
    );
  }

  // سكيلتون لفئة منتجات
  Widget _buildCategorySkeleton({required int productsCount}) {
    // لون خلفية البطاقات في التصميم الحقيقي
    final cardBgColor = const Color(0xFF1A1A1A);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الفئة
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: AppColors.primary.withOpacity(_animation.value),
                  size: 20,
                ),
                const SizedBox(width: 12),
                _buildShimmerLine(
                  width: 120,
                  height: 18,
                  color: Colors.white.withOpacity(_animation.value * 0.8),
                ),
              ],
            ),
          ),

          // شبكة المكافآت
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: productsCount,
            itemBuilder: (context, index) {
              // تلوين مختلف للمكافآت
              final colors = [
                Colors.purple,
                Colors.amber,
                Colors.teal,
                Colors.red,
                Colors.orange,
                Colors.blue,
              ];
              final color = colors[index % colors.length];

              return _buildRewardCardSkeleton(color, cardBgColor);
            },
          ),
        ],
      ),
    );
  }

  // سكيلتون لبطاقة مكافأة
  Widget _buildRewardCardSkeleton(Color rewardColor, Color cardBgColor) {
    final bool canPurchase =
        index % 2 == 0; // تبديل بين حالة كافية/غير كافية للنقاط

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rewardColor.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس المكافأة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rewardColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: rewardColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: rewardColor.withOpacity(_animation.value),
                    size: 18,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildShimmerLine(
                      width: 30,
                      height: 16,
                      color: Colors.white.withOpacity(_animation.value * 0.8),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star,
                      color: AppColors.points.withOpacity(_animation.value),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // تفاصيل المكافأة
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(
                    width: 110,
                    height: 14,
                    color: Colors.white.withOpacity(_animation.value * 0.8),
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerLine(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white.withOpacity(_animation.value * 0.5),
                  ),
                  const SizedBox(height: 4),
                  _buildShimmerLine(
                    width: double.infinity * 0.8,
                    height: 12,
                    color: Colors.white.withOpacity(_animation.value * 0.5),
                  ),
                  const SizedBox(height: 4),
                  _buildShimmerLine(
                    width: double.infinity * 0.6,
                    height: 12,
                    color: Colors.white.withOpacity(_animation.value * 0.5),
                  ),
                ],
              ),
            ),
          ),

          // زر الشراء
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: canPurchase
                  ? AppColors.primary.withOpacity(_animation.value * 0.7)
                  : Colors.grey.withOpacity(_animation.value * 0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canPurchase ? Icons.shopping_cart : Icons.lock,
                  color: Colors.white.withOpacity(_animation.value * 0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                _buildShimmerLine(
                  width: 60,
                  height: 13,
                  color: Colors.white.withOpacity(_animation.value * 0.8),
                ),
              ],
            ),
          ),
        ],
      ),
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

  // قيمة مؤقتة للتنويع في حالة الشراء
  int get index {
    int _index = 0;
    _index = (_index + 1) % 10;
    return _index;
  }
}
