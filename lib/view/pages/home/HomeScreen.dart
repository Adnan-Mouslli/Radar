import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/profile/ProfileController.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/data/model/UserProfile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:radar/view/pages/home/NetworkErrorSkeleton.dart';
import 'package:radar/view/pages/interests/InterestsManagementScreen.dart';
import 'package:radar/view/pages/skeletons_/HomeScreenSkeleton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final ProfileController controller = Get.put(ProfileController());

  // تحديث الألوان لتكون أكثر راحة للعين مع خلفية سوداء
  final Color bgColor = Colors.black; // لون خلفية أسود
  final Color cardBgColor =
      const Color(0xFF1A1A1A); // لون بطاقات أسود فاتح قليلا
  final Color primaryGradientStart =
      AppColors.primary.withOpacity(0.6); // خفض الشفافية للتناسق
  final Color primaryGradientEnd =
      AppColors.primaryLight.withOpacity(0.4); // أخف للتباين اللطيف
  final Color accentColor =
      AppColors.primary.withOpacity(0.85); // اللون الأساسي بشفافية لتخفيف الحدة

  // إضافة متغيرات جديدة للاتصال
  final String phoneRadar =
      "+963941325008"; // يجب جلب هذه القيمة من التخزين المحلي

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return HomeScreenSkeleton();
        } else if (controller.hasError.value) {
          return NetworkErrorSkeleton(
            message: controller.errorMessage.value,
            onRetry: () => controller.fetchUserProfile(),
          );
        } else if (controller.profile.value == null) {
          return _buildEmptyState();
        } else {
          return _buildHomeContent();
        }
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBgColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد بيانات متاحة',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final user = controller.profile.value!.user;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            // رأس الصفحة المميز
            SliverToBoxAdapter(
              child: _buildHeader(user),
            ),

            // محتوى الاهتمامات
            SliverToBoxAdapter(
              child: _buildInterestsSection(),
            ),

            // قسم تواصل معنا (تم إضافته)
            SliverToBoxAdapter(
              child: _buildContactUsSection(),
            ),

            // قسم الأسئلة الشائعة (تم إضافته)
            SliverToBoxAdapter(
              child: _buildFAQSection(),
            ),

            // زر تسجيل الخروج
            SliverToBoxAdapter(
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          // زر تسجيل الخروج (على اليمين)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.showLogoutConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.12),
                foregroundColor: Colors.white.withOpacity(0.9),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: AppColors.primary.withOpacity(0.25), width: 1),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.logout, size: 18),
              label: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: AppFonts.medium,
                ),
              ),
            ),
          ),

          // مسافة بين الزرين
          SizedBox(width: 12),

          // زر حذف الحساب (على اليسار)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.showDeleteAccountConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.12),
                foregroundColor: Colors.red.withOpacity(0.9),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side:
                      BorderSide(color: Colors.red.withOpacity(0.25), width: 1),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.delete_forever, size: 18),
              label: Text(
                'حذف الحساب',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: AppFonts.medium,
                  color: Colors.red.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile user) {
    // إنشاء تدرج لطيف من مشتقات اللون الأساسي مع الخلفية السوداء
    final List<Color> gradientColors = [
      AppColors.primary.withOpacity(0.65),
      Color.lerp(AppColors.primary, AppColors.primaryLight, 0.5)!
          .withOpacity(0.5),
      AppColors.primaryLight.withOpacity(0.4),
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
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // صورة البروفايل مع إمكانية التعديل
              GestureDetector(
                onTap: () => controller.showImagePickerOptions(),
                child: Stack(
                  children: [
                    // صورة البروفايل
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.7), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Obx(() {
                        // إذا كانت هناك صورة مؤقتة مختارة
                        if (controller.selectedImage.value != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.file(
                              controller.selectedImage.value!,
                              fit: BoxFit.cover,
                            ),
                          );
                        }

                        // إذا كان المستخدم لديه صورة شخصية
                        final profilePhoto = user.profilePhoto;
                        if (profilePhoto != null && profilePhoto.isNotEmpty) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CachedNetworkImage(
                              imageUrl: profilePhoto,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  _buildAvatarPlaceholder(user.name),
                              errorWidget: (context, url, error) =>
                                  _buildAvatarPlaceholder(user.name),
                            ),
                          );
                        }

                        // المستخدم ليس لديه صورة شخصية
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}&background=random",
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _buildAvatarPlaceholder(user.name),
                            errorWidget: (context, url, error) =>
                                _buildAvatarPlaceholder(user.name),
                          ),
                        );
                      }),
                    ),

                    // زر التعديل
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Obx(
                          () => controller.isUploadingPhoto.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // معلومات المستخدم مع إمكانية تعديل الاسم
              Expanded(
                child: Obx(() {
                  if (controller.isEditingName.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: controller.nameController.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: 'أدخل اسمك',
                            hintStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: controller.cancelNameEdit,
                              child: Text(
                                'إلغاء',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: controller.saveNewName,
                              child: Text(
                                'حفظ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "مرحباً، ${user.name}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 22,
                                  fontWeight: AppFonts.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: Colors.white, size: 18),
                              onPressed: controller.startEditingName,
                              padding: EdgeInsets.all(4),
                              constraints: BoxConstraints(),
                              tooltip: 'تعديل الاسم',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildPointsIndicator(user.points),
                      ],
                    );
                  }
                }),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // عرض الاهتمامات العلوية
          _buildTopInterests(),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      color: cardBgColor,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPointsIndicator(int points) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: AppColors.points.withOpacity(0.95),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$points نقطة',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: AppFonts.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInterests() {
    final interests = controller.profile.value?.interests ?? [];
    if (interests.isEmpty) return SizedBox.shrink();

    // عرض أول 5 اهتمامات فقط
    final topInterests = interests.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اهتماماتك المفضلة',
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 16,
            fontWeight: AppFonts.medium,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topInterests.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  topInterests[index].name,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    final interests = controller.profile.value?.interests ?? [];
    // if (interests.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'اهتماماتك',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 18,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => Get.to(() => InterestsManagementScreen()),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: Icon(
                  Icons.edit,
                  color: accentColor,
                  size: 16,
                ),
                label: Text(
                  'تعديل',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 14,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: interests.map((interest) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF222222),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  interest.name,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // إضافة قسم تواصل معنا (معاد تصميمه ليتناسب مع واجهة البروفايل)
  Widget _buildContactUsSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.primaryLight.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // عناصر زخرفية في الخلفية
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
              padding: EdgeInsets.all(20),
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
                          Icons.support_agent,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'خدمة العملاء',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // معلومات الاتصال
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'نحن هنا لمساعدتك',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: AppFonts.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'إذا كان لديك أي استفسار أو مشكلة في التطبيق، يمكنك التواصل معنا من خلال:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // أزرار الاتصال
                        Row(
                          children: [
                            // زر الاتصال
                            Expanded(
                              child: _buildContactButton(
                                onTap: () async {
                                  final String cleanPhone = phoneRadar
                                      .replaceAll('+', '')
                                      .replaceAll('-', '')
                                      .replaceAll(' ', '')
                                      .trim();

                                  try {
                                    final String telUri = 'tel:$cleanPhone';
                                    if (await canLaunch(telUri)) {
                                      await launch(telUri);
                                    } else {
                                      _showPhoneNumberSnackbar(cleanPhone);
                                    }
                                  } catch (e) {
                                    _showPhoneNumberSnackbar(cleanPhone);
                                  }
                                },
                                title: 'اتصل بنا',
                                icon: Icons.phone,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // زر واتساب
                            Expanded(
                              child: _buildContactButton(
                                onTap: () async {
                                  final String cleanPhone = phoneRadar
                                      .replaceAll('+', '')
                                      .replaceAll('-', '')
                                      .replaceAll(' ', '')
                                      .trim();

                                  try {
                                    final String whatsappUrl =
                                        'https://wa.me/$cleanPhone?text=مرحباً، أود الاستفسار عن تطبيق Radar';
                                    if (await canLaunch(whatsappUrl)) {
                                      await launch(whatsappUrl);
                                    } else {
                                      _showPhoneNumberSnackbar(cleanPhone);
                                    }
                                  } catch (e) {
                                    _showPhoneNumberSnackbar(cleanPhone);
                                  }
                                },
                                title: 'واتساب',
                                icon: FontAwesomeIcons.whatsapp,
                                color: Color(0xFF25D366),
                              ),
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
      ),
    );
  }

  Widget _buildContactButton({
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: AppFonts.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // طريقة عرض رسالة مع الرقم ونسخه
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

  // إضافة قسم الأسئلة الشائعة
  Widget _buildFAQSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'الأسئلة الشائعة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // قائمة الأسئلة الشائعة
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
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: AppFonts.medium,
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: Colors.white.withOpacity(0.7),
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              answer,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
