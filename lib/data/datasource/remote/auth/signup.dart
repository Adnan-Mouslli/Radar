import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as https;
import 'package:http_parser/http_parser.dart';
import '../../../../core/constant/Link.dart';

class SignUpData {
  SignUpData();

  Future<dynamic> signUp({
    required String name,
    required String phone,
    required String password,
    required String dateOfBirth,
    required String gender,
    required String providence,
    required List<String> interestIds,
    File? profilePhoto, // جعل الصورة اختيارية
  }) async {
    try {
      if (profilePhoto != null) {
        var request = https.MultipartRequest(
          'POST',
          Uri.parse(AppLink.signUp),
        );

        // إضافة البيانات النصية
        request.fields['name'] = name;
        request.fields['phone'] = phone;
        request.fields['password'] = password;
        request.fields['dateOfBirth'] = dateOfBirth;
        request.fields['gender'] = gender;
        request.fields['providence'] = providence;

        for (int i = 0; i < interestIds.length; i++) {
          request.fields['interestIds[$i]'] = interestIds[i];
        }

        // إضافة ملف الصورة
        var profilePhotoFile = await https.MultipartFile.fromPath(
          'profilePhoto',
          profilePhoto.path,
          contentType: MediaType('image', 'jpeg'), // تحديد نوع المحتوى
        );
        request.files.add(profilePhotoFile);

        // إرسال الطلب وانتظار الاستجابة
        var streamedResponse = await request.send();
        var response = await https.Response.fromStream(streamedResponse);

        // طباعة الاستجابة للتشخيص
        print("Server response code: ${response.statusCode}");
        print("Server response body: ${response.body}");

        // تحليل الاستجابة بشكل آمن
        try {
          var decodedResponse = jsonDecode(response.body);
          return _sanitizeResponse(decodedResponse);
        } catch (parseError) {
          print("Error parsing response: $parseError");
          return {
            "success": false,
            "message": "فشل في معالجة استجابة الخادم: ${response.statusCode}",
            "error": "ParseError"
          };
        }
      } else {
        // إذا لم تكن هناك صورة، استخدم طلب JSON العادي
        Map<String, dynamic> requestBody = {
          "name": name,
          "phone": phone,
          "password": password,
          "dateOfBirth": dateOfBirth,
          "gender": gender,
          "providence": providence,
          "interestIds": interestIds,
        };

        String requestBodyJson = jsonEncode(requestBody);
        print("Request body: $requestBodyJson");

        var headers = {
          'Content-Type': 'application/json',
        };

        var response = await https.post(
          Uri.parse(AppLink.signUp),
          headers: headers,
          body: requestBodyJson,
        );

        // طباعة الاستجابة للتشخيص
        print("Server response code: ${response.statusCode}");
        print("Server response body: ${response.body}");

        try {
          var decodedResponse = jsonDecode(response.body);
          return _sanitizeResponse(decodedResponse);
        } catch (parseError) {
          print("Error parsing response: $parseError");
          return {
            "success": false,
            "message": "فشل في معالجة استجابة الخادم: ${response.statusCode}",
            "error": "ParseError"
          };
        }
      }
    } catch (e) {
      print("Error in SignUpData: $e");
      // بدلاً من إعادة رمي الخطأ، نعيد استجابة منظمة
      return {
        "success": false,
        "message": "فشل الاتصال بالخادم: $e",
        "error": e.toString()
      };
    }
  }

  // دالة تنظيف وتأمين الاستجابة
  Map<String, dynamic> _sanitizeResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      // معالجة القيم غير المتوقعة
      var sanitizedResponse = Map<String, dynamic>.from(response);

      // التحقق من وجود الرسالة
      if (sanitizedResponse['message'] != null &&
          sanitizedResponse['message'] is List) {
        // إذا كانت الرسالة قائمة، نحولها إلى نص
        sanitizedResponse['message'] =
            (sanitizedResponse['message'] as List).join(", ");
      }

      return sanitizedResponse;
    } else if (response is List) {
      // إذا كانت الاستجابة قائمة، نحولها إلى خريطة
      return {
        "success": true,
        "data": response,
        "message": "تم معالجة الطلب بنجاح"
      };
    } else {
      // إذا كانت الاستجابة غير متوقعة
      return {
        "success": false,
        "message": "استجابة غير متوقعة من الخادم",
        "raw": response.toString()
      };
    }
  }
}
