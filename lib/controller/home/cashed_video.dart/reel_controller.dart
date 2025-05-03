// import 'dart:async';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cached_video_player/cached_video_player.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:radar/core/services/GemService.dart';
// import 'package:radar/core/services/ReelsApiService.dart';
// import 'package:radar/core/theme/app_colors.dart';
// import 'package:radar/data/model/reel_model_api.dart';
// import 'package:flutter/services.dart';
// import 'package:radar/view/components/store/StoreDetailsContent.dart';
// import 'package:radar/view/components/ui/CustomToast.dart';
// import 'package:radar/view/components/ui/ErrorView.dart';
// import 'package:radar/view/pages/skeletons_/StoreDetailsSkeleton.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wakelock/wakelock.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:http/http.dart' as http;

// /// مدير وحدات تحكم الفيديو والذاكرة التخزينية
// class VideoManager {
//   // خريطة تخزين متحكمات الفيديو
//   final Map<String, CachedVideoPlayerController> _controllers = {};
  
//   // متغير لحالة كتم الصوت
//   final RxBool isMuted = false.obs;
  
//   // متحكم التشغيل الحالي
//   String? _activeVideoId;
  
//   // حد أقصى للمتحكمات النشطة
//   final int _maxActiveControllers;
  
//   // متغير لحالة الاتصال
//   ConnectivityResult _connectionType = ConnectivityResult.none;
  
//   // إنشاء المدير
//   VideoManager({int maxActiveControllers = 4}) : _maxActiveControllers = maxActiveControllers {
//     _setupConnectivityMonitor();
//   }
  
//   // مراقبة حالة الاتصال
//   void _setupConnectivityMonitor() {
//     Connectivity().onConnectivityChanged.listen((result) {
//       _connectionType = result;
//       print('📶 تغيير حالة الاتصال: $_connectionType');
//     });
    
//     Connectivity().checkConnectivity().then((result) {
//       _connectionType = result;
//     });
//   }
  
//   // معرفة ما إذا كان الاتصال بطيئًا
//   bool isSlowConnection() {
//     return _connectionType == ConnectivityResult.mobile || 
//            _connectionType == ConnectivityResult.none;
//   }
  
//   // تهيئة وتشغيل فيديو
//   Future<CachedVideoPlayerController> initializeVideo(String id, String url, [String? posterUrl]) async {
//     print('🎬 بدء تهيئة الفيديو-ID:$id');
    
//     // إذا كان المتحكم موجودًا ومهيأ
//     if (_controllers.containsKey(id)) {
//       final controller = _controllers[id]!;
//       if (controller.value.isInitialized) {
//         // إعادة الفيديو للبداية
//         await controller.seekTo(Duration.zero);
//         _activeVideoId = id;
        
//         // تشغيل الفيديو
//         await controller.play();
//         await controller.setVolume(isMuted.value ? 0.0 : 1.0);
        
//         return controller;
//       }
      
//       // التخلص من المتحكم إذا كان موجودًا ولكن غير مهيأ
//       await disposeController(id);
//     }
    
//     // تنظيف المتحكمات القديمة إذا تجاوزنا الحد الأقصى
//     await _cleanupIfNeeded();
    
//     // إنشاء متحكم جديد
//     final controller = CachedVideoPlayerController.network(
//       url,
//       videoPlayerOptions: VideoPlayerOptions(
//         mixWithOthers: false,
//         allowBackgroundPlayback: false,
//       ),
//     );
    
//     try {
//       // تهيئة المتحكم
//       await controller.initialize();
      
//       // تكوين المتحكم
//       await controller.setLooping(true);
//       await controller.setVolume(isMuted.value ? 0.0 : 1.0);
//       await controller.play();
      
//       // تخزين المتحكم
//       _controllers[id] = controller;
//       _activeVideoId = id;
      
//       return controller;
//     } catch (e) {
//       print('❌ خطأ في تهيئة الفيديو: $e');
//       throw e;
//     }
//   }
  
//   // تحميل فيديو مسبقًا
//   Future<void> preloadVideo(String id, String url, [String? posterUrl]) async {
//     // تجاهل إذا كان المتحكم موجودًا بالفعل
//     if (_controllers.containsKey(id)) {
//       return;
//     }
    
//     // تجاهل التحميل المسبق على اتصالات بطيئة إذا وصلنا للحد الأقصى
//     if (isSlowConnection() && _controllers.length >= 2) {
//       print('⏩ تخطي التحميل المسبق للفيديو-ID:$id بسبب بطء الاتصال');
//       return;
//     }
    
//     try {
//       // تنظيف المتحكمات القديمة إذا لزم الأمر
//       await _cleanupIfNeeded();
      
//       // تحميل جزء صغير من الفيديو أولاً على الاتصالات البطيئة
//       if (isSlowConnection()) {
//         await _preloadPartialData(url);
//         return;
//       }
      
//       // إنشاء متحكم للتحميل المسبق
//       final controller = CachedVideoPlayerController.network(
//         url,
//         videoPlayerOptions: VideoPlayerOptions(
//           mixWithOthers: false,
//           allowBackgroundPlayback: false,
//         ),
//       );
      
//       // تهيئة أساسية فقط
//       await controller.initialize();
      
//       // تخزين المتحكم
//       _controllers[id] = controller;
      
//       print('✅ تم التحميل المسبق للفيديو-ID:$id');
//     } catch (e) {
//       print('⚠️ خطأ في التحميل المسبق للفيديو-ID:$id: $e');
//     }
//   }
  
//   // تنظيف المتحكمات القديمة إذا تجاوزنا الحد الأقصى
//   Future<void> _cleanupIfNeeded() async {
//     if (_controllers.length < _maxActiveControllers) {
//       return;
//     }
      
//     // الاحتفاظ بالمتحكم النشط
//     final idsToKeep = <String>{};
//     if (_activeVideoId != null) {
//       idsToKeep.add(_activeVideoId!);
//     }
    
//     // الحصول على قائمة المتحكمات للتخلص منها
//     final idsToRemove = _controllers.keys
//         .where((id) => !idsToKeep.contains(id))
//         .toList();
    
//     if (idsToRemove.isNotEmpty) {
//       // التخلص من أقدم متحكم
//       await disposeController(idsToRemove.first);
//     }
//   }
  
//   // تحميل جزء من بيانات الفيديو فقط (للاتصالات البطيئة)
//   Future<void> _preloadPartialData(String url) async {
//     try {
//       final client = http.Client();
//       final request = http.Request('GET', Uri.parse(url));
//       // طلب أول 300 كيلوبايت فقط من الفيديو
//       request.headers['Range'] = 'bytes=0-307200';
      
//       final response = await client.send(request);
      
//       if (response.statusCode == 206 || response.statusCode == 200) {
//         print('✅ تم تحميل جزء من الفيديو مسبقًا: ${response.contentLength} بايت');
//       }
      
//       client.close();
//     } catch (e) {
//       print('⚠️ خطأ في تحميل جزء من الفيديو: $e');
//     }
//   }
  
//   // تشغيل فيديو
//   Future<void> playVideo(String id) async {
//     if (!_controllers.containsKey(id)) {
//       throw Exception('المتحكم غير موجود');
//     }
    
//     // إيقاف الفيديوهات الأخرى
//     await stopAllVideosExcept(id);
    
//     // الحصول على المتحكم
//     final controller = _controllers[id]!;
    
//     // تشغيل الفيديو
//     await controller.setVolume(isMuted.value ? 0.0 : 1.0);
//     await controller.play();
    
//     // تحديث الفيديو النشط
//     _activeVideoId = id;
//   }
  
//   // إيقاف فيديو
//   Future<void> pauseVideo(String id) async {
//     if (!_controllers.containsKey(id)) {
//       return;
//     }
    
//     // الحصول على المتحكم
//     final controller = _controllers[id]!;
    
//     // إيقاف الفيديو
//     await controller.pause();
//   }
  
//   // إيقاف جميع الفيديوهات عدا واحد
//   Future<void> stopAllVideosExcept(String? exceptId) async {
//     // قائمة المتحكمات للإيقاف
//     final idsToStop = _controllers.keys
//         .where((id) => id != exceptId)
//         .toList();
    
//     // كتم صوت جميع الفيديوهات أولاً
//     for (final id in idsToStop) {
//       try {
//         final controller = _controllers[id]!;
//         await controller.setVolume(0.0);
//       } catch (e) {
//         print('⚠️ خطأ في كتم صوت الفيديو $id: $e');
//       }
//     }
    
//     // ثم إيقاف جميع الفيديوهات
//     for (final id in idsToStop) {
//       try {
//         final controller = _controllers[id]!;
//         await controller.pause();
//       } catch (e) {
//         print('⚠️ خطأ في إيقاف الفيديو $id: $e');
//       }
//     }
    
//     // تحديث الفيديو النشط
//     _activeVideoId = exceptId;
//   }
  
//   // تبديل حالة تشغيل فيديو
//   Future<void> togglePlayback(String id) async {
//     if (!_controllers.containsKey(id)) {
//       return;
//     }
    
//     final controller = _controllers[id]!;
//     final isPlaying = controller.value.isPlaying;
    
//     if (isPlaying) {
//       await pauseVideo(id);
//     } else {
//       await playVideo(id);
//     }
//   }
  
//   // تبديل حالة كتم الصوت
//   Future<void> toggleMute() async {
//     isMuted.value = !isMuted.value;
    
//     // تطبيق حالة كتم الصوت على الفيديو النشط
//     if (_activeVideoId != null && _controllers.containsKey(_activeVideoId!)) {
//       await _controllers[_activeVideoId!]!.setVolume(isMuted.value ? 0.0 : 1.0);
//     }
//   }
  
//   // التخلص من متحكم
//   Future<void> disposeController(String id) async {
//     if (!_controllers.containsKey(id)) {
//       return;
//     }
    
//     final controller = _controllers[id]!;
//     _controllers.remove(id);
    
//     try {
//       // إيقاف الفيديو أولاً
//       await controller.setVolume(0.0);
//       await controller.pause();
      
//       // التخلص من المتحكم
//       await controller.dispose();
      
//       // إعادة تعيين المتحكم النشط إذا لزم الأمر
//       if (_activeVideoId == id) {
//         _activeVideoId = null;
//       }
//     } catch (e) {
//       print('⚠️ خطأ في التخلص من المتحكم: $e');
//     }
//   }
  
//   // التخلص من جميع المتحكمات
//   Future<void> disposeAllControllers() async {
//     final ids = _controllers.keys.toList();
    
//     for (final id in ids) {
//       await disposeController(id);
//     }
    
//     _controllers.clear();
//     _activeVideoId = null;
//   }
  
//   // التحقق مما إذا كان الفيديو مهيأ
//   bool isVideoInitialized(String id) {
//     if (!_controllers.containsKey(id)) {
//       return false;
//     }
    
//     return _controllers[id]!.value.isInitialized;
//   }
  
//   // التحقق مما إذا كان الفيديو قيد التشغيل
//   bool isVideoPlaying(String id) {
//     if (!_controllers.containsKey(id)) {
//       return false;
//     }
    
//     return _controllers[id]!.value.isPlaying;
//   }
  
//   // الحصول على نسبة أبعاد الفيديو
//   double? getAspectRatio(String id) {
//     if (!_controllers.containsKey(id) || !_controllers[id]!.value.isInitialized) {
//       return 9.0 / 16.0; // القيمة الافتراضية
//     }
    
//     final size = _controllers[id]!.value.size;
//     if (size == null || size.width == 0 || size.height == 0) {
//       return 9.0 / 16.0;
//     }
    
//     return size.width / size.height;
//   }
  
//   // الحصول على المتحكم
//   CachedVideoPlayerController? getController(String id) {
//     return _controllers[id];
//   }
  
//   // الحصول على جميع المتحكمات
//   Map<String, CachedVideoPlayerController> getAllControllers() {
//     return Map.unmodifiable(_controllers);
//   }
  
//   // الحصول على معرف الفيديو النشط
//   String? getActiveVideoId() {
//     return _activeVideoId;
//   }
// }

// /// كنترولر عرض الريلز
// class ReelsController extends GetxController with GetTickerProviderStateMixin {
//   // خدمة API
//   final ReelsApiService _reelsApiService = ReelsApiService();
  
//   // مدير الفيديو
//   late VideoManager videoManager;
  
//   // متحكمات
//   final pageController = PageController();
//   late AnimationController storyAnimationController;
//   late AnimationController reelAnimationController;
//   final Map<String, PageController> mediaControllers = {};
  
//   // متغيرات Rx
//   final reels = <Reel>[].obs;
//   final currentReelIndex = 0.obs;
//   final currentMediaIndex = 0.obs;
//   final likedReels = <String, bool>{}.obs;
//   final viewedReels = <String, bool>{}.obs;
//   final whatsappedReels = <String, bool>{}.obs;
  
//   // حالات التحميل
//   final isLoading = true.obs;
//   final hasError = false.obs;
//   final errorMessage = ''.obs;
//   final isLoadingMore = false.obs;
//   final hasMoreReels = true.obs;
//   final isRefreshing = false.obs;
  
//   // حالات الفيديو
//   final playingStates = <String, bool>{}.obs;
//   final videoAspectRatios = <String, double>{};
//   final videoErrorStates = <String, bool>{}.obs;
//   final videoLoadingStates = <String, bool>{}.obs;
//   final imageAspectRatios = <String, double>{};
//   final expandedCaptions = <String, bool>{};
//   String? activeVideoId;
  
//   // متغيرات تتبع المشاهدة
//   final reelWatchProgress = <String, bool>{}.obs;
//   final reelWatchStartTimes = <String, DateTime>{};
//   final videoProgressValues = <String, double>{}.obs;
//   final double viewThreshold = 0.5; // نسبة المشاهدة المطلوبة للاحتساب
//   final Duration minWatchDuration = Duration(seconds: 2);
  
//   // متغيرات الرسوم المتحركة
//   final shineAnimationShown = <String, bool>{}.obs;
//   final shineAnimationActive = <String, bool>{}.obs;
  
//   // التنقل العميق
//   final pendingDeepLinkReelId = Rx<String?>(null);
  
//   // حالة كتم الصوت
//   late RxBool isMuted;
  
//   // متغيرات مساعدة
//   bool _isRapidSwiping = false;
//   bool _isPerformingCleanup = false;
//   DateTime _lastScrollTime = DateTime.now();
//   double _lastScrollPosition = 0.0;
//   DateTime _lastPageChangeTime = DateTime.now();
//   DateTime _lastReelSwitchTime = DateTime.now();
  
//   // تهيئة الكنترولر
//   @override
//   void onInit() {
//     super.onInit();
    
//     print('🚀 بدء تهيئة ReelsController');
    
//     // تهيئة مدير الفيديو
//     videoManager = VideoManager(maxActiveControllers: 4);
    
//     // ربط حالة كتم الصوت
//   isMuted = videoManager.isMuted;
    
//     // تهيئة متحكمات الرسوم المتحركة
//     _initAnimationControllers();
    
//     // بدء مراقبة التمرير
//     pageController.addListener(_onPageScroll);
    
//     // تفعيل إبقاء الشاشة مضاءة
//     Wakelock.enable();
    
//     // تهيئة مراقبة دورة حياة التطبيق
//     _setupLifecycleObserver();
    
//     // جلب الريلز
//     _fetchReels();
    
//     print('✅ اكتملت تهيئة ReelsController');
//   }
  
//   // دورة حياة التطبيق
//   void _setupLifecycleObserver() {
//     SystemChannels.lifecycle.setMessageHandler((msg) {
//       _handleAppLifecycleChange(msg ?? '');
//       return Future.value(null);
//     });
//   }
  
//   // تهيئة متحكمات الرسوم المتحركة
//   void _initAnimationControllers() {
//     storyAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
    
//     reelAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
    
//     storyAnimationController.forward();
//   }

//   // جلب الريلز
//   Future<void> _fetchReels() async {
//     try {
//       isLoading.value = true;
//       hasError.value = false;
//       errorMessage.value = '';
      
//       // جلب الريلز
//       final fetchedReels = await _reelsApiService.getRelevantReels();
      
//       // التحقق من وجود طلب تنقل معلق
//       final String? sharedReelId = pendingDeepLinkReelId.value;
      
//       if (sharedReelId != null) {
//         print("التحقق من وجود الريل المشارك في القائمة: $sharedReelId");
        
//         // البحث عن الريل
//         final existingIndex = fetchedReels.indexWhere((reel) => reel.id == sharedReelId);
        
//         if (existingIndex >= 0) {
//           print("الريل المشارك موجود بالفعل في الموقع: $existingIndex");
          
//           // نقل الريل للمقدمة
//           if (existingIndex > 0) {
//             final sharedReel = fetchedReels.removeAt(existingIndex);
//             fetchedReels.insert(0, sharedReel);
//             print("تم نقل الريل المشارك إلى بداية القائمة");
//           }
//         } else {
//           print("الريل المشارك غير موجود في القائمة، جلبه بشكل منفصل");
          
//           // جلب الريل المحدد
//           final specificReel = await _reelsApiService.getReelById(sharedReelId);
          
//           if (specificReel != null) {
//             fetchedReels.insert(0, specificReel);
//             print("تم جلب الريل المشارك بنجاح وإضافته في بداية القائمة");
//           } else {
//             print("تعذر العثور على الريل المشارك");
//           }
//         }
//       }
      
//       if (fetchedReels.isNotEmpty) {
//         // إيقاف جميع الفيديوهات قبل تحديث القائمة
//         await videoManager.stopAllVideosExcept(null);
        
//         // تحديث القائمة
//         reels.assignAll(fetchedReels);
        
//         // تهيئة حالات التفاعل
//         for (var reel in fetchedReels) {
//           likedReels[reel.id] = reel.isLiked;
//           viewedReels[reel.id] = reel.isWatched;
//           whatsappedReels[reel.id] = reel.isWhatsapped;
//         }
        
//         // التنقل إلى الريل المطلوب إذا وجد
//         if (sharedReelId != null) {
//           Future.delayed(Duration(milliseconds: 100), () {
//             navigateToReelById(sharedReelId, fromDeepLink: true);
//             pendingDeepLinkReelId.value = null;
//           });
//         }
//       } else {
//         hasMoreReels.value = false;
//       }
//     } catch (e) {
//       hasError.value = true;
//       if (e.toString().contains('SocketException') ||
//           e.toString().contains('Connection refused') ||
//           e.toString().contains('Network is unreachable')) {
//         errorMessage.value = 'لا يمكن الاتصال بالإنترنت';
//       } else if (e.toString().contains('Timeout')) {
//         errorMessage.value = 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
//       } else {
//         errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
//       }
//       print("خطأ في جلب الريلز: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
  
//   // تحميل المزيد من الريلز
//   Future<void> loadMoreReels() async {
//     if (isLoadingMore.value || !hasMoreReels.value || reels.isEmpty) return;
    
//     try {
//       isLoadingMore.value = true;
      
//       // استخدام معرف آخر ريل كنقطة البداية
//       final lastReel = reels.last;
//       final moreReels = await _reelsApiService.loadMoreReels(lastReel.id);
      
//       if (moreReels.isNotEmpty) {
//         reels.addAll(moreReels);
        
//         // تهيئة حالات التفاعل للريلز الجديدة
//         for (var reel in moreReels) {
//           likedReels[reel.id] = reel.isLiked;
//           viewedReels[reel.id] = reel.isWatched;
//           whatsappedReels[reel.id] = reel.isWhatsapped;
//         }
//       } else {
//         hasMoreReels.value = false;
//       }
//     } catch (e) {
//       print("خطأ في تحميل المزيد من الريلز: $e");
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }
  
//   // تحديث الريلز
//   Future<void> refreshReels() async {
//     if (isRefreshing.value) return;
    
//     try {
//       isRefreshing.value = true;
//       hasError.value = false;
      
//       // تأخير بسيط
//       await Future.delayed(Duration(milliseconds: 300));
      
//       // جلب ريلز جديدة
//       final freshReels = await _reelsApiService.getRelevantReels();
      
//       if (freshReels.isNotEmpty) {
//         // إيقاف جميع الفيديوهات
//         await videoManager.stopAllVideosExcept(null);
        
//         // تحديث القائمة
//         reels.assignAll(freshReels);
        
//         // تهيئة حالات التفاعل
//         for (var reel in freshReels) {
//           likedReels[reel.id] = reel.isLiked;
//           viewedReels[reel.id] = reel.isWatched;
//           whatsappedReels[reel.id] = reel.isWhatsapped;
//         }
        
//         // إعادة تعيين المؤشر
//         if (pageController.hasClients) {
//           pageController.jumpToPage(0);
//         }
//         currentReelIndex.value = 0;
//         currentMediaIndex.value = 0;
        
//         // تمكين تحميل المزيد مرة أخرى
//         hasMoreReels.value = true;
//       }
//     } catch (e) {
//       print("خطأ في تحديث الريلز: $e");
//       hasError.value = true;
//       errorMessage.value = 'حدث خطأ أثناء تحميل البيانات، يرجى المحاولة مرة أخرى';
//     } finally {
//       isRefreshing.value = false;
//     }
//   }
  
//   // معالجة التمرير
//   void _onPageScroll() {
//     if (!pageController.hasClients) return;
    
//     final now = DateTime.now();
//     final currentPosition = pageController.position.pixels;
//     final timeDiff = now.difference(_lastScrollTime).inMilliseconds;
    
//     // حساب سرعة التمرير
//     if (timeDiff > 0) {
//       final pixelsPerMs = (currentPosition - _lastScrollPosition) / timeDiff;
//       final speedPixelsPerSecond = pixelsPerMs * 1000;
      
//       // تحديد ما إذا كان التقليب سريعًا
//       _isRapidSwiping = speedPixelsPerSecond.abs() > 1000;
//     }
    
//     // تحديث القيم للحساب التالي
//     _lastScrollPosition = currentPosition;
//     _lastScrollTime = now;
    
//     // تحميل المزيد من الريلز عند الاقتراب من النهاية
//     final currentPage = pageController.page?.round() ?? 0;
//     if (currentPage >= reels.length - 3) {
//       loadMoreReels();
//     }
    
//     // تنظيف دوري للمتحكمات البعيدة
//     if (currentPage % 5 == 0 && !_isPerformingCleanup) {
//       _isPerformingCleanup = true;
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         cleanupDistantControllers(currentPage);
//         _isPerformingCleanup = false;
//       });
//     }
//   }
  
//   // الحصول على متحكم الوسائط
//   PageController getMediaController(int index) {
//     if (index < 0 || index >= reels.length) return PageController();
    
//     final reelId = reels[index].id;
//     if (!mediaControllers.containsKey(reelId)) {
//       mediaControllers[reelId] = PageController();
//     }
//     return mediaControllers[reelId]!;
//   }
  
//   // معالجة تغيير صفحة الريل
//   void onReelPageChanged(int index) {
//     if (index < 0 || index >= reels.length) return;
    
//     final previousIndex = currentReelIndex.value;
//     final now = DateTime.now();
    
//     // حساب الفاصل الزمني بين تغييرات الصفحة
//     final timeSinceLastChange = now.difference(_lastPageChangeTime).inMilliseconds;
//     _lastPageChangeTime = now;
    
//     // تحديد ما إذا كان التقليب سريعًا
//     _isRapidSwiping = timeSinceLastChange < 200;
    
//     print('📱 تغيير الريل من $previousIndex إلى $index (تقليب سريع: ${_isRapidSwiping ? "نعم" : "لا"})');
    
//     // إيقاف جميع الفيديوهات أولاً
//     videoManager.stopAllVideosExcept(null);
    
//     // تحديث المؤشرات
//     currentReelIndex.value = index;
//     currentMediaIndex.value = 0;
    
//     // تسجيل وقت بدء المشاهدة
//     final currentReel = reels[index];
//     reelWatchStartTimes[currentReel.id] = DateTime.now();
    
//     // إضافة تأخير صغير لمنع التحميل المفرط عند التقليب السريع
//     final timeSinceLastSwitch = now.difference(_lastReelSwitchTime);
//     final isFastSwitching = timeSinceLastSwitch.inMilliseconds < 300;
//     _lastReelSwitchTime = now;
    
//     final delayMs = isFastSwitching ? 200 : 50;
    
//     Future.delayed(Duration(milliseconds: delayMs), () {
//       // التحقق من أن المستخدم لم يقم بتغيير الريل مرة أخرى
//       if (currentReelIndex.value != index) {
//         print('⏩ تم تخطي تحميل الريل: $index (المستخدم انتقل إلى ريل آخر)');
//         return;
//       }
      
//       // تحميل الوسائط الحالية
//       if (currentReel.mediaUrls.isNotEmpty) {
//         final firstMedia = currentReel.mediaUrls[0];
        
//         if (currentReel.isVideoMedia(0)) {
//           print('🎬 بدء تهيئة الفيديو للريل الحالي');
//           initializeVideo(currentReel.id, firstMedia.url, firstMedia.poster);
//         } else {
//           print('🖼️ بدء مؤقت مشاهدة الصورة للريل الحالي');
//           startImageWatchTimer(index);
//         }
//       }
      
//       // تأخير التحميل المسبق عند التقليب السريع
//       final preloadDelayMs = isFastSwitching ? 300 : 100;
//       Future.delayed(Duration(milliseconds: preloadDelayMs), () {
//         // التحقق مرة أخرى من أن الريل لم يتغير
//         if (currentReelIndex.value == index) {
//           preloadAdjacentVideos(index);
//         }
//       });
//     });
    
//     // معالجة الريل السابق
//     if (previousIndex >= 0 && previousIndex < reels.length) {
//       checkAndMarkReelAsViewed(previousIndex);
//     }
    
//     // تنظيف المتحكمات البعيدة
//     if (previousIndex != index) {
//       Future.delayed(Duration(milliseconds: 300), () {
//         cleanupDistantControllers(index);
//       });
//     }
    
//     update();
//   }
  
//   // معالجة تغيير الوسائط داخل الريل
//   void onMediaPageChanged(int index) {
//     try {
//       // التحقق من صحة المؤشرات
//       final reelIndex = currentReelIndex.value;
//       if (reelIndex < 0 || reelIndex >= reels.length) {
//         print('⚠️ مؤشر الريل خارج النطاق: $reelIndex');
//         return;
//       }
      
//       final currentReel = reels[reelIndex];
//       if (index < 0 || index >= currentReel.mediaUrls.length) {
//         print('⚠️ مؤشر الوسائط خارج النطاق: $index');
//         return;
//       }
      
//       final prevMediaIndex = currentMediaIndex.value;
//       print('🔄 تغيير الوسائط من $prevMediaIndex إلى $index');
      
//       // إيقاف جميع الفيديوهات أولاً
//       videoManager.stopAllVideosExcept(null);
      
//       // تحديث مؤشر الوسائط
//       currentMediaIndex.value = index;
      
//       // معالجة التغيير بين أنواع الوسائط
//       if (prevMediaIndex >= 0 && prevMediaIndex < currentReel.mediaUrls.length) {
//         if (currentReel.isVideoMedia(prevMediaIndex) && !currentReel.isVideoMedia(index)) {
//           // تغيير من فيديو إلى صورة
//           print('🔄 تغيير من فيديو إلى صورة');
//           videoManager.stopAllVideosExcept(null);
//           startImageWatchTimer(reelIndex);
//         } else if (!currentReel.isVideoMedia(prevMediaIndex) && currentReel.isVideoMedia(index)) {
//           // تغيير من صورة إلى فيديو
//           print('🔄 تغيير من صورة إلى فيديو');
//           final mediaUrl = currentReel.mediaUrls[index].url;
//           final posterUrl = currentReel.mediaUrls[index].poster;
//           initializeVideo(currentReel.id, mediaUrl, posterUrl);
//         } else if (currentReel.isVideoMedia(prevMediaIndex) && 
//                    currentReel.isVideoMedia(index) && 
//                    prevMediaIndex != index) {
//           // تغيير من فيديو إلى فيديو آخر
//           print('🔄 تغيير من فيديو إلى فيديو آخر');
//           videoManager.stopAllVideosExcept(null);
//           final mediaUrl = currentReel.mediaUrls[index].url;
//           final posterUrl = currentReel.mediaUrls[index].poster;
//           initializeVideo(currentReel.id, mediaUrl, posterUrl);
//         }
//       }
      
//       update();
//     } catch (e) {
//       print('❌ خطأ في onMediaPageChanged: $e');
//     }
//   }
  
//   // تهيئة وتشغيل الفيديو
//   Future<void> initializeVideo(String id, String url, [String? posterUrl]) async {
//     videoLoadingStates[id] = true;
//     videoErrorStates[id] = false;
//     update();
    
//     try {
//       // تهيئة الفيديو باستخدام مدير الفيديو
//       final controller = await videoManager.initializeVideo(id, url, posterUrl);
      
//       // حساب نسبة الأبعاد
//       if (controller.value.isInitialized && controller.value.size != null) {
//         final size = controller.value.size!;
//         if (size.width > 0 && size.height > 0) {
//           videoAspectRatios[id] = size.width / size.height;
//         } else {
//           videoAspectRatios[id] = 9.0 / 16.0; // قيمة افتراضية
//         }
//       } else {
//         videoAspectRatios[id] = 9.0 / 16.0; // قيمة افتراضية
//       }
      
//       // إعداد تتبع التقدم
//       _setupProgressTracking(id, controller);
      
//       // تحديث الحالات
//       videoLoadingStates[id] = false;
//       playingStates[id] = true;
//       activeVideoId = id;
      
//       update();
//     } catch (e) {
//       print('❌ خطأ في تهيئة الفيديو-ID:$id: $e');
//       videoLoadingStates[id] = false;
//       videoErrorStates[id] = true;
//       update();
//     }
//   }
  
//   // تحميل الفيديو مسبقًا
//   Future<void> preloadVideo(String id, String url, [String? posterUrl]) async {
//     await videoManager.preloadVideo(id, url, posterUrl);
//   }
  
//   // تتبع تقدم الفيديو
//   void _setupProgressTracking(String id, CachedVideoPlayerController controller) {
//     // إنشاء مؤقت للتحقق من التقدم كل 250 مللي ثانية
//     Timer.periodic(Duration(milliseconds: 250), (timer) {
//       // إلغاء المؤقت إذا تم التخلص من المتحكم
//       if (!videoManager.isVideoInitialized(id)) {
//         timer.cancel();
//         return;
//       }
      
//       try {
//         // حساب نسبة التقدم
//         if (controller.value.isInitialized && controller.value.duration.inMilliseconds > 0) {
//           final progress = controller.value.position.inMilliseconds / 
//                          controller.value.duration.inMilliseconds;
          
//           // تحديث قيمة التقدم
//           if (progress >= 0 && progress <= 1.0) {
//             videoProgressValues[id] = progress;
            
//             // التحقق من تجاوز عتبة المشاهدة
//             if (progress >= viewThreshold &&
//                 !(reelWatchProgress[id] ?? false) &&
//                 !(viewedReels[id] ?? false)) {
              
//               // تسجيل المشاهدة
//               reelWatchProgress[id] = true;
//               final reelIndex = reels.indexWhere((reel) => reel.id == id);
//               if (reelIndex != -1) {
//                 markAsViewed(reelIndex);
//               }
//             }
            
//             // تفعيل تأثير اللمعة عند تجاوز عتبة المشاهدة
//             if (progress >= viewThreshold && 
//                 !(shineAnimationShown[id] ?? false) && 
//                 !(shineAnimationActive[id] ?? false)) {
//               shineAnimationActive[id] = true;
//               update();
//             }
            
//             // تحديث الواجهة لعرض شريط التقدم
//             update();
//           }
//         }
//       } catch (e) {
//         // تجاهل الأخطاء في حساب التقدم
//       }
//     });
//   }
  
//   // فحص وتسجيل مشاهدة الريل
//   void checkAndMarkReelAsViewed(int index) {
//     if (index < 0 || index >= reels.length) return;
    
//     final reel = reels[index];
    
//     // تجنب تكرار تسجيل المشاهدة
//     if ((viewedReels[reel.id] ?? false) || (reelWatchProgress[reel.id] ?? false)) {
//       return;
//     }
    
//     // التحقق من وقت بداية المشاهدة
//     final startTime = reelWatchStartTimes[reel.id];
//     if (startTime == null) {
//       return;
//     }
    
//     // حساب مدة المشاهدة
//     final watchDuration = DateTime.now().difference(startTime);
    
//     // تقدير ما إذا كان المستخدم قد شاهد معظم المحتوى
//     bool hasWatchedEnough = false;
    
//     // للفيديوهات، استخدم قيمة التقدم المسجلة
//     if (reel.mediaUrls.isNotEmpty && reel.isVideoMedia(0)) {
//       if (videoProgressValues.containsKey(reel.id)) {
//         final progress = videoProgressValues[reel.id]!;
//         hasWatchedEnough = progress >= viewThreshold;
//       } else {
//         hasWatchedEnough = watchDuration >= minWatchDuration;
//       }
//     } else {
//       // للصور، نعتبر المشاهدة تمت إذا بقي عليها لمدة كافية
//       hasWatchedEnough = watchDuration >= minWatchDuration;
//     }
    
//     // تسجيل المشاهدة إذا تمت مشاهدة محتوى كافٍ
//     if (hasWatchedEnough) {
//       reelWatchProgress[reel.id] = true;
//       markAsViewed(index);
//     }
    
//     // إعادة تعيين وقت البداية
//     reelWatchStartTimes.remove(reel.id);
//   }
  
//   // تسجيل مشاهدة الريل
//   void markAsViewed(int index) async {
//     if (index < 0 || index >= reels.length) return;
    
//     final reel = reels[index];
    
//     // تجنب تسجيل المشاهدة مرة أخرى
//     if (viewedReels[reel.id] == true) {
//       return;
//     }
    
//     // تحديث حالة المشاهدة محلياً أولاً
//     viewedReels[reel.id] = true;
//     reel.counts.viewedBy += 1;
//     reel.isWatched = true;
//     update();
    
//     try {
//       // إرسال الطلب إلى API
//       final response = await _reelsApiService.viewContent(reel.id);
      
//       final bool isSuccess = response['success'] == true;
      
//       if (isSuccess) {
//         // التحقق من وجود جوهرة
//         final bool hasGem = response['gemClaimed'] == true;
        
//         if (hasGem) {
//           // استخراج بيانات الجوهرة
//           final int gemPoints = response['gemPoints'] is int
//               ? response['gemPoints']
//               : (int.tryParse(response['gemPoints'].toString()) ?? 0);
          
//           // استخدام اللون الافتراضي
//           const String gemColor = "blue";
          
//           // عرض الرسوم المتحركة للجوهرة
//           if (gemPoints > 0) {
//             final gemService = Get.find<GemService>();
//             gemService.showGemAnimation(gemPoints, gemColor);
//           }
//         }
//       } else {
//         // إعادة الحالة السابقة في حالة الفشل
//         _revertViewState(index, reel.counts.viewedBy - 1);
//       }
//     } catch (e) {
//       print("❌ خطأ في تسجيل المشاهدة: $e");
//       _revertViewState(index, reel.counts.viewedBy - 1);
//     }
//   }
  
//   // إعادة حالة المشاهدة في حالة الفشل
//   void _revertViewState(int index, int originalViewCount) {
//     if (index < 0 || index >= reels.length) return;
    
//     final reel = reels[index];
    
//     // إعادة الحالة الأصلية
//     viewedReels[reel.id] = false;
//     reelWatchProgress[reel.id] = false;
//     reel.counts.viewedBy = originalViewCount;
//     reel.isWatched = false;
    
//     update();
//   }
  
//   // تنفيذ آلية تتبع المشاهدة للصور
//   void startImageWatchTimer(int index) {
//     if (index < 0 || index >= reels.length) return;
    
//     final reel = reels[index];
    
//     // تجنب تكرار تسجيل المشاهدة
//     if ((viewedReels[reel.id] ?? false) || (reelWatchProgress[reel.id] ?? false)) return;
    
//     // تسجيل وقت البداية
//     reelWatchStartTimes[reel.id] = DateTime.now();
    
//     // إنشاء مؤقت لتسجيل المشاهدة بعد المدة المحددة
//     Future.delayed(minWatchDuration, () {
//       // التحقق مما إذا كان المستخدم لا يزال يشاهد نفس الريل
//       if (currentReelIndex.value == index) {
//         reelWatchProgress[reel.id] = true;
//         markAsViewed(index);
//       }
//     });
//   }
  
//   // تبديل حالة الإعجاب
//   void toggleLike(int index) async {
//     if (index < 0 || index >= reels.length) return;
    
//     final reel = reels[index];
    
//     // حفظ الحالة قبل التغيير
//     final currentLikeState = likedReels[reel.id] ?? false;
//     final currentLikeCount = reel.counts.likedBy;
    
//     // التحديث المتفائل
//     final newLikeState = !currentLikeState;
//     likedReels[reel.id] = newLikeState;
    
//     // تحديث العداد
//     if (newLikeState) {
//       reel.counts.likedBy += 1;
//     } else {
//       reel.counts.likedBy -= 1;
//       if (reel.counts.likedBy < 0) reel.counts.likedBy = 0;
//     }
    
//     // تحديث حالة الإعجاب في الكائن
//     reel.isLiked = newLikeState;
    
//     update();
    
//     try {
//       // إرسال الطلب إلى API
//       final success = await _reelsApiService.likeContent(reel.id);
      
//       if (!success) {
//         // إعادة الحالة السابقة في حالة الفشل
//         _revertLikeState(index, currentLikeState, currentLikeCount);
//       }
//     } catch (e) {
//       print("خطأ في تحديث الإعجاب: $e");
//       _revertLikeState(index, currentLikeState, currentLikeCount);
//     }
//   }
  
//   // إعادة حالة الإعجاب في حالة الفشل
//   void _revertLikeState(int index, bool originalLikeState, int originalLikeCount) {
//     if (index < 0 || index >= reels.length) return;
    
//     final reel = reels[index];
    
//     // إعادة الحالة الأصلية
//     likedReels[reel.id] = originalLikeState;
//     reel.counts.likedBy = originalLikeCount;
//     reel.isLiked = originalLikeState;
    
//     update();
    
//     // إشعار المستخدم
//     Get.snackbar(
//       'خطأ في الاتصال',
//       'فشل تحديث الإعجاب، يرجى المحاولة مرة أخرى',
//       snackPosition: SnackPosition.BOTTOM,
//       duration: Duration(seconds: 2),
//     );
//   }
  
//   // تسجيل نقرة على واتساب
//   void markAsWhatsappClicked(int index) async {
//     if (index < 0 || index >= reels.length) return;
    
//     final reel = reels[index];
    
//     try {
//       // تسجيل النقرة وجلب رابط الواتساب
//       final response = await _reelsApiService.whatsappClick(reel.id);
      
//       // الحصول على رابط الواتساب
//       final whatsappLink = response['whatsappLink'];
      
//       if (whatsappLink != null && whatsappLink.isNotEmpty) {
//         // فتح رابط الواتساب
//         launchWhatsApp(whatsappLink);
        
//         // تحديث العداد محلياً
//         whatsappedReels[reel.id] = true;
//         reel.counts.whatsappedBy += 1;
//         update();
//       }
//     } catch (e) {
//       print("خطأ في تسجيل نقرة واتساب: $e");
//     }
//   }
  
//   // فتح رابط الواتساب
//   void launchWhatsApp(String url) async {
//     try {
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         CustomToast.showErrorToast(
//             message: 'لا يمكن فتح واتساب. يرجى التأكد من تثبيت التطبيق.');
//       }
//     } catch (e) {
//       print("خطأ في فتح واتساب: $e");
//     }
//   }
  
//   // التعامل مع السحب الأفقي
//   void handleHorizontalDrag(DragEndDetails details, int index, int mediaCount) {
//     if (index < 0 ||
//         index >= reels.length ||
//         currentMediaIndex.value < 0 ||
//         currentMediaIndex.value >= mediaCount) {
//       return;
//     }
    
//     final controller = getMediaController(index);
//     final velocity = details.primaryVelocity ?? 0;
//     final velocityThreshold = 200.0;
    
//     // السرعة السالبة للانتقال للصفحة السابقة
//     if (velocity < -velocityThreshold && currentMediaIndex.value > 0) {
//       controller.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//     // السرعة الموجبة للانتقال للصفحة التالية
//     else if (velocity > velocityThreshold && currentMediaIndex.value < mediaCount - 1) {
//       controller.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
  
//   // التعامل مع النقر المزدوج
//   void handleDoubleTap(int index) {
//     if (index < 0 || index >= reels.length) {
//       return;
//     }
    
//     toggleLike(index);
//   }
  
//   // تشغيل فيديو
//   void playVideo(String id) {
//     videoManager.playVideo(id).then((_) {
//       playingStates[id] = true;
//       activeVideoId = id;
//       update();
//     }).catchError((e) {
//       print('❌ خطأ في تشغيل الفيديو-ID:$id: $e');
//     });
//   }
  
//   // إيقاف فيديو
//   void pauseVideo(String id) {
//     videoManager.pauseVideo(id).then((_) {
//       playingStates[id] = false;
//       update();
//     }).catchError((e) {
//       print('❌ خطأ في إيقاف الفيديو-ID:$id: $e');
//     });
//   }
  
//   // إيقاف جميع الفيديوهات
//   void pauseAllVideos() {
//     videoManager.stopAllVideosExcept(null).then((_) {
//       for (var id in playingStates.keys.toList()) {
//         playingStates[id] = false;
//       }
//       update();
//     });
//   }
  
//   // التحقق ما إذا كان الفيديو قيد التشغيل
//   bool isVideoPlaying(String id) {
//     return videoManager.isVideoPlaying(id);
//   }
  
//   // التحقق ما إذا كان الفيديو مهيأ
//   bool isVideoInitialized(String id) {
//     return videoManager.isVideoInitialized(id);
//   }
  
//   // الحصول على نسبة أبعاد الفيديو
//   double? getVideoAspectRatio(String id) {
//     return videoManager.getAspectRatio(id) ?? videoAspectRatios[id] ?? 9.0 / 16.0;
//   }
  
//   // إيقاف جميع الفيديوهات عدا واحد
//   void stopAllVideosExcept(String? exceptId) {
//     videoManager.stopAllVideosExcept(exceptId).then((_) {
//       // تحديث حالات التشغيل
//       for (var id in playingStates.keys.toList()) {
//         if (id != exceptId) {
//           playingStates[id] = false;
//         }
//       }
      
//       // تحديث المتحكم النشط
//       activeVideoId = exceptId;
      
//       update();
//     });
//   }
  
//   // تبديل حالة تشغيل الفيديو
//   void toggleVideoPlayback(String id) {
//     if (!videoManager.isVideoInitialized(id)) {
//       return;
//     }
    
//     final isPlaying = videoManager.isVideoPlaying(id);
    
//     if (isPlaying) {
//       pauseVideo(id);
//     } else {
//       playVideo(id);
//     }
//   }
  
//   // تبديل حالة كتم الصوت
//   void toggleMute() {
//     videoManager.toggleMute();
//   }
  
//   // تنظيف المتحكمات البعيدة
//   void cleanupDistantControllers(int currentIndex) {
//     if (_isPerformingCleanup) return;
//     _isPerformingCleanup = true;
    
//     try {
//       // تحديد المعرفات التي يجب الاحتفاظ بها
//       final keepIds = <String>{};
      
//       // الاحتفاظ بالريل الحالي والريلز المجاورة
//       for (int i = -2; i <= 2; i++) {
//         final idx = currentIndex + i;
//         if (idx >= 0 && idx < reels.length) {
//           keepIds.add(reels[idx].id);
//         }
//       }
      
//       // الحصول على قائمة المتحكمات
//       final controllers = videoManager.getAllControllers();
      
//       // التخلص من المتحكمات البعيدة
//       for (final id in controllers.keys.toList()) {
//         if (!keepIds.contains(id)) {
//           videoManager.disposeController(id);
//         }
//       }
//     } catch (e) {
//       print('❌ خطأ أثناء تنظيف المتحكمات: $e');
//     } finally {
//       _isPerformingCleanup = false;
//     }
//   }
  
//   // التحميل المسبق للفيديوهات المجاورة
//   Future<void> preloadAdjacentVideos(int currentIndex) async {
//     if (currentIndex < 0 || currentIndex >= reels.length) return;
    
//     // تجاهل التحميل المسبق أثناء التقليب السريع
//     if (_isRapidSwiping) {
//       print('⚡ تم تخطي التحميل المسبق بسبب التقليب السريع');
//       return;
//     }
    
//     // تحميل الفيديو التالي أولاً (أولوية عالية)
//     final nextIndex = currentIndex + 1;
//     if (nextIndex < reels.length) {
//       final nextReel = reels[nextIndex];
//       if (nextReel.mediaUrls.isNotEmpty && nextReel.isVideoMedia(0)) {
//         final firstMedia = nextReel.mediaUrls[0];
//         await preloadVideo(nextReel.id, firstMedia.url, firstMedia.poster);
//       }
//     }
    
//     // ثم تحميل الفيديو السابق إذا كان الاتصال جيدًا
//     final isSlowConn = videoManager.isSlowConnection();
//     if (!isSlowConn) {
//       final prevIndex = currentIndex - 1;
//       if (prevIndex >= 0) {
//         final prevReel = reels[prevIndex];
//         if (prevReel.mediaUrls.isNotEmpty && prevReel.isVideoMedia(0)) {
//           final firstMedia = prevReel.mediaUrls[0];
//           await preloadVideo(prevReel.id, firstMedia.url, firstMedia.poster);
//         }
//       }
//     }
//   }
  
//   // تنظيف ذاكرة الصور المؤقتة
//   void cleanupImageCache() {
//     try {
//       // تنظيف الذاكرة المؤقتة للصور
//       PaintingBinding.instance.imageCache.clear();
//       PaintingBinding.instance.imageCache.clearLiveImages();
      
//       // تنظيف مدير التخزين المؤقت
//       DefaultCacheManager().emptyCache();
//     } catch (e) {
//       print('خطأ في تنظيف ذاكرة الصور المؤقتة: $e');
//     }
//   }
  
//   // التعامل مع تغييرات دورة حياة التطبيق
//   void _handleAppLifecycleChange(String state) {
//     if (state == 'AppLifecycleState.paused' || state == 'AppLifecycleState.inactive') {
//       // إيقاف جميع الوسائط عندما يكون التطبيق في الخلفية
//       pauseAllVideos();
//     } else if (state == 'AppLifecycleState.resumed') {
//       // استئناف الفيديو النشط عند العودة للمقدمة
//       if (activeVideoId != null) {
//         playVideo(activeVideoId!);
//       }
//     }
//   }
  
//   // التنقل إلى ريل محدد بواسطة المعرف
//   Future<void> navigateToReelById(String reelId, {bool fromDeepLink = false}) async {
//     // عند بدء التنقل، إيقاف جميع الفيديوهات
//     stopAllVideosExcept(null);
    
//     // إذا كانت الريلز قيد التحميل وكان الطلب من رابط عميق
//     if (isLoading.value && fromDeepLink) {
//       pendingDeepLinkReelId.value = reelId;
//       return;
//     }
    
//     // انتظار انتهاء التحميل إذا كان جاريًا
//     if (isLoading.value) {
//       int attempts = 0;
//       while (isLoading.value && attempts < 10) {
//         await Future.delayed(Duration(milliseconds: 300));
//         attempts++;
//       }
//     }
    
//     // البحث عن الريل في القائمة الحالية
//     final existingIndex = reels.indexWhere((reel) => reel.id == reelId);
    
//     if (existingIndex >= 0) {
//       // إذا كان الريل ليس في البداية، نقله للمقدمة
//       if (existingIndex > 0) {
//         final targetReel = reels.removeAt(existingIndex);
//         reels.insert(0, targetReel);
//       }
      
//       // الانتقال إلى الصفحة الأولى
//       _jumpToFirstReel();
//     } else {
//       // جلب الريل من الخادم
//       try {
//         isLoading.value = true;
//         final specificReel = await _reelsApiService.getReelById(reelId);
        
//         if (specificReel != null) {
//           // إضافة الريل في بداية القائمة
//           reels.insert(0, specificReel);
          
//           // تهيئة حالات الريل
//           likedReels[specificReel.id] = specificReel.isLiked;
//           viewedReels[specificReel.id] = specificReel.isWatched;
//           whatsappedReels[specificReel.id] = specificReel.isWhatsapped;
          
//           // الانتقال إلى الصفحة الأولى
//           _jumpToFirstReel();
//         }
//       } catch (e) {
//         print("خطأ أثناء جلب الريل: $e");
//       } finally {
//         isLoading.value = false;
//       }
//     }
    
//     update();
//   }
  
//   // الانتقال إلى الريل الأول
//   void _jumpToFirstReel() {
//     if (pageController.hasClients) {
//       pageController.jumpToPage(0);
//     }
//     currentReelIndex.value = 0;
//     currentMediaIndex.value = 0;
//   }
  
//   // مشاركة الريل
//   void shareReel(int index) {
//     if (index < 0 || index >= reels.length) return;
    
//     final reel = reels[index];
    
//     // عرض خيارات المشاركة
//     _showShareOptions(reel);
//   }
  
//   // عرض خيارات المشاركة
//   void _showShareOptions(Reel reel) {
//     List<ShareOption> options = [
//       ShareOption(
//         icon: Icons.link,
//         title: 'نسخ الرابط',
//         onTap: () => _copyReelLink(reel),
//       ),
//       ShareOption(
//         icon: Icons.share,
//         title: 'مشاركة الرابط',
//         onTap: () => _shareReelLink(reel),
//       ),
//       ShareOption(
//         icon: FontAwesomeIcons.whatsapp,
//         title: 'مشاركة في واتساب',
//         onTap: () => _shareToWhatsApp(reel),
//       ),
//       ShareOption(
//         icon: Icons.image,
//         title: 'مشاركة كصورة',
//         onTap: () => _shareReelImage(reel),
//       ),
//     ];
    
//     Get.bottomSheet(
//       Container(
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[600],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'مشاركة المحتوى',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20),
//               ...options.map((option) => _buildShareOptionItem(option)).toList(),
//               SizedBox(height: 20),
//               InkWell(
//                 onTap: () => Get.back(),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[800]!),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'إلغاء',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }
  
//   // بناء عنصر خيار مشاركة
//   Widget _buildShareOptionItem(ShareOption option) {
//     return InkWell(
//       onTap: () {
//         Get.back();
//         option.onTap();
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           border: Border(bottom: BorderSide(color: Colors.grey[900]!)),
//         ),
//         child: Row(
//           children: [
//             Icon(option.icon, color: AppColors.primary, size: 24),
//             SizedBox(width: 16),
//             Text(
//               option.title,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // مشاركة رابط الريل
//   Future<void> _shareReelLink(Reel reel) async {
//     try {
//       // إنشاء رابط عميق
//       final reelLink = _generateDeepLink(reel);
      
//       // نص المشاركة
//       final shareText = 'شاهد هذا المحتوى المميز من رادار 📱✨\n$reelLink';
      
//       // مشاركة الرابط
//       await Share.share(
//         shareText,
//         subject: 'مشاركة من رادار',
//       );
//     } catch (e) {
//       print("خطأ في مشاركة الريل: $e");
//       _showErrorSnackbar('مشاركة الرابط', e.toString());
//     }
//   }
  
//   // نسخ رابط الريل
//   Future<void> _copyReelLink(Reel reel) async {
//     try {
//       // إنشاء رابط عميق
//       final reelLink = _generateDeepLink(reel);
      
//       // نسخ الرابط
//       await Clipboard.setData(ClipboardData(text: reelLink));
      
//       // إظهار رسالة تأكيد
//       Get.snackbar(
//         'تم النسخ',
//         'تم نسخ رابط المحتوى إلى الحافظة',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green.withOpacity(0.7),
//         colorText: Colors.white,
//         duration: Duration(seconds: 2),
//       );
//     } catch (e) {
//       print("خطأ أثناء نسخ رابط الريل: $e");
//       _showErrorSnackbar('نسخ الرابط', e.toString());
//     }
//   }
  
//   // المشاركة عبر واتساب
//   Future<void> _shareToWhatsApp(Reel reel) async {
//     try {
//       final reelIndex = reels.indexWhere((r) => r.id == reel.id);
//       if (reelIndex != -1) {
//         markAsWhatsappClicked(reelIndex);
//       } else {
//         throw Exception("لم يتم العثور على الريل في القائمة");
//       }
//     } catch (e) {
//       print("خطأ أثناء المشاركة على واتساب: $e");
//       _showErrorSnackbar('مشاركة واتساب', e.toString());
//     }
//   }
  
//   // مشاركة الريل كصورة
//   Future<void> _shareReelImage(Reel reel) async {
//     // عرض مؤشر تحميل
//     final loadingDialogCompleter = Completer();
//     Get.dialog(
//       Center(
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.7),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 color: AppColors.primary,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 "جاري تحضير الصورة للمشاركة...",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ],
//           ),
//         ),
//       ),
//       barrierDismissible: false,
//     ).then((_) => loadingDialogCompleter.complete());
    
//     try {
//       // التحقق من وجود وسائط
//       if (reel.mediaUrls.isEmpty) {
//         throw Exception("لا توجد وسائط للمشاركة في هذا الريل");
//       }
      
//       // اختيار الرابط المناسب
//       final mediaUrl = reel.isVideoMedia(0)
//         ? (reel.mediaUrls[0].poster ?? reel.mediaUrls[0].url)
//         : reel.mediaUrls[0].url;
      
//       // تنزيل الصورة
//       final response = await http.get(Uri.parse(mediaUrl));
      
//       if (response.statusCode != 200) {
//         throw Exception("فشل تحميل صورة الريل (${response.statusCode})");
//       }
      
//       // حفظ الصورة مؤقتًا
//       final tempDir = await getTemporaryDirectory();
//       final filePath = '${tempDir.path}/reel_image_${reel.id}.jpg';
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);
      
//       // إغلاق مؤشر التحميل
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       } else {
//         loadingDialogCompleter.complete();
//       }
      
//       // مشاركة الصورة
//       await Share.shareFiles(
//         [filePath],
//         text: 'شاهد هذا المحتوى المميز من رادار 📱✨',
//         subject: 'مشاركة من رادار',
//       );
//     } catch (e) {
//       print("خطأ أثناء مشاركة صورة الريل: $e");
      
//       // إغلاق مؤشر التحميل
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       } else {
//         loadingDialogCompleter.complete();
//       }
      
//       _showErrorSnackbar('مشاركة الصورة', e.toString());
//     }
//   }
  
//   // إنشاء رابط عميق
//   String _generateDeepLink(Reel reel) {
//     final baseWebUrl = "https://radar.anycode-sy.com/reel/${reel.id}";
    
//     final params = {
//       'source': 'app',
//       'utm_source': 'share',
//       'utm_medium': 'app_share',
//       'content_type': reel.isVideoMedia(0) ? 'video' : 'image',
//       'owner': Uri.encodeComponent(reel.ownerName),
//       'share_time': DateTime.now().millisecondsSinceEpoch.toString(),
//     };
    
//     final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    
//     return '$baseWebUrl?$queryString';
//   }
  
//   // عرض رسالة خطأ
//   void _showErrorSnackbar(String action, String errorDetails) {
//     // تبسيط رسالة الخطأ للمستخدم
//     final userMessage = errorDetails.contains('Exception:')
//         ? errorDetails.split('Exception:')[1].trim()
//         : 'لم نتمكن من إتمام العملية، يرجى المحاولة مرة أخرى.';
    
//     Get.snackbar(
//       'خطأ في $action',
//       userMessage,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red.withOpacity(0.7),
//       colorText: Colors.white,
//       duration: Duration(seconds: 3),
//     );
//   }
  
//   // تبديل حالة توسيع وصف الريل
//   void toggleCaptionExpansion(String reelId) {
//     expandedCaptions[reelId] = !(expandedCaptions[reelId] ?? false);
//     update(['caption_$reelId']);
//   }
  
//   // إعادة تعيين كل أوصاف الريلز المتوسعة
//   void resetExpandedCaptions() {
//     expandedCaptions.clear();
//     update();
//   }
  
//   // عرض تفاصيل المتجر
//   Future<void> showStoreDetails(String storeId) async {
//     pauseAllVideos();
    
//     // متغيرات مراقبة حالة التحميل
//     final isLoading = true.obs;
//     final storeDataRx = Rxn<Map<String, dynamic>>();
//     final errorMessageRx = RxnString();
    
//     // عرض bottom sheet
//     Get.bottomSheet(
//       Obx(() => Container(
//         height: Get.height * 0.75,
//         decoration: BoxDecoration(
//           color: Color(0xFF1E1E1E),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             // مقبض السحب
//             Container(
//               margin: EdgeInsets.only(top: 10, bottom: 5),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[600],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
            
//             // المحتوى
//             Expanded(
//               child: isLoading.value
//                 ? StoreDetailsSkeleton()
//                 : errorMessageRx.value != null
//                   ? ErrorView(
//                       message: errorMessageRx.value,
//                       onRetry: () => _retryLoadStoreDetails(
//                         storeId, isLoading, storeDataRx, errorMessageRx),
//                     )
//                   : storeDataRx.value != null
//                     ? StoreDetailsContent(
//                         storeData: storeDataRx.value!,
//                         launchWhatsApp: _launchWhatsApp,
//                       )
//                     : ErrorView(message: 'حدث خطأ غير متوقع'),
//             ),
//           ],
//         ),
//       )),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       isDismissible: false,
//       enableDrag: true,
//     );
    
//     // تحميل البيانات
//     _loadStoreDetails(storeId, isLoading, storeDataRx, errorMessageRx);
//   }
  
//   // تحميل بيانات المتجر
//   Future<void> _loadStoreDetails(
//     String storeId,
//     RxBool isLoading,
//     Rxn<Map<String, dynamic>> storeDataRx,
//     RxnString errorMessageRx
//   ) async {
//     try {
//       // جلب بيانات المتجر
//       final storeData = await _reelsApiService.getStoreDetails(storeId);
      
//       // تحديث البيانات
//       storeDataRx.value = storeData;
//       errorMessageRx.value = null;
//     } catch (e) {
//       // تحديث رسالة الخطأ
//       errorMessageRx.value = 'فشل في تحميل بيانات المتجر، يرجى المحاولة مرة أخرى';
      
//       // عرض رسالة الخطأ
//       CustomToast.showErrorToast(
//         message: 'فشل في تحميل بيانات المتجر، يرجى المحاولة مرة أخرى'
//       );
      
//       print("خطأ في تحميل بيانات المتجر: $e");
//     } finally {
//       // إيقاف حالة التحميل
//       isLoading.value = false;
//     }
//   }
  
//   // إعادة محاولة تحميل بيانات المتجر
//   Future<void> _retryLoadStoreDetails(
//     String storeId,
//     RxBool isLoading,
//     Rxn<Map<String, dynamic>> storeDataRx,
//     RxnString errorMessageRx
//   ) async {
//     isLoading.value = true;
//     await _loadStoreDetails(storeId, isLoading, storeDataRx, errorMessageRx);
//   }
  
//   // فتح رابط واتساب في صفحة المتجر
//   void _launchWhatsApp(String url) async {
//     try {
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         CustomToast.showErrorToast(message: 'لا يمكن فتح تطبيق واتساب');
//       }
//     } catch (e) {
//       CustomToast.showErrorToast(message: 'حدث خطأ أثناء فتح واتساب');
//       print("خطأ في فتح واتساب: $e");
//     }
//   }
  
//   // تنظيف الموارد عند إغلاق الكنترولر
//   @override
//   void onClose() {
//     print('🔄 بدء إغلاق ReelsController');
    
//     // التحقق من الريل الحالي قبل الإغلاق
//     final currentIndex = currentReelIndex.value;
//     if (currentIndex >= 0 && currentIndex < reels.length) {
//       checkAndMarkReelAsViewed(currentIndex);
//     }
    
//     // إلغاء المستمعات
//     pageController.removeListener(_onPageScroll);
    
//     // إيقاف جميع الفيديوهات
//     videoManager.stopAllVideosExcept(null);
    
//     // التخلص من جميع المتحكمات
//     videoManager.disposeAllControllers();
    
//     // التخلص من متحكمات الرسوم المتحركة
//     storyAnimationController.dispose();
//     reelAnimationController.dispose();
//     pageController.dispose();
    
//     // التخلص من متحكمات الوسائط
//     for (var controller in mediaControllers.values) {
//       controller.dispose();
//     }
    
//     // تنظيف ذاكرة الصور المؤقتة
//     cleanupImageCache();
    
//     // تعطيل إبقاء الشاشة مضاءة
//     Wakelock.disable();
    
//     print('✅ تم إغلاق ReelsController بنجاح');
//     super.onClose();
//   }
// }

// /// فئة خيار المشاركة
// class ShareOption {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;
  
//   ShareOption({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });
// }