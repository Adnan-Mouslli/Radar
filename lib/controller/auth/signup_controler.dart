import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:radar/core/functions/openPrivacyPolicyUrl.dart';
import 'package:radar/data/model/reel_model_api.dart';
import 'package:radar/view/components/ui/CustomToast.dart';
import '../../core/constant/routes.dart';
import '../../data/datasource/remote/auth/signup.dart';
import '../../data/datasource/remote/interests/interestsData.dart';

class SignUpController extends GetxController {
  final SignUpData signUpData = SignUpData();
  final InterestData interestData = InterestData(Get.find());
  final ImagePicker _imagePicker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  // متغيرات البيانات
  DateTime? selectedDate;
  String selectedGender = "";
  String selectedProvidence = "";
  List<Interest> interests = [];
  List<String> selectedInterests = [];

  // متغير للصورة الشخصية
  File? profileImage;
  bool isUploadingImage = false;

  // متغيرات متعلقة برقم الهاتف
  CountryCode selectedCountryCode = CountryCode(code: 'SY', dialCode: '+963');
  String? phoneErrorText;

  // حالات التحميل والعرض
  bool isLoadingInterests = false;
  bool isLoadingSignUp = false;
  bool isPasswordHidden = true;

  bool isPrivacyPolicyAccepted = false;

  @override
  void onInit() {
    initControllers();
    // fetchInterests();
    super.onInit();
  }

  void initControllers() {
    nameController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
  }

  void togglePrivacyPolicyAcceptance() {
    isPrivacyPolicyAccepted = !isPrivacyPolicyAccepted;
    update();
  }

  void showPrivacyPolicy() {
    openPrivacyPolicyUrl();
  }

  // دالة اختيار الصورة من المعرض
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // تقليل جودة الصورة لتقليل حجم الملف
      );

      if (image != null) {
        profileImage = File(image.path);
        update();
      }
    } catch (e) {
      print('Error picking image: $e');
      CustomToast.showErrorToast(message: 'فشل في اختيار الصورة');
    }
  }

  // دالة التقاط صورة باستخدام الكاميرا
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        profileImage = File(photo.path);
        update();
      }
    } catch (e) {
      print('Error taking photo: $e');
      CustomToast.showErrorToast(message: 'فشل في التقاط الصورة');
    }
  }

  // دالة حذف الصورة المختارة
  void removeProfileImage() {
    profileImage = null;
    update();
  }

  // دالة مساعدة لعرض خيارات اختيار الصورة
  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Color(0xFF2A2A2A)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر صورة الملف الشخصي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  takePhoto();
                },
                icon: Icon(Icons.camera_alt),
                label: Text('التقاط صورة'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerRight,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  pickImageFromGallery();
                },
                icon: Icon(Icons.photo_library),
                label: Text('اختيار من المعرض'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerRight,
                ),
              ),
              if (profileImage != null)
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    removeProfileImage();
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                  label:
                      Text('حذف الصورة', style: TextStyle(color: Colors.red)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.centerRight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  void setDate(DateTime? date) {
    try {
      selectedDate = date;
      update(['date_picker']);
    } catch (e) {
      print('Error setting date: $e');
    }
  }

  void setGender(String value) {
    selectedGender = value;
    update();
  }

  void setProvidence(String value) {
    selectedProvidence = value;
    update();
  }

  void setCountryCode(CountryCode code) {
    selectedCountryCode = code;
    // إعادة التحقق من صحة رقم الهاتف بعد تغيير كود البلد
    validatePhone(phoneController.text);
    update();
  }

  Future<void> fetchInterests() async {
    try {
      isLoadingInterests = true;
      update();

      var response = await interestData.getInterestsList();

      response.fold(
          (failure) =>
              CustomToast.showErrorToast(message: "فشل تحميل الاهتمامات"),
          (interestsList) {
        interests = interestsList;
        update();
      });
    } catch (e) {
      print("Error fetching interests: $e");
      CustomToast.showErrorToast(message: "حدث خطأ في تحميل الاهتمامات");
    } finally {
      isLoadingInterests = false;
      update();
    }
  }

  void toggleInterest(String interestId) {
    if (selectedInterests.contains(interestId)) {
      selectedInterests.remove(interestId);
    } else {
      selectedInterests.add(interestId);
    }
    update();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم';
    }
    return null;
  }

  String? validatePhone(String? value) {
    // إعادة تعيين نص الخطأ
    phoneErrorText = null;

    if (value == null || value.isEmpty) {
      phoneErrorText = 'الرجاء إدخال رقم الهاتف';
      update();
      return phoneErrorText;
    }

    // التحقق من الأرقام الدولية - تحقق عام
    if (value.length < 5) {
      phoneErrorText = 'رقم الهاتف قصير جداً';
      update();
      return phoneErrorText;
    }

    // تحقق من أن الرقم يحتوي على أرقام فقط
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      phoneErrorText = 'يجب أن يحتوي الرقم على أرقام فقط';
      update();
      return phoneErrorText;
    }

    update();
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }

    // تحقق من طول كلمة المرور
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل';
    }

    // تحقق من وجود حرف كبير
    // if (!value.contains(RegExp(r'[A-Z]'))) {
    //   return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    // }

    // // تحقق من وجود حرف صغير
    // if (!value.contains(RegExp(r'[a-z]'))) {
    //   return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    // }

    // // تحقق من وجود رقم
    // if (!value.contains(RegExp(r'[0-9]'))) {
    //   return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    // }

    // // تحقق من وجود رمز خاص
    // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل (@\$!%*?& وغيرها)';
    // }

    return null;
  }

  bool validateForm() {
    // التحقق من الحقول

    if (!isPrivacyPolicyAccepted) {
      CustomToast.showWarningToast(
        message: "يرجى الموافقة على سياسة الخصوصية للمتابعة",
      );
      return false;
    }

    // تحقق من الاسم
    String? nameError = validateName(nameController.text);
    if (nameError != null) {
      CustomToast.showErrorToast(message: nameError);
      return false;
    }

    // تحقق من رقم الهاتف
    String? phoneError = validatePhone(phoneController.text);
    if (phoneError != null) {
      CustomToast.showErrorToast(message: phoneError);
      return false;
    }

    // تحقق من كلمة المرور
    String? passwordError = validatePassword(passwordController.text);
    if (passwordError != null) {
      CustomToast.showErrorToast(message: passwordError);
      return false;
    }

    // تحقق من باقي الحقول
    if (selectedDate == null) {
      CustomToast.showErrorToast(message: 'الرجاء اختيار تاريخ الميلاد');
      return false;
    }

    if (selectedGender.isEmpty) {
      CustomToast.showErrorToast(message: 'الرجاء اختيار الجنس');
      return false;
    }

    if (selectedProvidence.isEmpty) {
      CustomToast.showErrorToast(message: 'الرجاء اختيار المحافظة');
      return false;
    }

    // تحقق من الاهتمامات - اختياري
    // if (selectedInterests.isEmpty) {
    //   CustomToast.showErrorToast(message: 'الرجاء اختيار اهتمام واحد على الأقل');
    //   return false;
    // }

    return true;
  }

  // الحصول على رقم الهاتف الكامل بما في ذلك كود البلد
  String getFullPhoneNumber() {
    // إزالة أي علامة + من كود الطلب
    String dialCode = selectedCountryCode.dialCode ?? '+963';
    dialCode = dialCode.startsWith('+') ? dialCode.substring(1) : dialCode;

    // إزالة أي أصفار في بداية رقم الهاتف المدخل
    String phoneNumber = phoneController.text.trim();
    while (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // دمج رقم الهاتف مع كود البلد
    return dialCode + phoneNumber;
  }

  String getFormattedPhoneForAPI() {
    // الحصول على كود البلد بدون علامة +
    String dialCode = selectedCountryCode.dialCode ?? '+963';
    dialCode = dialCode.startsWith('+') ? dialCode.substring(1) : dialCode;

    // إزالة أي أصفار في بداية رقم الهاتف المدخل
    String phoneNumber = phoneController.text.trim();

    // إزالة أي صفر في بداية الرقم
    while (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // في حالة الرقم السوري، إذا بدأ بـ 9 نتأكد من إضافة كود البلد فقط
    if (selectedCountryCode.code == 'SY' && phoneNumber.startsWith('9')) {
      return dialCode + phoneNumber;
    }
    // في حالة الأرقام الدولية الأخرى
    else {
      return dialCode + phoneNumber;
    }
  }

  // عرض التاريخ بالعربي في الواجهة
  String getFormattedDateArabic() {
    if (selectedDate == null) return "اختر تاريخ الميلاد";

    // تنسيق التاريخ بالعربي
    String day = selectedDate!.day.toString();
    String year = selectedDate!.year.toString();

    List<String> arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    String month = arabicMonths[selectedDate!.month - 1];

    return "$day $month $year";
  }

  // تحويل التاريخ للإنجليزية للإرسال للخادم
  String getFormattedDateForAPI() {
    if (selectedDate == null) return "";

    // تنسيق التاريخ بالصيغة المطلوبة YYYY-MM-DD
    String year = selectedDate!.year.toString();
    String month = selectedDate!.month.toString().padLeft(2, '0');
    String day = selectedDate!.day.toString().padLeft(2, '0');

    return "$year-$month-$day";
  }

  void showSuccess(String message) {
    CustomToast.showSuccessToast(message: message);
  }

  void handleError(String message) {
    CustomToast.showErrorToast(message: message);
  }

  Future<void> signUp() async {
    if (formKey.currentState!.validate() && validateForm()) {
      if (!validateForm()) return;

      try {
        isLoadingSignUp = true;
        update();

        try {
          final formattedPhone = getFormattedPhoneForAPI();
          print('Sending phone: $formattedPhone');

          var response = await signUpData.signUp(
            name: nameController.text,
            phone: formattedPhone,
            password: passwordController.text,
            dateOfBirth: getFormattedDateForAPI(),
            gender: selectedGender,
            providence: selectedProvidence,
            interestIds: selectedInterests,
            profilePhoto: profileImage,
          );

          if (response['message'] ==
                  'User created successfully. Please verify your phone number.' &&
              response['user'] != null) {
            showSuccess('تم إنشاء الحساب بنجاح');
            Get.toNamed(
              AppRoute.otpVerification,
              arguments: {
                'phoneNumber': formattedPhone,
              },
            );
          } else if (response['message'] ==
                  'User with this phone number already exists' ||
              response['statusCode'] == 409 ||
              (response['error'] != null && response['error'] == 'Conflict')) {
            handleError("الرقم موجود بالفعل");
          } else {
            // Handle other error messages
            handleError(response['message'] ?? "حدث خطأ في إنشاء الحساب");
          }
        } catch (e) {
          print('Error in signUp: $e');
          if (e.toString().contains('409') ||
              e.toString().contains('Conflict') ||
              e.toString().contains('already exists')) {
            handleError("الرقم موجود بالفعل");
          } else {
            handleError("حدث خطأ غير متوقع");
          }
        }
      } catch (e) {
        print('Error in signUp: $e');
        handleError("حدث خطأ غير متوقع");
      } finally {
        isLoadingSignUp = false;
        update();
      }
    }

    @override
    void dispose() {
      nameController.dispose();
      phoneController.dispose();
      passwordController.dispose();
      super.dispose();
    }
  }
}
