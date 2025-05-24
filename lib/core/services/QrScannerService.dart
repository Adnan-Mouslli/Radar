import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';

class QrScannerService {
  final String baseUrl = AppLink.server;

  String? _getToken() {
    return MyServices.instance.getToken();
  }

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

  // مسح كود QR وإرسال الطلب للخادم
  Future<Map<String, dynamic>> scanQrCode(String qrCodeId) async {
    try {
      final response =
          await http.post(Uri.parse('${qrCodeId}'), headers: _getHeaders());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        if (errorData["statusCode"] == 400)
          return errorData;
        else
          return {
            'isValid': false,
            'message': errorData['message'] ?? 'حدث خطأ أثناء معالجة الكود',
          };
      }
    } catch (e) {
      return {
        'isValid': false,
        'message': 'حدث خطأ في الاتصال بالخادم: ${e.toString()}',
      };
    }
  }

  // معالجة مسح الكود عبر الرابط
  Future<Map<String, dynamic>> handleQrScanViaUrl(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/qr/scan/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'isValid': true,
          'points': responseData['pointsAwarded'],
          'totalPoints': responseData['totalPoints'],
          'message': responseData['message'] ?? 'تم مسح الكود بنجاح!',
        };
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'isValid': false,
          'message': errorData['message'] ?? 'حدث خطأ أثناء معالجة الكود',
        };
      }
    } catch (e) {
      return {
        'isValid': false,
        'message': 'حدث خطأ في الاتصال بالخادم: ${e.toString()}',
      };
    }
  }

  // للاختبار والتجريب الداخلي
  Future<Map<String, dynamic>> validateQrCode(String qrData) async {
    try {
      // سنستخدم هذا لمحاكاة تواصل API في الاختبار
      await Future.delayed(Duration(milliseconds: 800));

      // للاختبار - في التطبيق الحقيقي يجب استخدام scanQrCode
      if (qrData.startsWith('radar_')) {
        int randomPoints = 10 + (DateTime.now().millisecondsSinceEpoch % 90);

        return {
          'isValid': true,
          'points': randomPoints,
          'message': 'تم التحقق من الكود بنجاح!',
        };
      } else {
        return {
          'isValid': false,
          'message': 'كود QR غير صالح أو منتهي الصلاحية',
        };
      }
    } catch (e) {
      return {
        'isValid': false,
        'message': 'حدث خطأ أثناء التحقق من الكود: ${e.toString()}',
      };
    }
  }
}
