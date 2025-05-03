import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final FontWeight? fontWeight;
  final bool useGradient;
  final double? elevation;
  final double? borderRadius;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? iconSize;
  final Color? iconColor;
  final double? iconSpacing;
  final double opacity;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 55,
    this.fontSize = 16,
    this.padding,
    this.fontWeight,
    this.useGradient = false,
    // New optional properties
    this.elevation,
    this.borderRadius = 12,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize = 18,
    this.iconColor,
    this.iconSpacing = 8,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color disabledColor = isDarkMode
        ? Colors.grey.withOpacity(0.3)
        : AppColors.grey.withOpacity(0.3);

    final Color disabledTextColor =
        isDarkMode ? Colors.grey[400]! : AppColors.textSecondary;

    // تحديد لون الزر، إما من الخاصية المعطاة أو من الألوان الافتراضية
    final buttonColor =
        isDisabled ? disabledColor : backgroundColor ?? AppColors.primary;

    // تحديد لون الأيقونة
    final Color actualIconColor = iconColor ?? (textColor ?? Colors.white);

    // إنشاء محتوى الزر (نص أو حالة التحميل)
    Widget buttonContent = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
              strokeWidth: 2.5,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Icon(
                  prefixIcon,
                  color: actualIconColor,
                  size: iconSize,
                ),
                SizedBox(width: iconSpacing),
              ],
              Text(
                text,
                style: TextStyle(
                  color: isDisabled
                      ? disabledTextColor
                      : textColor ?? Colors.white,
                  fontSize: fontSize,
                  fontWeight: fontWeight ?? AppFonts.bold,
                ),
              ),
              if (suffixIcon != null) ...[
                SizedBox(width: iconSpacing),
                Icon(
                  suffixIcon,
                  color: actualIconColor,
                  size: iconSize,
                ),
              ],
            ],
          );

    // ننشئ الزر الرئيسي
    if (useGradient && !isDisabled) {
      // الزر مع تدرج لوني
      return Opacity(
        opacity: opacity,
        child: InkWell(
          onTap: (isLoading || isDisabled) ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius!),
          child: Container(
            width: width ?? double.infinity,
            height: height,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius!),
              boxShadow: [
                if (!isDisabled && (elevation != null && elevation! > 0))
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: elevation! * 2,
                    offset: Offset(0, elevation! / 2),
                  ),
              ],
            ),
            child: Center(
              child: buttonContent,
            ),
          ),
        ),
      );
    } else {
      // الزر العادي بدون تدرج
      return MaterialButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        minWidth: width ?? double.infinity,
        height: height,
        color: buttonColor,
        disabledColor: disabledColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        elevation: elevation ?? 0,
        highlightElevation: elevation != null ? elevation! * 0.7 : 0,
        child: buttonContent,
      );
    }
  }
}

// يمكن إضافة أزرار مخصصة إضافية للاستخدام المتكرر
class PrimaryButton extends CustomButton {
  PrimaryButton({
    super.key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    bool useGradient = true,
    double? elevation,
    double? borderRadius,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) : super(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          isDisabled: isDisabled,
          width: width,
          height: height,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          useGradient: useGradient,
          elevation: elevation,
          borderRadius: borderRadius,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        );
}

class SecondaryButton extends CustomButton {
  SecondaryButton({
    super.key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) : super(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          isDisabled: isDisabled,
          width: width,
          height: height,
          backgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          useGradient: false,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        );
}
