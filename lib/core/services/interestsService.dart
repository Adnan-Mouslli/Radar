import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';

class InterestsApiService {
  // الرابط الأساسي للخادم
  final String baseUrl = AppLink.server;

  // الحصول على توكن المستخدم من MyServices
  String? _getToken() {
    return MyServices.instance.getToken();
  }

  // إعداد رؤوس الطلبات
  Map<String, String> _getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// جلب جميع الاهتمامات المتاحة في النظام
  Future<List<Map<String, dynamic>>> getAllInterestsList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/interests/list'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Map<String, dynamic>> interests = [];

        // التعامل مع البيانات كقائمة مباشرة
        if (jsonData is List) {
          for (var item in jsonData) {
            if (item is Map<String, dynamic>) {
              interests.add(item);
            }
          }
        } else if (jsonData['data'] != null && jsonData['data'] is List) {
          // احتفظ بهذا كاحتياط في حال كانت البيانات ضمن مفتاح 'data'
          for (var item in jsonData['data']) {
            if (item is Map<String, dynamic>) {
              interests.add(item);
            }
          }
        }

        return interests;
      } else {
        throw Exception('فشل في جلب الاهتمامات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب الاهتمامات: $e');
    }
  }

  /// إضافة اهتمامات للمستخدم
  ///
  /// [interestIds] قائمة بمعرفات الاهتمامات المراد إضافتها
  Future<bool> addUserInterests(List<String> interestIds) async {
    try {
      // تحضير بيانات الطلب
      final Map<String, dynamic> requestData = {
        'interestIds': interestIds,
      };

      // إرسال طلب إضافة الاهتمامات
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/interests'),
        headers: _getHeaders(),
        body: json.encode(requestData),
      );

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("تمت إضافة الاهتمامات بنجاح");
        return true;
      } else {
        print("فشل إضافة الاهتمامات: ${response.statusCode}");
        print("رسالة الخطأ: ${response.body}");
        return false;
      }
    } catch (e) {
      print("حدث خطأ أثناء إضافة الاهتمامات: $e");
      return false;
    }
  }

  /// حذف اهتمامات من قائمة اهتمامات المستخدم
  ///
  /// [interestIds] قائمة بمعرفات الاهتمامات المراد حذفها
  Future<bool> removeUserInterests(List<String> interestIds) async {
    try {
      // تحضير بيانات الطلب
      final Map<String, dynamic> requestData = {
        'interestIds': interestIds,
      };

      // إرسال طلب حذف الاهتمامات
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/interests'),
        headers: _getHeaders(),
        body: json.encode(requestData),
      );

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        print("تم حذف الاهتمامات بنجاح");
        return true;
      } else {
        print("فشل حذف الاهتمامات: ${response.statusCode}");
        print("رسالة الخطأ: ${response.body}");
        return false;
      }
    } catch (e) {
      print("حدث خطأ أثناء حذف الاهتمامات: $e");
      return false;
    }
  }

  /// جلب اهتمامات المستخدم الحالي
  Future<List<Map<String, dynamic>>> getUserInterests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/interests'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Map<String, dynamic>> userInterests = [];

        if (jsonData is List) {
          for (var item in jsonData) {
            if (item is Map<String, dynamic>) {
              userInterests.add(item);
            }
          }
        } else if (jsonData['data'] != null && jsonData['data'] is List) {
          for (var item in jsonData['data']) {
            if (item is Map<String, dynamic>) {
              userInterests.add(item);
            }
          }
        }

        return userInterests;
      } else {
        throw Exception('فشل في جلب اهتمامات المستخدم: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب اهتمامات المستخدم: $e');
    }
  }

  /// البحث عن اهتمامات حسب الاسم
  Future<List<Map<String, dynamic>>> searchInterests(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/interests/search?query=$query'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Map<String, dynamic>> searchResults = [];

        if (jsonData is List) {
          for (var item in jsonData) {
            if (item is Map<String, dynamic>) {
              searchResults.add(item);
            }
          }
        } else if (jsonData['data'] != null && jsonData['data'] is List) {
          for (var item in jsonData['data']) {
            if (item is Map<String, dynamic>) {
              searchResults.add(item);
            }
          }
        }

        return searchResults;
      } else {
        throw Exception('فشل في البحث عن الاهتمامات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء البحث عن الاهتمامات: $e');
    }
  }

  /// الحصول على تفاصيل اهتمام محدد بواسطة المعرف
  Future<Map<String, dynamic>?> getInterestDetails(String interestId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/interests/$interestId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic>) {
          return jsonData;
        } else if (jsonData['data'] != null &&
            jsonData['data'] is Map<String, dynamic>) {
          return jsonData['data'];
        }

        return null;
      } else {
        throw Exception('فشل في جلب تفاصيل الاهتمام: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب تفاصيل الاهتمام: $e');
    }
  }
}
