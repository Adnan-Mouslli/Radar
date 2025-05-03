import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:radar/core/theme/app_colors.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(CountryCode)? onCountryCodeChanged;
  final String? Function(String?)? validator;
  final String label;
  final String hintText;
  final bool isDarkMode;
  final CountryCode? initialCountryCode;
  final String? errorText;

  const PhoneInputField({
    Key? key,
    required this.controller,
    this.onCountryCodeChanged,
    this.validator,
    required this.label,
    required this.hintText,
    required this.isDarkMode,
    this.initialCountryCode,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fillColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[800]! : AppColors.lightGrey;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final hintColor = isDarkMode ? Colors.grey[400]! : AppColors.textSecondary;
    final prefixIconColor =
        isDarkMode ? AppColors.primary.withOpacity(0.8) : AppColors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : borderColor,
              width: errorText != null ? 1.5 : 1,
            ),
            color: fillColor,
          ),
          child: Row(
            children: [
              // منتقي كود البلد - يظهر على اليمين (للغة العربية)
              Directionality(
                textDirection: TextDirection.ltr,
                child: CountryCodePicker(
                  onChanged: onCountryCodeChanged,
                  initialSelection: initialCountryCode?.code ?? 'SY',
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  favorite: const ['SY', 'AE', 'SA', 'EG', 'JO', 'IQ', 'LB'],
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                  dialogTextStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  dialogBackgroundColor:
                      isDarkMode ? const Color(0xFF222222) : Colors.white,
                  boxDecoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF222222) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  searchDecoration: InputDecoration(
                    hintText: 'البحث عن دولة',
                    hintStyle: TextStyle(color: hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: borderColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // حقل إدخال رقم الهاتف
              Expanded(
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  style: TextStyle(color: textColor),
                  keyboardType: TextInputType.phone,
                  textDirection:
                      TextDirection.ltr, // دائمًا من اليسار لليمين للأرقام
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: hintColor),
                    prefixIcon:
                        Icon(Icons.phone_outlined, color: prefixIconColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
