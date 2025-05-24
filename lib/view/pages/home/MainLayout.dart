import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/home/MainLayoutController.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/view/pages/home/HomeScreen.dart';
import 'package:radar/view/pages/home/MarketScreen.dart';
import 'package:radar/view/pages/home/OffersRadarScreen.dart';
import 'package:radar/view/pages/home/ReelsScreen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:radar/view/pages/home/StoresScreen.dart';

class MainLayout extends StatelessWidget {
  final controller = Get.put(MainLayoutController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Obx(() => _buildCurrentPage()),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (controller.currentIndex.value) {
      case 0:
        return ReelsScreen();
      case 1:
        return OffersRadarScreen();
      case 2:
        return StoresScreen();
      case 3:
        return MarketScreen();
      case 4:
        return HomeScreen();
      default:
        return ReelsScreen();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, PhosphorIcons.playCircleBold, 'ريلز'),
              _buildNavItem(1, PhosphorIcons.target, 'الرادار'),
              _buildNavItem(
                  2, PhosphorIcons.storefront, 'المتاجر'), // المتاجر المشتركة
              _buildNavItem(3, PhosphorIcons.trophy, 'الجوائز'), // متجر النقاط
              _buildNavItem(4, PhosphorIcons.userCircleBold, 'حسابي'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = controller.currentIndex.value == index;

    return InkWell(
      onTap: () => controller.changePage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                isSelected ? AppColors.primary : Colors.white.withOpacity(0.6),
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
