import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors

  static const Color primary = Color(0xFFFD5C47);
  static const Color primaryLight = Color(0xFFFFA08A);

  // static const Color primary = Color(0xFFFF7D3B);
  // static const Color primaryLight = Color(0xFFFFA372);

  // static const Color primary =
  //     Color.fromARGB(255, 250, 130, 1); //Color(0xFFFF3366);
  // static const Color primaryLight =
  //     Color.fromARGB(255, 236, 154, 67); // Color(0xFFFF6B93);

  static const Color primaryDark = Color(0xFFE61E50);
  static const Color secondary = Color(0xFF2D3250);

  // Accent Colors
  static const Color accent1 = Color(0xFF00D9F5); // أزرق فاتح للتفاعلات
  static const Color accent2 = Color(0xFFFFA41B); // برتقالي للتنبيهات
  static const Color accent3 = Color(0xFF7A4EFE); // بنفسجي للمميزات الخاصة

  // Neutral Colors
  static const Color black = Color(0xFF1A1A1A);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color white = Colors.white;

  // Background Colors
  static const Color background = Colors.black;
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFF8F9FA);
  static const Color modalBackground = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFAAAAAA);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF2196F3);

  // Social & Engagement Colors
  static const Color like = Color(0xFFFF4B4B);
  static const Color share = Color(0xFF4B9DFF);
  static const Color comment = Color(0xFF4CAF50);
  static const Color points = Color(0xFFFFD700); // لون النقاط والجواهر

  // Gradient Colors
  static List<Color> primaryGradient = [
    primary,
    primaryLight,
  ];

  static List<Color> storyGradient = [
    const Color(0xFFFF6B93),
    const Color(0xFFFF3366),
  ];

  // Overlay & Shadow Colors
  static Color shadowColor = Colors.black.withOpacity(0.1);
  static Color overlayColor = Colors.black.withOpacity(0.5);
  static Color shimmerBase = Colors.grey[200]!;
  static Color shimmerHighlight = Colors.grey[100]!;
}
