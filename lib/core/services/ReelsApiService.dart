import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/constant/routes.dart';
import 'package:radar/core/services/services.dart';
import 'package:radar/data/model/reel_model_api.dart';

class ReelsApiService {
  // استخدام الرابط من AppLink
  final String baseUrl = AppLink.server;
  final MyServices myServices = MyServices.instance;

  // الحصول على توكن المستخدم من MyServices
  String? _getToken() {
    return MyServices.instance.getToken();
  }

  // دالة مساعدة لتحضير رؤوس الطلبات (headers) مع إضافة توكن المصادقة
  Map<String, String> _getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // إضافة توكن المصادقة إذا كان متوفراً
    final token = _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // دالة للتحقق من استجابة API والتعامل مع خطأ 401
  void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // التحقق من نوع الخطأ من محتوى الاستجابة
      try {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['statusCode'] == 401 ||
            jsonResponse['message'] == 'Unauthorized') {
          // تنفيذ تسجيل خروج وتوجيه المستخدم إلى شاشة تسجيل الدخول
          _handleUnauthorized('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
        }
      } catch (e) {
        // إذا لم نتمكن من تحليل الاستجابة، نفترض أنها خطأ 401
        if (response.statusCode == 401) {
          _handleUnauthorized('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
        }
      }
    }
    // إضافة معالجة خطأ 404 للتحقق من حذف الحساب
    else if (response.statusCode == 404) {
      try {
        final jsonResponse = json.decode(response.body);
        // التحقق من محتوى الرسالة للتأكد من أن هذا يتعلق بحذف الحساب
        // يمكن تعديل الشرط حسب هيكل الاستجابة الفعلي من الخادم
        if (jsonResponse['message']
                    ?.toString()
                    .toLowerCase()
                    .contains('user') ==
                true ||
            jsonResponse['error']?.toString().toLowerCase().contains('user') ==
                true ||
            jsonResponse['message']
                    ?.toString()
                    .toLowerCase()
                    .contains('account') ==
                true) {
          _handleUnauthorized(
              'تم حذف الحساب أو لم يعد موجودًا، يرجى تسجيل الدخول مرة أخرى');
        }
      } catch (e) {
        // في حالة تعذر تحليل الاستجابة، نتحقق من مسار URL لتحديد ما إذا كان يتعلق بمعلومات المستخدم
        if (response.request?.url.toString().contains('/user/') == true ||
            response.request?.url.toString().contains('/users/') == true ||
            response.request?.url.toString().contains('/profile') == true ||
            response.request?.url.toString().contains('/relevant') == true) {
          _handleUnauthorized('تعذر الوصول للحساب، يرجى تسجيل الدخول مرة أخرى');
        }
      }
    }
  }

  void _handleUnauthorized(String message) {
    print("تم اكتشاف حالة عدم تصريح أو حذف حساب، جاري تسجيل الخروج...");

    // حذف بيانات المستخدم من الكاش
    myServices.clearUserData();
    myServices.sharedPreferences.remove("loggedin");

    // عرض إشعار للمستخدم
    Get.snackbar(
      'تنبيه',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );

    // توجيه المستخدم إلى شاشة تسجيل الدخول
    // استخدام تأخير بسيط لضمان إتمام العمليات السابقة
    Future.delayed(Duration(milliseconds: 500), () {
      Get.offAllNamed(AppRoute.login);
    });
  }

  // دالة للحصول على الريلز ذات الصلة بالمستخدم
  Future<List<Reel>> getRelevantReels({int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/content/user/relevant'),
        headers: _getHeaders(),
      );

      print(response.body);
      // التحقق من حالة الاستجابة
      _handleResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // تحويل البيانات إلى قائمة من نوع Reel
        if (jsonData['data'] != null && jsonData['data'] is List) {
          return (jsonData['data'] as List)
              .map((item) => Reel.fromJson(item))
              .toList();
        } else {
          // في حال كان التنسيق مختلفًا
          return [];
        }
      } else {
        throw Exception('فشل في الحصول على الريلز: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب الريلز: $e');
    }
  }

  // دالة للحصول على ريل محدد بواسطة المعرف
  Future<dynamic> getReelById(String reelId) async {
    try {
      // إنشاء URL مع الترميز المناسب
      final url = Uri.parse('${baseUrl}/reels/$reelId');

      // إجراء طلب API
      final response = await http
          .get(
            url,
            headers: _getHeaders(),
          )
          .timeout(Duration(seconds: 15)); // إضافة مهلة

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          // التحقق مما إذا كانت الاستجابة تتضمن ريل واحد أو قائمة
          if (jsonData['data'] is Map) {
            // تم إرجاع ريل واحد
            return Reel.fromJson(jsonData['data']);
          } else if (jsonData['data'] is List) {
            // تم إرجاع قائمة من الريلز (قد تتضمن ريلز ذات صلة)
            return (jsonData['data'] as List)
                .map((reelJson) => Reel.fromJson(reelJson))
                .toList();
          }
        }

        // إذا وصلنا إلى هنا، فقد أعاد API استجابة غير ناجحة أو تنسيق غير متوقع
        print(
            "أعاد API استجابة غير ناجحة أو تنسيق غير متوقع: ${response.body}");
        return null;
      } else {
        // معالجة خطأ HTTP
        print(
            "خطأ في جلب الريل بواسطة المعرف: [${response.statusCode}] ${response.body}");
        return null;
      }
    } catch (e) {
      print("استثناء أثناء جلب الريل بواسطة المعرف: $e");
      rethrow; // إعادة رمي الاستثناء للسماح لوحدة التحكم بمعالجته
    }
  }

  // دالة للحصول على ريلز مستخدم معين
  Future<List<Reel>> getUserReels(String userId,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/content/user/$userId?page=$page&limit=$limit'),
        headers: _getHeaders(),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['data'] != null && jsonData['data'] is List) {
          return (jsonData['data'] as List)
              .map((item) => Reel.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
            'فشل في الحصول على ريلز المستخدم: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب ريلز المستخدم: $e');
    }
  }

  // دالة لتحميل المزيد من الريلز
  Future<List<Reel>> loadMoreReels(String lastReelId, {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/content/user/relevant/more?lastId=$lastReelId&limit=$limit'),
        headers: _getHeaders(),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['data'] != null && jsonData['data'] is List) {
          return (jsonData['data'] as List)
              .map((item) => Reel.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
            'فشل في تحميل المزيد من الريلز: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل المزيد من الريلز: $e');
    }
  }

  // دالة للإعجاب بمحتوى معين
  Future<bool> likeContent(String contentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/content/$contentId/like'),
        headers: _getHeaders(),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('حدث خطأ أثناء الإعجاب بالمحتوى: $e');
    }
  }

  // دالة لإلغاء الإعجاب بمحتوى معين
  Future<bool> unlikeContent(String contentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/content/$contentId/like'),
        headers: _getHeaders(),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('حدث خطأ أثناء إلغاء الإعجاب بالمحتوى: $e');
    }
  }

  // دالة لتسجيل مشاهدة محتوى معين
  Future<Map<String, dynamic>> viewContent(String contentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/content/$contentId/view'),
        headers: _getHeaders(),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // محاولة تحليل الاستجابة كـ JSON
        try {
          final jsonResponse = jsonDecode(response.body);

          // التأكد من أن الاستجابة هي Map
          if (jsonResponse is Map<String, dynamic>) {
            return jsonResponse;
          } else {
            // إذا لم تكن Map، نقوم بلفها في Map
            return {
              'success': true,
              'data': jsonResponse,
              'message': 'تم تسجيل المشاهدة بنجاح',
            };
          }
        } catch (jsonError) {
          // لا يمكن تحليل JSON، نعيد استجابة بدفعها في Map
          print("Error parsing JSON response: $jsonError");
          return {
            'success': true,
            'message': 'تم تسجيل المشاهدة بنجاح',
            'rawResponse': response.body,
          };
        }
      } else {
        // حالة خطأ من الخادم
        return {
          'success': false,
          'message': 'فشل تسجيل المشاهدة: ${response.statusCode}',
          'statusCode': response.statusCode,
          'rawResponse': response.body,
        };
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء تسجيل المشاهدة: $e');
    }
  }

  Future<Map<String, dynamic>> whatsappClick(String contentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/content/$contentId/whatsapp'),
        headers: _getHeaders(),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      // تحقق من نجاح الطلب
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return {'success': false};
    } catch (error) {
      print('خطأ في طلب نقرة واتساب: $error');
      return {'success': false};
    }
  }

  // دالة للحصول على تعليقات محتوى معين
  Future<List<dynamic>> getContentComments(String contentId,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/content/$contentId/comments?page=$page&limit=$limit'),
        headers: _getHeaders(),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['data'] != null && jsonData['data'] is List) {
          return jsonData['data'];
        } else {
          return [];
        }
      } else {
        throw Exception('فشل في الحصول على التعليقات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب التعليقات: $e');
    }
  }

  // دالة لإرسال تعليق على محتوى
  Future<bool> commentOnContent(String contentId, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/content/$contentId/comments'),
        headers: _getHeaders(),
        body: json.encode({
          'comment': comment,
        }),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('حدث خطأ أثناء إرسال التعليق: $e');
    }
  }

  // إضافة دالة لجلب بيانات المتجر في ReelsApiService
  Future<Map<String, dynamic>> getStoreDetails(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stores/$storeId'),
        headers: _getHeaders(),
      );

      // التحقق من حالة الاستجابة
      _handleResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
            'فشل في الحصول على بيانات المتجر: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب بيانات المتجر: $e');
    }
  }
}
