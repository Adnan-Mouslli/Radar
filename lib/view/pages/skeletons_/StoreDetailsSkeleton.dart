import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:radar/core/theme/app_colors.dart';

class StoreDetailsSkeleton extends StatefulWidget {
  const StoreDetailsSkeleton({Key? key}) : super(key: key);

  @override
  State<StoreDetailsSkeleton> createState() => _StoreDetailsSkeletonState();
}

class _StoreDetailsSkeletonState extends State<StoreDetailsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
          height: Get.height * 0.75,
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // سكيلتون معلومات المتجر
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // سكيلتون صورة المتجر
                    _buildSkeletonCircle(60),

                    SizedBox(width: 16),

                    // سكيلتون معلومات المتجر
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSkeletonLine(width: 150, height: 22),
                          SizedBox(height: 8),
                          _buildSkeletonLine(width: 100, height: 16),
                          SizedBox(height: 6),
                          _buildSkeletonLine(width: 180, height: 14),
                        ],
                      ),
                    ),

                    // سكيلتون زر الاتصال
                    _buildSkeletonCircle(36),
                  ],
                ),
              ),

              // فاصل
              Divider(color: Colors.grey[800]),

              // سكيلتون عنوان القسم
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    _buildSkeletonCircle(20),
                    SizedBox(width: 8),
                    _buildSkeletonLine(width: 100, height: 20),
                  ],
                ),
              ),

              // سكيلتون قائمة العروض
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: 3, // عرض 3 عناصر سكيلتون
                  itemBuilder: (context, index) {
                    return _buildSkeletonOfferCard();
                  },
                ),
              ),

              // سكيلتون زر الإغلاق
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة مساعدة لإنشاء دائرة سكيلتون
  Widget _buildSkeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[800]!.withOpacity(_animation.value),
        shape: BoxShape.circle,
      ),
    );
  }

  // دالة مساعدة لإنشاء خط سكيلتون
  Widget _buildSkeletonLine(
      {required double width,
      required double height,
      double borderRadius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800]!.withOpacity(_animation.value),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // دالة مساعدة لإنشاء بطاقة عرض سكيلتون
  Widget _buildSkeletonOfferCard() {
    // تلوين مختلف للبطاقات
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.purple,
    ];
    final color = colors[_getRandomIndex() % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(_animation.value * 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // سكيلتون صورة العرض
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(_animation.value * 0.8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),

          // سكيلتون تفاصيل العرض
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // سكيلتون عنوان العرض والفئة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSkeletonLine(width: 150, height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(_animation.value * 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 60,
                      height: 18,
                    ),
                  ],
                ),

                // سكيلتون وصف العرض
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildSkeletonLine(width: double.infinity, height: 16),
                ),
                SizedBox(height: 4),
                _buildSkeletonLine(width: 200, height: 16),

                SizedBox(height: 12),

                // سكيلتون السعر والخصم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonLine(width: 70, height: 12),
                        SizedBox(height: 4),
                        _buildSkeletonLine(width: 60, height: 16),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSkeletonLine(width: 80, height: 12),
                        SizedBox(height: 4),
                        Container(
                          width: 70,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green
                                .withOpacity(_animation.value * 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(_animation.value * 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  // قيمة عشوائية للتنويع في العناصر
  int _getRandomIndex() {
    return DateTime.now().microsecond % 3;
  }
}
