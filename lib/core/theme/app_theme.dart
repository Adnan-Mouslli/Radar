import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      fontFamily: AppFonts.mainFont,
      textTheme: AppTextStyles.textTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black),
        titleTextStyle: TextStyle(  // إضافة ستايل للعنوان
          fontFamily: AppFonts.mainFont,
          fontWeight: AppFonts.bold,
          fontSize: 20,
          color: AppColors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // يمكنك إضافة السمة الداكنة هنا
    return ThemeData.dark().copyWith(
      // إضافة تخصيصات السمة الداكنة
    );
  }
}