import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:radar/controller/auth/OtpVerificationController.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/view/components/auth/CustomButton.dart';

class OtpVerificationScreen extends StatelessWidget {
  final OtpVerificationController controller =
      Get.put(OtpVerificationController());

  OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ألوان متوافقة مع الوضع الداكن والفاتح
    final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : AppColors.white;
    final textPrimaryColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final textSecondaryColor =
        isDarkMode ? Colors.grey[400] : AppColors.textSecondary;
    final inputFillColor = isDarkMode ? Color(0xFF333333) : Colors.white;

    // ألوان ثابتة
    final primaryColor = AppColors.primary;

    return GetBuilder<OtpVerificationController>(
      builder: (controller) => Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimaryColor),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'التحقق من رقم الهاتف',
            style: TextStyle(
              color: textPrimaryColor,
              fontWeight: AppFonts.semiBold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  _buildHeader(
                      textPrimaryColor, textSecondaryColor!, primaryColor),
                  const SizedBox(height: 40),
                  _buildPinCodeInput(context, isDarkMode, textPrimaryColor,
                      inputFillColor, primaryColor),
                  const SizedBox(height: 30),
                  _buildResendButton(textSecondaryColor, primaryColor),
                  const SizedBox(height: 30),
                  _buildVerifyButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // في دالة _buildHeader قم بتعديل النص التوضيحي
  Widget _buildHeader(
      Color textPrimaryColor, Color textSecondaryColor, Color primaryColor) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            // تغيير الأيقونة إلى أيقونة واتساب
            FontAwesomeIcons.whatsapp,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          "تحقق من واتساب",
          style: TextStyle(
            fontSize: 24,
            fontWeight: AppFonts.bold,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "لقد أرسلنا رمز التحقق المكون من 6 أرقام إلى واتساب الرقم التالي",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: textSecondaryColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        GetBuilder<OtpVerificationController>(
          id: 'phone_number',
          builder: (controller) => Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.displayPhoneNumber,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: AppFonts.semiBold,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCodeInput(BuildContext context, bool isDarkMode,
      Color textColor, Color fillColor, Color primaryColor) {
    return Directionality(
      textDirection:
          TextDirection.ltr, // الاتجاه من اليسار إلى اليمين لإدخال الأرقام
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Text(
              "أدخل رمز التحقق",
              style: TextStyle(
                fontSize: 16,
                fontWeight: AppFonts.medium,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                blinkWhenObscuring: true,
                animationType: AnimationType.fade,

                // ربط مع المتحكم
                controller:
                    TextEditingController(text: controller.getEnteredOtp()),
                onChanged: (value) {
                  // تحديث قيم المتحكمات الفردية للتوافق مع الكود الحالي
                  for (int i = 0; i < value.length && i < 6; i++) {
                    controller.otpControllers[i].text = value[i];
                  }
                  for (int i = value.length; i < 6; i++) {
                    controller.otpControllers[i].text = '';
                  }
                  controller.currentText = value;
                },

                // الخصائص المرئية
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: fillColor,
                  inactiveFillColor: fillColor,
                  selectedFillColor: fillColor,
                  activeColor: primaryColor,
                  inactiveColor:
                      isDarkMode ? Colors.grey[700]! : AppColors.lightGrey,
                  selectedColor: primaryColor,
                  borderWidth: 1.5,
                  errorBorderColor: Colors.red,
                ),

                cursorColor: primaryColor,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                keyboardType: TextInputType.number,

                // التخصيص الإضافي
                beforeTextPaste: (text) => true, // السماح بلصق النص

                // تنسيق النص
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: AppFonts.semiBold,
                  color: textColor,
                ),

                // تأثيرات إضافية
                enablePinAutofill: true,
                autoFocus: true,

                // تأثيرات الحركة
                errorAnimationController: null,
                boxShadows: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    color: isDarkMode
                        ? Colors.black12
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendButton(Color textSecondaryColor, Color primaryColor) {
    return GetBuilder<OtpVerificationController>(
      id: 'resend_timer',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: controller.canResend
              ? TextButton(
                  onPressed: controller.resendOtp,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    backgroundColor: primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "إعادة إرسال الرمز",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: AppFonts.semiBold,
                      fontSize: 16,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Text(
                      "لم تستلم الرمز؟",
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "إعادة الإرسال بعد ${controller.getFormattedRemainingTime()}",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: AppFonts.semiBold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildVerifyButton() {
    return CustomButton(
      text: "تأكيد الرمز",
      isLoading: controller.isLoading,
      onPressed: () => controller.sendOtp(),
      useGradient: true,
      height: 55,
    );
  }
}
