import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';

class RewardsService {
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

  Future<List<dynamic>> getRewardsWithCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rewards/categories'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData;
        } else {
          return [];
        }
      } else {
        throw Exception('فشل في الحصول على الفئات والجوائز');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب الفئات والجوائز');
    }
  }

  // شراء مكافأة
  Future<Map<String, dynamic>> purchaseReward(String rewardId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/rewards/purchase'),
        headers: _getHeaders(),
        body: json.encode({'rewardId': rewardId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // تحليل البيانات المستلمة من الاستجابة
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('فشل في شراء المكافأة');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء شراء المكافأة');
    }
  }
}
