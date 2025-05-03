// file: lib/widgets/common/error_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/theme/app_colors.dart';

class ErrorView extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final bool showCloseButton;
  final Color? iconColor;
  final double iconSize;

  const ErrorView({
    Key? key,
    this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.showCloseButton = true,
    this.iconColor,
    this.iconSize = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة الخطأ
          Icon(
            icon,
            color: iconColor ?? Colors.red[300],
            size: iconSize,
          ),

          SizedBox(height: 16),

          // رسالة الخطأ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message ?? 'حدث خطأ أثناء تحميل البيانات',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),

          SizedBox(height: 24),

          // أزرار الإجراءات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // زر إعادة المحاولة (إذا كان متوفراً)
              if (onRetry != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              // زر الإغلاق
              if (showCloseButton)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
