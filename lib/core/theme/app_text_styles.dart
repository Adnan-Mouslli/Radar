import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontFamily: AppFonts.mainFont,
      fontWeight: AppFonts.bold,
      fontSize: AppFonts.h1,
      color: AppColors.black,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppFonts.mainFont,
      fontWeight: AppFonts.semiBold,
      fontSize: AppFonts.h2,
      color: AppColors.black,
    ),
    headlineSmall: TextStyle(
      color: AppColors.primary,
      fontFamily: AppFonts.mainFont,
      fontSize: AppFonts.h3,
      fontWeight: AppFonts.bold,
    ),
    bodyLarge: TextStyle(
      height: 1.5,  // تعديل المسافة بين السطور لتناسب الخط العربي
      color: AppColors.grey,
      fontWeight: AppFonts.medium,
      fontSize: AppFonts.body1,
      fontFamily: AppFonts.mainFont,
    ),
    bodyMedium: TextStyle(
      height: 1.5,
      color: AppColors.grey,
      fontSize: AppFonts.body2,
      fontFamily: AppFonts.mainFont,
      fontWeight: AppFonts.regular,
    ),
  );
}