// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cached_video_player/cached_video_player.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

// /// مدير للتعامل مع تشغيل الفيديو والتخزين المؤقت
// class CachedVideoManager {
//   // خريطة لتخزين مشغلات الفيديو النشطة
//   final Map<String, CachedVideoPlayerController> _controllers = {};
  
//   // خريطة لتخزين حالات التشغيل
//   final Map<String, bool> _playingStates = {};
  
//   // خريطة لتخزين نسب أبعاد الفيديو
//   final Map<String, double> _aspectRatios = {};
  
//   // خريطة للمتحكمات قيد التحميل
//   final Map<String, Completer<CachedVideoPlayerController>> _loadingControllers = {};
  
//   // معرف الفيديو النشط حاليًا
//   String? _activeVideoId;
  
//   // حد أقصى للمتحكمات النشطة في وقت واحد
//   final int _maxActiveControllers;
  
//   // الحد الأقصى للتحميل المسبق
//   final int _maxPreloadItems;
  
//   // حالة كتم الصوت
//   final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);
  
//   // حالة الاتصال الحالية
//   ConnectivityResult _connectionType = ConnectivityResult.none;
  
//   CachedVideoManager({
//     int maxActiveControllers = 4,
//     int maxPreloadItems = 2,
//   }) : 
//     _maxActiveControllers = maxActiveControllers,
//     _maxPreloadItems = maxPreloadItems {
//     // بدء مراقبة الاتصال
//     _setupConnectivityListener();
//   }
  
//   /// تهيئة مراقبة الاتصال
//   void _setupConnectivityListener() {
//     Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//       _connectionType = result;
//       // يمكن تعديل استراتيجية التحميل المسبق بناءً على نوع الاتصال
//       _adjustSettingsForConnectionType(result);
//     });
    
//     // التحقق من الاتصال الحالي
//     Connectivity().checkConnectivity().then((result) {
//       _connectionType = result;
//       _adjustSettingsForConnectionType(result);
//     });
//   }
  
//   /// تعديل الإعدادات بناءً على نوع الاتصال
//   void _adjustSettingsForConnectionType(ConnectivityResult type) {
//     // يمكن تعديل الإعدادات هنا، مثل:
//     // - عدد الفيديوهات للتحميل المسبق
//     // - جودة الفيديو
//     // - حجم التخزين المؤقت
//     if (type == ConnectivityResult.mobile) {
//       // على اتصال الجوال، قلل من التحميل المسبق
//       print('🔄 اتصال جوال: تقليل التحميل المسبق');
//     } else if (type == ConnectivityResult.wifi) {
//       // على اتصال واي فاي، يمكن زيادة التحميل المسبق
//       print('🔄 اتصال واي فاي: زيادة التحميل المسبق');
//     } else {
//       // في حالة عدم وجود اتصال، تعطيل التحميل المسبق
//       print('🔄 لا يوجد اتصال: تعطيل التحميل المسبق');
//     }
//   }
  
//   /// التحقق من بطء الاتصال
//   bool isSlowConnection() {
//     return _connectionType == ConnectivityResult.mobile || 
//            _connectionType == ConnectivityResult.none;
//   }
  
//   /// إنشاء وتهيئة متحكم فيديو جديد
//   Future<CachedVideoPlayerController> initializeVideo(
//       String id, String url, [String? posterUrl]) async {
//     // إذا كان هناك طلب تحميل قيد التنفيذ، انتظر اكتماله
//     if (_loadingControllers.containsKey(id)) {
//       return _loadingControllers[id]!.future;
//     }
    
//     // إذا كان المتحكم موجودًا ومهيأ بالفعل، استخدمه
//     if (_controllers.containsKey(id)) {
//       final controller = _controllers[id]!;
//       if (controller.value.isInitialized) {
//         // إعادة تعيين الفيديو للبداية
//         await controller.seekTo(Duration.zero);
//         // حفظ المعرف النشط
//         _activeVideoId = id;
//         return controller;
//       }
//     }
    
//     // إنشاء متعقب جديد للتحميل
//     final completer = Completer<CachedVideoPlayerController>();
//     _loadingControllers[id] = completer;
    
//     // تنظيف المتحكمات غير المستخدمة إذا وصلنا للحد الأقصى
//     await _cleanupControllersIfNeeded();
    
//     try {
//       // إنشاء متحكم جديد
//       final controller = CachedVideoPlayerController.network(
//         url,
//         // خيارات متقدمة لتحسين أداء التحميل
//         videoPlayerOptions: VideoPlayerOptions(
//           mixWithOthers: false,
//           allowBackgroundPlayback: false,
//         ),
//       );
      
//       // تهيئة المتحكم
//       await controller.initialize();
      
//       // ضبط إعادة التشغيل وكتم الصوت
//       await controller.setLooping(true);
//       await controller.setVolume(isMuted.value ? 0.0 : 1.0);
      
//       // حفظ المتحكم في الخريطة
//       _controllers[id] = controller;
//       _playingStates[id] = false;
      
//       // حفظ نسبة الأبعاد
//       if (controller.value.isInitialized && 
//           controller.value.size != null &&
//           controller.value.size!.width > 0 &&
//           controller.value.size!.height > 0) {
//         _aspectRatios[id] = controller.value.aspectRatio;
//       } else {
//         // نسبة افتراضية إذا لم تتوفر الأبعاد
//         _aspectRatios[id] = 16.0 / 9.0;
//       }
      
//       // تعيين الفيديو النشط
//       _activeVideoId = id;
      
//       // إكمال المتعقب
//       completer.complete(controller);
//     } catch (e) {
//       print('❌ خطأ في تهيئة الفيديو: $e');
//       completer.completeError(e);
//     } finally {
//       // إزالة المتعقب من القائمة
//       _loadingControllers.remove(id);
//     }
    
//     return completer.future;
//   }
  
//   /// التحميل المسبق للفيديو دون تشغيله
//   Future<void> preloadVideo(String id, String url, [String? posterUrl]) async {
//     // تجاهل التحميل المسبق إذا كان المتحكم موجودًا بالفعل
//     if (_controllers.containsKey(id)) {
//       return;
//     }
    
//     // تجاهل التحميل المسبق إذا كان الاتصال بطيئًا وتخطي بعض الفيديوهات
//     if (isSlowConnection() && _controllers.length >= _maxPreloadItems) {
//       print('⏩ تخطي التحميل المسبق لـ $id بسبب بطء الاتصال');
//       return;
//     }
    
//     try {
//       // تنظيف غير المستخدم أولاً
//       await _cleanupControllersIfNeeded();
      
//       // للاتصالات البطيئة: تنزيل جزء صغير فقط من الفيديو
//       if (isSlowConnection()) {
//         await _preloadPartialVideoData(url);
//         return;
//       }
      
//       // إنشاء المتحكم ولكن بدون تهيئة كاملة - فقط تحميل البيانات الأولية
//       final controller = CachedVideoPlayerController.network(
//         url,
//         videoPlayerOptions: VideoPlayerOptions(
//           mixWithOthers: false,
//           allowBackgroundPlayback: false,
//         ),
//       );
      
//       // تهيئة أساسية فقط
//       await controller.initialize();
      
//       // حفظ المتحكم
//       _controllers[id] = controller;
//       _playingStates[id] = false;
      
//       print('✅ تم التحميل المسبق لـ $id');
//     } catch (e) {
//       print('⚠️ فشل التحميل المسبق لـ $id: $e');
//     }
//   }
  
//   /// تنظيف المتحكمات غير المستخدمة إذا تجاوزنا الحد الأقصى
//   Future<void> _cleanupControllersIfNeeded() async {
//     if (_controllers.length < _maxActiveControllers) {
//       return;
//     }
    
//     // الاحتفاظ بالمتحكم النشط
//     final controllersToKeep = <String>[];
//     if (_activeVideoId != null) {
//       controllersToKeep.add(_activeVideoId!);
//     }
    
//     // قائمة المتحكمات للإزالة
//     final controllersToRemove = _controllers.keys
//         .where((id) => !controllersToKeep.contains(id))
//         .toList();
    
//     // حذف المتحكمات الأقدم أولاً
//     if (controllersToRemove.isNotEmpty) {
//       final idToRemove = controllersToRemove.first;
//       await disposeController(idToRemove);
//     }
//   }
  
//   /// التحميل المسبق لجزء من بيانات الفيديو
//   Future<void> _preloadPartialVideoData(String url) async {
//     try {
//       final client = http.Client();
//       final request = http.Request('GET', Uri.parse(url));
//       // طلب أول 300 كيلوبايت فقط من الفيديو
//       request.headers['Range'] = 'bytes=0-307200';
      
//       final response = await client.send(request);
      
//       if (response.statusCode == 206 || response.statusCode == 200) {
//         // نجاح في تحميل الجزء الأول من الفيديو
//         print('✅ تم تحميل جزء من الفيديو مسبقًا: ${response.contentLength} بايت');
//       }
      
//       client.close();
//     } catch (e) {
//       print('⚠️ فشل تحميل جزء من الفيديو: $e');
//     }
//   }
  
//   /// تشغيل الفيديو
//   Future<void> playVideo(String id) async {
//     if (!_controllers.containsKey(id)) {
//       print('⚠️ محاولة تشغيل فيديو غير مهيأ: $id');
//       return;
//     }
    
//     // إيقاف جميع الفيديوهات الأخرى
//     await stopAllVideosExcept(id);
    
//     try {
//       // الحصول على المتحكم
//       final controller = _controllers[id]!;
      
//       // ضبط الصوت
//       await controller.setVolume(isMuted.value ? 0.0 : 1.0);
      
//       // تشغيل الفيديو
//       await controller.play();
      
//       // تحديث الحالة
//       _playingStates[id] = true;
//       _activeVideoId = id;
//     } catch (e) {
//       print('❌ خطأ في تشغيل الفيديو: $e');
//     }
//   }
  
//   /// إيقاف الفيديو
//   Future<void> pauseVideo(String id) async {
//     if (!_controllers.containsKey(id)) {
//       return;
//     }
    
//     try {
//       // الحصول على المتحكم
//       final controller = _controllers[id]!;
      
//       // إيقاف الفيديو
//       await controller.pause();
      
//       // تحديث الحالة
//       _playingStates[id] = false;
//     } catch (e) {
//       print('❌ خطأ في إيقاف الفيديو: $e');
//     }
//   }
  
//   /// إيقاف جميع الفيديوهات عدا واحد
//   Future<void> stopAllVideosExcept(String? exceptId) async {
//     // قائمة المعرفات للإيقاف
//     final idsToStop = _controllers.keys
//         .where((id) => id != exceptId)
//         .toList();
    
//     for (final id in idsToStop) {
//       // كتم الصوت أولاً ثم الإيقاف
//       try {
//         final controller = _controllers[id]!;
//         await controller.setVolume(0.0);
//         await controller.pause();
//         _playingStates[id] = false;
//       } catch (e) {
//         print('⚠️ خطأ في إيقاف الفيديو $id: $e');
//       }
//     }
//   }
  
//   /// تبديل حالة تشغيل الفيديو
//   Future<void> toggleVideoPlayback(String id) async {
//     if (!_controllers.containsKey(id)) {
//       return;
//     }
    
//     final isPlaying = _playingStates[id] ?? false;
    
//     if (isPlaying) {
//       await pauseVideo(id);
//     } else {
//       await playVideo(id);
//     }
//   }
  
//   /// تبديل حالة كتم الصوت
//   Future<void> toggleMute() async {
//     isMuted.value = !isMuted.value;
    
//     // تطبيق حالة كتم الصوت على الفيديو النشط
//     if (_activeVideoId != null && _controllers.containsKey(_activeVideoId!)) {
//       await _controllers[_activeVideoId!]!.setVolume(isMuted.value ? 0.0 : 1.0);
//     }
//   }
  
//   /// التخلص من متحكم
//   Future<void> disposeController(String id) async {
//     if (!_controllers.containsKey(id)) {
//       return;
//     }
    
//     try {
//       // الحصول على المتحكم
//       final controller = _controllers[id]!;
      
//       // إيقاف الفيديو وكتم الصوت أولاً
//       await controller.setVolume(0.0);
//       await controller.pause();
      
//       // التخلص من المتحكم
//       await controller.dispose();
      
//       // إزالة من الخرائط
//       _controllers.remove(id);
//       _playingStates.remove(id);
//       _aspectRatios.remove(id);
      
//       // مسح المعرف النشط إذا كان هو المتحكم الذي تم التخلص منه
//       if (_activeVideoId == id) {
//         _activeVideoId = null;
//       }
//     } catch (e) {
//       print('❌ خطأ في التخلص من المتحكم: $e');
//     }
//   }
  
//   /// التخلص من جميع المتحكمات
//   Future<void> disposeAllControllers() async {
//     // نسخ المفاتيح لتجنب التعديل أثناء التكرار
//     final ids = _controllers.keys.toList();
    
//     for (final id in ids) {
//       await disposeController(id);
//     }
    
//     // مسح جميع الخرائط
//     _controllers.clear();
//     _playingStates.clear();
//     _aspectRatios.clear();
//     _activeVideoId = null;
//   }
  
//   /// التحقق مما إذا كان الفيديو مهيأ
//   bool isVideoInitialized(String id) {
//     if (!_controllers.containsKey(id)) {
//       return false;
//     }
    
//     return _controllers[id]!.value.isInitialized;
//   }
  
//   /// التحقق مما إذا كان الفيديو قيد التشغيل
//   bool isVideoPlaying(String id) {
//     if (!_controllers.containsKey(id)) {
//       return false;
//     }
    
//     return _playingStates[id] ?? false;
//   }
  
//   /// الحصول على نسبة أبعاد الفيديو
//   double? getVideoAspectRatio(String id) {
//     return _aspectRatios[id];
//   }
  
//   /// الحصول على المتحكم للفيديو
//   CachedVideoPlayerController? getController(String id) {
//     return _controllers[id];
//   }
  
//   /// التحميل المسبق للفيديوهات المجاورة
//   Future<void> preloadAdjacentVideos(
//       int currentIndex, List<String> ids, List<String> urls) async {
//     // تجاهل التحميل المسبق إذا كان الاتصال بطيئًا
//     if (isSlowConnection() && _connectionType == ConnectivityResult.mobile) {
//       // على الاتصال الخلوي، نقوم بتحميل فيديو واحد فقط مسبقًا
//       int nextIndex = currentIndex + 1;
//       if (nextIndex < ids.length) {
//         await preloadVideo(ids[nextIndex], urls[nextIndex]);
//       }
//       return;
//     }
    
//     // تحميل مسبق للفيديو التالي بشكل أساسي
//     int nextIndex = currentIndex + 1;
//     if (nextIndex < ids.length) {
//       await preloadVideo(ids[nextIndex], urls[nextIndex]);
//     }
    
//     // تحميل مسبق للفيديو السابق (إذا كان متاحًا وكان الاتصال جيدًا)
//     if (_connectionType == ConnectivityResult.wifi) {
//       int prevIndex = currentIndex - 1;
//       if (prevIndex >= 0) {
//         await preloadVideo(ids[prevIndex], urls[prevIndex]);
//       }
//     }
//   }
// }