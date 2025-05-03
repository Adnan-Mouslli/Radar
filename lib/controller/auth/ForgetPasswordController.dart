import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/data/datasource/remote/auth/ForgetPasswordData.dart';
import 'package:radar/view/components/ui/CustomToast.dart';
import 'package:radar/core/constant/routes.dart';
import '../../core/services/services.dart';

class ForgetPasswordController extends GetxController {
  // حقل النموذج
  final formKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();

  // متحكمات النصوص
  late TextEditingController phoneController;
  late TextEditingController otpController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  // حالة التحميل والرؤية
  bool isLoading = false;
  bool isPasswordHidden = true;

  // مؤقت إعادة الإرسال
  bool canResend = false;
  int resendTimer = 60;
  Timer? _resendTimer;

  // قوة كلمة المرور (0-4)
  int passwordStrength = 0;

  // للتحقق من حالة الإغلاق
  bool _isDisposed = false;

  // خدمات
  final ForgetPasswordData _forgotPasswordData = ForgetPasswordData();
  final MyServices _services = MyServices.instance;

  @override
  void onInit() {
    phoneController = TextEditingController();
    otpController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // مراقبة تغييرات كلمة المرور لحساب القوة
    newPasswordController.addListener(_calculatePasswordStrength);

    super.onInit();
  }

  @override
  void onClose() {
    _isDisposed = true;

    // إلغاء المؤقت
    _resendTimer?.cancel();

    // إزالة المستمع أولاً لمنع الاستدعاء أثناء التخلص
    try {
      newPasswordController.removeListener(_calculatePasswordStrength);
    } catch (e) {
      // تجاهل الأخطاء هنا حيث قد يكون المستمع أو المتحكم قد تم التخلص منه بالفعل
    }

    // التخلص من المتحكمات بأمان
    _safeDispose(phoneController);
    _safeDispose(otpController);
    _safeDispose(newPasswordController);
    _safeDispose(confirmPasswordController);

    super.onClose();
  }

  // دالة آمنة للتخلص من المتحكمات
  void _safeDispose(TextEditingController controller) {
    try {
      if (!_isDisposed) {
        controller.dispose();
      }
    } catch (e) {
      // تجاهل أي أخطاء قد تحدث عند التخلص من المتحكم
      // عادة ما تكون بسبب أن المتحكم قد تم التخلص منه بالفعل
    }
  }

  // إرسال رمز التحقق
  Future<void> sendVerificationCode() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading = true;
      update();

      // تنسيق رقم الهاتف
      String phone = _formatPhoneNumber(phoneController.text);

      // استدعاء API لإرسال رمز التحقق
      var response = await _forgotPasswordData.sendVerificationCode(phone);

      if (response['success'] == true) {
        // بدء مؤقت إعادة الإرسال
        _startResendTimer();

        // الانتقال لشاشة إدخال الرمز
        Get.toNamed(
          AppRoute.otpVerificationCode,
          arguments: {
            'phoneNumber': phone,
          },
        );

        CustomToast.showSuccessToast(message: "تم إرسال رمز التحقق بنجاح");
      } else {
        CustomToast.showErrorToast(
            message: response['message'] ?? "حدث خطأ، حاول مرة أخرى");
      }
    } catch (e) {
      CustomToast.showErrorToast(message: "حدث خطأ غير متوقع، حاول مرة أخرى");
    } finally {
      isLoading = false;
      update();
    }
  }

  // إعادة تعيين كلمة المرور وتحقق من OTP
  Future<void> resetPasswordWithOTP() async {
    if (otpController.text.length != 6) {
      CustomToast.showErrorToast(message: "الرجاء إدخال رمز التحقق كاملاً");
      return;
    }

    if (!resetFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading = true;
      update();

      // تنسيق رقم الهاتف
      String phone = _formatPhoneNumber(phoneController.text);

      // التأكد من تطابق كلمات المرور
      if (newPasswordController.text != confirmPasswordController.text) {
        CustomToast.showErrorToast(message: "كلمات المرور غير متطابقة");
        return;
      }

      // استدعاء API لإعادة تعيين كلمة المرور مع التحقق من الرمز
      var response = await _forgotPasswordData.resetPassword(
          phone, otpController.text, newPasswordController.text);

      if (response['success'] == true) {
        // العودة لشاشة تسجيل الدخول
        Get.offAllNamed(AppRoute.login);
        CustomToast.showSuccessToast(message: "تم تغيير كلمة المرور بنجاح");
      } else {
        CustomToast.showErrorToast(
            message:
                response['message'] ?? "رمز التحقق غير صحيح أو حدث خطأ آخر");
      }
    } catch (e) {
      CustomToast.showErrorToast(message: "حدث خطأ غير متوقع، حاول مرة أخرى");
    } finally {
      isLoading = false;
      update();
    }
  }

  // إعادة إرسال رمز التحقق
  Future<void> resendCode() async {
    if (!canResend) return;

    try {
      isLoading = true;
      update();

      // تنسيق رقم الهاتف
      String phone = _formatPhoneNumber(phoneController.text);

      // استدعاء API لإعادة إرسال الرمز
      var response = await _forgotPasswordData.sendVerificationCode(phone);

      if (response['success'] == true) {
        // بدء مؤقت إعادة الإرسال من جديد
        _startResendTimer();
        CustomToast.showSuccessToast(message: "تم إعادة إرسال الرمز بنجاح");
      } else {
        CustomToast.showErrorToast(
            message: response['message'] ?? "حدث خطأ، حاول مرة أخرى");
      }
    } catch (e) {
      CustomToast.showErrorToast(message: "حدث خطأ غير متوقع، حاول مرة أخرى");
    } finally {
      isLoading = false;
      update();
    }
  }

  // تبديل رؤية كلمة المرور
  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  // حساب قوة كلمة المرور
  void _calculatePasswordStrength() {
    // التحقق من أن المتحكم لم يتم التخلص منه
    if (_isDisposed) return;

    String password = newPasswordController.text;

    // إعادة تعيين القوة
    int strength = 0;

    // كلمة المرور فارغة
    if (password.isEmpty) {
      passwordStrength = strength;
      update();
      return;
    }

    // التحقق من الطول
    if (password.length >= 8) strength++;

    // التحقق من وجود أحرف كبيرة
    if (password.contains(RegExp(r'[A-Z]'))) strength++;

    // التحقق من وجود أرقام
    if (password.contains(RegExp(r'[0-9]'))) strength++;

    // التحقق من وجود رموز خاصة
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    // تحديث قوة كلمة المرور
    passwordStrength = strength;
    update();
  }

  // بدء مؤقت إعادة الإرسال
  void _startResendTimer() {
    canResend = false;
    resendTimer = 60;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // التحقق من أن المتحكم لم يتم التخلص منه
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (resendTimer > 0) {
        resendTimer--;
        update();
      } else {
        canResend = true;
        timer.cancel();
        update();
      }
    });
  }

  // تنسيق رقم الهاتف
  String _formatPhoneNumber(String phone) {
    // إزالة المسافات وأي أحرف غير رقمية
    phone = phone.replaceAll(RegExp(r'\s+'), '');

    // التأكد من أن الرقم يبدأ بـ 0
    if (!phone.startsWith('0') && !phone.startsWith('963')) {
      phone = '0$phone';
    }

    return phone;
  }
}
