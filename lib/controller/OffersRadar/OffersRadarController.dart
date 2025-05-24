import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:radar/controller/OffersRadar/AppLifecycleController.dart';
import 'package:radar/core/services/LocationService.dart';
import 'package:radar/core/services/MapLauncherService.dart';
import 'package:radar/core/services/OffersService.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/data/model/OfferModel.dart';
import 'package:radar/data/model/ProvidenceModel.dart';
import 'package:radar/view/components/offers/OfferDetailsBottomSheet.dart';
import 'package:radar/view/components/ui/CustomDialog.dart';
import 'package:radar/view/components/ui/CustomToast.dart';

class OffersRadarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Services
  final OffersService _offersService = OffersService();
  final LocationService _locationService = Get.find<LocationService>();
  final MapLauncherService _mapLauncherService = Get.find<MapLauncherService>();

  // User location
  final Rx<Position?> userLocation = Rx<Position?>(null);

  // Search parameters
  final RxDouble currentRadius = 1.0.obs;
  final RxString selectedCategoryId =
      ''.obs; // معرف الفئة المحددة، يكون فارغاً عند اختيار "الكل"

  final RxString selectedCategory = 'الكل'.obs;

  final RxString selectedCategoryName = 'الكل'.obs; // اسم الفئة المحددة للعرض
  final RxList<CategoryModel> categories =
      <CategoryModel>[].obs; // قائمة الفئات كاملة مع ID والاسم

  // Sorting and filtering
  final RxString sortBy = 'distance'.obs; // 'distance', 'discount', 'price'
  final RxBool descendingOrder = false.obs;

  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isScanning = false.obs;
  final RxBool showOffersList = false.obs;
  final RxBool showRadarMode = false.obs;
  final RxBool lowBatteryMode = false.obs;
  final RxBool hasCompletedScan =
      false.obs; // Flag to track if a scan has been completed

  final RxBool hasFoundOffers = false.obs; // متغير جديد لتتبع وجود عروض

  // NEW: Enhanced Radar Animation State
  final RxBool isShowingRadarAnimation = false.obs;
  Timer? _radarDisplayTimer;

  // Offers data
  final RxList<OfferModel> discoveredOffers = <OfferModel>[].obs;

  // Animation controller for radar
  late AnimationController radarAnimationController;

  // Debouncer for radius changes
  final Debouncer _debouncer = Debouncer(
      delay: const Duration(
    milliseconds: 500,
  ));

  // Location updates subscription
  StreamSubscription<Position>? _locationSubscription;

  final RxList<ProvidenceModel> providences = <ProvidenceModel>[].obs;
  final Rx<ProvidenceModel?> selectedProvidence = Rx<ProvidenceModel?>(null);

  final Rx<ProvidenceModel?> tempSelectedProvidence =
      Rx<ProvidenceModel?>(null);

  // متغيرات مؤقتة للفلاتر غير المطبقة
  final RxString tempSelectedCategoryId = ''.obs;
  final RxString tempSelectedCategoryName = 'الكل'.obs;
  final RxDouble tempCurrentRadius = 1.0.obs;
  final RxString tempSortBy = 'distance'.obs;
  final RxBool tempDescendingOrder = false.obs;
  final RxBool hasFilterChanges = false.obs;

  void initTempFilters() {
    // تهيئة بسيطة للقيم المؤقتة من القيم الفعلية
    tempSelectedProvidence.value = selectedProvidence.value;
    tempSelectedCategoryId.value = selectedCategoryId.value;
    tempSelectedCategoryName.value = selectedCategoryName.value;
    tempCurrentRadius.value = currentRadius.value;
    tempSortBy.value = sortBy.value;
    tempDescendingOrder.value = descendingOrder.value;
  }

  void applyTempFilters() {
    // نقل القيم المؤقتة إلى القيم الفعلية بشكل مباشر
    selectedProvidence.value = tempSelectedProvidence.value;
    selectedCategoryId.value = tempSelectedCategoryId.value;
    selectedCategoryName.value = tempSelectedCategoryName.value;
    currentRadius.value = tempCurrentRadius.value;
    sortBy.value = tempSortBy.value;
    descendingOrder.value = tempDescendingOrder.value;

    hasFilterChanges.value = false;

    // تحديث واجهة المستخدم
    update();

    scanForOffers();
  }

  // تعديل دالة changeRadius لاستخدام المتغير المؤقت
  void changeRadius(double radius, {bool isTemp = true}) {
    if (isTemp) {
      // استخدام المتغير المؤقت في حالة الاستخدام داخل الفلتر
      tempCurrentRadius.value = radius;
    } else {
      // استخدام المتغير الفعلي في حالة الاستخدام في واجهة المستخدم الرئيسية
      currentRadius.value = radius;
      // تحديث المتغير المؤقت أيضًا للحفاظ على التزامن
      tempCurrentRadius.value = radius;
    }
  }

// تعديل دالة changeCategory لاستخدام المتغيرات المؤقتة
  void changeCategory(String id, String name, {bool isTemp = true}) {
    print('Changing category to: $id - $name, isTemp: $isTemp');

    if (isTemp) {
      // تغيير القيم المؤقتة فقط عند استخدامها داخل نافذة الفلتر
      tempSelectedCategoryId.value = id;
      tempSelectedCategoryName.value = name;
    } else {
      // تغيير القيم الفعلية عند استخدامها خارج نافذة الفلتر
      selectedCategoryId.value = id;
      selectedCategoryName.value = name;
      // تحديث القيم المؤقتة أيضًا للحفاظ على التزامن
      tempSelectedCategoryId.value = id;
      tempSelectedCategoryName.value = name;
    }

    // تحديث واجهة المستخدم
    update();
  }

// تعديل دالة changeProvidence لاستخدام المتغير المؤقت
  void changeProvidence(ProvidenceModel providence, {bool isTemp = true}) {
    print(
        'Changing providence to: ${providence.id} - ${providence.name}, isTemp: $isTemp');

    if (isTemp) {
      // تغيير القيمة المؤقتة فقط عند استخدامها داخل نافذة الفلتر
      tempSelectedProvidence.value = providence;
    } else {
      // تغيير القيمة الفعلية عند استخدامها خارج نافذة الفلتر
      selectedProvidence.value = providence;
      // تحديث القيمة المؤقتة أيضًا للحفاظ على التزامن
      tempSelectedProvidence.value = providence;
    }

    // تحديث واجهة المستخدم بشكل صريح
    update();
  }

// تعديل دالة changeSorting لاستخدام المتغيرات المؤقتة
  void changeSorting(String newSortBy) {
    // إذا تم النقر على نفس خيار الترتيب، قم بتبديل الترتيب (تصاعدي/تنازلي)
    if (tempSortBy.value == newSortBy) {
      tempDescendingOrder.toggle();
    } else {
      tempSortBy.value = newSortBy;
      tempDescendingOrder.value = false;
    }

    update();
  }

  @override
  void onInit() {
    super.onInit();

    providences.value = ProvidenceModel.getProvidences();

    selectedProvidence.value = providences.first; // 'موقعي الحالي'

    // Initialize radar animation controller
    radarAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    // Load categories first
    fetchCategories();

    ever(Get.find<AppLifecycleController>().isAppInForeground,
        (bool isInForeground) {
      if (isInForeground) {
        // التطبيق عاد للمقدمة - إعادة بدء تحديثات الموقع إذا لزم الأمر
        if (userLocation.value != null && _locationSubscription == null) {
          startLocationUpdates();
        }
      } else {
        // التطبيق ذهب للخلفية - إيقاف تحديثات الموقع
        stopLocationUpdates();
      }
    });

    // ما زلنا نحتفظ بفحص الموقع ولكن بدون بدء البحث
    Future.delayed(Duration(milliseconds: 500), () {
      _checkLocationPermissionWithoutScan();
    });

    // Check battery status
    checkBatteryStatus();
  }

  // دالة فحص الموقع بدون بدء البحث تلقائياً
  Future<void> _checkLocationPermissionWithoutScan() async {
    try {
      isLoading.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (serviceEnabled) {
        // استخدام الدالة المحسنة - بدون عرض ديالوج
        final hasPermission =
            await _locationService.requestPermission(showSettingsDialog: false);
        if (hasPermission) {
          getUserLocation(skipAutoScan: true);
        }
      }
    } catch (e) {
      print('Error checking location service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    // فقط نبدأ بتحديثات الموقع بدون البحث التلقائي
    startLocationUpdates();
  }

  @override
  void onClose() {
    // Cleanup
    stopLocationUpdates();
    radarAnimationController.dispose();
    _debouncer.cancel();

    if (_radarDisplayTimer != null) {
      _radarDisplayTimer!.cancel();
    }

    super.onClose();
  }

  // Check if location service is enabled
  Future<bool> checkAndRequestLocationService() async {
    try {
      isLoading.value = true;

      // استخدام الدالة المحسنة مع عرض ديالوج
      final hasPermission = await _locationService.requestPermission();

      if (hasPermission) {
        // إذا تم منح الإذن، نحصل على الموقع
        getUserLocation();
        return true;
      } else {
        // لم يتم منح الإذن - لا نحتاج لعرض رسالة هنا لأن الدالة المحسنة
        // ستعرض رسائل مناسبة
        return false;
      }
    } catch (e) {
      print('Error checking location service: $e');
      CustomToast.showErrorToast(
        message: 'حدث خطأ أثناء التحقق من خدمة الموقع',
        duration: Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch categories from API
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final fetchedCategories = await _offersService.getCategories();

      // إضافة فئة "الكل" في بداية القائمة
      categories.clear();
      categories
          .add(CategoryModel(id: '', name: 'الكل')); // استخدام معرف فارغ للكل
      categories.addAll(fetchedCategories);

      // اختيار "الكل" كقيمة افتراضية
      selectedCategoryId.value = '';
      selectedCategoryName.value = 'الكل';
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الفئات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get user's current location
  Future<void> getUserLocation({bool skipAutoScan = false}) async {
    try {
      isLoading.value = true;

      // استخدام الدالة المحسنة بدون عرض ديالوج
      final location = await _locationService.getCurrentLocation(
          requestPermissionIfNeeded: false);

      if (location != null) {
        userLocation.value = location;

        // تعديل الشرط هنا لتخطي البحث التلقائي عند فتح الواجهة
        if (!hasCompletedScan.value &&
            discoveredOffers.isEmpty &&
            !skipAutoScan) {
          scanForOffers();
        }
      } else {
        // Use CustomToast instead of defaults
        CustomToast.showWarningToast(
            message:
                'تعذر الحصول على موقعك الحالي، سيتم استخدام موقعك عند فتح خرائط جوجل',
            duration: Duration(seconds: 3));
      }
    } catch (e) {
      // استخدام CustomDialog بدلاً من Get.snackbar
      CustomToast.showErrorToast(
        message: 'فشل في تحديد موقعك',
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Start listening to location updates
  void startLocationUpdates() {
    // إيقاف أي اشتراكات سابقة
    stopLocationUpdates();

    // التحقق من وجود إذن الموقع
    if (userLocation.value == null) return;

    // إضافة: التحقق من أن التطبيق في المقدمة
    if (!Get.isRegistered<AppLifecycleController>()) {
      Get.put(AppLifecycleController());
    }

    // التحديثات تعمل فقط عندما يكون التطبيق في المقدمة
    final appLifecycleController = Get.find<AppLifecycleController>();
    if (!appLifecycleController.isAppInForeground.value) {
      print('التطبيق في الخلفية - لن يتم بدء تحديثات الموقع');
      return;
    }

    // استخدام فترة تحديث أطول لتقليل استهلاك البطارية
    final interval = Duration(minutes: 5); // زيادة الفترة الزمنية

    _locationSubscription = _locationService
        .getLocationStream(interval)
        .listen((Position newLocation) {
      // تحديث موقع المستخدم فقط إذا كان التطبيق في المقدمة
      if (appLifecycleController.isAppInForeground.value) {
        userLocation.value = newLocation;

        // تحديث العروض إذا تغير الموقع بشكل كبير
        if (discoveredOffers.isNotEmpty && !isScanning.value) {
          final distance = Geolocator.distanceBetween(
                  userLocation.value!.latitude,
                  userLocation.value!.longitude,
                  newLocation.latitude,
                  newLocation.longitude) /
              1000;

          if (distance > 0.5) {
            // زيادة المسافة المطلوبة لإعادة البحث
            refreshOffersWithNewLocation();
          }
        }
      } else {
        // إيقاف التحديثات إذا ذهب التطبيق للخلفية
        stopLocationUpdates();
      }
    });
  }

  // Calculate distance between two coordinates
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Convert to kilometers
  }

  // Stop location updates
  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // Refresh offers based on new location without UI changes
  void refreshOffersWithNewLocation() async {
    if (userLocation.value == null || isScanning.value) return;

    try {
      print(
          'Refreshing offers with new location: ${userLocation.value!.latitude}, ${userLocation.value!.longitude}');
      // تحديث المسافات للعروض الموجودة
      for (var offer in discoveredOffers) {
        offer.distance = calculateDistance(
          userLocation.value!.latitude,
          userLocation.value!.longitude,
          offer.store.latitude,
          offer.store.longitude,
        );
      }

      // إذا كان البحث حسب الموقع الحالي، نعيد البحث
      if (selectedProvidence.value?.id == 'CURRENT_LOCATION') {
        final filters = <String, dynamic>{
          'latitude': userLocation.value!.latitude,
          'longitude': userLocation.value!.longitude,
          'maxDistance': currentRadius.value,
        };

        if (selectedCategoryId.value.isNotEmpty) {
          filters['categoryId'] = selectedCategoryId.value;
        }

        final offers = await _offersService.getOffers(filters);

        // حساب المسافات للعروض الجديدة
        for (var offer in offers) {
          offer.distance = calculateDistance(
            userLocation.value!.latitude,
            userLocation.value!.longitude,
            offer.store.latitude,
            offer.store.longitude,
          );
        }

        discoveredOffers.assignAll(offers);
      }
    } catch (e) {
      print('Failed to refresh offers: ${e.toString()}');
    }
  }

  // Check device battery status
  void checkBatteryStatus() async {
    try {
      // In a real app, use battery_plus or device_info_plus to check battery
      // For now, just setting to false
      lowBatteryMode.value = false;

      // Adjust location updates based on battery status
      if (_locationSubscription != null) {
        stopLocationUpdates();
        startLocationUpdates();
      }
    } catch (e) {
      print('Failed to check battery status: ${e.toString()}');
    }
  }

  final RxBool showSuccessMessage = false.obs;

  void resetRadarView() {
    // إعادة ضبط حالة الرادار
    isShowingRadarAnimation.value = true;
    showRadarMode.value = true;
    showSuccessMessage.value = false;
    hasFoundOffers.value = false;

    // إيقاف أي مؤقت موجود
    if (_radarDisplayTimer != null) {
      _radarDisplayTimer!.cancel();
      _radarDisplayTimer = null;
    }
  }

  Future<void> scanForOffers() async {
    print('Scan initiated, user location: ${userLocation.value}');

    // الفحص إذا كان المستخدم يريد موقعه الحالي بينما موقعه غير متاح
    if (selectedProvidence.value?.id == 'CURRENT_LOCATION' &&
        userLocation.value == null) {
      showLocationPermissionDialog();
      return;
    }

    try {
      // التأكد من تفعيل عرض الرادار قبل أي شيء
      isShowingRadarAnimation.value = true;
      isLoading.value = true;
      isScanning.value = true;
      showSuccessMessage.value = false;
      hasFoundOffers.value = false;

      // بدء تحريك الرادار
      radarAnimationController.repeat();

      // تحضير وسائط الفلتر
      final filters = <String, dynamic>{};

      // إضافة معرف الفئة إذا كان محدداً
      if (selectedCategoryId.value.isNotEmpty) {
        filters['categoryId'] = selectedCategoryId.value;
      }

      // اختيار إحداثيات البحث بناءً على المحافظة المحددة
      if (selectedProvidence.value?.id == 'CURRENT_LOCATION') {
        // استخدام موقع المستخدم الحالي ونطاق البحث
        filters['latitude'] = userLocation.value!.latitude;
        filters['longitude'] = userLocation.value!.longitude;
        filters['maxDistance'] = currentRadius.value;
      } else {
        // استخدام معرف المدينة فقط عند اختيار مدينة محددة
        filters['city'] = selectedProvidence.value!.id;
      }

      // سجل التصحيح
      print('Scanning with filters: $filters');

      // تأخير قصير لإظهار تجربة البحث - تم تقليله إلى 1000 مللي ثانية فقط (ثانية واحدة)
      await Future.delayed(Duration(milliseconds: 1000));

      // جلب العروض باستخدام الفلتر
      final offers = await _offersService.getOffers(filters);

      // تعيين العثور على عروض بعد الحصول عليها مباشرة
      hasFoundOffers.value = true;

      // سجل التصحيح
      print('Found ${offers.length} offers');

      // حساب المسافات للعروض إذا كان لدينا موقع المستخدم
      if (userLocation.value != null) {
        for (var offer in offers) {
          offer.distance = calculateDistance(
            userLocation.value!.latitude,
            userLocation.value!.longitude,
            offer.store.latitude,
            offer.store.longitude,
          );
        }
      } else {
        // إذا لم يكن لدينا موقع، نجعل المسافة null
        for (var offer in offers) {
          offer.distance = null;
        }
      }

      // تحديث العروض المكتشفة
      discoveredOffers.assignAll(offers);

      // إظهار وضع الرادار لعرض النتائج - بدون تأخير
      showRadarMode.value = true;
      hasCompletedScan.value = true;
      isScanning.value = false;

      // إظهار رسالة النجاح فوراً
      showSuccessMessage.value = true;

      // إلغاء أي مؤقت موجود
      if (_radarDisplayTimer != null) {
        _radarDisplayTimer!.cancel();
      }

      // تأخير قصير لإخفاء الرادار بعد عرض النتائج - ثانيتان فقط
      _radarDisplayTimer = Timer(Duration(seconds: 2), () {
        isShowingRadarAnimation.value = false;
      });
    } catch (e) {
      print('Error scanning for offers: ${e.toString()}');
      CustomToast.showErrorToast(
          message: "فشل في البحث عن العروض", duration: Duration(seconds: 3));

      isScanning.value = false;
      isShowingRadarAnimation.value = false;
      showSuccessMessage.value = false;
      hasFoundOffers.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Open store location in Google Maps
  Future<void> openStoreLocation(OfferModel offer) async {
    await _mapLauncherService.openGoogleMaps(
      latitude: offer.store.latitude,
      longitude: offer.store.longitude,
      title: offer.store.name,
    );
  }

  // Get filtered and sorted offers
  List<OfferModel> getFilteredOffers() {
    // تطبيق فلتر الفئة
    List<OfferModel> filtered;
    if (selectedCategoryName.value == 'الكل') {
      filtered = List.from(discoveredOffers);
    } else {
      filtered = discoveredOffers
          .where((offer) => offer.category.name == selectedCategoryName.value)
          .toList();
    }

    // تطبيق الترتيب
    switch (sortBy.value) {
      case 'distance':
        // فقط الترتيب حسب المسافة إذا كان لدينا موقع
        if (userLocation.value != null) {
          filtered.sort((a, b) {
            // إذا كانت المسافة null، نضعها في النهاية
            if (a.distance == null && b.distance == null) return 0;
            if (a.distance == null) return 1;
            if (b.distance == null) return -1;

            return descendingOrder.value
                ? b.distance!.compareTo(a.distance!)
                : a.distance!.compareTo(b.distance!);
          });
        }
        break;
      case 'discount':
        filtered.sort((a, b) => descendingOrder.value
            ? a.discount.compareTo(b.discount)
            : b.discount.compareTo(a.discount));
        break;
      case 'price':
        filtered.sort((a, b) => descendingOrder.value
            ? b.priceAfterDiscount.compareTo(a.priceAfterDiscount)
            : a.priceAfterDiscount.compareTo(b.priceAfterDiscount));
        break;
    }

    return filtered;
  }

  // Get message for empty state
  String getEmptyStateMessage() {
    if (discoveredOffers.isEmpty && isScanning.value == false) {
      return "ابدأ البحث عن العروض القريبة";
    } else if (discoveredOffers.isEmpty) {
      if (selectedProvidence.value?.id == 'CURRENT_LOCATION') {
        return "لم يتم العثور على عروض في هذا النطاق";
      } else {
        return "لم يتم العثور على عروض في ${selectedProvidence.value!.name}";
      }
    } else if (getFilteredOffers().isEmpty &&
        selectedCategoryName.value != 'الكل') {
      if (selectedProvidence.value?.id == 'CURRENT_LOCATION') {
        return "لا توجد عروض في فئة ${selectedCategoryName.value} ضمن هذا النطاق";
      } else {
        return "لا توجد عروض في فئة ${selectedCategoryName.value} في ${selectedProvidence.value!.name}";
      }
    }
    return "حاول زيادة نطاق البحث أو تغيير الفئة أو المدينة";
  }

  // Toggle offers list view
  void toggleOffersList() {
    showOffersList.value = !showOffersList.value;
    if (showOffersList.value) {
      showRadarMode.value = false;
      radarAnimationController.stop();
      isShowingRadarAnimation.value = false; // NEW: Hide radar animation

      // Cancel any active radar display timer
      if (_radarDisplayTimer != null) {
        _radarDisplayTimer!.cancel();
        _radarDisplayTimer = null;
      }
    }
  }

  // Toggle radar view
  void toggleRadarMode() {
    showRadarMode.value = !showRadarMode.value;
    if (showRadarMode.value) {
      showOffersList.value = false;
      // Start radar animation when showing radar mode
      radarAnimationController.repeat();
      isShowingRadarAnimation.value = true; // NEW: Show radar animation
    } else {
      // Stop radar animation when hiding radar mode
      radarAnimationController.stop();
      isShowingRadarAnimation.value = false; // NEW: Hide radar animation

      // Cancel any active radar display timer
      if (_radarDisplayTimer != null) {
        _radarDisplayTimer!.cancel();
        _radarDisplayTimer = null;
      }
    }
  }

  // Format distance for display
  String formatDistance(double? distance) {
    if (distance == null) {
      return 'غير محدد';
    }

    if (distance < 1.0) {
      final meters = (distance * 1000).toInt();
      return '$meters متر';
    } else {
      return '${distance.toStringAsFixed(1)} كم';
    }
  }

  // Get directions to store in Google Maps
  Future<void> getDirectionsToStore(OfferModel offer) async {
    // Get user location if available
    if (userLocation.value != null) {
      await _mapLauncherService.openGoogleMapsDirections(
        startLatitude: userLocation.value!.latitude,
        startLongitude: userLocation.value!.longitude,
        destinationLatitude: offer.store.latitude,
        destinationLongitude: offer.store.longitude,
      );
    } else {
      // If user location isn't available, let Google Maps determine it
      await _mapLauncherService.openGoogleMapsDirections(
        destinationLatitude: offer.store.latitude,
        destinationLongitude: offer.store.longitude,
      );
    }
  }

  // Show offer details in bottom sheet
  void showOfferDetails(OfferModel offer) {
    Get.bottomSheet(
      OfferDetailsBottomSheet(offer: offer, controller: this),
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
    );
  }

  // Show location permission dialog
  void showLocationPermissionDialog() {
    // استخدام الدالة المحسنة مباشرة بدلاً من العرض اليدوي للديالوج
    checkAndRequestLocationService().then((hasPermission) {
      if (hasPermission) {
        // تم منح الإذن بنجاح، يمكننا المتابعة
        print('تم منح إذن الموقع بنجاح');
      } else {
        // استخدام CustomToast بدلاً من Get.snackbar
        CustomToast.showWarningToast(
          message: 'لن تتمكن من رؤية العروض القريبة بدون إذن الموقع',
          duration: Duration(seconds: 3),
        );
      }
    });
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
}
