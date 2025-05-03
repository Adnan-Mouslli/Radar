import 'dart:convert';

import 'package:get/get.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/functions/DistanceCalculator.dart';
import 'package:radar/core/services/services.dart';
import 'package:http/http.dart' as http;
import 'package:radar/data/model/OfferModel.dart';

class OffersService extends GetxService {
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

  // Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/offer-categories'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((category) => CategoryModel(
                  id: category['id'],
                  name: category['name'],
                ))
            .toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  // Get offers based on filters
  Future<List<OfferModel>> getOffers(Map<String, dynamic> filters) async {
    try {
      // بناء معلمات الاستعلام من المرشحات
      final queryParams = <String, String>{};

      filters.forEach((key, value) {
        if (value != null) {
          queryParams[key] = value.toString();
        }
      });

      print("queryParams: ${queryParams}");

      final uri = Uri.parse('$baseUrl/api/offers').replace(
        queryParameters: queryParams,
      );

      print('Request URL: ${uri.toString()}');
      final response = await http.get(
        uri,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> offersJson = responseData['data'];

        // تحقق من وجود مدينة محددة
        if (filters.containsKey('city')) {
          final List<OfferModel> offers = offersJson.map((json) {
            // استخدام مسافة افتراضية (صفر) أو المسافة من الخادم إن وجدت
            double distance = 0.0;
            if (json.containsKey('distance') && json['distance'] != null) {
              distance = double.parse(json['distance'].toString());
            }
            return OfferModel.fromJson(json, distance: distance);
          }).toList();

          return offers;
        } else {
          // التأكد من وجود إحداثيات المستخدم
          if (!filters.containsKey('latitude') ||
              !filters.containsKey('longitude')) {
            throw Exception('User location coordinates are required');
          }

          // استخراج إحداثيات المستخدم
          final userLat = filters['latitude'] as double;
          final userLng = filters['longitude'] as double;

          final List<OfferModel> offers = offersJson.map((json) {
            // حساب المسافة من موقع المستخدم
            final storeLat = json['store']['latitude'].toDouble();
            final storeLng = json['store']['longitude'].toDouble();
            final distance = DistanceCalculator.calculateDistance(
                userLat, userLng, storeLat, storeLng);

            return OfferModel.fromJson(json, distance: distance);
          }).toList();

          // ترتيب العروض حسب المسافة
          offers.sort((a, b) => a.distance!.compareTo(b.distance!));

          return offers;
        }
      } else {
        throw Exception(
            'Failed to load offers: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load offers: ${e.toString()}');
    }
  }
}
