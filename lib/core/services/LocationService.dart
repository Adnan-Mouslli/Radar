import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/view/components/ui/CustomDialog.dart';
import 'package:radar/view/components/ui/CustomToast.dart';

class LocationService extends GetxService {
  // Keys for SharedPreferences
  static const String _hasAskedPermissionKey = 'has_asked_location_permission';
  
  // Observable state for location permission
  final RxBool hasLocationPermission = false.obs;
  
  // الدالة التي تُستدعى عند تسجيل الخدمة
  Future<LocationService> init() async {
    print('تم بدء خدمة الموقع');
    
    // Check if we already have permissions on startup
    LocationPermission permission = await Geolocator.checkPermission();
    hasLocationPermission.value = (permission == LocationPermission.whileInUse || 
                                  permission == LocationPermission.always);
    
    return this;
  }
  
  // التحقق من حالة إذن الوصول إلى الموقع
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }
  
  // التحقق مما إذا كان قد تم طلب الإذن من قبل
  Future<bool> _hasAskedForPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasAskedPermissionKey) ?? false;
  }
  
  // تحديث حالة طلب الإذن
  Future<void> _setHasAskedForPermission(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasAskedPermissionKey, value);
  }
  
  // طلب إذن الوصول إلى الموقع - محسن ومبسط
  Future<bool> requestPermission({bool showSettingsDialog = true}) async {
    try {
      print('التحقق من صلاحية الموقع...');
      
      // 1. تحقق أولاً من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        print('خدمة الموقع غير مفعلة');
        
        // عرض ديالوج فقط إذا كان مطلوبًا
        if (showSettingsDialog) {
          bool openSettings = await _showLocationServiceDialog();
          if (openSettings) {
            await Geolocator.openLocationSettings();
            // نتحقق مرة أخرى بعد العودة من الإعدادات
            serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
      
      // 2. تحقق من إذن الوصول إلى الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      
      // 3. إذا كان لدينا بالفعل إذن، فلا داعي للمتابعة
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        print('تم منح إذن الوصول إلى الموقع مسبقاً');
        hasLocationPermission.value = true;
        return true;
      }
      
      // 4. إذا تم رفض الإذن نهائيًا، نعرض ديالوج الإعدادات
      if (permission == LocationPermission.deniedForever) {
        print('تم رفض إذن الوصول نهائياً');
        
        // عرض ديالوج الإعدادات فقط إذا كان مطلوبًا
        if (showSettingsDialog) {
          bool openSettings = await _showPermissionDeniedForeverDialog();
          if (openSettings) {
            await Geolocator.openAppSettings();
            // نتحقق مرة أخرى بعد العودة من الإعدادات
            permission = await Geolocator.checkPermission();
            hasLocationPermission.value = (permission == LocationPermission.whileInUse || 
                                          permission == LocationPermission.always);
            return hasLocationPermission.value;
          }
        }
        return false;
      }
      
      // 5. إذا لم يتم طلب الإذن من قبل أو تم رفضه، نطلب الإذن
      bool hasAskedBefore = await _hasAskedForPermission();
      
      if (permission == LocationPermission.denied) {
        // إذا لم نطلب من قبل، أو كان showSettingsDialog = true (طلب صريح)
        if (!hasAskedBefore || showSettingsDialog) {
          // إذا كان طلب صريح، نعرض ديالوج مخصص أولاً
          if (showSettingsDialog && !hasAskedBefore) {
            bool shouldAskPermission = await _showPermissionRequestDialog();
            if (!shouldAskPermission) {
              // المستخدم لا يريد منح الإذن
              await _setHasAskedForPermission(true); // نحفظ أننا طلبنا الإذن
              return false;
            }
          }
          
          // طلب إذن الموقع من النظام
          permission = await Geolocator.requestPermission();
          await _setHasAskedForPermission(true); // تحديث حالة الطلب
          
          hasLocationPermission.value = (permission == LocationPermission.whileInUse || 
                                        permission == LocationPermission.always);
          return hasLocationPermission.value;
        }
        
        // إذا سبق وطلبنا الإذن وتم رفضه، ولا نريد عرض ديالوج، نرجع false
        return false;
      }
      
      return false;
    } catch (e) {
      print('خطأ في طلب إذن الوصول: $e');
      return false;
    }
  }
  
  // الحصول على الموقع الحالي مع التحقق من الإذن أولاً (بدون عرض ديالوج)
  Future<Position?> getCurrentLocation({bool requestPermissionIfNeeded = false}) async {
    try {
      print('جاري محاولة الحصول على الموقع الحالي...');
      
      // تحقق من إذن الوصول
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        
        // إذا كان مطلوباً طلب الإذن، نحاول ذلك
        if (requestPermissionIfNeeded) {
          bool hasPermission = await requestPermission();
          if (!hasPermission) {
            print('لم يتم منح إذن الوصول إلى الموقع');
            return null;
          }
        } else {
          print('لا يوجد إذن للوصول إلى الموقع');
          return null;
        }
      }
      
      // محاولة الحصول على آخر موقع معروف أولاً للتسريع
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      
      if (lastKnownPosition != null) {
        print('تم الحصول على آخر موقع معروف: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}');
      }
      
      // الحصول على الموقع الحالي بدقة عالية
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15), // حد زمني لتجنب التعليق
      );
      
      print('تم الحصول على الموقع الحالي: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
      CustomToast.showErrorToast(
        message: 'تعذر الحصول على الموقع. الرجاء المحاولة مرة أخرى',
        duration: Duration(seconds: 3),
      );
      return null;
    }
  }
  
  // ديالوج طلب تفعيل خدمة الموقع
  Future<bool> _showLocationServiceDialog() async {
    // استخدام CustomDialog بدلاً من Get.dialog
    final completer = Completer<bool>();
    
    CustomDialog.show(
      title: 'خدمة الموقع معطلة',
      message: 'يرجى تفعيل GPS لتتمكن من استخدام ميزات تحديد الموقع والبحث عن العروض القريبة',
      icon: Icons.location_off,
      iconColor: Colors.amber,
      confirmButtonColor: AppColors.primary,
      cancelText: 'لاحقاً',
      confirmText: 'فتح الإعدادات',
      onCancel: () {
        completer.complete(false);
      },
      onConfirm: () {
        completer.complete(true);
      },
    );
    
    return await completer.future;
  }
  
  // ديالوج طلب الإذن من المستخدم
  Future<bool> _showPermissionRequestDialog() async {
    // استخدام CustomDialog بدلاً من Get.dialog
    final completer = Completer<bool>();
    
    CustomDialog.show(
      title: 'إذن الوصول إلى الموقع',
      message: 'يحتاج التطبيق إلى الوصول إلى موقعك لعرض العروض القريبة منك. هل تسمح بذلك؟',
      icon: Icons.location_on,
      iconColor: Colors.green,
      confirmButtonColor: AppColors.primary,
      cancelText: 'لا',
      confirmText: 'نعم',
      onCancel: () {
        completer.complete(false);
      },
      onConfirm: () {
        completer.complete(true);
      },
    );
    
    return await completer.future;
  }
  
  // ديالوج إظهار أن الإذن مرفوض نهائيًا
  Future<bool> _showPermissionDeniedForeverDialog() async {
    // استخدام CustomDialog بدلاً من Get.dialog
    final completer = Completer<bool>();
    
    CustomDialog.show(
      title: 'الوصول إلى الموقع مرفوض',
      message: 'تم رفض إذن الوصول إلى الموقع. لاستخدام هذه الميزة، يرجى السماح بالوصول إلى موقعك من إعدادات التطبيق.',
      icon: Icons.location_disabled,
      iconColor: Colors.red,
      confirmButtonColor: AppColors.primary,
      cancelText: 'لاحقاً',
      confirmText: 'فتح الإعدادات',
      onCancel: () {
        completer.complete(false);
      },
      onConfirm: () {
        completer.complete(true);
      },
    );
    
    return await completer.future;
  }
  
  // الحصول على تيار تحديثات الموقع
  Stream<Position> getLocationStream(Duration interval) {
    try {
      print('بدء الاستماع إلى تحديثات الموقع');
      
      // إعدادات تحديد الموقع
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // زيادة المسافة لتقليل التحديثات
      );
      
      // إرجاع تيار تحديثات الموقع
      return Geolocator.getPositionStream(locationSettings: locationSettings);
    } catch (e) {
      print('خطأ في بدء استماع الموقع: $e');
      // إرجاع تيار فارغ في حالة حدوث خطأ
      return Stream.empty();
    }
  }
  
  // فتح إعدادات الموقع في الجهاز
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('خطأ في فتح إعدادات الموقع: $e');
      CustomToast.showErrorToast(
        message: 'تعذر فتح إعدادات الموقع',
        duration: Duration(seconds: 3),
      );
      return false;
    }
  }
  
  // فتح إعدادات التطبيق
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      print('خطأ في فتح إعدادات التطبيق: $e');
      CustomToast.showErrorToast(
        message: 'تعذر فتح إعدادات التطبيق',
        duration: Duration(seconds: 3),
      );
      return false;
    }
  }
  
  // محو حالة طلب الإذن - مفيد للاختبار أو إعادة ضبط التطبيق
  Future<void> resetPermissionState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasAskedPermissionKey);
    CustomToast.showSuccessToast(
      message: 'تم إعادة ضبط حالة طلب الإذن',
      duration: Duration(seconds: 2),
    );
  }
}