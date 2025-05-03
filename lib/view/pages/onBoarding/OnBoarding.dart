import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/view/components/onbording/CustomDotControllerOnBoarding.dart';
import '../../../controller/onBoarding/onboarding_controller.dart';
import '../../components/onbording/custombutton.dart';
import '../../components/onbording/customslider.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OnBoardingControllerImp());

    // تحديد وضع السمة الحالي
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // تعيين لون الخلفية بناءً على وضع السمة
    final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : AppColors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const Expanded(
            child: CustomSliderOnBoarding(),
          ),
          const SizedBox(height: 20),
          const CustomDotControllerOnBoarding(),
          const SizedBox(height: 20),
          const CustomButtonOnBoarding(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
