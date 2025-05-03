import 'package:flutter/material.dart';
import '../../../controller/onBoarding/onboarding_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasource/static/static.dart';
import 'package:get/get.dart';

class CustomDotControllerOnBoarding extends StatelessWidget {
  const CustomDotControllerOnBoarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحديد وضع السمة الحالي
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // تعيين لون النقاط غير النشطة بناءً على وضع السمة
    final inactiveDotColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    
    return GetBuilder<OnBoardingControllerImp>(
      builder: (controller) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          onBoardingList.length,
          (index) => Container(
            margin: const EdgeInsets.only(right: 8),
            width: controller.currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: controller.currentPage == index
                  ? AppColors.primary
                  : inactiveDotColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}