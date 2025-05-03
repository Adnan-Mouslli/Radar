import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';

/// فئة أساسية لجميع خدمات API في التطبيق
/// تتعامل مع إعداد رؤوس الطلبات وتوكن المصادقة والتعامل مع الاستجابات
class ApiServiceBase {
  // استخدام الرابط من AppLink
  final String baseUrl = AppLink.server;

  // الحصول على توكن المستخدم من MyServices
  String? _getToken() {
    return MyServices.instance.getToken();
  }

  // إنشاء رؤوس الطلبات مع إضافة توكن المصادقة
  Map<String, String> getHeaders({bool requireAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // إضافة توكن المصادقة إذا كان مطلوبًا ومتوفرًا
    if (requireAuth) {
      final token = _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // دالة للطلبات من نوع GET
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParams, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters:
            queryParams?.map((key, value) => MapEntry(key, value.toString())),
      );

      final response = await http.get(
        uri,
        headers: getHeaders(requireAuth: requireAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('حدث خطأ في الطلب: $e');
    }
  }

  // دالة للطلبات من نوع POST
  Future<Map<String, dynamic>> post(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: getHeaders(requireAuth: requireAuth),
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('حدث خطأ في الطلب: $e');
    }
  }

  // دالة للطلبات من نوع PUT
  Future<Map<String, dynamic>> put(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: getHeaders(requireAuth: requireAuth),
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('حدث خطأ في الطلب: $e');
    }
  }

  // دالة للطلبات من نوع DELETE
  Future<Map<String, dynamic>> delete(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    try {
      final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(getHeaders(requireAuth: requireAuth));

      if (body != null) {
        request.body = json.encode(body);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('حدث خطأ في الطلب: $e');
    }
  }

  // معالجة الاستجابة وتحويلها إلى تنسيق موحد
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody =
        response.body.isNotEmpty ? json.decode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      // استجابة ناجحة
      if (responseBody is Map<String, dynamic>) {
        return responseBody;
      } else if (responseBody is List) {
        return {'data': responseBody};
      } else {
        return {'data': responseBody};
      }
    } else {
      // استجابة غير ناجحة
      String errorMessage = 'حدث خطأ في الطلب';

      if (responseBody != null && responseBody is Map<String, dynamic>) {
        errorMessage =
            responseBody['message'] ?? responseBody['error'] ?? errorMessage;
      }

      throw ApiException(
        message: errorMessage,
        statusCode: statusCode,
        response: responseBody,
      );
    }
  }
}

/// فئة استثناء مخصصة لأخطاء API
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic response;

  ApiException({
    required this.message,
    required this.statusCode,
    this.response,
  });

  @override
  String toString() {
    return 'ApiException: $message (statusCode: $statusCode)';
  }
}
