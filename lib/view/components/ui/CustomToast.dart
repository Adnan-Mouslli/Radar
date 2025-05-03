import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomToast {
  static void showToast({
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    Color iconColor = Colors.redAccent,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.error_outline,
  }) {
    // استخدام Get.snackbar مع تحسين الحركة والتصميم
    Get.snackbar(
      '', // عنوان فارغ
      '', // رسالة فارغة لأننا سنستخدم messageText
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      borderRadius: 15,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      duration: duration,
      
      // تخفيف سرعة الحركة
      animationDuration: const Duration(milliseconds: 500),
      
      // تغيير منحنى الحركة لجعلها أكثر سلاسة
      forwardAnimationCurve: Curves.easeInOut,
      reverseAnimationCurve: Curves.easeOutQuart,
      
      // جعل الرسالة تظهر ببطء
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      
      // تحسين التظليل
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: const Offset(0, 4),
          spreadRadius: 0.5,
        ),
      ],
      
      // محتوى الرسالة
      messageText: Row(
        textDirection: TextDirection.rtl, // اتجاه العرض من اليمين إلى اليسار
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
      
      // إخفاء العنوان
      titleText: const SizedBox.shrink(),
      
      // تغيير طريقة عرض الرسالة
      snackStyle: SnackStyle.FLOATING,
    );
  }
  
  // دالة لإظهار توست نجاح
  static void showSuccessToast({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      message: message,
      backgroundColor: Color.fromRGBO(34, 139, 34, 0.9), // ظل أخضر شفاف قليلاً
      iconColor: Colors.white,
      icon: Icons.check_circle,
      duration: duration,
    );
  }
  
  // دالة لإظهار توست إنذار
  static void showWarningToast({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      message: message,
      backgroundColor: Color.fromRGBO(255, 140, 0, 0.9), // ظل برتقالي شفاف قليلاً
      iconColor: Colors.white,
      icon: Icons.warning_amber_rounded,
      duration: duration,
    );
  }
  
  // دالة لإظهار توست خطأ
  static void showErrorToast({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      message: message,
      backgroundColor: Color.fromRGBO(178, 34, 34, 0.9), // ظل أحمر شفاف قليلاً
      iconColor: Colors.white,
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  static void showInfoToast({required String message}) {
  Get.snackbar(
    'معلومات',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.blue.withOpacity(0.8),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    borderRadius: 10,
    icon: const Icon(Icons.info, color: Colors.white),
  );
}

}