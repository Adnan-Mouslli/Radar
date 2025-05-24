import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:radar/core/services/RewardsService.dart';
import 'package:radar/core/services/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:radar/controller/profile/ProfileController.dart';
import 'package:radar/view/components/ui/CustomDialog.dart';
import 'package:radar/view/components/ui/CustomToast.dart';
import 'package:radar/view/pages/home/QrScannerScreen.dart';



// نموذج بيانات المكافأة
class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final bool isActive;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final IconData iconData;
  final Color color;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.isActive,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.iconData,
    required this.color,
  });

  factory Reward.fromJson(
      Map<String, dynamic> json, IconData iconData, Color color) {
    return Reward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pointsCost: json['pointsCost'],
      isActive: json['isActive'],
      categoryId: json['categoryId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      iconData: iconData,
      color: color,
    );
  }
}

// نموذج بيانات الفئة
class Category {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Reward> rewards;

  Category({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.rewards,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // تعيين أيقونة ولون مختلف لكل فئة
    Color categoryColor = _getCategoryColor(json['name']);
    IconData categoryIcon = _getCategoryIcon(json['name']);

    List<Reward> rewardsList = [];
    if (json['rewards'] != null) {
      rewardsList = (json['rewards'] as List)
          .map((rewardJson) =>
              Reward.fromJson(rewardJson, categoryIcon, categoryColor))
          .toList();
    }

    return Category(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      rewards: rewardsList,
    );
  }

  // دالة مساعدة للحصول على لون مناسب لكل فئة
  static Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'قسائم':
        return Colors.purple;
      case 'اشتراكات':
        return Colors.amber;
      case 'عضويات':
        return Colors.teal;
      case 'بطاقات هدايا':
        return Colors.red;
      case 'عملات افتراضية':
        return Colors.orange;
      case 'شارات':
        return Colors.blue;
      default:
        // لون عشوائي للفئات الأخرى
        final List<Color> colors = [
          Colors.pink,
          Colors.indigo,
          Colors.green,
          Colors.deepOrange,
          Colors.lightBlue,
          Colors.lime,
        ];

        // استخدام اسم الفئة لتوليد رقم ثابت لنفس الفئة دائمًا
        int hashCode = categoryName.hashCode;
        return colors[hashCode % colors.length];
    }
  }

  // دالة مساعدة للحصول على أيقونة مناسبة لكل فئة
  static IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'قسائم':
        return FontAwesomeIcons.ticket;
      case 'اشتراكات':
        return FontAwesomeIcons.crown;
      case 'عضويات':
        return FontAwesomeIcons.gem;
      case 'بطاقات هدايا':
        return FontAwesomeIcons.gift;
      case 'عملات افتراضية':
        return FontAwesomeIcons.coins;
      case 'شارات':
        return FontAwesomeIcons.certificate;
      default:
        // أيقونة افتراضية للفئات الأخرى
        final List<IconData> icons = [
          FontAwesomeIcons.star,
          FontAwesomeIcons.trophy,
          FontAwesomeIcons.medal,
          FontAwesomeIcons.award,
          FontAwesomeIcons.ribbon,
          FontAwesomeIcons.gift,
        ];

        // استخدام اسم الفئة لتوليد رقم ثابت لنفس الفئة دائمًا
        int hashCode = categoryName.hashCode;
        return icons[hashCode % icons.length];
    }
  }
}


class MarketController extends GetxController {
  final ProfileController profileController = Get.find<ProfileController>();
  final RewardsService _rewardsService = RewardsService();
  final MyServices _services = Get.find<MyServices>();

  // حالة تحميل متجر النقاط
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Category> categories = <Category>[].obs;
  
  // حالة تحميل المتصدرين
  final RxBool isLoadingLeaders = false.obs;
  final RxBool hasLeadersError = false.obs;
  final RxString leadersErrorMessage = ''.obs;
  final RxList<Map<String, dynamic>> topWinners = <Map<String, dynamic>>[].obs;
  
  // معلومات الجوهرة الأسبوعية
  final RxString weeklyJewelValue = "500".obs;
  final int topWinnersCount = 10; // عدد المتصدرين المراد عرضهم
  
  // بيانات التبويب
  final RxInt activeTabIndex = 0.obs;
  late TabController tabController;
  
  @override
  void onInit() {
    super.onInit();
    // تهيئة قيمة الجوهرة من المخزن المحلي
    weeklyJewelValue.value = _services.getData("WeeklyJewelValue") ?? "500";
    
    // تحميل البيانات
    loadRewards();
    loadTopWinners();
    profileController.update();
  }
  
  // دالة لتهيئة وحدة تحكم التبويب
  void initTabController(TabController controller) {
    tabController = controller;
    tabController.addListener(_handleTabChange);
  }
  
  // الاستماع لتغييرات التبويب
  void _handleTabChange() {
    if (!tabController.indexIsChanging) {
      activeTabIndex.value = tabController.index;
      
      // إعادة تحميل البيانات عند الانتقال للتبويب إذا كانت فارغة
      if (activeTabIndex.value == 0 && categories.isEmpty && !isLoading.value) {
        loadRewards();
      } else if (activeTabIndex.value == 2 && topWinners.isEmpty && !isLoadingLeaders.value) {
        loadTopWinners();
      }
    }
  }
  
  // تغيير التبويب النشط
  void changeTab(int index) {
    if (tabController.index != index) {
      tabController.animateTo(index);
    }
  }

  // تحميل المكافآت وفئاتها
  Future<void> loadRewards() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final data = await _rewardsService.getRewardsWithCategories();
      categories.value = data
          .map((item) => Category.fromJson(item))
          .where((category) => category.isActive && category.rewards.isNotEmpty)
          .toList();
    } catch (e) {
      hasError.value = true;
      
      // تحسين رسائل الخطأ للمستخدم
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage.value = 'لا يمكن الاتصال بالإنترنت';
      } else if (e.toString().contains('Timeout')) {
        errorMessage.value = 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
      } else {
        errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
      }
      print("خطأ في جلب بيانات المتجر: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل قائمة المتصدرين
  Future<void> loadTopWinners() async {
    try {
      isLoadingLeaders.value = true;
      hasLeadersError.value = false;

      final url = Uri.parse('${AppLink.server}/api/users/top-awarded?limit=$topWinnersCount');
      final response = await https.get(
        url,
        headers: {
          'Authorization': 'Bearer ${_services.getToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Connection timeout');
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          topWinners.value = List<Map<String, dynamic>>.from(data['data']);
        } else {
          hasLeadersError.value = true;
          leadersErrorMessage.value = 'لا توجد بيانات متاحة';
        }
      } else {
        hasLeadersError.value = true;
        leadersErrorMessage.value = 'حدث خطأ في استرجاع البيانات';
      }
    } catch (e) {
      hasLeadersError.value = true;
      leadersErrorMessage.value = e.toString().contains('timeout') ||
              e.toString().contains('Connection')
          ? 'لا يمكن الاتصال بالإنترنت'
          : 'حدث خطأ في تحميل البيانات';
      print('Error fetching top winners: $e');
    } finally {
      isLoadingLeaders.value = false;
    }
  }
  
  // تحديث قيمة الجوهرة الأسبوعية
  Future<void> refreshWeeklyJewelValue() async {
    try {
      final response = await https.get(
        Uri.parse('${AppLink.server}/api/config/weekly-jewel-value'),
        headers: {
          'Authorization': 'Bearer ${_services.getToken()}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final value = data['data']['value'].toString();
          weeklyJewelValue.value = value;
          
          // حفظ القيمة في المخزن المحلي
          _services.sharedPreferences.setString("WeeklyJewelValue", value);
        }
      }
    } catch (e) {
      print('Error refreshing weekly jewel value: $e');
      // لا نظهر رسالة خطأ للمستخدم، نستمر في استخدام القيمة المخزنة محلياً
    }
  }

  // شراء مكافأة
  void purchaseReward(Reward reward) {
    final int userPoints = profileController.profile.value?.user.points ?? 0;

    if (userPoints < reward.pointsCost) {
      // استخدام CustomToast
      CustomToast.showErrorToast(
        message: 'ليس لديك نقاط كافية لشراء هذه المكافأة',
      );
    } else {
      // استخدام CustomDialog
      CustomDialog.showConfirmation(
        title: 'تأكيد الشراء',
        message:
            'هل أنت متأكد من شراء ${reward.title} مقابل ${reward.pointsCost} نقطة؟',
        cancelText: 'إلغاء',
        confirmText: 'تأكيد الشراء',
        onConfirm: () {
          _confirmPurchase(reward);
        },
      );
    }
  }

  // تأكيد عملية الشراء
  Future<void> _confirmPurchase(Reward reward) async {
    isLoading.value = true;

    try {
      // استدعاء API لشراء المكافأة والحصول على الاستجابة
      final response = await _rewardsService.purchaseReward(reward.id);

      // تحديث نقاط المستخدم من الاستجابة
      final int remainingPoints = response['remainingPoints'];

      // تحديث نقاط المستخدم في ملف التعريف
      profileController.updateUserPoints(remainingPoints);

      const duration = Duration(seconds: 10);

      // إظهار رسالة نجاح الشراء
      CustomToast.showSuccessToast(
        duration: duration,
        message:
            'تم شراء ${reward.title} بنجاح، سيتم التواصل معك من قبل فريق رادار لاستلام الجائزة خلال 24 ساعة',
      );

      // إعادة تحميل المكافآت
      loadRewards();
    } catch (error) {
      // إظهار رسالة الخطأ
      CustomToast.showErrorToast(
        message: error.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // تحديث جميع البيانات
  Future<void> refreshAllData() async {
    // تحميل جميع البيانات المطلوبة بالتوازي
    await Future.wait([
      loadRewards().catchError((_) {}),
      loadTopWinners().catchError((_) {}),
      refreshWeeklyJewelValue().catchError((_) {}),
    ]);
  }
  
  // فتح QR Scanner
  void openQrScanner() {
    Get.to(() => QrScannerScreen());
  }
  
  @override
  void onClose() {
    tabController.removeListener(_handleTabChange);
    super.onClose();
  }
}