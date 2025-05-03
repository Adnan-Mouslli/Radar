import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:radar/controller/Market/MarketController.dart';
import 'package:radar/controller/profile/ProfileController.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/view/pages/home/NetworkErrorSkeleton.dart';
import 'package:radar/view/pages/skeletons_/MarketScreenSkeleton.dart';

class MarketScreen extends StatelessWidget {
  final MarketController controller = Get.put(MarketController());

  final ProfileController controllerProfile = Get.find<ProfileController>();

  // تحديث الألوان لتكون متناسقة مع HomeScreen
  final Color bgColor = Colors.black; // لون خلفية أسود
  final Color cardBgColor =
      const Color(0xFF1A1A1A); // لون بطاقات أسود فاتح قليلا
  final Color accentColor =
      AppColors.primary.withOpacity(0.85); // اللون الأساسي بشفافية لتخفيف الحدة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return MarketScreenSkeleton(); // استخدام السكيلتون أثناء التحميل
          } else if (controller.hasError.value) {
            return NetworkErrorSkeleton(
              message: controller.errorMessage.value,
              onRetry: () => controller.loadRewards(),
            );
          } else {
            return _buildMarketContent();
          }
        }),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color:
                AppColors.error.withOpacity(0.8), // خفض قليلا لتكون أكثر هدوء
            size: 60,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(
                color: Colors.white
                    .withOpacity(0.85), // خفض التباين قليلا مع الخلفية السوداء
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.loadRewards(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.75), // أقل حدة
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1, // تقليل الظل للراحة البصرية
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "إعادة المحاولة",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketContent() {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        // رأس الصفحة
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),

        // قائمة الفئات والمكافآت
        controller.categories.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false, // هذه القيمة مهمة لمنع حدوث overflow
                child: _buildEmptyState(),
              )
            : SliverToBoxAdapter(child: _buildCategoriesList()),
      ],
    );
  }

  Widget _buildHeader() {
    final userPoints =
        controller.profileController.profile.value?.user.points ?? 0;

    // إنشاء تدرج لطيف من مشتقات اللون الأساسي مع الخلفية السوداء
    final List<Color> gradientColors = [
      AppColors.primary.withOpacity(0.65),
      Color.lerp(AppColors.primary, AppColors.primaryLight, 0.5)!
          .withOpacity(0.5),
      AppColors.primaryLight.withOpacity(0.4),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 20),
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'متجر النقاط',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'استبدل نقاطك بمكافآت حصرية',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // عرض رصيد النقاط محسن
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]),
                  child: Center(
                    child: Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رصيد نقاطك',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$userPoints نقطة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: AppFonts.bold,
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

  Widget _buildEmptyState() {
    // تحسين حالة الفراغ مع معالجة مشكلة الـ overflow
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // تغيير من MainAxisAlignment.center إلى MainAxisSize.min
          children: [
            SizedBox(height: 20),

            // رسم دائرة وإضافة أيقونة متجر جذابة
            Container(
              width: 100, // تقليل الحجم قليلاً
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primary.withOpacity(0.8),
                size: 50, // تقليل حجم الأيقونة
              ),
            ),

            const SizedBox(height: 24), // تقليل المسافة

            // رسالة محسنة ومصممة بشكل جذاب
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 20), // تقليل الpadding
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'المتجر فارغ حالياً',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // تصغير حجم الخط
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  const SizedBox(height: 12), // تقليل المسافة
                  Text(
                    'لا توجد مكافآت متاحة للاستبدال في الوقت الحالي. نعمل على إضافة مكافآت جديدة قريباً!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14, // تصغير حجم الخط
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16), // تقليل المسافة
                  ElevatedButton.icon(
                    onPressed: () => controller.loadRewards(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12), // تقليل الpadding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.refresh, size: 16),
                    label: Text(
                      "تحديث المتجر",
                      style: TextStyle(
                        fontSize: 14, // تصغير حجم الخط
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24), // تقليل المسافة

            // رسالة إضافية توضيحية مع تقليل حجمها
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "استمر في مشاهدة المحتوى لكسب المزيد من ",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13, // تصغير حجم الخط
                  ),
                  children: [
                    TextSpan(
                      text: "النقاط",
                      style: TextStyle(
                        color: AppColors.points,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                    TextSpan(
                      text: " واستبدالها بمكافآت حصرية لاحقاً!",
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.categories.map((category) {
          final rewards =
              category.rewards.where((reward) => reward.isActive).toList();

          // تخطي الفئات التي ليس لديها مكافآت نشطة
          if (rewards.isEmpty) {
            return SizedBox.shrink();
          }

          return Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان الفئة محسن
                Container(
                  margin: EdgeInsets.only(bottom: 14, left: 4, right: 4),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.category,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "${rewards.length} مكافآت",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // مكافآت الفئة المحسنة
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: rewards.length,
                  itemBuilder: (context, idx) {
                    final reward = rewards[idx];
                    return _buildRewardCard(reward);
                  },
                ),

                SizedBox(height: 10),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final userPoints =
        controller.profileController.profile.value?.user.points ?? 0;
    final bool canPurchase = userPoints >= reward.pointsCost;

    return GestureDetector(
      onTap: () => controller.purchaseReward(reward),
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: reward.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس المكافأة المحسن
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: reward.color.withOpacity(0.15),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: reward.color.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: reward.color.withOpacity(0.15),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FaIcon(
                      reward.iconData,
                      color: reward.color,
                      size: 20,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${reward.pointsCost}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          color: AppColors.points,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // تفاصيل المكافأة
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: AppFonts.semiBold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        reward.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // زر الشراء المحسن
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: canPurchase
                    ? reward.color.withOpacity(0.8)
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: canPurchase
                    ? [
                        BoxShadow(
                          color: reward.color.withOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(0, -2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canPurchase ? Icons.shopping_cart : Icons.lock,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canPurchase ? 'اشتر الآن' : 'نقاط غير كافية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: canPurchase ? AppFonts.bold : AppFonts.medium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
