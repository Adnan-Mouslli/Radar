import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../controller/auth/login_controler.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../components/auth/CustomButton.dart';
import '../../components/auth/CustomTextFormField.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginControlerImp());
    final screenSize = MediaQuery.of(context).size;

    // تحديد الألوان بناءً على وضع السمة الحالي
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ألوان متوافقة مع الوضع الداكن والفاتح
    final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : AppColors.white;
    final textPrimaryColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final textSecondaryColor =
        isDarkMode ? Colors.grey[400] : AppColors.textSecondary;
    final cardColor = isDarkMode ? Color(0xFF222222) : Colors.white;
    final dividerColor =
        isDarkMode ? Colors.grey[800] : Colors.grey.withOpacity(0.2);
    final borderColor = isDarkMode ? Colors.grey[700]! : AppColors.lightGrey;

    // ألوان العلامة التجارية ثابتة بغض النظر عن وضع السمة
    final primaryColor = AppColors.primary; // FF3366
    final primaryLightColor = AppColors.primaryLight; // FF6B93

    return Scaffold(
      backgroundColor: backgroundColor,
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
                  SizedBox(height: screenSize.height * 0.03),

                  // اللوغو بحجم مناسب مع تدرج لوني
                  _buildAppLogo(primaryColor, primaryLightColor),

                  const SizedBox(height: 12),

                  // اسم التطبيق بخط مميز
                  Text(
                    'Radar',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontSize: 28,
                      fontWeight: AppFonts.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // بطاقة تسجيل الدخول
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
                          // عنوان الصفحة
                          _buildPageHeader(
                              textPrimaryColor,
                              textSecondaryColor!,
                              primaryColor,
                              primaryLightColor),

                          const SizedBox(height: 30),

                          // رقم الهاتف مع كود البلد
                          GetBuilder<LoginControlerImp>(
                            builder: (controller) => _buildPhoneField(
                                controller,
                                isDarkMode,
                                textPrimaryColor,
                                textSecondaryColor,
                                borderColor),
                          ),

                          const SizedBox(height: 24),

                          // كلمة المرور
                          GetBuilder<LoginControlerImp>(
                            builder: (controller) => CustomTextFormField(
                              controller: controller.password,
                              label: "كلمة المرور",
                              hintText: "أدخل كلمة المرور",
                              prefixIcon: Icons.lock_outline,
                              isPassword: controller.isshowpassword,
                              isDarkMode: isDarkMode,
                              onPasswordToggle: controller.showPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // نسيت كلمة المرور
                          _buildForgotPassword(primaryColor),

                          const SizedBox(height: 30),

                          // زر تسجيل الدخول
                          GetBuilder<LoginControlerImp>(
                            builder: (controller) => CustomButton(
                              text: "تسجيل الدخول",
                              isLoading: controller.statusRequest ==
                                  StatusRequest.loading,
                              onPressed: controller.login,
                              useGradient: true,
                              height: 55,
                              borderRadius: 15,
                              elevation: 3,
                              fontWeight: AppFonts.bold,
                              fontSize: 17,
                              prefixIcon: Icons.login_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.08),

                  // خيار إنشاء حساب في الأسفل
                  _buildSignUpLink(
                      textSecondaryColor, primaryColor, dividerColor!),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(LoginControlerImp controller, bool isDarkMode,
      Color textPrimaryColor, Color textSecondaryColor, Color borderColor) {
    final fillColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final hintColor = isDarkMode ? Colors.grey[400]! : AppColors.textSecondary;
    final prefixIconColor =
        isDarkMode ? AppColors.primary.withOpacity(0.8) : AppColors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            "رقم الهاتف",
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  controller.phoneErrorText != null ? Colors.red : borderColor,
              width: controller.phoneErrorText != null ? 1.5 : 1,
            ),
            color: fillColor,
            boxShadow: isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // منتقي كود البلد مع تعديل للأستايل
              Theme(
                data: Theme.of(Get.context!).copyWith(
                  dialogBackgroundColor:
                      isDarkMode ? Color(0xFF222222) : Colors.white,
                  unselectedWidgetColor:
                      isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
                child: CountryCodePicker(
                  onChanged: (CountryCode countryCode) {
                    controller.setCountryCode(countryCode);
                  },
                  initialSelection: controller.selectedCountryCode.code ?? 'SY',
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  favorite: const ['SY', 'AE', 'SA', 'EG', 'JO', 'IQ', 'LB'],
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 16,
                  ),
                  flagWidth: 30,
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
                  controller: controller.phone,
                  validator: controller.validatePhone,
                  style: TextStyle(color: textPrimaryColor, fontSize: 16),
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: "أدخل رقم الهاتف",
                    // controller.selectedCountryCode.code == 'SY'
                    //     ? "912345678"
                    //     : "أدخل رقم الهاتف",
                    hintStyle: TextStyle(color: hintColor, fontSize: 15),
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
        if (controller.phoneErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  controller.phoneErrorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAppLogo(Color primaryColor, Color primaryLightColor) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        // يمكنك إزالة التدرج اللوني إذا كان اللوغو يحتوي على خلفية بالفعل
        // gradient: LinearGradient(
        //   colors: [
        //     primaryColor,
        //     primaryLightColor,
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        shape: BoxShape.circle,
        // boxShadow: [
        //   BoxShadow(
        //     color: primaryColor.withOpacity(0.25),
        //     blurRadius: 15,
        //     offset: const Offset(0, 5),
        //   ),
        // ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/ReelWin.png',
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPageHeader(Color textPrimaryColor, Color textSecondaryColor,
      Color primaryColor, Color primaryLightColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 25,
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryLightColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "مرحباً بعودتك!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: AppFonts.bold,
                color: textPrimaryColor,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15, top: 8, left: 15),
          child: Text(
            "سجل دخولك واستمتع بمشاهدة أفضل المحتويات",
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword(Color primaryColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => Get.toNamed(AppRoute.forgetPassword),
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "نسيت كلمة المرور؟",
            style: TextStyle(
              fontSize: 14,
              fontWeight: AppFonts.medium,
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(
      Color textSecondaryColor, Color primaryColor, Color dividerColor) {
    return GestureDetector(
      onTap: () => Get.offNamed(AppRoute.signup),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ليس لديك حساب؟ ",
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 15,
              ),
            ),
            Text(
              "إنشاء حساب",
              style: TextStyle(
                color: primaryColor,
                fontWeight: AppFonts.semiBold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.person_add_alt,
              color: primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
