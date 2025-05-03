import 'dart:convert';

import 'package:radar/core/class/crud.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:http/http.dart' as http;

class ForgetPasswordData {
  final Crud _crud;

  ForgetPasswordData() : _crud = Crud();
  Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // إرسال رمز التحقق
  Future<Map<String, dynamic>> sendVerificationCode(String phoneNumber) async {
    try {
      // تأكد من أن رقم الهاتف في التنسيق المناسب
      // إذا كان يبدأ بـ 0، يتم استبداله بـ 963
      if (phoneNumber.startsWith('0')) {
        phoneNumber = '963${phoneNumber.substring(1)}';
      }
      var response = await http.post(
        Uri.parse(AppLink.forgetPasswordVerification),
        body: jsonEncode({
          "phone": phoneNumber,
        }),
        headers: _headers,
      );

      final res = jsonDecode(response.body);

      if (res["success"] == true) {
        return Map<String, dynamic>.from(
            {"success": true, "message": "تم ارسال رمز التحقق بنجاح"});
      } else if (res["statusCode"] == 400 &&
          res["message"] == "No account found with this phone number") {
        return <String, dynamic>{
          "success": false,
          "message": "الرقم غير موجود بالخدمة",
        };
      } else {
        return <String, dynamic>{
          "success": false,
          "message": "حدث خطأ، حاول مرة أخرى",
        };
      }
    } catch (e) {
      return <String, dynamic>{
        "success": false,
        "message": "حدث خطأ، حاول مرة أخرى",
      };
    }
  }

  // تم دمج التحقق من OTP وإعادة تعيين كلمة المرور في طلب واحد
  Future<Map<String, dynamic>> resetPassword(
      String phoneNumber, String otp, String newPassword) async {
    try {
      // تأكد من أن رقم الهاتف في التنسيق المناسب
      // إذا كان يبدأ بـ 0، يتم استبداله بـ 963
      if (phoneNumber.startsWith('0')) {
        phoneNumber = '963${phoneNumber.substring(1)}';
      }

      final response = await _crud.postData(
        AppLink.resetPassword,
        {
          "phone": phoneNumber,
          "otp": otp,
          "newPassword": newPassword,
        },
      );

      return response.fold((failure) {
        return <String, dynamic>{
          "success": false,
          "message": failure.toString(),
        };
      }, (success) {
        // Cast the success map to Map<String, dynamic>
        return Map<String, dynamic>.from(success);
      });
    } catch (e) {
      return <String, dynamic>{
        "success": false,
        "message": e.toString(),
      };
    }
  }
}
