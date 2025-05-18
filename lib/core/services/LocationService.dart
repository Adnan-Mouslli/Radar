import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService extends GetxService {
  // الدالة التي تُستدعى عند تسجيل الخدمة
  Future<LocationService> init() async {
    print('تم بدء خدمة الموقع - المقدمة فقط');
    return this;
  }
  
  // التحقق من حالة إذن الوصول إلى الموقع
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }
  
  // طلب إذن الوصول إلى الموقع - المقدمة فقط
  Future<bool> requestPermission() async {
    try {
      print('جاري طلب إذن الوصول إلى الموقع (المقدمة فقط)...');
      
      // تحقق أولاً من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('حالة خدمة الموقع: $serviceEnabled');
      
      if (!serviceEnabled) {
        print('خدمة الموقع غير مفعلة');
        return false;
      }
      
      // تحقق من إذن الوصول إلى الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      print('حالة إذن الوصول الحالية: $permission');
      
      if (permission == LocationPermission.denied) {
        // طلب إذن الموقع في المقدمة فقط
        permission = await Geolocator.requestPermission();
        print('حالة إذن الوصول بعد الطلب: $permission');
        
        if (permission == LocationPermission.denied) {
          print('تم رفض إذن الوصول');
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('تم رفض إذن الوصول نهائياً');
        // يمكن هنا توجيه المستخدم إلى إعدادات التطبيق
        return false;
      }
      
      // نقبل فقط إذن الموقع في المقدمة (while in use)
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        print('تم منح إذن الوصول إلى الموقع في المقدمة');
        return true;
      }
      
      return false;
    } catch (e) {
      print('خطأ في طلب إذن الوصول: $e');
      return false;
    }
  }
  
  // الحصول على الموقع الحالي - فقط عندما يكون التطبيق في المقدمة
  Future<Position?> getCurrentLocation() async {
    try {
      print('جاري محاولة الحصول على الموقع الحالي (المقدمة فقط)...');
      
      // تحقق من إذن الوصول
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        print('لا يوجد إذن للوصول إلى الموقع');
        return null;
      }
      
      // محاولة الحصول على آخر موقع معروف أولاً للتسريع
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      
      if (lastKnownPosition != null) {
        print('تم الحصول على آخر موقع معروف: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}');
      }
      
      // الحصول على الموقع الحالي بدقة عالية - فقط في المقدمة
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15), // حد زمني لتجنب التعليق
      );
      
      print('تم الحصول على الموقع الحالي: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
      return null;
    }
  }
  
  // الحصول على تيار تحديثات الموقع - فقط عندما يكون التطبيق في المقدمة
  Stream<Position> getLocationStream(Duration interval) {
    try {
      print('بدء الاستماع إلى تحديثات الموقع (المقدمة فقط)');
      
      // إعدادات تحديد الموقع للمقدمة فقط
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
      return false;
    }
  }
  
  // فتح إعدادات التطبيق
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      print('خطأ في فتح إعدادات التطبيق: $e');
      return false;
    }
  }
  
  // توفير وسيلة للتحقق من خدمة الموقع مع عرض ديالوج للمستخدم
  Future<bool> checkAndRequestLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      // عرض ديالوج للمستخدم
      bool shouldOpenSettings = await Get.dialog(
        AlertDialog(
          title: Text('خدمة الموقع معطلة'),
          content: Text('يرجى تفعيل GPS لتتمكن من استخدام ميزات تحديد الموقع أثناء استخدام التطبيق'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('فتح الإعدادات'),
            ),
          ],
        ),
      ) ?? false;
      
      if (shouldOpenSettings) {
        return await openLocationSettings();
      }
      return false;
    }
    
    return true;
  }
}