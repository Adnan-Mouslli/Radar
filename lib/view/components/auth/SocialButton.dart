import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const SocialButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // ألوان متوافقة مع الوضع الداكن والفاتح
    final borderColor = isDarkMode 
        ? Colors.grey[800] 
        : AppColors.lightGrey;
    
    final backgroundColor = isDarkMode 
        ? const Color(0xFF1A1A1A) 
        : Colors.white;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}