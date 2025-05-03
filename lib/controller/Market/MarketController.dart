import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/profile/ProfileController.dart';
import 'package:radar/core/services/RewardsService.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:radar/view/components/ui/CustomToast.dart';
import 'package:radar/view/components/ui/CustomDialog.dart'; // Add this import
import 'package:url_launcher/url_launcher.dart';

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

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Category> categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRewards();
    profileController.update();
  }

  void loadRewards() {
    isLoading.value = true;
    hasError.value = false;

    _rewardsService.getRewardsWithCategories().then((data) {
      categories.value = data
          .map((item) => Category.fromJson(item))
          .where((category) => category.isActive && category.rewards.isNotEmpty)
          .toList();

      isLoading.value = false;
    }).catchError((e) {
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

      isLoading.value = false;
    });
  }

  void purchaseReward(Reward reward) {
    final int userPoints = profileController.profile.value?.user.points ?? 0;

    if (userPoints < reward.pointsCost) {
      // استخدام CustomToast بدلاً من Get.snackbar
      CustomToast.showErrorToast(
        message: 'ليس لديك نقاط كافية لشراء هذه المكافأة',
      );
    } else {
      // استخدام CustomDialog بدلاً من AlertDialog
      CustomDialog.showConfirmation(
        title: 'تأكيد الشراء',
        message:
            'هل أنت متأكد من شراء ${reward.title} مقابل ${reward.pointsCost} نقطة؟',
        cancelText: 'إلغاء',
        confirmText: 'تأكيد الشراء',
        onConfirm: () {
          _confirmPurchase(reward);
        },
        // icon: FontAwesomeIcons.shoppingCart,
        // iconColor: AppColors.primary,
        // confirmButtonColor: AppColors.primary,
      );
    }
  }

  Future<void> _confirmPurchase(Reward reward) async {
    isLoading.value = true;

    try {
      // استدعاء API لشراء المكافأة والحصول على الاستجابة
      final response = await _rewardsService.purchaseReward(reward.id);

      // تحديث نقاط المستخدم من الاستجابة
      final int remainingPoints = response['remainingPoints'];
      // final userReward = response['userReward'];

      // تحديث نقاط المستخدم في ملف التعريف
      profileController.updateUserPoints(remainingPoints);

      const duration = Duration(
          days: 0,
          hours: 0,
          minutes: 0,
          seconds: 10,
          milliseconds: 0,
          microseconds: 0);

      // استخدام CustomToast بدلاً من Get.snackbar
      CustomToast.showSuccessToast(
        duration: duration,
        message:
            'تم شراء ${reward.title} بنجاح، سيتم التوصل معك من قبل فريق رادار لاستلام الجائزة خلال 24 ساعة',
      );

      // إظهار مربع حوار للتأكيد قبل فتح الواتساب باستخدام CustomDialog
      // CustomDialog.showConfirmation(
      //   title: 'متابعة المكافأة',
      //   message: 'سيتم فتح واتساب لمتابعة مكافأتك مع فريق الدعم. هل ترغب في المتابعة؟',
      //   cancelText: 'لاحقًا',
      //   confirmText: 'متابعة على واتساب',
      //   // icon: FontAwesomeIcons.whatsapp,
      //   // iconColor: Colors.green,
      //   // confirmButtonColor: Colors.green,
      //   onConfirm: () {
      //     _openWhatsApp(userReward);
      //   },
      // );

      // إعادة تحميل الصفحة لتحديث البيانات
      loadRewards();
    } catch (error) {
      // استخدام CustomToast بدلاً من Get.snackbar
      CustomToast.showErrorToast(
        message: error.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _openWhatsApp(dynamic userReward) async {
    try {
      // استخراج معلومات المكافأة
      final rewardTitle = userReward['reward']['title'];
      final rewardPoints = userReward['pointsSpent'];
      final rewardId = userReward['id'];
      final categoryName = userReward['reward']['category']['name'];

      // إنشاء رسالة واتساب
      final message = '''
مرحبا فريق Radar،

لقد قمت بشراء مكافأة:
- المكافأة: $rewardTitle
- الفئة: $categoryName
- النقاط المستخدمة: $rewardPoints
- رقم الطلب: $rewardId

أرجو المساعدة في الحصول على المكافأة.

شكرا لكم!
''';

      // رقم الواتساب للشركة (يجب تحديثه بالرقم الصحيح)
      const phoneNumber = '+963941325008'; // تحديث الرقم حسب رقم واتساب الشركة

      // إنشاء رابط واتساب مع الرسالة
      final whatsappUrl =
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

      // فتح الرابط
      final Uri uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // استخدام CustomToast بدلاً من Get.snackbar
        CustomToast.showErrorToast(
          message: 'لا يمكن فتح واتساب، الرجاء التأكد من تثبيت التطبيق',
        );
      }
    } catch (e) {
      // استخدام CustomToast بدلاً من Get.snackbar
      CustomToast.showErrorToast(
        message: 'فشل في فتح واتساب: ${e.toString()}',
      );
    }
  }
}
