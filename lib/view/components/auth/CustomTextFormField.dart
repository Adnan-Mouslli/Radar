import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final VoidCallback? onPasswordToggle;
  final void Function(String)? onChanged;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final bool isDarkMode;

  const CustomTextFormField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.controller,
    this.validator,
    this.onPasswordToggle,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ألوان متوافقة مع الوضع الداكن والفاتح
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final hintColor = isDarkMode 
        ? Colors.grey[500] 
        : AppColors.textSecondary.withOpacity(0.5);
    final fillColor = isDarkMode 
        ? const Color(0xFF1A1A1A) 
        : Colors.white;
    final borderColor = isDarkMode 
        ? Colors.grey[800] 
        : AppColors.lightGrey.withOpacity(0.5);
    final iconColor = isDarkMode 
        ? AppColors.primary.withOpacity(0.8) 
        : AppColors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Text
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: AppFonts.medium,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),

        // TextFormField
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          maxLines: isPassword ? 1 : maxLines,
          minLines: minLines,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: AppFonts.regular,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 14,
              fontWeight: AppFonts.regular,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: iconColor,
              size: 22,
            ),
            suffixIcon: isPassword && onPasswordToggle != null ? IconButton(
              icon: Icon(
                isPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: iconColor,
                size: 22,
              ),
              onPressed: onPasswordToggle,
            ) : null,

            // Borders
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade300,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade300,
                width: 1.5,
              ),
            ),

            // Colors and Padding
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            // Error Style
            errorStyle: TextStyle(
              color: Colors.red.shade300,
              fontSize: 12,
              fontWeight: AppFonts.regular,
            ),
          ),
        ),
      ],
    );
  }
}