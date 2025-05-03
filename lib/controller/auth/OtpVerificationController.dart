import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/class/statusrequest.dart';
import 'package:radar/core/constant/routes.dart';
import 'package:radar/core/services/OtpService.dart';
import 'package:radar/core/services/services.dart';
import 'package:radar/view/components/ui/CustomToast.dart';

class OtpVerificationController extends GetxController {
  final OtpService otpService = OtpService(Get.find());
  final MyServices _services = MyServices.instance;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // بيانات المستخدم (تأتي من الشاشة السابقة)
  late String phoneNumber;
  late String displayPhoneNumber; // للعرض في الواجهة
  late Map<String, dynamic> userData;

  // متغيرات للتحكم بإدخال رمز OTP
  // نحتفظ بالمتحكمات الفردية للتوافق مع الكود القديم
  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // إضافة متحكم رئيسي لـ PinCodeTextField
  TextEditingController otpController = TextEditingController();

  // متغير جديد لتتبع حالة التحقق من الإدخال
  bool hasError = false;
  String currentText = "";

  // متغيرات لإعادة الإرسال
  bool canResend = false;
  int resendSeconds = 30; // نبدأ بمؤقت 30 ثانية
  int resendAttempts = 0; // عدد محاولات إعادة الإرسال
  Timer? _resendTimer;

  // متغيرات للتحكم بحالة العملية
  bool isLoading = false;
  StatusRequest? statusRequest = StatusRequest.none;

  @override
  void onInit() {
    super.onInit();

    // استلام البيانات من الشاشة السابقة
    if (Get.arguments != null) {
      phoneNumber = Get.arguments['phoneNumber'];

      // إنشاء نسخة للعرض مع تنسيق مناسب للقراءة
      displayPhoneNumber = formatPhoneNumberForDisplay(phoneNumber);
    } else {
      // في حالة الاختبار أو عدم وجود بيانات
      phoneNumber = "+963XXXXXXXX";
      displayPhoneNumber = "+963 XX XXX XXXX";
      userData = {};
    }

    // بدء مؤقت إعادة الإرسال
    startResendTimer();

    // مراقبة تغييرات متحكم OTP الرئيسي
    otpController.addListener(() {
      currentText = otpController.text;

      // تحديث المتحكمات الفردية للتوافق مع الكود القديم
      for (int i = 0; i < currentText.length && i < 6; i++) {
        otpControllers[i].text = currentText[i];
      }

      // تنظيف الحقول التي تزيد عن طول النص المدخل
      for (int i = currentText.length; i < 6; i++) {
        otpControllers[i].text = '';
      }
    });

    update(['phone_number']);
  }

  // تنسيق رقم الهاتف للعرض بشكل أفضل
  String formatPhoneNumberForDisplay(String phone) {
    if (phone.isEmpty) return phone;

    // إذا كان الرقم يبدأ بعلامة +
    if (phone.startsWith('+')) {
      // محاولة تنسيق الرقم الدولي بشكل أكثر قابلية للقراءة
      // مثال: +963 94 626 9777
      String countryCode = '';
      String number = '';

      // استخراج كود البلد (أول 3-4 أرقام بعد علامة +)
      int codeEndIndex = 4; // افتراضي
      if (phone.length > 4) {
        for (int i = 1; i < phone.length && i <= 5; i++) {
          if (!RegExp(r'[0-9]').hasMatch(phone[i])) {
            codeEndIndex = i;
            break;
          }
        }
        countryCode = phone.substring(0, codeEndIndex);
        number = phone.substring(codeEndIndex);
      } else {
        return phone; // الرقم قصير جداً
      }

      // إضافة مسافات لجعل الرقم أكثر قابلية للقراءة
      if (number.length > 6) {
        final formattedNumber =
            '${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}';
        return '$countryCode $formattedNumber';
      } else {
        return '$countryCode $number';
      }
    }
    // إذا كان الرقم يبدأ بـ 0 (رقم محلي)
    else if (phone.startsWith('0')) {
      if (phone.length >= 10) {
        // تنسيق مثل: 094 626 9777
        return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
      }
      return phone;
    }

    return phone;
  }

  // حساب مدة المؤقت للمحاولة التالية
  int _calculateNextTimerDuration() {
    // البداية ب 30 ثانية، ثم مضاعفة (×2) في كل مرة
    // 30 -> 60 -> 120 -> 240 وهكذا
    return 30 * (1 << resendAttempts); // 1 << n هي 2^n
  }

  // بدء مؤقت إعادة الإرسال مع الوقت المحسوب
  void startResendTimer() {
    canResend = false;
    resendSeconds = _calculateNextTimerDuration();

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds > 0) {
        resendSeconds--;
        update(['resend_timer']);
      } else {
        canResend = true;
        _resendTimer?.cancel();
        update(['resend_timer']);
      }
    });
  }

  // الحصول على رمز OTP المدخل
  String getEnteredOtp() {
    // استخدام النص الحالي إذا كان محدداً من مكتبة PinCodeTextField
    if (currentText.isNotEmpty) {
      return currentText;
    }
    // التجميع من المتحكمات الفردية
    return otpControllers.map((controller) => controller.text).join();
  }

  Future<void> sendOtp() async {
    try {
      // التحقق من اكتمال إدخال الرمز
      if (!_validateOtpComplete()) {
        CustomToast.showErrorToast(
          message: "الرجاء إدخال الرمز المكون من 6 أرقام بالكامل",
        );
        hasError = true;
        update();
        return;
      }

      isLoading = true;
      hasError = false;
      update();

      final response = await otpService.sendOtp(
        phoneNumber,
        getEnteredOtp(),
      );

      response.fold(
        (failure) {
          CustomToast.showErrorToast(
            message: "حدث خطأ في إرسال رمز التحقق",
          );
          hasError = true;
        },
        (success) async {
          if (success['success'] == true) {
            CustomToast.showSuccessToast(
              message: "تم التحقق من رقم الهاتف بنجاح",
            );
            if (await _handleLoginSuccess(success)) {
              Get.offAllNamed(AppRoute.main);
            }
          } else {
            CustomToast.showErrorToast(
              message: success['message'] ?? "الرمز المدخل غير صحيح",
            );
            hasError = true;
            print("API Error: ${success['message']}");
          }
        },
      );
    } catch (e) {
      print("Exception sending OTP: $e");
      CustomToast.showErrorToast(
        message: "حدث خطأ غير متوقع",
      );
      hasError = true;
    } finally {
      isLoading = false;
      update();
    }
  }

  // التحقق من اكتمال إدخال الرمز
  bool _validateOtpComplete() {
    // التحقق من النص المدخل في PinCodeTextField
    if (currentText.length == 6) {
      return true;
    }

    // التحقق البديل باستخدام المتحكمات الفردية
    for (var controller in otpControllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _handleLoginSuccess(Map<dynamic, dynamic> response) async {
    try {
      final userData = response['user'];
      final token = response['token'];

      print("token: ${token}");
      final tokenSaved = await _services.setToken(token);
      if (!tokenSaved) {
        throw Exception('فشل في حفظ التوكن');
      }

      // response.remove('token');
      final userSaved = await _services.saveUserData(userData);

      if (!userSaved) {
        await _services.removeToken();
        throw Exception('فشل في حفظ بيانات المستخدم');
      }

      _services.saveData("loggedin", "1");

      print('تم تسجيل الدخول بنجاح: ${_services.getUserData()}');
      return true;
    } catch (e) {
      _handleLoginError(e);
      return false;
    }
  }

  void _handleLoginFailure(String message) {
    Get.defaultDialog(title: "تنبيه", middleText: message);
    statusRequest = StatusRequest.failure;
    update();
  }

  void _handleLoginError(dynamic error) {
    print("خطأ في تسجيل الدخول: $error");
    statusRequest = StatusRequest.error;
    Get.defaultDialog(
        title: "خطأ",
        middleText: "حدث خطأ غير متوقع، الرجاء المحاولة مرة أخرى");
    update();
  }

  // إعادة إرسال رمز OTP
  Future<void> resendOtp() async {
    if (!canResend) return;

    try {
      isLoading = true;
      update();

      await otpService.reSendOtp(phoneNumber);
      showSuccess("تم إعادة إرسال رمز التحقق");

      // إعادة تعيين الإدخال
      otpController.clear();
      currentText = "";
      for (var controller in otpControllers) {
        controller.clear();
      }

      // زيادة عدد محاولات الإرسال وبدء مؤقت جديد
      resendAttempts++;
      startResendTimer();
    } catch (e) {
      handleError("حدث خطأ في إعادة إرسال الرمز");
      print("Resend OTP error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  void showSuccess(String message) {
    CustomToast.showSuccessToast(message: message);
  }

  void handleError(String message) {
    CustomToast.showErrorToast(message: message);
  }

  // تنسيق وقت الانتظار للعرض في الواجهة
  String getFormattedRemainingTime() {
    if (resendSeconds < 60) {
      return "${resendSeconds} ثانية";
    } else {
      int minutes = resendSeconds ~/ 60;
      int seconds = resendSeconds % 60;
      return "$minutes:${seconds.toString().padLeft(2, '0')} دقيقة";
    }
  }

  @override
  void onClose() {
    // إلغاء المؤقتات والتحكم
    _resendTimer?.cancel();

    // التخلص من وحدات التحكم بالنص
    otpController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }

    super.onClose();
  }
}
