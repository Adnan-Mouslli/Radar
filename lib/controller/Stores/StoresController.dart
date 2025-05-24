import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:radar/core/class/statusrequest.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';
import 'package:radar/data/model/Store.dart';
import 'package:radar/view/pages/home/StoreDetailsScreen.dart';

class StoresController extends GetxController {
  final MyServices services = Get.find<MyServices>();

  // متغيرات حالة التحميل
  var statusRequest = StatusRequest.none.obs;

  // قائمة المتاجر
  var stores = <Store>[].obs;

  // متغيرات أخرى للبحث والتصفية
  var searchQuery = ''.obs;
  var selectedCity = 'الكل'.obs;
  var cities = <String>['الكل'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  // جلب المتاجر من API
  Future<void> fetchStores() async {
    try {
      statusRequest.value = StatusRequest.loading;

      final url = Uri.parse('${AppLink.server}/api/stores');

      // طباعة طلب API للتصحيح
      print('Fetching stores from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${services.getToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Connection timeout');
      });

      // محاولة تحليل الاستجابة لتحديد أي أخطاء تحويل
      try {
        final rawData = response.body;

        if (response.statusCode == 200) {
          final data = jsonDecode(rawData);

          final List<dynamic> storesData = data;
          print('Found ${storesData.length} stores in response');

          // معالجة كل متجر على حدة لتسهيل تحديد المشكلة
          final parsedStores = <Store>[];

          for (int i = 0; i < storesData.length; i++) {
            try {
              final storeJson = storesData[i];
              print('Processing store at index $i: ${storeJson['name']}');

              // التحقق من شكل _count قبل المعالجة
              if (storeJson['_count'] == null) {
                print('Warning: _count is null for store ${storeJson['name']}');
                // إضافة كائن _count افتراضي
                storeJson['_count'] = {"offers": 0, "contents": 0};
              } else if (storeJson['_count'] is! Map) {
                print(
                    'Warning: _count is not a Map for store ${storeJson['name']}, it is: ${storeJson['_count'].runtimeType}');
                // تحويل _count إلى كائن إذا كان غير ذلك
                storeJson['_count'] = {"offers": 0, "contents": 0};
              }

              final store = Store.fromJson(storeJson);
              parsedStores.add(store);
            } catch (e) {
              print('Error parsing store at index $i: $e');
              // استمر بالمعالجة حتى مع وجود خطأ في متجر واحد
              continue;
            }
          }

          // تحديث قائمة المتاجر
          stores.value = parsedStores;

          // استخراج المدن المتوفرة للفلترة
          _extractCities();

          statusRequest.value = StatusRequest.success;
        } else {
          print('Server responded with status code: ${response.statusCode}');
          statusRequest.value = StatusRequest.serverfailure;
        }
      } catch (e) {
        print('Error decoding or processing API response: $e');
        statusRequest.value = StatusRequest.serverfailure;
      }
    } catch (e) {
      print('Error fetching stores: $e');
      statusRequest.value = e.toString().contains('timeout') ||
              e.toString().contains('Connection')
          ? StatusRequest.offlinefailure
          : StatusRequest.serverfailure;
    }
  }

  // استخراج المدن الفريدة من المتاجر للفلترة
  void _extractCities() {
    final Set<String> uniqueCities = {'الكل'};
    for (var store in stores) {
      if (store.city.isNotEmpty) {
        uniqueCities.add(store.city);
      }
    }
    cities.value = uniqueCities.toList();
  }

  // الحصول على المتاجر المفلترة (بحسب المدينة والبحث)
  List<Store> get filteredStores {
    return stores.where((store) {
      // فلترة بحسب المدينة
      bool matchesCity =
          selectedCity.value == 'الكل' || store.city == selectedCity.value;

      // فلترة بحسب البحث
      bool matchesSearch = searchQuery.isEmpty ||
          store.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          store.address.toLowerCase().contains(searchQuery.value.toLowerCase());

      return matchesCity && matchesSearch;
    }).toList();
  }

  // تغيير المدينة المحددة للفلترة
  void changeCity(String city) {
    selectedCity.value = city;
  }

  // تغيير نص البحث
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // إعادة تحميل المتاجر
  void refreshStores() {
    fetchStores();
  }

  // فتح صفحة تفاصيل المتجر
  void openStoreDetails(Store store) {
    print('Opening store details for: ${store.name}');

    // الانتقال إلى صفحة تفاصيل المتجر مع تمرير بيانات المتجر
    Get.to(
      () => StoreDetailsScreen(),
      arguments: store, // تمرير بيانات المتجر كـ arguments
      transition: Transition.cupertino, // انتقال سلس
      duration: Duration(milliseconds: 300),
    );
  }
}

// دالة مساعدة
int min(int a, int b) {
  return a < b ? a : b;
}
