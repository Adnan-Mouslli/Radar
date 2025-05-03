import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';
import 'package:radar/data/model/UserProfile.dart';

class ProfileApiService {
  // الرابط الأساسي للخادم
  final String baseUrl = AppLink.server;

  // الحصول على توكن المستخدم من MyServices
  String? _getToken() {
    return MyServices.instance.getToken();
  }

  // إعداد رؤوس الطلبات
  Map<String, String> _getHeaders({bool isMultipart = false}) {
    Map<String, String> headers = {};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    headers['Accept'] = 'application/json';

    final token = _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<ProfileResponseModel?> getUserProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("تم استلام بيانات الملف الشخصي بنجاح");

        // تحويل البيانات المستلمة إلى نموذج ProfileResponseModel
        return ProfileResponseModel.fromJson(jsonData['data']);
      } else {
        throw Exception('فشل في جلب بيانات المستخدم: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب بيانات المستخدم: $e');
    }
  }

  // تحديث بيانات المستخدم
  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: _getHeaders(),
        body: json.encode(data),
      );

      print(
          'تحديث الملف الشخصي - الاستجابة: ${response.statusCode} ${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('خطأ في تحديث بيانات المستخدم: $e');
      throw Exception('حدث خطأ أثناء تحديث بيانات المستخدم: $e');
    }
  }

  // تحديث الصورة الشخصية
  // تحديث الصورة الشخصية
  Future<bool> updateProfilePicture(String userId, String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/auth/profile'),
      );

      // إضافة الهيدرز بما في ذلك توكن المصادقة
      request.headers.addAll(_getHeaders(isMultipart: true));

      // تحديد نوع المحتوى بشكل صريح
      final extension = imagePath.split('.').last.toLowerCase();
      String contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg'; // افتراضي
      }

      // إضافة ملف الصورة الشخصية مع تحديد نوع المحتوى
      var file = await http.MultipartFile.fromPath('profilePhoto', imagePath,
          contentType: MediaType.parse(contentType));
      request.files.add(file);

      // طباعة معلومات الطلب للتصحيح
      print(
          'Sending request with file: ${file.filename}, content-type: ${file.contentType}, length: ${file.length}');

      // إرسال الطلب وانتظار الاستجابة
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          'تحديث صورة الملف الشخصي - الاستجابة: ${response.statusCode} ${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('خطأ في تحديث الصورة الشخصية: $e');
      throw Exception('حدث خطأ أثناء تحديث الصورة الشخصية: $e');
    }
  }

  // جلب قائمة المتابعين
  Future<List<UserProfile>> getFollowers(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/followers'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return (jsonData['data'] as List)
            .map((item) => UserProfile.fromJson(item))
            .toList();
      } else {
        throw Exception('فشل في جلب قائمة المتابعين: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب قائمة المتابعين: $e');
    }
  }

  // جلب قائمة المتابعين له
  Future<List<UserProfile>> getFollowing(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/following'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return (jsonData['data'] as List)
            .map((item) => UserProfile.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'فشل في جلب قائمة المتابعين له: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب قائمة المتابعين له: $e');
    }
  }

  Future<bool> deleteAccount(String password) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/auth/account'),
        headers: _getHeaders(),
        body: json.encode({'password': password}),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('خطأ في حذف الحساب: $e');
      throw Exception('حدث خطأ أثناء حذف الحساب: $e');
    }
  }
}
