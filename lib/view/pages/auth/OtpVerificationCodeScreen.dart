import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:radar/controller/auth/ForgetPasswordController.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../components/auth/CustomButton.dart';
import '../../components/auth/CustomTextFormField.dart';

class OtpVerificationCodeScreen extends StatelessWidget {
  final String phoneNumber;

  const OtpVerificationCodeScreen({Key? key, this.phoneNumber = "091323213"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgetPasswordController>();
    final screenSize = MediaQuery.of(context).size;

    // تحديد الألوان بناءً على وضع السمة الحالي
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ألوان متوافقة مع الوضع الداكن والفاتح
    final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : AppColors.white;
    final textPrimaryColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final textSecondaryColor =
        isDarkMode ? Colors.grey[400] : AppColors.textSecondary;
    final cardColor = isDarkMode ? Color(0xFF222222) : Colors.white;

    // ألوان العلامة التجارية ثابتة بغض النظر عن وضع السمة
    final primaryColor = AppColors.primary;
    final primaryLightColor = AppColors.primaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: textPrimaryColor,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'التحقق وتغيير كلمة المرور',
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 18,
            fontWeight: AppFonts.semiBold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: controller.resetFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenSize.height * 0.02),

                    // أيقونة التحقق
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.1),
                            primaryLightColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.sms_outlined,
                          color: primaryColor,
                          size: 50,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // بطاقة الإدخال
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDarkMode
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // عنوان وشرح
                            Text(
                              "رمز التحقق",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: AppFonts.bold,
                                color: textPrimaryColor,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "تم إرسال رمز التحقق إلى رقم هاتفك $phoneNumber",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 15),

                            // حقول إدخال الرمز
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: PinCodeTextField(
                                  appContext: context,
                                  length: 6,
                                  controller: controller.otpController,
                                  keyboardType: TextInputType.number,
                                  obscureText: false,
                                  animationType: AnimationType.fade,
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(12),
                                    fieldHeight: 50,
                                    fieldWidth: 40,
                                    activeFillColor: isDarkMode
                                        ? Color(0xFF2A2A2A)
                                        : Colors.white,
                                    inactiveFillColor: isDarkMode
                                        ? Color(0xFF2A2A2A)
                                        : Colors.grey[100],
                                    selectedFillColor: isDarkMode
                                        ? Color(0xFF333333)
                                        : Colors.white,
                                    activeColor: primaryColor,
                                    inactiveColor: isDarkMode
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
                                    selectedColor: primaryColor,
                                  ),
                                  animationDuration:
                                      const Duration(milliseconds: 300),
                                  backgroundColor: Colors.transparent,
                                  enableActiveFill: true,
                                  onCompleted: (v) {
                                    // فتح لوحة المفاتيح للحقل التالي
                                    FocusScope.of(context).nextFocus();
                                  },
                                  onChanged: (value) {
                                    // عند تغيير القيمة
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // عداد إعادة الإرسال
                            GetBuilder<ForgetPasswordController>(
                              builder: (controller) {
                                if (controller.canResend) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: controller.resendCode,
                                      child: Text(
                                        "إعادة إرسال الرمز",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: AppFonts.medium,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: textSecondaryColor,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "إعادة إرسال الرمز بعد ",
                                          ),
                                          TextSpan(
                                            text:
                                                "${controller.resendTimer} ثانية",
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: AppFonts.semiBold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            // قسم كلمة المرور الجديدة
                            Text(
                              "كلمة المرور الجديدة",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: AppFonts.bold,
                                color: textPrimaryColor,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "قم بإنشاء كلمة مرور قوية للحفاظ على أمان حسابك",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 15),

                            // كلمة المرور الجديدة
                            GetBuilder<ForgetPasswordController>(
                              builder: (controller) => CustomTextFormField(
                                controller: controller.newPasswordController,
                                label: "كلمة المرور الجديدة",
                                hintText: "******",
                                prefixIcon: Icons.lock_outline,
                                isPassword: controller.isPasswordHidden,
                                isDarkMode: isDarkMode,
                                onPasswordToggle:
                                    controller.togglePasswordVisibility,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال كلمة المرور';
                                  }
                                  if (value.length < 8) {
                                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                                  }
                                  // if (!value.contains(RegExp(r'[A-Z]'))) {
                                  //   return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
                                  // }
                                  // if (!value.contains(RegExp(r'[a-z]'))) {
                                  //   return 'يجب أن تحتوي على حرف صغير واحد على الأقل';
                                  // }
                                  // if (!value.contains(RegExp(r'[0-9]'))) {
                                  //   return 'يجب أن تحتوي على رقم واحد على الأقل';
                                  // }
                                  // if (!value.contains(
                                  //     RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                  //   return 'يجب أن تحتوي على رمز خاص واحد على الأقل';
                                  // }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 15),

                            // تأكيد كلمة المرور
                            GetBuilder<ForgetPasswordController>(
                              builder: (controller) => CustomTextFormField(
                                controller:
                                    controller.confirmPasswordController,
                                label: "تأكيد كلمة المرور",
                                hintText: "******",
                                prefixIcon: Icons.lock_outline,
                                isPassword: controller.isPasswordHidden,
                                isDarkMode: isDarkMode,
                                onPasswordToggle:
                                    controller.togglePasswordVisibility,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء تأكيد كلمة المرور';
                                  }
                                  if (value !=
                                      controller.newPasswordController.text) {
                                    return 'كلمات المرور غير متطابقة';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            // مؤشر قوة كلمة المرور
                            const SizedBox(height: 15),
                            GetBuilder<ForgetPasswordController>(
                              builder: (controller) {
                                final strength = controller.passwordStrength;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "قوة كلمة المرور: ",
                                          style: TextStyle(
                                            color: textSecondaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          _getPasswordStrengthText(strength),
                                          style: TextStyle(
                                            color: _getPasswordStrengthColor(
                                                strength),
                                            fontWeight: AppFonts.semiBold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: strength / 4,
                                      backgroundColor: isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getPasswordStrengthColor(strength),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 25),

                            // زر التأكيد
                            GetBuilder<ForgetPasswordController>(
                              builder: (controller) => CustomButton(
                                text: "تأكيد وتغيير كلمة المرور",
                                isLoading: controller.isLoading,
                                onPressed: controller.resetPasswordWithOTP,
                                useGradient: true,
                                height: 55,
                                borderRadius: 15,
                                elevation: 3,
                                fontWeight: AppFonts.bold,
                                fontSize: 17,
                                prefixIcon: Icons.check_circle_outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
        return "ضعيفة جداً";
      case 1:
        return "ضعيفة";
      case 2:
        return "متوسطة";
      case 3:
        return "قوية";
      case 4:
        return "قوية جداً";
      default:
        return "ضعيفة";
    }
  }

  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}
