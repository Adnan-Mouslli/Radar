import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/profile/ProfileController.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/data/model/UserProfile.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          } else if (controller.hasError.value) {
            return _buildErrorState();
          } else if (controller.profile.value == null) {
            return _buildEmptyState();
          } else {
            return _buildProfileContent();
          }
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
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
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text(
              "إعادة المحاولة",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'لا توجد بيانات متاحة',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final user = controller.profile.value!.user;
    final stats = controller.profile.value!.stats;

    return SafeArea(
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // رأس الصفحة
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'الملف الشخصي',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: AppFonts.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              // إضافة زر تسجيل الخروج
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () => controller.showLogoutConfirmation(),
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),

          // معلومات المستخدم الأساسية
          SliverToBoxAdapter(
            child: _buildUserInfo(user),
          ),

          // إحصائيات المستخدم
          SliverToBoxAdapter(
            child: _buildUserStats(stats),
          ),

          // الاهتمامات
          SliverToBoxAdapter(
            child: _buildInterests(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(UserProfile user) {
    final provMap = {
      'ALEPPO': 'حلب',
      'DAMASCUS': 'دمشق',
      'HOMS': 'حمص',
      'HAMA': 'حماة',
      'LATAKIA': 'اللاذقية',
      'TARTUS': 'طرطوس',
      'IDLIB': 'إدلب',
      'RAQQA': 'الرقة',
      'DEIR_EZ_ZOR': 'دير الزور',
      'HASAKA': 'الحسكة',
      'DARAA': 'درعا',
      'SUWAYDA': 'السويداء',
      'QUNEITRA': 'القنيطرة',
    };

    final providence = provMap[user.providence] ?? user.providence;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // صورة البروفايل
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.2),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // معلومات المستخدم الأساسية
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عضو منذ ${_formatDate(user.createdAt)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.points} نقطة',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // معلومات إضافية
          _buildInfoItem(Icons.phone, user.phone),
          _buildInfoItem(Icons.location_on, providence),
          _buildInfoItem(
            Icons.person,
            controller.getGenderText(),
          ),
          _buildInfoItem(
            Icons.cake,
            '${controller.getFormattedBirthDate()} (${controller.getAge()} سنة)',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(UserStats stats) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإحصائيات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildStatRow('المشاهدات', stats.totalViews.toString(),
                    'الإعجابات', stats.totalLikes.toString()),
                Divider(color: Colors.white.withOpacity(0.1), height: 30),
                _buildStatRow('المشاركات', stats.totalShares.toString(),
                    'الإعلانات', stats.viewedAdsCount.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(label1, value1),
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.white.withOpacity(0.1),
        ),
        Expanded(
          child: _buildStatItem(label2, value2),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: AppFonts.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInterests() {
    final interests = controller.profile.value?.interests ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الاهتمامات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests
                  .map((interest) => _buildInterestItem(interest))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestItem(Interest interest) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        interest.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: AppFonts.medium,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
