import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'dart:async';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? cancelText;
  final String confirmText;
  final Function onConfirm;
  final Function? onCancel;
  final IconData icon;
  final Color iconColor;
  final Color confirmButtonColor;
  final bool showCancelButton;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.cancelText = 'إلغاء',
    this.confirmText = 'تأكيد',
    this.icon = Icons.info_outline,
    this.iconColor = Colors.blue,
    this.confirmButtonColor = Colors.blue,
    this.showCancelButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: AppFonts.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showCancelButton) ...[
                  TextButton(
                    onPressed: () {
                      Get.back();
                      if (onCancel != null) onCancel!();
                    },
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      cancelText!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                ],
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // إغلاق الحوار
                    onConfirm(); // تنفيذ الإجراء المؤكد
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmButtonColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // طرق ساكنة سهلة للاستخدام للحالات الشائعة

  // حوار عام
  static void show({
    required String title,
    required String message,
    required Function onConfirm,
    Function? onCancel,
    String? cancelText,
    String confirmText = 'تأكيد',
    IconData icon = Icons.info_outline,
    Color iconColor = Colors.blue,
    Color confirmButtonColor = Colors.blue,
    bool showCancelButton = true,
  }) {
    Get.dialog(
      CustomDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        cancelText: cancelText,
        confirmText: confirmText,
        icon: icon,
        iconColor: iconColor,
        confirmButtonColor: confirmButtonColor,
        showCancelButton: showCancelButton,
      ),
    );
  }

  // حوار تسجيل الخروج
  static void showLogout({
    required Function onConfirm,
    String title = 'تسجيل الخروج',
    String message = 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
    String cancelText = 'إلغاء',
    String confirmText = 'تأكيد',
  }) {
    show(
      title: title,
      message: message,
      onConfirm: onConfirm,
      cancelText: cancelText,
      confirmText: confirmText,
      icon: Icons.logout,
      iconColor: Colors.redAccent,
      confirmButtonColor: Colors.redAccent,
    );
  }

  // حوار التنبيه
  static void showAlert({
    required String title,
    required String message,
    required Function onConfirm,
    String confirmText = 'حسناً',
  }) {
    show(
      title: title,
      message: message,
      onConfirm: onConfirm,
      confirmText: confirmText,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.amber,
      confirmButtonColor: Colors.amber,
      showCancelButton: false,
    );
  }

  // حوار التأكيد
  static void showConfirmation({
    required String title,
    required String message,
    required Function onConfirm,
    Function? onCancel,
    String cancelText = 'إلغاء',
    String confirmText = 'تأكيد',
  }) {
    show(
      title: title,
      message: message,
      onConfirm: onConfirm,
      onCancel: onCancel,
      cancelText: cancelText,
      confirmText: confirmText,
      icon: Icons.help_outline,
      iconColor: Colors.green,
      confirmButtonColor: Colors.green,
    );
  }

  // حوار الخطأ
  static void showError({
    required String title,
    required String message,
    required Function onConfirm,
    String confirmText = 'حسناً',
  }) {
    show(
      title: title,
      message: message,
      onConfirm: onConfirm,
      confirmText: confirmText,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      confirmButtonColor: Colors.red,
      showCancelButton: false,
    );
  }

  // حوار النجاح
  static void showSuccess({
    required String title,
    required String message,
    required Function onConfirm,
    String confirmText = 'حسناً',
  }) {
    show(
      title: title,
      message: message,
      onConfirm: onConfirm,
      confirmText: confirmText,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
      confirmButtonColor: Colors.green,
      showCancelButton: false,
    );
  }

  // إضافة طريقة للاستخدام مع WillPopScope
  static Future<bool> showConfirmExit({
    String title = 'هل تريد المغادرة؟',
    String message = 'هل أنت متأكد من رغبتك في المغادرة؟',
    String cancelText = 'البقاء',
    String confirmText = 'مغادرة',
    IconData icon = Icons.exit_to_app,
    Color iconColor = Colors.orange,
    Color confirmButtonColor = Colors.orange,
  }) async {
    // استخدام Completer للحصول على نتيجة Future
    final completer = Completer<bool>();

    // عرض الحوار
    show(
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: confirmText,
      icon: icon,
      iconColor: iconColor,
      confirmButtonColor: confirmButtonColor,
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    );

    // إرجاع Future لانتظار النتيجة
    return await completer.future;
  }

  // طريقة خاصة للتأكيد من مغادرة الصفحة مع تغييرات غير محفوظة
  static Future<bool> showUnsavedChangesExit({
    String title = 'هل تريد مغادرة الصفحة؟',
    String message = 'لديك تغييرات غير محفوظة. هل تريد المغادرة بدون حفظ؟',
    String cancelText = 'البقاء',
    String confirmText = 'مغادرة',
  }) async {
    return await showConfirmExit(
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: confirmText,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.primary,
      confirmButtonColor: AppColors.primary,
    );
  }
}
