import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/auth/ForgetPasswordController.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../components/auth/CustomButton.dart';
import '../../components/auth/CustomTextFormField.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
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
          'نسيت كلمة المرور',
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
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenSize.height * 0.05),

                  // أيقونة القفل المفتوح
                  Container(
                    width: 120,
                    height: 120,
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
                        Icons.lock_open_rounded,
                        color: primaryColor,
                        size: 60,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // بطاقة نسيت كلمة المرور
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                            "استعادة كلمة المرور",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: AppFonts.bold,
                              color: textPrimaryColor,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "أدخل رقم هاتفك لإرسال رمز التحقق إليك",
                            style: TextStyle(
                              color: textSecondaryColor,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // رقم الهاتف
                          GetBuilder<ForgetPasswordController>(
                            builder: (controller) => CustomTextFormField(
                              controller: controller.phoneController,
                              label: "رقم الهاتف",
                              hintText: "أدخل رقم الهاتف",
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              isDarkMode: isDarkMode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال رقم الهاتف';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 30),

                          // زر إرسال رمز التحقق
                          GetBuilder<ForgetPasswordController>(
                            builder: (controller) => CustomButton(
                              text: "إرسال رمز التحقق",
                              isLoading: controller.isLoading,
                              onPressed: controller.sendVerificationCode,
                              useGradient: true,
                              height: 55,
                              borderRadius: 15,
                              elevation: 3,
                              fontWeight: AppFonts.bold,
                              fontSize: 17,
                              prefixIcon: Icons.send_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // نص للعودة لصفحة تسجيل الدخول
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "العودة لتسجيل الدخول",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
