import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:radar/core/class/statusrequest.dart';
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';
import 'package:radar/data/model/Store.dart';
import 'package:radar/data/model/OfferModel.dart';

class StoreDetailsController extends GetxController {
  final MyServices services = Get.find<MyServices>();
  
  // المتجر المحدد
  late Store store;
  
  // متغيرات حالة التحميل
  var statusRequest = StatusRequest.none.obs;
  
  // قائمة العروض
  var offers = <OfferModel>[].obs;
  
  // متغيرات البحث والتصفية
  var searchQuery = ''.obs;
  var selectedCategory = 'الكل'.obs;
  var categories = <String>['الكل'].obs;

  @override
  void onInit() {
    super.onInit();
    // الحصول على بيانات المتجر من الـ arguments
    if (Get.arguments != null && Get.arguments is Store) {
      store = Get.arguments as Store;
      fetchStoreOffers();
    }
  }

  // جلب عروض المتجر من API
  Future<void> fetchStoreOffers() async {
    try {
      statusRequest.value = StatusRequest.loading;

      final url = Uri.parse('${AppLink.server}/api/offers/store/${store.id}');

      print('Fetching store offers from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${services.getToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Connection timeout');
      });

      if (response.statusCode == 200) {
        final List<dynamic> offersData = jsonDecode(response.body);
        print('Found ${offersData.length} offers for store ${store.name}');

        // معالجة كل عرض على حدة
        final parsedOffers = <OfferModel>[];

        for (int i = 0; i < offersData.length; i++) {
          try {
            final offerJson = offersData[i];
            print('Processing offer at index $i: ${offerJson['title']}');

            // التأكد من وجود بيانات المتجر في العرض
            if (offerJson['store'] == null) {
              offerJson['store'] = {
                'id': store.id,
                'name': store.name,
                'address': store.address,
                'city': store.city,
                'image': store.image,
                'latitude': store.latitude,
                'longitude': store.longitude,
                'phone': store.phone,
                'isActive': store.isActive,
                'createdAt': store.createdAt.toIso8601String(),
                'updatedAt': store.updatedAt.toIso8601String(),
              };
            }

            final offer = OfferModel.fromJson(offerJson);
            parsedOffers.add(offer);
          } catch (e) {
            print('Error parsing offer at index $i: $e');
            continue;
          }
        }

        offers.value = parsedOffers;
        _extractCategories();
        statusRequest.value = StatusRequest.success;
      } else {
        print('Server responded with status code: ${response.statusCode}');
        statusRequest.value = StatusRequest.serverfailure;
      }
    } catch (e) {
      print('Error fetching store offers: $e');
      statusRequest.value = e.toString().contains('timeout') ||
              e.toString().contains('Connection')
          ? StatusRequest.offlinefailure
          : StatusRequest.serverfailure;
    }
  }

  // استخراج الفئات الفريدة من العروض للفلترة
  void _extractCategories() {
    final Set<String> uniqueCategories = {'الكل'};
    for (var offer in offers) {
      if (offer.category.name.isNotEmpty) {
        uniqueCategories.add(offer.category.name);
      }
    }
    categories.value = uniqueCategories.toList();
  }

  // الحصول على العروض المفلترة
  List<OfferModel> get filteredOffers {
    return offers.where((offer) {
      // فلترة بحسب الفئة
      bool matchesCategory = selectedCategory.value == 'الكل' || 
          offer.category.name == selectedCategory.value;

      // فلترة بحسب البحث
      bool matchesSearch = searchQuery.isEmpty ||
          offer.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          offer.description.toLowerCase().contains(searchQuery.value.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // تغيير الفئة المحددة للفلترة
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  // تغيير نص البحث
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // إعادة تحميل العروض
  void refreshOffers() {
    fetchStoreOffers();
  }

  // فتح صفحة تفاصيل العرض
  void openOfferDetails(OfferModel offer) {
    // TODO: قم بتنفيذ الانتقال إلى صفحة تفاصيل العرض
    // Get.to(() => OfferDetailsScreen(offer: offer));

    print('Opening offer: ${offer.title}');
    Get.snackbar(
      'تفاصيل العرض',
      'تم النقر على عرض ${offer.title}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  String getCurrencySymbol(String? priceType) {
    const symbols = {
      'SYP': 'ل.س',
      'USD': '\$',
      'EUR': '€',
      'TRY': '₺',
      'GBP': '£',
      'SAR': 'ر.س',
      'AED': 'د.إ',
    };
    return symbols[priceType] ?? '';
  }

  
  // دالة للرجوع للخلف
  void goBack() {
    Get.back();
  }
}