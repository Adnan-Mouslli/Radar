import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:radar/core/class/statusrequest.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as https;
import 'package:flutter/services.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({Key? key}) : super(key: key);

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final MyServices services = Get.find<MyServices>();
  late final String weeklyJewelValue;
  late final String phoneRadar;

  // State variables for top winners
  List<Map<String, dynamic>> topWinners = [];
  StatusRequest topWinnersStatus = StatusRequest.none;
  final int topWinnersCount = 10; // Number of top winners to fetch

  @override
  void initState() {
    super.initState();
    weeklyJewelValue = services.getData("WeeklyJewelValue") ?? "500";
    phoneRadar = services.getData("phoneRadar") ?? "+963941325008";

    // Fetch top winners when the screen loads
    _fetchTopWinners();
  }

  // Function to fetch top winners using http
  Future<void> _fetchTopWinners() async {
    try {
      setState(() {
        topWinnersStatus = StatusRequest.loading;
      });

      final url = Uri.parse(
          '${AppLink.server}/api/users/top-awarded?limit=$topWinnersCount');
      final response = await https.get(
        url,
        headers: {
          'Authorization': 'Bearer ${services.getToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Connection timeout');
      });

      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Parse the data according to the actual response format
          setState(() {
            topWinners = List<Map<String, dynamic>>.from(data['data']);
            topWinnersStatus = StatusRequest.success;
          });
        } else {
          setState(() {
            topWinnersStatus = StatusRequest.failure;
          });
        }
      } else {
        setState(() {
          topWinnersStatus = StatusRequest.serverfailure;
        });
      }
    } catch (e) {
      print('Error fetching top winners: $e');
      setState(() {
        topWinnersStatus = e.toString().contains('timeout') ||
                e.toString().contains('Connection')
            ? StatusRequest.offlinefailure
            : StatusRequest.serverfailure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'النصائح والإرشادات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: AppFonts.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTopWinners,
        child: SafeArea(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // Weekly Gem Section
              SliverToBoxAdapter(
                child: _buildWeeklyGemSection(),
              ),

              // Top Winners Section
              SliverToBoxAdapter(
                child: _buildTopWinnersSection(),
              ),

              // Contact Us Section
              SliverToBoxAdapter(
                child: _buildContactUsSection(),
              ),

              // FAQ Section
              SliverToBoxAdapter(
                child: _buildFAQSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyGemSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 20),
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
            // بارتكلز لجعل التصميم أكثر جمالاً
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
              padding: EdgeInsets.all(22),
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
                  const SizedBox(height: 20),
                  _buildGemCard(),
                  const SizedBox(height: 22),
                  _buildGemRulesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGemCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
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
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.diamond,
              color: Colors.amber,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جوهرة هذا الأسبوع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${weeklyJewelValue} نقطة',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: AppFonts.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'تظهر الجوهرة بوقت عشوائي خلال هذا الأسبوع. كن أول من يشاهد الفيديو الذي تظهر فيه لتفوز بها!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGemRulesList() {
    return Container(
      padding: EdgeInsets.all(18),
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
          const SizedBox(height: 14),
          _buildRuleItem('تظهر جوهرة واحدة أسبوعياً في فيديو عشوائي'),
          _buildRuleItem('الجوهرة تظهر في وقت عشوائي خلال الأسبوع'),
          _buildRuleItem('أول من يشاهد الفيديو الذي فيه الجوهرة يحصل عليها'),
          _buildRuleItem('قيمة الجوهرة متغيرة وتتراوح بين 100 و1000 نقطة'),
          _buildRuleItem('يمكن متابعة آخر الفائزين في قسم "المتصدرين"'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.blue.withOpacity(0.9),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تحسين طريقة بناء قسم أفضل 10 فائزين
  Widget _buildTopWinnersSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // تحسين العناصر الديكورية في الخلفية
            Positioned(
              left: -20,
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
              right: -30,
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

            // إضافة شكل إضافي للتصميم
            Positioned(
              right: 60,
              top: 50,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // المحتوى الرئيسي
            Padding(
              padding: EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تحسين شكل العنوان
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
                        'أفضل $topWinnersCount فائزين بالجواهر',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // تحسين الحاوية الرئيسية
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
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
                    child: _buildTopWinnersList(),
                  ),

                  // تحسين زر التحديث
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: GestureDetector(
                        onTap: _fetchTopWinners,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh,
                                  color: Colors.amber, size: 16),
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
          ],
        ),
      ),
    );
  }

// تحسين طريقة عرض المستخدمين الفائزين
  Widget _buildTopWinnersList() {
    switch (topWinnersStatus) {
      case StatusRequest.loading:
        return _buildLoadingState();
      case StatusRequest.offlinefailure:
        return _buildErrorState('لا يوجد اتصال بالإنترنت');
      case StatusRequest.serverfailure:
        return _buildErrorState('حدث خطأ في الاتصال بالخادم');
      case StatusRequest.failure:
        return _buildErrorState('لا توجد بيانات متاحة');
      case StatusRequest.success:
        if (topWinners.isEmpty) {
          return _buildErrorState('لا يوجد فائزين بعد');
        }

        // إنشاء المراكز الأولى بشكل خاص ومميز
        return Column(
          children: [
            // عرض خاص للمراكز الثلاثة الأولى
            if (topWinners.length >= 3) _buildTopThreeWinners(),

            SizedBox(height: 16),

            // فاصل بين المراكز الأولى وباقي القائمة
            if (topWinners.length > 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Divider(color: Colors.white.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'باقي المتصدرين',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: Colors.white.withOpacity(0.2))),
                  ],
                ),
              ),

            // عرض باقي المراكز
            ...List.generate(
              topWinners.length > 3 ? topWinners.length - 3 : 0,
              (index) => _buildTopWinnerItem(
                topWinners[index + 3]['name'] ?? 'مستخدم',
                topWinners[index + 3]['points']?.toString() ?? '0',
                (index + 4).toString(),
                false,
                topWinners[index + 3],
              ),
            ),
          ],
        );
      default:
        return _buildLoadingState();
    }
  }

// عرض المراكز الثلاثة الأولى بشكل مميز
  Widget _buildTopThreeWinners() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // المركز الثاني
          if (topWinners.length >= 2)
            _buildPodiumWinner(
              topWinners[1],
              2,
              height: 120,
              color: Colors.grey.shade300,
              medalColor: Colors.grey.shade300,
              medalIcon: '2',
            ),

          // المركز الأول (في الوسط وأعلى)
          if (topWinners.length >= 1)
            _buildPodiumWinner(
              topWinners[0],
              1,
              height: 140,
              color: Colors.amber,
              medalColor: Colors.amber,
              medalIcon: '1',
              isFirst: true,
            ),

          // المركز الثالث
          if (topWinners.length >= 3)
            _buildPodiumWinner(
              topWinners[2],
              3,
              height: 100,
              color: Colors.brown.shade300,
              medalColor: Colors.brown.shade300,
              medalIcon: '3',
            ),
        ],
      ),
    );
  }

// تعديل عرض الفائزين في منصة التتويج
  Widget _buildPodiumWinner(
    Map<String, dynamic> winner,
    int position, {
    required double height,
    required Color color,
    required Color medalColor,
    required String medalIcon,
    bool isFirst = false,
  }) {
    final String name = winner['name'] ?? 'مستخدم';
    final String points = winner['points']?.toString() ?? '0';
    final String? profilePhoto = winner['profilePhoto'];
    final String claimedGems = winner['stats']['claimedGems'].toString();

    return Column(
      children: [
        // Badge for winner (better design)
        Stack(
          alignment: Alignment.center,
          children: [
            // Award icon for the position
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
                  medalIcon,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Profile picture with improved border and shine effect
        Container(
          width: isFirst ? 80 : 70,
          height: isFirst ? 80 : 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.7),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: profilePhoto != null && profilePhoto.isNotEmpty
                ? _buildCachedProfileImage(profilePhoto, name, isFirst)
                : _buildProfileImageFallback(name, isFirst),
          ),
        ),

        const SizedBox(height: 8),

        // Winner name with improved style
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

        // تحسين عرض النقاط - إظهار أيقونة مختلفة
        Container(
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
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

        // عرض عدد الجواهر بشكل منفصل
        if (int.parse(claimedGems) > 0)
          Container(
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond, color: Colors.amber, size: 10),
                SizedBox(width: 2),
                Text(
                  "$claimedGems",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Podium
        Container(
          width: isFirst ? 80 : 70,
          height: 10,
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

// تحسين عنصر عرض الفائز في القائمة لتمييز النقاط عن الجواهر
  Widget _buildTopWinnerItem(String name, String points, String rank,
      bool isFirst, Map<String, dynamic> user) {
    final String? profilePhoto = user['profilePhoto'];
    final String claimedGems = user['stats']['claimedGems'].toString();
    final bool hasClaimedGems = int.parse(claimedGems) > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFirst
            ? Colors.amber.withOpacity(0.25)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? Colors.amber.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFirst
                ? Colors.amber.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // تحسين شكل الترتيب
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isFirst ? Colors.amber : _getRankColor(int.parse(rank)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isFirst
                      ? Colors.amber.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                rank,
                style: TextStyle(
                  color: isFirst ? Colors.black : Colors.white,
                  fontWeight: AppFonts.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // تحسين عرض صورة البروفايل
          Stack(
            children: [
              // Main avatar with enhanced border
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isFirst ? Colors.amber : Colors.white.withOpacity(0.3),
                    width: isFirst ? 2 : 1,
                  ),
                  boxShadow: isFirst
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: profilePhoto != null && profilePhoto.isNotEmpty
                      ? _buildCachedProfileImage(profilePhoto, name, isFirst)
                      : _buildProfileImageFallback(name, isFirst),
                ),
              ),

              // Badge for claimed gems (only if they have any)
              if (hasClaimedGems)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.diamond,
                      color: Colors.black,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // تحسين عرض معلومات المستخدم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isFirst ? AppFonts.bold : AppFonts.medium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                // عرض كلا من النقاط والجواهر في سطر واحد
                Row(
                  children: [
                    // عرض النقاط
                    Container(
                      margin: EdgeInsets.only(top: 4, right: 6),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: isFirst
                                ? Colors.amber
                                : Colors.white.withOpacity(0.7),
                            size: 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            points,
                            style: TextStyle(
                              color: isFirst ? Colors.amber : Colors.white,
                              fontSize: 12,
                              fontWeight: AppFonts.medium,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // عرض الجواهر إذا كان هناك
                    if (hasClaimedGems)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.diamond,
                              color: Colors.amber,
                              size: 12,
                            ),
                            SizedBox(width: 2),
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

          // إضافة نص توضيحي للنقاط
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          //   decoration: BoxDecoration(
          //     color: isFirst
          //         ? Colors.amber.withOpacity(0.2)
          //         : Colors.white.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: isFirst
          //           ? Colors.amber.withOpacity(0.3)
          //           : Colors.transparent,
          //       width: 1,
          //     ),
          //   ),
          //   child: Column(
          //     children: [
          //       Text(
          //         'نقاط',
          //         style: TextStyle(
          //           color:
          //               isFirst ? Colors.amber : Colors.white.withOpacity(0.8),
          //           fontSize: 12,
          //           fontWeight: AppFonts.medium,
          //         ),
          //       ),
          //       SizedBox(height: 2),
          //       Text(
          //         points,
          //         style: TextStyle(
          //           color: isFirst ? Colors.amber : Colors.white,
          //           fontSize: 16,
          //           fontWeight: AppFonts.bold,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

// دالة مساعدة لتحديد لون الرتبة بناءً على المركز
  Color _getRankColor(int rank) {
    if (rank <= 3)
      return Colors
          .transparent; // لن تستخدم في الواقع لأن المراكز الثلاثة الأولى لها تصميم خاص
    if (rank <= 5) return Colors.blue;
    if (rank <= 7) return Colors.purple;
    return Colors.grey;
  }

// تحسين طريقة تحميل صور البروفايل مع معالجة أفضل للأخطاء واستخدام ذاكرة التخزين المؤقت
  Widget _buildCachedProfileImage(String imageUrl, String name, bool isFirst) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      cacheWidth: 150, // استخدام قيمة أقل للذاكرة المؤقتة
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: isFirst ? Colors.amber : Colors.white,
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildProfileImageFallback(name, isFirst);
      },
    );
  }

// تحسين الصورة الافتراضية عند عدم توفر صورة للمستخدم
  Widget _buildProfileImageFallback(String name, bool isFirst) {
    // تحسين ألوان الصورة الافتراضية
    final bgColor = isFirst ? 'F0C419' : '808080';
    final textColor = 'FFFFFF';

    // استخدام API حقيقي لإنشاء صور أفاتار
    return Image.network(
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=$bgColor&color=$textColor&bold=true&size=150',
      fit: BoxFit.cover,
      cacheWidth: 150,
      errorBuilder: (context, error, stackTrace) {
        // في حالة فشل API الأفاتار، نعرض أيقونة احتياطية
        return Container(
          color: isFirst ? Colors.amber.withOpacity(0.3) : Colors.grey[800],
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: isFirst ? 32 : 24,
          ),
        );
      },
    );
  }

// تحسين حالة التحميل
  Widget _buildLoadingState() {
    return Container(
      height: 250,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // إضافة تأثير نبض للتحميل
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل أفضل الفائزين...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

// تحسين حالة الخطأ
  Widget _buildErrorState(String message) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // تحسين أيقونة الخطأ
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.white.withOpacity(0.7),
                size: 40,
              ),
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _fetchTopWinners,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'إعادة المحاولة',
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
          ],
        ),
      ),
    );
  }

  // Helper method to build an avatar image
  Widget buildAvatarImage(String name, bool isFirst) {
    return Image.network(
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=${isFirst ? 'F0C419' : '808080'}&color=fff&size=100',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: isFirst ? Colors.amber.withOpacity(0.3) : Colors.grey[800],
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildContactUsSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.green.withOpacity(0.7),
            Colors.teal.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // بارتكلز زخرفية
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
              padding: EdgeInsets.all(22),
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
                        ),
                        child: Icon(
                          Icons.business,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'تواصل معنا للإعلان',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // محتوى القسم
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // عنصر زخرفي
                        Positioned(
                          bottom: -40,
                          right: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),

                        // المحتوى
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // مخطط تسويقي
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildStatItem('+50K', 'مشاهدة يومية'),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        _buildStatItem('+10K', 'مستخدم نشط'),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        _buildStatItem('+20K', 'تفاعل شهري'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),

                              // عنوان فرعي
                              Text(
                                'أعلن معنا واصل لجمهورك المستهدف',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: AppFonts.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 12),

                              // وصف
                              Text(
                                'نقدم حلول إعلانية متكاملة تناسب احتياجات عملك. تواصل معنا الآن للحصول على عروض وباقات خاصة',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 30),

                              // زر الاتصال
                              _buildContactButton(
                                onTap: () async {
                                  // تنظيف رقم الهاتف من أي علامات إضافية
                                  final String cleanPhone = phoneRadar
                                      .replaceAll('+', '')
                                      .replaceAll('-', '')
                                      .replaceAll(' ', '')
                                      .trim();

                                  try {
                                    // استخدام صيغة مباشرة لفتح تطبيق الهاتف
                                    final String telUri = 'tel:$cleanPhone';

                                    if (await canLaunch(telUri)) {
                                      await launch(telUri);
                                    } else {
                                      _showPhoneNumberSnackbar(cleanPhone);
                                    }
                                  } catch (e) {
                                    print("Error launching phone app: $e");
                                    _showPhoneNumberSnackbar(cleanPhone);
                                  }
                                },
                                icon: Icons.phone,
                                title: 'اتصل بنا',
                                subtitle: 'للتحدث مع فريق المبيعات',
                                color: Colors.blue.shade700,
                              ),

                              SizedBox(height: 16),

                              // زر واتساب
                              _buildContactButton(
                                onTap: () async {
                                  // تنظيف رقم الهاتف من أي علامات إضافية
                                  final String cleanPhone = phoneRadar
                                      .replaceAll('+', '')
                                      .replaceAll('-', '')
                                      .replaceAll(' ', '')
                                      .trim();

                                  try {
                                    // استخدام صيغة مباشرة لفتح واتساب
                                    final String whatsappUrl =
                                        'https://wa.me/$cleanPhone?text=مرحباً، أود الاستفسار عن الإعلان في تطبيق Radar';

                                    if (await canLaunch(whatsappUrl)) {
                                      await launch(whatsappUrl);
                                    } else {
                                      _showPhoneNumberSnackbar(cleanPhone);
                                    }
                                  } catch (e) {
                                    print("Error launching WhatsApp: $e");
                                    _showPhoneNumberSnackbar(cleanPhone);
                                  }
                                },
                                icon: FontAwesomeIcons.whatsapp,
                                title: 'تواصل عبر واتساب',
                                subtitle: 'للاستفسار والعروض الخاصة',
                                color: Color(0xFF25D366),
                              ),

                              SizedBox(height: 20),

                              // وقت العمل (إصلاح مشكلة التكسر)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'متاح من الأحد إلى الخميس، 9 صباحاً - 5 مساءً',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

// دالة مساعدة لعرض رسالة مع الرقم ونسخه
  void _showPhoneNumberSnackbar(String phoneNumber) {
    Get.snackbar(
      'رقم الاتصال',
      'يمكنك الاتصال على الرقم: $phoneNumber',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 5),
      backgroundColor: Colors.black.withOpacity(0.7),
      colorText: Colors.white,
      mainButton: TextButton(
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: phoneNumber));
          Get.snackbar(
            'تم النسخ',
            'تم نسخ الرقم إلى الحافظة',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 2),
          );
        },
        child: Text(
          'نسخ',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

// دالة مساعدة لبناء عنصر إحصائي
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: AppFonts.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

// دالة مساعدة لبناء زر تواصل
  Widget _buildContactButton({
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF222222),
            Color(0xFF333333),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'الأسئلة الشائعة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFAQItem('كيف أعرف أنني وجدت الجوهرة؟',
                'ستظهر رسالة تهنئة على الشاشة عند مشاهدة الفيديو الذي يحتوي على الجوهرة، وسيتم إضافة النقاط لحسابك فوراً.'),
            _buildFAQItem('هل يمكنني الفوز بأكثر من جوهرة؟',
                'نعم، يمكنك الفوز بجوهرة كل أسبوع إذا كنت أول من يشاهد الفيديو الذي تظهر فيه.'),
            _buildFAQItem('ماذا يمكنني أن أفعل بالنقاط؟',
                'يمكنك استبدال النقاط بجوائز وعروض حصرية في قسم "المتجر".'),
            _buildFAQItem('متى تبدأ فرصة الجوهرة الجديدة؟',
                'تبدأ فرصة جديدة كل يوم أحد في تمام الساعة 12:00 صباحاً.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.question_answer,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
