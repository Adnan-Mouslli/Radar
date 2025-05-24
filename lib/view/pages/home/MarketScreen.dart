import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:radar/controller/Market/MarketController.dart';
import 'package:radar/controller/Market/QrScannerController.dart';
import 'package:radar/controller/profile/ProfileController.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/view/pages/home/NetworkErrorSkeleton.dart';
import 'package:radar/view/pages/skeletons_/MarketScreenSkeleton.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  final MarketController controller = Get.put(MarketController());
  late final QrScannerController qrController;
  final ProfileController controllerProfile = Get.find<ProfileController>();

  late TabController _tabController;

  // ألوان أكثر تناسقًا وراحة للعين
  final Color bgColor = const Color(0xFF121212); // خلفية أغمق قليلًا
  final Color cardBgColor =
      const Color(0xFF1E1E1E); // بطاقات أفتح قليلًا للتباين
  final Color accentColor = AppColors.primary.withOpacity(0.9);
  final Color darkOverlayColor = Colors.black.withOpacity(0.6);

  @override
  void initState() {
    super.initState();

    // تهيئة وحدة التحكم في المسح
    qrController = Get.put(QrScannerController(marketController: controller));

    // تهيئة TabController وربطه بالكونترولر
    _tabController = TabController(length: 3, vsync: this);
    controller.initTabController(_tabController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return MarketScreenSkeleton();
          } else if (controller.hasError.value) {
            return NetworkErrorSkeleton(
              message: controller.errorMessage.value,
              onRetry: () => controller.loadRewards(),
            );
          } else {
            return _buildContent();
          }
        }),
      ),
    );
  }

  // تقسيم المحتوى الرئيسي بشكل أفضل
  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        // تحسين التابات وعزلها
        _buildTabBar(),
        // استخدام Expanded لحل مشاكل المساحة
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: BouncingScrollPhysics(),
            children: [
              // صفحة المتجر والمكافآت
              _buildRewardsTab(),

              // صفحة الجوهرة الأسبوعية
              _buildWeeklyGemTab(),

              // صفحة المتصدرين
              _buildLeadersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final userPoints =
        controller.profileController.profile.value?.user.points ?? 0;
    final List<Color> gradientColors = [
      AppColors.primary.withOpacity(0.8),
      Color.lerp(AppColors.primary, AppColors.primaryLight, 0.5)!
          .withOpacity(0.7),
      AppColors.primaryLight.withOpacity(0.6),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: EdgeInsets.all(20),
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
        children: [
          // عنوان المتجر
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
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
                      'متجر الجوائز',
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

          const SizedBox(height: 18),

          // فقط رصيد النقاط (إزالة الجوهرة من الهيدر كما طلبت)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
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
                    ],
                  ),
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
                      'رصيدك',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$userPoints نقطة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, // حجم أكبر للقراءة بسهولة
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

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: 65, // زيادة الارتفاع قليلاً
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TabBar(
          controller: _tabController,
          // تغيير المؤشر إلى لون أساسي بدلاً من الأبيض
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.primary,
                width: 3,
              ),
            ),
          ),
          indicatorColor: AppColors.primary, // تأكيد لون المؤشر
          dividerColor: Colors.transparent, // إزالة الخط الفاصل الأبيض

          // ألوان وأنماط النص مع حجم خط أصغر
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: TextStyle(
            fontSize: 13, // تقليل حجم الخط
            fontWeight: AppFonts.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12, // تقليل حجم الخط
            fontWeight: AppFonts.medium,
          ),

          // تباعد أقل للمساحات
          labelPadding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 10),

          // استخدام تابات بدون هوامش إضافية
          tabs: [
            _buildSimpleTab(Icons.card_giftcard, "المتجر"),
            _buildSimpleTab(Icons.diamond, "الجوهرة"),
            _buildSimpleTab(Icons.emoji_events, "المتصدرين"),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTab(IconData icon, String text) {
    return Tab(
      height: 65, // ارتفاع مساوي للكونتينر الخارجي
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20), // حجم أيقونة أصغر
          SizedBox(height: 2), // مسافة أقل
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text),
          ),
        ],
      ),
    );
  }

  // تاب مخصص جديد بتصميم محسن
  Widget _buildCustomTab(IconData icon, String text) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
            ),
            SizedBox(height: 4),
            Text(text),
          ],
        ),
      ),
    );
  }

  // صفحة المتجر والمكافآت
  Widget _buildRewardsTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshAllData,
      color: AppColors.primary,
      backgroundColor: Colors.black,
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // بنر ترويجي لميزة QR
          SliverToBoxAdapter(
            child: _buildQrPromoBanner(),
          ),

          // عرض فئات المتجر
          SliverToBoxAdapter(
            child: controller.categories.isEmpty
                ? _buildEmptyState()
                : _buildCategoriesList(),
          ),

          // مساحة إضافية في الأسفل
          SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  // صفحة الجوهرة الأسبوعية
  Widget _buildWeeklyGemTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshAllData,
      color: AppColors.primary,
      backgroundColor: Colors.black,
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // محتوى الجوهرة الأسبوعية
          SliverToBoxAdapter(
            child: _buildWeeklyGemDetails(),
          ),

          // مساحة إضافية في الأسفل
          SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  // صفحة المتصدرين
  Widget _buildLeadersTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshAllData,
      color: AppColors.primary,
      backgroundColor: Colors.black,
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // محتوى المتصدرين
          SliverToBoxAdapter(
            child: _buildTopWinnersSection(),
          ),

          // مساحة إضافية في الأسفل
          SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  // بنر ترويجي للميزة الجديدة - تحسين التصميم
  Widget _buildQrPromoBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.withOpacity(0.8),
            Colors.indigo.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.openQrScanner,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    // أيقونة مع تأثير حركي
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        FontAwesomeIcons.qrcode,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جديد! امسح QR واربح نقاط',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: AppFonts.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'ابحث عن ملصقات QR في المتاجر واربح نقاط عشوائية',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // زر مسح جديد - تحسين الشكل
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    // إضافة ظل للزر
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'امسح كود QR الآن',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: AppFonts.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // تفاصيل الجوهرة الأسبوعية - تحسين الشكل والمساحة
  Widget _buildWeeklyGemDetails() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8A2BE2).withOpacity(0.7),
            Color(0xFF4169E1).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // عناصر زخرفية
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // المحتوى الرئيسي
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'الجوهرة الأسبوعية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildGemCard(),
                  const SizedBox(height: 24),
                  _buildGemRulesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // كارت الجوهرة - تحسين التصميم
  Widget _buildGemCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // تحسين أيقونة الجوهرة
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.diamond,
              color: Colors.amber,
              size: 50,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جوهرة هذا الأسبوع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 12),
          // تحسين عرض قيمة الجوهرة
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => Text(
                  '${controller.weeklyJewelValue.value} نقطة',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: AppFonts.bold,
                  ),
                )),
          ),
          const SizedBox(height: 18),
          Text(
            'تظهر الجوهرة بوقت عشوائي خلال هذا الأسبوع. كن أول من يشاهد الفيديو الذي تظهر فيه لتفوز بها!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.6, // زيادة تباعد السطور للقراءة السهلة
            ),
          ),
        ],
      ),
    );
  }

  // قواعد الجوهرة - تحسين المساحات والتباعد
  Widget _buildGemRulesList() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قواعد الفوز بالجوهرة:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRuleItem('تظهر جوهرة واحدة أسبوعياً في فيديو عشوائي'),
          _buildRuleItem('الجوهرة تظهر في وقت عشوائي خلال الأسبوع'),
          _buildRuleItem('أول من يشاهد الفيديو الذي فيه الجوهرة يحصل عليها'),
          _buildRuleItem('قيمة الجوهرة متغيرة وتتراوح بين 100 و1000 نقطة'),
          _buildRuleItem('يمكن متابعة آخر الفائزين في قسم "المتصدرين"'),
        ],
      ),
    );
  }

  // قاعدة الجوهرة - تحسين المسافات
  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0), // زيادة التباعد بين القواعد
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2), // محاذاة الأيقونة مع النص
            child: Icon(
              Icons.check_circle,
              color: Colors.blue.withOpacity(0.9),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5, // زيادة تباعد السطور للقراءة السهلة
              ),
            ),
          ),
        ],
      ),
    );
  }

  // قسم المتصدرين - تحسين الشكل
  Widget _buildTopWinnersSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.amber.withOpacity(0.6),
            Colors.orange.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24), // زيادة التباعد الداخلي
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'المتصدرون',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // عرض مبسط للمتصدرين - تحسين المساحة والتباعد
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                if (controller.isLoadingLeaders.value) {
                  return _buildLoadingState();
                } else if (controller.hasLeadersError.value) {
                  return _buildErrorState(controller.leadersErrorMessage.value);
                } else if (controller.topWinners.isEmpty) {
                  return _buildNoLeadersYet();
                } else {
                  return Column(
                    children: [
                      // عرض المتصدرين الثلاثة الأوائل
                      _buildTopThreeSection(),

                      // فاصل محسن
                      if (controller.topWinners.length > 3)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(
                            color: Colors.white.withOpacity(0.2),
                            height: 32,
                            thickness: 1.5,
                          ),
                        ),

                      // عرض باقي المتصدرين
                      ...List.generate(
                        controller.topWinners.length > 3
                            ? min(controller.topWinners.length - 3, 7)
                            : 0,
                        (index) => _buildLeaderItem(index + 3),
                      ),
                    ],
                  );
                }
              }),
            ),

            // زر تحديث القائمة - تحسين الشكل
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: GestureDetector(
                  onTap: controller.loadTopWinners,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.amber, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'تحديث القائمة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض المتصدرين الثلاثة الأوائل - تحسين الشكل والمساحة
  Widget _buildTopThreeSection() {
    // التأكد من وجود بيانات كافية
    if (controller.topWinners.length < 1) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // المركز الثاني (يسار)
          if (controller.topWinners.length >= 2) _buildPodiumWinner(1, 110),

          // المركز الأول (وسط) - قليلاً أكبر
          _buildPodiumWinner(0, 130, isFirst: true),

          // المركز الثالث (يمين)
          if (controller.topWinners.length >= 3) _buildPodiumWinner(2, 90),
        ],
      ),
    );
  }

  // حالة التحميل - تحسين الشكل
  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل المتصدرين...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // حالة الخطأ - تحسين الشكل والقراءة
  Widget _buildErrorState(String message) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white.withOpacity(0.7),
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: controller.loadTopWinners,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر الفائز على المنصة - تحسين الشكل والتباعد
  Widget _buildPodiumWinner(int index, double height, {bool isFirst = false}) {
    if (index >= controller.topWinners.length) return SizedBox.shrink();

    final winner = controller.topWinners[index];
    final position = index + 1;
    final name = winner['name'] ?? 'مستخدم';
    final points = winner['points']?.toString() ?? '0';
    final profilePhoto = winner['profilePhoto'];
    final claimedGems = winner['stats']?['claimedGems']?.toString() ?? '0';

    Color medalColor;
    if (position == 1)
      medalColor = Colors.amber;
    else if (position == 2)
      medalColor = Colors.grey.shade300;
    else
      medalColor = Colors.brown.shade300;

    return Column(
      children: [
        // وسام المركز - تحسين المظهر
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: medalColor,
            boxShadow: [
              BoxShadow(
                color: medalColor.withOpacity(0.5),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: TextStyle(
                color: position == 1 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // صورة البروفايل - تحسين الحجم والتأثيرات
        Container(
          width: isFirst ? 80 : 70,
          height: isFirst ? 80 : 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: medalColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: medalColor.withOpacity(0.7),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: profilePhoto != null && profilePhoto.isNotEmpty
                ? Image.network(
                    profilePhoto,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildProfileFallback(name),
                  )
                : _buildProfileFallback(name),
          ),
        ),

        const SizedBox(height: 10),

        // اسم الفائز - تحسين الحجم
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: isFirst ? 14 : 12,
              fontWeight: isFirst ? AppFonts.bold : AppFonts.medium,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        // عدد النقاط - تحسين الشكل
        Container(
          margin: EdgeInsets.only(top: 6),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                color: isFirst ? Colors.amber : Colors.white.withOpacity(0.8),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                points,
                style: TextStyle(
                  color: isFirst ? Colors.amber : Colors.white,
                  fontSize: isFirst ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // عدد الجواهر - تحسين الشكل
        if (int.parse(claimedGems) > 0)
          Container(
            margin: EdgeInsets.only(top: 6),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond, color: Colors.amber, size: 10),
                SizedBox(width: 2),
                Text(
                  claimedGems,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // منصة التتويج - تحسين الشكل
        Container(
          width: isFirst ? 80 : 70,
          height: 12,
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.7),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: medalColor.withOpacity(0.5),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // عنصر متصدر في القائمة - تحسين المساحات والتباعد
  Widget _buildLeaderItem(int index) {
    if (index >= controller.topWinners.length) return SizedBox.shrink();

    final winner = controller.topWinners[index];
    final position = index + 1;
    final name = winner['name'] ?? 'مستخدم';
    final points = winner['points']?.toString() ?? '0';
    final profilePhoto = winner['profilePhoto'];
    final claimedGems = winner['stats']?['claimedGems']?.toString() ?? '0';
    final bool hasClaimedGems = int.parse(claimedGems) > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ترتيب المتصدر - تحسين المظهر
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(position),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getRankColor(position).withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: AppFonts.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // صورة البروفايل - تحسين الحجم
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: profilePhoto != null && profilePhoto.isNotEmpty
                  ? Image.network(
                      profilePhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildProfileFallback(name),
                    )
                  : _buildProfileFallback(name),
            ),
          ),

          const SizedBox(width: 14),

          // معلومات المتصدر - تحسين المساحات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: AppFonts.medium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                // النقاط والجواهر
                Row(
                  children: [
                    // النقاط - تحسين الشكل
                    Container(
                      margin: EdgeInsets.only(top: 6, right: 8),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 12,
                          ),
                          SizedBox(width: 3),
                          Text(
                            points,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: AppFonts.medium,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // الجواهر - تحسين الشكل
                    if (hasClaimedGems)
                      Container(
                        margin: EdgeInsets.only(top: 6),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.diamond,
                              color: Colors.amber,
                              size: 12,
                            ),
                            SizedBox(width: 3),
                            Text(
                              claimedGems,
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: AppFonts.medium,
                              ),
                            ),
                          ],
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

  // صورة بروفايل افتراضية - تحسين الشكل
  Widget _buildProfileFallback(String name) {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // رسالة عدم وجود متصدرين بعد - تحسين الشكل
  Widget _buildNoLeadersYet() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 50,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'لا يوجد متصدرين بعد',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: AppFonts.medium,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'كن أول من يفوز بالجواهر الأسبوعية',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // لون ترتيب المتصدر - تحسين الألوان
  Color _getRankColor(int rank) {
    if (rank <= 3)
      return Colors.transparent; // غير مستخدم للمراكز الثلاثة الأولى
    if (rank <= 5) return Colors.blue.shade600;
    if (rank <= 7) return Colors.purple.shade600;
    return Colors.grey.shade700;
  }

  // محتوى قائمة الفئات - تحسين الشكل والمساحات
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
            margin: EdgeInsets.only(bottom: 24), // زيادة المساحة بين الفئات
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان الفئة محسن - تحسين التصميم
                Container(
                  margin: EdgeInsets.only(bottom: 16, left: 4, right: 4),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${rewards.length} مكافآت",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // مكافآت الفئة المحسنة - تحسين عرض الشبكة
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: 2), // تقليل الهوامش لمنع التكسير
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8, // تعديل النسبة لتناسب أكثر
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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

  // كارت المكافأة - تحسين الشكل
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
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

            // تفاصيل المكافأة - تحسين المساحات والخطوط
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
                        height: 1.3,
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
                          height: 1.4, // زيادة تباعد الاسطر للقراءة السهلة
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // زر الشراء المحسن - تحسين المظهر
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  // حالة المتجر الفارغ
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),

            // أيقونة المتجر الفارغ
            Container(
              width: 100,
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
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            // رسالة
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      fontSize: 18,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد مكافآت متاحة للاستبدال في الوقت الحالي. نعمل على إضافة مكافآت جديدة قريباً!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadRewards(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.refresh, size: 16),
                    label: Text(
                      "تحديث المتجر",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // رسالة تشجيعية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "استمر في مشاهدة المحتوى لكسب المزيد من ",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
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
}
