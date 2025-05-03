import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:radar/core/functions/openPrivacyPolicyUrl.dart';
import 'package:radar/data/model/reel_model_api.dart';
import '../../../controller/auth/signup_controler.dart';
import '../../../core/constant/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../components/auth/CustomButton.dart';
import '../../components/auth/CustomTextFormField.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);

  final controller = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ألوان متوافقة مع الوضع الداكن والفاتح
    final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : AppColors.white;
    final textPrimaryColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final textSecondaryColor =
        isDarkMode ? Colors.grey[400] : AppColors.textSecondary;
    final dividerColor =
        isDarkMode ? Colors.grey[800] : Colors.grey.withOpacity(0.2);
    final cardColor = isDarkMode ? Color(0xFF222222) : Colors.white;

    // ألوان ثابتة
    final primaryColor = AppColors.primary;
    final primaryLightColor = AppColors.primaryLight;

    return GetBuilder<SignUpController>(
      builder: (controller) => Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenSize.height * 0.03),

                  // اللوغو مع تدرج لوني
                  _buildAppLogo(primaryColor, primaryLightColor),

                  const SizedBox(height: 12),

                  // اسم التطبيق
                  Text(
                    'Radar',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontSize: 28,
                      fontWeight: AppFonts.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // بطاقة التسجيل
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

                          const SizedBox(height: 25),

                          // نموذج التسجيل
                          // البيانات الأساسية
                          _buildBasicFields(controller, isDarkMode, context),
                          const SizedBox(height: 24),

                          // الأقسام الأخرى مفصولة بخط رفيع
                          Divider(color: dividerColor, height: 32),

                          // تاريخ الميلاد
                          _buildDatePicker(context, controller, isDarkMode,
                              textPrimaryColor, textSecondaryColor),
                          const SizedBox(height: 24),

                          // الجنس
                          _buildGenderSelection(
                              controller, isDarkMode, textPrimaryColor),
                          const SizedBox(height: 24),

                          // المحافظة
                          _buildProvidenceDropdown(controller, isDarkMode,
                              textPrimaryColor, textSecondaryColor),
                          const SizedBox(height: 24),

                          Divider(color: dividerColor, height: 32),

                          // الاهتمامات
                          // _buildInterestsSection(
                          //     controller, isDarkMode, textPrimaryColor),
                          // const SizedBox(height: 10),

                          // رسالة أهمية البيانات
                          _buildDataImportanceMessage(isDarkMode),

                          const SizedBox(height: 10),

                          _buildPrivacyPolicyConsent(controller, isDarkMode),

                          // زر التسجيل
                          _buildSignUpButton(controller),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.04),

                  // رابط تسجيل الدخول
                  _buildLoginLink(
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
              "إنشاء حساب جديد",
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
            "أدخل بياناتك للتسجيل والاستمتاع بمشاهدة أفضل المحتويات",
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

  Widget _buildBasicFields(
      SignUpController controller, bool isDarkMode, BuildContext context) {
    return Column(
      children: [
        // _buildProfilePhotoSelector(controller, isDarkMode),

        _buildTextField(
          controller: controller.nameController,
          label: "الاسم الكامل",
          hintText: "أدخل اسمك الكامل",
          prefixIcon: Icons.person_outline,
          validator: controller.validateName,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 20),

        // استخدام مكون حقل رقم الهاتف مع كود البلد
        _buildPhoneField(controller, isDarkMode),

        const SizedBox(height: 20),
        _buildTextField(
          controller: controller.passwordController,
          label: "كلمة المرور",
          hintText: "********",
          prefixIcon: Icons.lock_outline,
          isPassword: controller.isPasswordHidden,
          onPasswordToggle: controller.togglePasswordVisibility,
          validator: controller.validatePassword,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildProfilePhotoSelector(
      SignUpController controller, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final labelColor = isDarkMode ? Colors.grey[300] : AppColors.textPrimary;
    final borderColor = isDarkMode ? Colors.grey[700]! : AppColors.lightGrey;
    final backgroundColor = isDarkMode ? Color(0xFF2A2A2A) : Colors.grey[100];
    final defaultUserIcon = isDarkMode ? Icons.person : Icons.person_outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 12),
          child: Text(
            "الصورة الشخصية (اختياري)",
            style: TextStyle(
              color: labelColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Center(
          child: Stack(
            children: [
              // صورة الملف الشخصي أو الأيقونة الافتراضية
              GestureDetector(
                onTap: () => controller.showImagePickerOptions(Get.context!),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.profileImage != null
                          ? AppColors.primary
                          : borderColor,
                      width: controller.profileImage != null ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: controller.profileImage != null
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: controller.profileImage != null ? 12 : 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                    image: controller.profileImage != null
                        ? DecorationImage(
                            image: FileImage(controller.profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.profileImage == null
                      ? Icon(
                          defaultUserIcon,
                          size: 60,
                          color: AppColors.primary.withOpacity(0.7),
                        )
                      : null,
                ),
              ),

              // زر الإضافة
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => controller.showImagePickerOptions(Get.context!),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode ? Colors.black : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.profileImage == null
                          ? Icons.add_a_photo
                          : Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (controller.profileImage != null)
          Center(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: 10),
              child: TextButton.icon(
                onPressed: controller.removeProfileImage,
                icon: Icon(Icons.delete, color: Colors.red, size: 18),
                label: Text(
                  "حذف الصورة",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhoneField(SignUpController controller, bool isDarkMode) {
    final fillColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : AppColors.lightGrey;
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
            "رقم الهاتف",
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
                    color: textColor,
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
                  controller: controller.phoneController,
                  validator: controller.validatePhone,
                  style: TextStyle(color: textColor, fontSize: 16),
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: "أدخل رقم الهاتف",
                    // controller.selectedCountryCode.code == 'SY'
                    //     ? "912345678"
                    //     : "أدخل رقم الهاتف",
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required bool isDarkMode,
    TextInputType? keyboardType,
    bool isPassword = false,
    VoidCallback? onPasswordToggle,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      controller: controller,
      label: label,
      hintText: hintText,
      prefixIcon: prefixIcon,
      keyboardType: keyboardType,
      isPassword: isPassword,
      onPasswordToggle: onPasswordToggle,
      validator: validator,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: AppFonts.medium,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, SignUpController controller,
      bool isDarkMode, Color textPrimaryColor, Color textSecondaryColor) {
    final fillColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : AppColors.lightGrey;
    final iconColor =
        isDarkMode ? AppColors.primary.withOpacity(0.8) : AppColors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("تاريخ الميلاد", textPrimaryColor),
        GetBuilder<SignUpController>(
          id: 'date_picker',
          builder: (controller) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                try {
                  final DateTime currentDate = DateTime.now();
                  final DateTime initialDate = DateTime(currentDate.year - 18,
                      currentDate.month, currentDate.day);

                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate ?? initialDate,
                    firstDate: DateTime(1950),
                    lastDate: currentDate,
                    locale: const Locale('ar'),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDarkMode
                              ? ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: const Color(0xFF222222),
                                  onSurface: Colors.white,
                                )
                              : ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: AppColors.textPrimary,
                                ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    controller.setDate(picked);
                  }
                } catch (e) {
                  print('Error in date picker: $e');
                  Get.snackbar(
                    'خطأ',
                    'حدث خطأ في اختيار التاريخ',
                    backgroundColor: Colors.red.shade100,
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
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
                    Icon(Icons.calendar_today, color: iconColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.selectedDate != null
                            ? DateFormat.yMd('ar')
                                .format(controller.selectedDate!)
                            : "اختر تاريخ الميلاد",
                        style: TextStyle(
                          color: controller.selectedDate != null
                              ? textPrimaryColor
                              : textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection(
      SignUpController controller, bool isDarkMode, Color textPrimaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("الجنس", textPrimaryColor),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton(
                controller,
                "MALE",
                "ذكر",
                isDarkMode,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildGenderButton(
                controller,
                "FEMALE",
                "أنثى",
                isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(
    SignUpController controller,
    String value,
    String label,
    bool isDarkMode,
  ) {
    final isSelected = controller.selectedGender == value;

    final unselectedFillColor =
        isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final unselectedBorderColor =
        isDarkMode ? Colors.grey[700]! : AppColors.lightGrey;
    final unselectedTextColor =
        isDarkMode ? Colors.white : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.setGender(value),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : unselectedFillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : unselectedBorderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : isDarkMode
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                Icon(
                  value == "MALE" ? Icons.male : Icons.female,
                  color: Colors.white,
                  size: 18,
                ),
              if (isSelected) SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : unselectedTextColor,
                  fontWeight: isSelected ? AppFonts.semiBold : AppFonts.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProvidenceDropdown(SignUpController controller, bool isDarkMode,
      Color textPrimaryColor, Color textSecondaryColor) {
    final fillColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : AppColors.lightGrey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("المحافظة", textPrimaryColor),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedProvidence.isEmpty
                  ? null
                  : controller.selectedProvidence,
              hint: Text(
                "اختر المحافظة",
                style: TextStyle(color: textSecondaryColor),
              ),
              dropdownColor: fillColor,
              style: TextStyle(color: textPrimaryColor),
              icon: Icon(Icons.arrow_drop_down, color: textPrimaryColor),
              items: [
                "DAMASCUS",
                "ALEPPO",
                "HOMS",
                "HAMA",
                "LATAKIA",
                "DEIR_EZ_ZOR",
                "RAQQA",
                "HASAKAH",
                "TARTUS",
                "IDLIB",
                "DARAA",
                "SUWEIDA",
                "QUNEITRA"
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_getArabicProvidence(value)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.setProvidence(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection(
      SignUpController controller, bool isDarkMode, Color textPrimaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان وحده بدون أي عناصر إضافية
        _buildSectionTitle("اختر اهتماماتك", textPrimaryColor),

        // زر "اختيار الكل" في سطر منفصل تحت العنوان مباشرة
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _toggleSelectAllInterests(controller),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _isAllInterestsSelected(controller)
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _isAllInterestsSelected(controller)
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAllInterestsSelected(controller)
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 18,
                      color: _isAllInterestsSelected(controller)
                          ? Colors.white
                          : AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      _isAllInterestsSelected(controller)
                          ? "إلغاء اختيار الكل"
                          : "اختيار الكل",
                      style: TextStyle(
                        color: _isAllInterestsSelected(controller)
                            ? Colors.white
                            : AppColors.primary,
                        fontSize: 13,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // استخدام حالة التحميل الخاصة بالاهتمامات
        if (controller.isLoadingInterests)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.interests
                .map((interest) =>
                    _buildInterestChip(controller, interest, isDarkMode))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildDataImportanceMessage(bool isDarkMode) {
    final bgColor = isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFF5F5F5);
    final borderColor = isDarkMode ? Colors.grey[600] : Colors.grey[300];
    final textColor =
        isDarkMode ? Colors.white.withOpacity(0.9) : AppColors.textPrimary;

    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.primary,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "لماذا نطلب هذه البيانات؟",
                  style: TextStyle(
                    fontWeight: AppFonts.semiBold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "تاريخ الميلاد والجنس يساعداننا على تخصيص تجربتك وعرض محتوى يناسب اهتماماتك. نحن نحترم خصوصيتك ونستخدم بياناتك وفقًا لسياسة الخصوصية.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// تحقق ما إذا كانت جميع الاهتمامات محددة
  bool _isAllInterestsSelected(SignUpController controller) {
    // إذا كانت قائمة الاهتمامات فارغة، نعتبر أن كل الاهتمامات غير محددة
    if (controller.interests.isEmpty) {
      return false;
    }

    // تحقق مما إذا كانت جميع معرفات الاهتمامات موجودة في القائمة المحددة
    return controller.interests.every(
        (interest) => controller.selectedInterests.contains(interest.id));
  }

// دالة لتبديل حالة "اختيار الكل"
  void _toggleSelectAllInterests(SignUpController controller) {
    if (_isAllInterestsSelected(controller)) {
      // إذا كانت جميع الاهتمامات محددة، قم بإلغاء تحديدها
      controller.selectedInterests.clear();
    } else {
      // إذا لم تكن جميع الاهتمامات محددة، قم بتحديدها جميعًا
      controller.selectedInterests.clear();
      for (var interest in controller.interests) {
        controller.selectedInterests.add(interest.id);
      }
    }
    controller.update();
  }

  Widget _buildInterestChip(
    SignUpController controller,
    Interest interest,
    bool isDarkMode,
  ) {
    final isSelected = controller.selectedInterests.contains(interest.id);

    final unselectedFillColor =
        isDarkMode ? Color(0xFF2A2A2A) : Colors.grey[100];
    final unselectedBorderColor =
        isDarkMode ? Colors.grey[700]! : AppColors.lightGrey;
    final unselectedTextColor =
        isDarkMode ? Colors.white : AppColors.textPrimary;

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.only(bottom: 8, right: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.toggleInterest(interest.id),
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : unselectedFillColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : unselectedBorderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                Text(
                  interest.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : unselectedTextColor,
                    fontWeight:
                        isSelected ? AppFonts.semiBold : AppFonts.regular,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(SignUpController controller) {
    return CustomButton(
      text: "إنشاء حساب",
      isLoading: controller.isLoadingSignUp,
      onPressed: controller.signUp,
      useGradient: true,
      height: 55,
      borderRadius: 15,
      elevation: 3,
      fontWeight: AppFonts.bold,
      fontSize: 17,
      prefixIcon: Icons.person_add_rounded,
      opacity: controller.isPrivacyPolicyAccepted ? 1.0 : 0.5,
    );
  }

  Widget _buildLoginLink(
      Color textSecondaryColor, Color primaryColor, Color dividerColor) {
    return GestureDetector(
      onTap: () => Get.offNamed(AppRoute.login),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "لديك حساب بالفعل؟",
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "تسجيل الدخول",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: AppFonts.semiBold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward,
                  color: primaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyConsent(
      SignUpController controller, bool isDarkMode) {
    final secondaryTextColor =
        isDarkMode ? Colors.grey[400] : AppColors.textSecondary;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // زر القبول
              Transform.scale(
                scale: 1.1,
                child: Theme(
                  data: ThemeData(
                    unselectedWidgetColor:
                        isDarkMode ? Colors.grey : AppColors.lightGrey,
                  ),
                  child: Checkbox(
                    value: controller.isPrivacyPolicyAccepted,
                    onChanged: (bool? value) {
                      controller.togglePrivacyPolicyAcceptance();
                    },
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // نص الموافقة
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: "بالضغط على (إنشاء حساب)، فإنك توافق على ",
                        ),
                        TextSpan(
                          text: "شروط الاستخدام وسياسة الخصوصية ",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: AppFonts.semiBold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // استخدام CustomDialog لفتح سياسة الخصوصية
                              controller.showPrivacyPolicy();
                            },
                        ),
                        TextSpan(
                          text: "الخاصة بتطبيق Radar.",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // رسالة الخطأ في حالة عدم الموافقة
          if (!controller.isPrivacyPolicyAccepted &&
              controller.isLoadingSignUp == false)
            Padding(
              padding: const EdgeInsets.only(right: 32, top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber[700],
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "يجب الموافقة على سياسة الخصوصية للمتابعة",
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getArabicProvidence(String providence) {
    switch (providence) {
      case 'DAMASCUS':
        return 'دمشق';
      case 'ALEPPO':
        return 'حلب';
      case 'HOMS':
        return 'حمص';
      case 'HAMA':
        return 'حماة';
      case 'LATAKIA':
        return 'اللاذقية';
      case 'DEIR_EZ_ZOR':
        return 'دير الزور';
      case 'RAQQA':
        return 'الرقة';
      case 'HASAKAH':
        return 'الحسكة';
      case 'TARTUS':
        return 'طرطوس';
      case 'IDLIB':
        return 'إدلب';
      case 'DARAA':
        return 'درعا';
      case 'SUWEIDA':
        return 'السويداء';
      case 'QUNEITRA':
        return 'القنيطرة';
      default:
        return providence;
    }
  }
}
