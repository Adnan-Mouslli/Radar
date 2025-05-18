
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppLifecycleController extends GetxController with WidgetsBindingObserver {
  final RxBool isAppInForeground = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    // إضافة المراقب لدورة حياة التطبيق
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void onClose() {
    // إزالة المراقب عند إغلاق الـ Controller
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // التطبيق في المقدمة
        isAppInForeground.value = true;
        print('التطبيق في المقدمة - يمكن استخدام الموقع');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // التطبيق في الخلفية أو غير نشط
        isAppInForeground.value = false;
        print('التطبيق في الخلفية - إيقاف استخدام الموقع');
        break;
    }
  }
}