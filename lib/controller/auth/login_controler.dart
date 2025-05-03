import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../view/components/ui/CustomToast.dart';
import 'package:http/http.dart' as http;

class LoginControlerImp extends GetxController {
  final formKey = GlobalKey<FormState>();

  late TextEditingController phone;
  late TextEditingController password;
  bool isshowpassword = true;

  // Country code properties
  CountryCode selectedCountryCode = CountryCode(
    code: "SY",
    dialCode: "+963",
    name: "Syrian Arab Republic",
  );

  // Phone validation error
  String? phoneErrorText;

  final MyServices _services = MyServices.instance;

  StatusRequest? statusRequest = StatusRequest.none;

  showPassword() {
    isshowpassword = isshowpassword == true ? false : true;
    update();
  }

  // Set country code from the UI
  void setCountryCode(CountryCode code) {
    selectedCountryCode = code;
    update();
  }

  // Format phone number properly for API
  String formatPhoneNumber(String phoneNumber) {
    // Remove any leading zeros
    while (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // Get dial code without the + symbol
    String formattedCode = selectedCountryCode.dialCode!;
    if (formattedCode.startsWith('+')) {
      formattedCode = formattedCode.substring(1);
    }

    // Return formatted number (e.g., 963941325008)
    return formattedCode + phoneNumber;
  }

  // Validate phone input
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      phoneErrorText = "الرجاء إدخال رقم الهاتف";
      update();
      return phoneErrorText;
    }

    // إزالة رسالة الخطأ إذا كان الإدخال صحيحًا
    phoneErrorText = null;
    update();
    return null;
  }

  login() async {
    if (formKey.currentState!.validate()) {
      try {
        statusRequest = StatusRequest.loading;
        update();

        // Format the phone number properly
        String formattedPhone = formatPhoneNumber(phone.text);

        var res = await http.post(
          Uri.parse(AppLink.login),
          body: jsonEncode({
            "phone": formattedPhone,
            "password": password.text,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        var response = jsonDecode(res.body);

        print("API Response: $response");

        String message = response["message"];
        int? statusCode = response["statusCode"];

        if (message == "Signed in successfully") {
          // حفظ التوكن والبيانات
          if (await _handleLoginSuccess(response)) {
            // عرض رسالة نجاح
            CustomToast.showSuccessToast(
              message: "تم تسجيل الدخول بنجاح",
            );
            Get.offAllNamed(AppRoute.main);
          }
        } else if (statusCode == 401) {
          if (message == 'User not verified') {
            // التعامل مع المستخدم غير المفعل
            CustomToast.showWarningToast(
              message: "يرجى تفعيل حسابك أولاً",
            );

            Get.offNamed(
              AppRoute.otpVerification,
              arguments: {
                'phoneNumber': formattedPhone,
              },
            );
          } else {
            _handleLoginFailure("رقم الهاتف أو كلمة المرور غير صحيحة");
          }
        } else if (statusCode == 500) {
          _handleLoginFailure("فشل الاتصال بالخادم");
        } else {
          _handleLoginFailure("حدث خطأ في تسجيل الدخول");
        }

        update();
      } catch (e) {
        print("Error en login: $e");
        _handleLoginError(e);
      }
    }
  }

  Future<bool> _handleLoginSuccess(Map<String, dynamic> response) async {
    try {
      final userData = response['data'];
      final token = response['token'];

      print("token: ${token}");
      final tokenSaved = await _services.setToken(token);
      if (!tokenSaved) {
        throw Exception('فشل في حفظ التوكن');
      }

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
    CustomToast.showErrorToast(
      message: message,
    );
    statusRequest = StatusRequest.failure;
    update();
  }

  void _handleLoginError(dynamic error) {
    print("خطأ في تسجيل الدخول: $error");
    statusRequest = StatusRequest.error;

    CustomToast.showErrorToast(
      message: "حدث خطأ غير متوقع: ${error.toString()}",
    );
    update();
  }

  bool get isLoggedIn => _services.isUserLoggedIn();

  void logout() async {
    await _services.clearUserData();
    CustomToast.showSuccessToast(
      message: "تم تسجيل الخروج بنجاح",
    );
    Get.offAllNamed(AppRoute.login);
  }

  @override
  void onInit() {
    phone = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    super.dispose();
  }
}
