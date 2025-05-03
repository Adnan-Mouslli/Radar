import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/onBoarding/onboarding_controller.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/datasource/static/static.dart';

class CustomSliderOnBoarding extends GetView<OnBoardingControllerImp> {
  const CustomSliderOnBoarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحديد وضع السمة الحالي
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // تعيين ألوان النصوص بناءً على وضع السمة
    final titleColor = isDarkMode ? Colors.white : Theme.of(context).textTheme.headlineLarge?.color;
    final bodyColor = isDarkMode ? Colors.grey[400] : Colors.grey[800];
    
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: onBoardingList.length,
      itemBuilder: (context, i) => FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الصورة - قد تحتاج إلى صور مختلفة للوضع الداكن إذا كانت الصور الحالية غير مناسبة
              Image.asset(
                isDarkMode && onBoardingList[i].darkImage != null
                    ? onBoardingList[i].darkImage!  // استخدام الصورة المخصصة للوضع الداكن إذا كانت متوفرة
                    : onBoardingList[i].image!,
                height: MediaQuery.of(context).size.height * 0.35,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              // العنوان
              Text(
                onBoardingList[i].title!,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: AppFonts.bold,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // النص التوضيحي
              Text(
                onBoardingList[i].body!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.6,
                  fontSize: 16,
                  color: bodyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}