// // test
// import 'dart:async';
// import 'dart:io';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:better_player/better_player.dart';
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

// // إضافة هذه الفئة الجديدة لإدارة الصوت بشكل متقدم
// class AdvancedAudioManager {
//   // حالة التقليب السريع
//   bool _isFastSwitching = false;
//   DateTime _lastSwitchTime = DateTime.now();

//   // حدود التقليب السريع (بالمللي ثانية)
//   final int _fastSwitchingThreshold = 500;

//   // قائمة انتظار الصوت
//   final Map<String, Timer> _audioActivationTimers = {};
//   final Map<String, BetterPlayerController> _pendingControllers = {};

//   // متغير لتخزين الفيديو النشط حالياً
//   String? _currentActiveVideoId;

//   // متغير للتحكم في حالة كتم الصوت
//   final RxBool isMuted;

//   AdvancedAudioManager(this.isMuted);

//   // تسجيل الفيديو النشط ومراقبة التقليب السريع
//   void registerActiveVideo(String id) {
//     // تعيين الفيديو النشط
//     final DateTime now = DateTime.now();
//     final Duration timeSinceLastSwitch = now.difference(_lastSwitchTime);

//     // تحديث متغير التقليب السريع
//     _isFastSwitching =
//         timeSinceLastSwitch.inMilliseconds < _fastSwitchingThreshold;

//     // تحديث الزمن
//     _lastSwitchTime = now;
//     _currentActiveVideoId = id;

//     print(
//         '🔊 تسجيل فيديو نشط: $id (تقليب سريع: ${_isFastSwitching ? "نعم" : "لا"})');
//   }

//   // جدولة تفعيل الصوت مع تأخير ديناميكي
//   void scheduleAudioActivation(String id, BetterPlayerController controller) {
//     // إلغاء أي مؤقتات سابقة
//     cancelPendingAudioActivation(id);

//     // حساب التأخير الديناميكي بناءً على حالة التقليب
//     int delayMs = _isFastSwitching ? 800 : 300;

//     print('🕒 جدولة تفعيل الصوت للفيديو-ID:$id بتأخير $delayMs مللي ثانية');

//     // تخزين المتحكم للاستخدام لاحقاً
//     _pendingControllers[id] = controller;

//     // إنشاء مؤقت جديد
//     _audioActivationTimers[id] = Timer(Duration(milliseconds: delayMs), () {
//       _activateAudioForVideo(id);
//     });
//   }

//   // تفعيل الصوت للفيديو
//   void _activateAudioForVideo(String id) {
//     // التحقق من أن الفيديو لا يزال نشطاً
//     if (_currentActiveVideoId != id) {
//       print('⏩ تخطي تفعيل الصوت للفيديو-ID:$id (لم يعد نشطاً)');
//       return;
//     }

//     // استخراج المتحكم
//     final controller = _pendingControllers[id];
//     if (controller == null) {
//       print('⚠️ لم يتم العثور على متحكم للفيديو-ID:$id');
//       return;
//     }

//     // تفعيل الصوت إذا لم يكن مكتوماً
//     print('🔊 تفعيل صوت الفيديو-ID:$id (حالة كتم الصوت: ${isMuted.value})');
//     controller.setVolume(isMuted.value ? 0.0 : 1.0);

//     // تنظيف
//     _pendingControllers.remove(id);
//     _audioActivationTimers.remove(id);
//   }

//   // إلغاء تفعيل الصوت المجدول
//   void cancelPendingAudioActivation(String id) {
//     final timer = _audioActivationTimers[id];
//     if (timer != null && timer.isActive) {
//       print('🛑 إلغاء تفعيل الصوت المجدول للفيديو-ID:$id');
//       timer.cancel();
//       _audioActivationTimers.remove(id);
//     }
//     _pendingControllers.remove(id);
//   }

//   // كتم صوت جميع الفيديوهات عدا واحد
//   void muteAllExcept(String? exceptId) {
//     print('🔇 كتم صوت جميع الفيديوهات عدا: ${exceptId ?? "لا شيء"}');

//     // إلغاء جميع المؤقتات
//     for (final id in _audioActivationTimers.keys.toList()) {
//       if (id != exceptId) {
//         cancelPendingAudioActivation(id);
//       }
//     }

//     // تحديث الفيديو النشط
//     _currentActiveVideoId = exceptId;
//   }

//   // تحديث حالة كتم الصوت
//   void updateMuteState(bool muted, String? currentVideoId) {
//     if (currentVideoId != null &&
//         _pendingControllers.containsKey(currentVideoId)) {
//       final controller = _pendingControllers[currentVideoId];
//       if (controller != null) {
//         controller.setVolume(muted ? 0.0 : 1.0);
//       }
//     }
//   }

//   // تنظيف الموارد
//   void dispose() {
//     for (final timer in _audioActivationTimers.values) {
//       timer.cancel();
//     }
//     _audioActivationTimers.clear();
//     _pendingControllers.clear();
//   }
// }

// class MemoryMonitor {
//   // إحصائيات استخدام الذاكرة
//   final RxDouble videoMemoryUsage = 0.0.obs;
//   final RxDouble imageMemoryUsage = 0.0.obs;
//   final RxInt activeControllers = 0.obs;
//   final RxInt preloadedVideos = 0.obs;
//   final RxMap<String, String> activeVideoStatus = <String, String>{}.obs;

//   // المستويات المسموح بها للتحميل المسبق
//   final int lowMemoryThreshold = 50; // ميغابايت
//   final int highMemoryThreshold = 200; // ميغابايت

//   // محددات الوقت
//   final Map<String, DateTime> controllerLastAccessTime = {};

//   // رصد استخدام الذاكرة
//   Future<double> getAppMemoryUsage() async {
//     double estimatedUsage = 0.0;

//     try {
//       // تقدير استخدام الذاكرة من حجم ملفات التخزين المؤقت
//       final tempDir = await getTemporaryDirectory();
//       final files = tempDir.listSync(recursive: true);

//       for (var file in files) {
//         if (file is File) {
//           try {
//             final size = await file.length();
//             estimatedUsage += size / (1024 * 1024); // تحويل إلى ميغابايت
//           } catch (e) {
//             // تجاهل الملفات التي لا يمكن قراءتها
//           }
//         }
//       }
//     } catch (e) {
//       print('خطأ في حساب استخدام الذاكرة: $e');
//     }

//     return estimatedUsage;
//   }

//   // تحديث إحصائيات الذاكرة
//   Future<void> updateMemoryStats(
//       Map<String, BetterPlayerController> videoControllers) async {
//     try {
//       // حساب إحصائيات الذاكرة
//       final memoryUsage = await getAppMemoryUsage();

//       // تقدير استخدام الذاكرة للصور والفيديو
//       videoMemoryUsage.value = memoryUsage * 0.8; // تقديرياً 80% للفيديو
//       imageMemoryUsage.value = memoryUsage * 0.2; // تقديرياً 20% للصور

//       // تحديث عدد وحدات التحكم النشطة
//       activeControllers.value = videoControllers.length;

//       // طباعة حالة الذاكرة بعد كل تحديث
//       printMemoryStatus();
//     } catch (e) {
//       print('خطأ في تحديث إحصائيات الذاكرة: $e');
//     }
//   }

//   // طباعة حالة الذاكرة للمراقبة
//   void printMemoryStatus() {
//     print('===== حالة الذاكرة =====');
//     print(
//         '📊 استخدام ذاكرة الفيديو: ${videoMemoryUsage.value.toStringAsFixed(2)} MB');
//     print(
//         '🖼️ استخدام ذاكرة الصور: ${imageMemoryUsage.value.toStringAsFixed(2)} MB');
//     print('🎮 وحدات تحكم نشطة: ${activeControllers.value}');
//     print('📥 فيديوهات محملة مسبقاً: ${preloadedVideos.value}');

//     // طباعة حالة الفيديوهات النشطة
//     if (activeVideoStatus.isNotEmpty) {
//       print('📹 حالة الفيديوهات النشطة:');
//       activeVideoStatus.forEach((id, status) {
//         print('   - $id: $status');
//       });
//     }

//     print('=======================');
//   }

//   // التحقق من حالة الذاكرة
//   bool isLowMemory() {
//     return videoMemoryUsage.value + imageMemoryUsage.value > lowMemoryThreshold;
//   }

//   bool isCriticalMemory() {
//     return videoMemoryUsage.value + imageMemoryUsage.value >
//         highMemoryThreshold;
//   }

//   // تحديث آخر وقت وصول للمتحكم
//   void updateLastAccessTime(String id) {
//     controllerLastAccessTime[id] = DateTime.now();
//   }

//   // الحصول على المتحكمات الأقدم
//   List<String> getOldestControllers(
//       Map<String, BetterPlayerController> controllers,
//       int count,
//       String exceptId) {
//     final controllerIds =
//         controllers.keys.where((id) => id != exceptId).toList();

//     // ترتيب المتحكمات حسب آخر وقت وصول
//     controllerIds.sort((a, b) {
//       final timeA = controllerLastAccessTime[a] ?? DateTime.now();
//       final timeB = controllerLastAccessTime[b] ?? DateTime.now();
//       return timeA.compareTo(timeB);
//     });

//     // إرجاع أقدم المتحكمات
//     return controllerIds.take(count).toList();
//   }
// }

// // ------ 2. إضافة مدير التحميل المسبق المتقدم ------

// class AdvancedPreloadManager {
//   // خيارات التكوين
//   final int preloadVideoCount;
//   final int maxActiveControllers;
//   final Duration cleanupInterval;

//   // مراقب الذاكرة
//   final MemoryMonitor memoryMonitor;

//   // خرائط لمتابعة حالة التحميل
//   final Map<String, bool> preloadInProgress = {};
//   final Map<String, bool> preloadFailed = {};

//   // مؤقتات التنظيف
//   Timer? cleanupTimer;

//   AdvancedPreloadManager({
//     this.preloadVideoCount = 2,
//     this.maxActiveControllers = 4,
//     this.cleanupInterval = const Duration(minutes: 1),
//     required this.memoryMonitor,
//   }) {
//     // بدء المؤقت الدوري للتنظيف
//     _startCleanupTimer();
//   }

//   void _startCleanupTimer() {
//     cleanupTimer?.cancel();
//     cleanupTimer = Timer.periodic(cleanupInterval, (_) {
//       // الطباعة فقط - التنظيف الفعلي يتم من خلال الدالة المعلنة
//       print(
//           '🧹 تم تشغيل مؤقت التنظيف الدوري (مجدول كل: ${cleanupInterval.inMinutes} دقيقة)');
//     });
//   }

//   // التوقف وتنظيف الموارد
//   void dispose() {
//     cleanupTimer?.cancel();
//     preloadInProgress.clear();
//     preloadFailed.clear();
//   }

//   // تحديد عدد الفيديوهات للتحميل المسبق بناءً على حالة الذاكرة
//   int getAdjustedPreloadCount() {
//     if (memoryMonitor.isCriticalMemory()) {
//       return 0; // إيقاف التحميل المسبق في حالة الذاكرة الحرجة
//     } else if (memoryMonitor.isLowMemory()) {
//       return 1; // تقليل التحميل المسبق في حالة الذاكرة المنخفضة
//     } else {
//       return preloadVideoCount; // العدد العادي
//     }
//   }

//   // التحقق من إمكانية التحميل المسبق
//   bool canPreloadMore(Map<String, BetterPlayerController> controllers) {
//     final currentCount = controllers.length;
//     final maxAllowed = memoryMonitor.isCriticalMemory()
//         ? 2 // في الذاكرة الحرجة، سمح فقط بمتحكمين
//         : (memoryMonitor.isLowMemory()
//             ? maxActiveControllers - 1
//             : maxActiveControllers);

//     return currentCount < maxAllowed;
//   }

//   // منع تكرار التحميل المسبق لنفس الفيديو
//   bool shouldSkipPreload(
//       String id, Map<String, BetterPlayerController> controllers) {
//     return controllers.containsKey(id) ||
//         preloadInProgress[id] == true ||
//         (preloadFailed[id] == true);
//   }

//   // مسح سجل الإخفاقات السابقة للسماح بإعادة المحاولة
//   void resetFailedPreloads() {
//     preloadFailed.clear();
//     print('⚠️ تم مسح سجل إخفاقات التحميل المسبق، سيتم السماح بإعادة المحاولة');
//   }
// }

// /// Abstract class that defines the interface for Reels Controller
// abstract class AbstractReelsController extends GetxController
//     with GetTickerProviderStateMixin {
//   // ------------------ Getters ------------------

//   /// Get current reel
//   Reel get currentReel;

//   /// Get current media URLs
//   List<String> get currentMediaUrls;

//   // ------------------ Observable Variables ------------------

//   /// List of all reels
//   final reels = <Reel>[].obs;

//   /// Current reel index
//   final currentReelIndex = 0.obs;

//   /// Current media index within a reel
//   final currentMediaIndex = 0.obs;

//   /// Map of liked reels by ID
//   final likedReels = <String, bool>{}.obs;

//   /// Map of viewed reels by ID
//   final viewedReels = <String, bool>{}.obs;

//   /// Map of whatsapped reels by ID
//   final whatsappedReels = <String, bool>{}.obs;

//   // ------------------ Lifecycle Methods ------------------

//   /// Initialize controller
//   @override
//   void onInit();

//   /// Clean up resources
//   @override
//   void onClose();

//   // ------------------ Reel Loading Methods ------------------

//   /// Fetch initial reels from API
//   Future<void> _fetchReels();

//   /// Load more reels (pagination)
//   Future<void> loadMoreReels();

//   /// Refresh reels (pull to refresh)
//   Future<void> refreshReels();

//   // ------------------ Interaction Methods ------------------

//   /// Toggle like state for a reel
//   void toggleLike(int index);

//   /// Mark a reel as viewed
//   void markAsViewed(int index);

//   /// Mark a reel as whatsapp clicked
//   void markAsWhatsappClicked(int index);

//   /// Handle page scroll
//   void _onPageScroll();

//   // ------------------ Navigation Methods ------------------

//   /// Called when reel page changes
//   void onReelPageChanged(int index);

//   /// Called when media page changes within a reel
//   void onMediaPageChanged(int index);

//   /// Get media controller for a specific reel
//   PageController getMediaController(int index);

//   /// Handle horizontal drag for navigation
//   void handleHorizontalDrag(DragEndDetails details, int index, int mediaCount);

//   /// Handle double tap (like)
//   void handleDoubleTap(int index);

//   // ------------------ Video Control Methods ------------------

//   /// Initialize video player
//   Future<void> initializeVideo(String id, String url);

//   /// Preload video
//   Future<void> preloadVideo(String id, String url);

//   /// Play video
//   void playVideo(String id);

//   /// Pause video
//   void pauseVideo(String id);

//   /// Pause all videos
//   void pauseAllVideos();

//   /// Toggle video playback state
//   void toggleVideoPlayback(String id);

//   /// Stop all videos except the one with the given ID
//   void stopAllVideosExcept(String? exceptId);

//   /// Check if video is playing
//   bool isVideoPlaying(String id);

//   /// Check if video is initialized
//   bool isVideoInitialized(String id);

//   /// Get video aspect ratio
//   double? getVideoAspectRatio(String id);

//   // ------------------ Helper Methods ------------------

//   /// Check if URL is a video URL
//   bool isVideoUrl(String url);

//   /// Cleanup distant controllers to free memory
//   void cleanupDistantControllers(int currentIndex);

//   /// Cleanup all controllers
//   void cleanupAllControllers();

//   /// Dispose a specific controller
//   Future<void> disposeController(String id);

//   /// Clean up image cache
//   void cleanupImageCache();

//   /// Preload adjacent videos
//   Future<void> preloadAdjacentVideos(int currentIndex);

//   /// Initialize controllers
//   void _initControllers();

//   /// Check and mark reel as viewed based on watch progress
//   void checkAndMarkReelAsViewed(int index);

//   /// Start image watch timer
//   void startImageWatchTimer(int index);

//   // ------------------ Helper Methods (Private) ------------------

//   /// Update video aspect ratio
//   void _updateAspectRatio(String id);

//   /// Update video progress
//   void _updateVideoProgress(String id);

//   /// Revert like state if API call fails
//   void _revertLikeState(
//       int index, bool originalLikeState, int originalLikeCount);

//   /// Revert view state if API call fails
//   void _revertViewState(int index, int originalViewCount);

//   /// Get video format from URL
//   BetterPlayerVideoFormat _getVideoFormat(String url);
// }

// class ReelsController extends AbstractReelsController {
//   // API Service
//   final ReelsApiService _reelsApiService = ReelsApiService();

//   // Controllers
//   final pageController = PageController();
//   late AnimationController storyAnimationController;
//   late AnimationController reelAnimationController;
//   final Map<String, PageController> mediaControllers = {};

//   // تكوين ثوابت للتحكم في التحميل المسبق والأداء
//   final int preloadDistance = 0;
//   final int maxActiveControllers = 2;
//   final int cleanupInterval = 8; // تنظيف الذاكرة المؤقتة كل 5 ريلز

//   // Observable Variables
//   final reels = <Reel>[].obs;
//   final currentReelIndex = 0.obs;
//   final currentMediaIndex = 0.obs;
//   final likedReels = <String, bool>{}.obs;
//   final viewedReels = <String, bool>{}.obs;
//   final whatsappedReels = <String, bool>{}.obs;

//   // حالات التحميل والأخطاء
//   final isLoading = true.obs;
//   final hasError = false.obs;
//   final errorMessage = ''.obs;
//   final isLoadingMore = false.obs;
//   final hasMoreReels = true.obs;
//   final isRefreshing = false.obs;

//   // متغيرات متعلقة بالفيديو
//   final Map<String, BetterPlayerController> videoControllers = {};
//   final Map<String, bool> playingStates = <String, bool>{}.obs;
//   final Map<String, bool> preloadedVideos = {};
//   final Map<String, double?> videoAspectRatios = {};
//   final Map<String, bool> videoErrorStates = <String, bool>{}.obs;
//   final Map<String, bool> videoLoadingStates = <String, bool>{}.obs;

//   final Map<String, double> imageAspectRatios = <String, double>{};

//   final Map<String, bool> expandedCaptions = <String, bool>{};

//   String? currentActiveVideoId;
//   bool isPerformingCleanup = false;

//   final Map<String, bool> reelWatchProgress = <String, bool>{}.obs;
//   final Map<String, DateTime> reelWatchStartTimes = <String, DateTime>{};
//   final Map<String, double> videoProgressValues =
//       <String, double>{}.obs; // لتخزين قيمة تقدم كل فيديو (0.0 إلى 1.0)
//   final double viewThreshold =
//       0.5; // نسبة المشاهدة المطلوبة لاعتبار الريل مشاهداً (50%)
//   final Duration minWatchDuration =
//       Duration(seconds: 2); // الحد الأدنى لوقت المشاهدة

//   // متحولات الجوهرة
//   final isShowingGemAnimation = false.obs;
//   final gemPoints = 0.obs;
//   final gemColor = ''.obs;

//   final Map<String, bool> shineAnimationShown = <String, bool>{}.obs;
//   final Map<String, bool> shineAnimationActive = <String, bool>{}.obs;

//   final RxBool isMuted = false.obs;

//   late MemoryMonitor _memoryMonitor;
//   late AdvancedPreloadManager _preloadManager;
//   late AdvancedAudioManager _audioManager;

//   bool _isPerformingCleanup = false;

//   // متغير تتبع وقت آخر تغيير للريل
//   DateTime _lastReelSwitchTime = DateTime.now();

//   Future<void> preloadAdjacentContent(int currentIndex) async {
//     // تخطي التحميل المسبق أثناء التقليب السريع
//     if (_isRapidSwiping) {
//       print('⚡ تم تخطي التحميل المسبق بسبب التقليب السريع');
//       return;
//     }

//     print('🔄 بدء التحميل المسبق للمحتوى المجاور للريل: $currentIndex');

//     // التحقق من سرعة تقليب الريلز
//     final now = DateTime.now();
//     final timeSinceLast = now.difference(_lastReelSwitchTime);
//     print(
//         "====================== timeSinceLast  ${timeSinceLast.inMilliseconds}");
//     final isFastSwitching = timeSinceLast.inMilliseconds < 100;

//     // تحديث إحصائيات الذاكرة أولاً
//     await _memoryMonitor.updateMemoryStats(videoControllers);

//     // تحديد عدد الفيديوهات للتحميل المسبق بناءً على حالة الذاكرة وسرعة التقليب
//     int preloadCount = _preloadManager.getAdjustedPreloadCount();

//     // تقليل التحميل المسبق عند التقليب السريع
//     if (isFastSwitching) {
//       preloadCount = preloadCount > 0 ? 1 : 0;
//       print('⚡ تم تقليل التحميل المسبق بسبب التقليب السريع');
//     }

//     print('📊 مستوى التحميل المسبق الحالي: $preloadCount فيديو');

//     if (preloadCount <= 0) {
//       print('⚠️ تم تعليق التحميل المسبق بسبب قيود الذاكرة أو التقليب السريع');
//       return;
//     }

//     // 1. الريل التالي بأولوية قصوى (دائماً)
//     final nextIndex = currentIndex + 1;
//     if (nextIndex < reels.length) {
//       await _preloadReelMedia(nextIndex, highPriority: true);
//     }

//     // 2. الريل السابق بأولوية متوسطة (فقط إذا كان هناك أكثر من واحد للتحميل)
//     if (preloadCount > 1 && !isFastSwitching) {
//       final prevIndex = currentIndex - 1;
//       if (prevIndex >= 0) {
//         await _preloadReelMedia(prevIndex, highPriority: false);
//       }
//     }

//     // 3. المزيد من الريلز المستقبلية بأولوية منخفضة (فقط في حالة الذاكرة الجيدة ولا يوجد تقليب سريع)
//     if (preloadCount > 2 && !_memoryMonitor.isLowMemory() && !isFastSwitching) {
//       Future.delayed(Duration(milliseconds: 300), () {
//         // التحقق مرة أخرى من أن الريل لم يتغير
//         if (currentReelIndex.value == currentIndex) {
//           _preloadFutureReels(currentIndex, preloadCount - 2);
//         }
//       });
//     }

//     print('✅ اكتمل جدول التحميل المسبق للمحتوى المجاور');
//   }

// // دالة مساعدة للتحميل المسبق للريلز المستقبلية
//   Future<void> _preloadFutureReels(int currentIndex, int count) async {
//     print(
//         '🔮 جدولة التحميل المسبق لـ $count ريل مستقبلي من الموقع $currentIndex');

//     for (int i = 2; i <= count + 1; i++) {
//       final targetIndex = currentIndex + i;
//       if (targetIndex < reels.length) {
//         // إضافة تأخير متزايد للريلز الأبعد
//         final delay = 200 * (i - 1);
//         await Future.delayed(Duration(milliseconds: delay));

//         // التحقق من الذاكرة مرة أخرى قبل كل تحميل
//         if (_memoryMonitor.isLowMemory()) {
//           print('⚠️ تم إلغاء التحميل المسبق المستقبلي بسبب انخفاض الذاكرة');
//           break;
//         }

//         await _preloadReelMedia(targetIndex, highPriority: false);
//       }
//     }
//   }

// // دالة تحميل محتوى الريل مسبقاً
//   Future<void> _preloadReelMedia(int index, {bool highPriority = false}) async {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];
//     final reelId = reel.id;
//     final priority = highPriority ? "عالية" : "عادية";

//     print('🔍 فحص الريل[$index]-ID:$reelId للتحميل المسبق بأولوية $priority');

//     // تخطي إذا كانت الذاكرة منخفضة ولم تكن الأولوية عالية
//     if (!highPriority && _memoryMonitor.isLowMemory()) {
//       print('⏩ تخطي التحميل المسبق للريل[$index] بسبب انخفاض الذاكرة');
//       return;
//     }

//     if (reel.mediaUrls.isEmpty) {
//       print('⚠️ الريل[$index] لا يحتوي على وسائط للتحميل المسبق');
//       return;
//     }

//     // تحميل أول وسيلة إعلامية في الريل
//     final firstMedia = reel.mediaUrls[0];

//     if (reel.isVideoMedia(0)) {
//       if (_preloadManager.canPreloadMore(videoControllers)) {
//         // الفحص قبل التحميل المسبق
//         if (_preloadManager.shouldSkipPreload(reelId, videoControllers)) {
//           print(
//               '⏩ تخطي التحميل المسبق للفيديو[$index]-ID:$reelId (محمل مسبقاً أو قيد التحميل)');
//           return;
//         }

//         // تحميل البوستر أولاً
//         if (firstMedia.poster != null && firstMedia.poster!.isNotEmpty) {
//           await _preloadVideoPoster(reelId, firstMedia.poster!);
//         }

//         // ثم تحميل الفيديو مسبقاً
//         print(
//             '📥 بدء التحميل المسبق للفيديو[$index]-ID:$reelId بأولوية $priority');

//         // تحديث الحالة لمنع التحميل المتكرر
//         _preloadManager.preloadInProgress[reelId] = true;
//         _memoryMonitor.activeVideoStatus[reelId] = "جاري التحميل المسبق";

//         preloadVideo(reelId, firstMedia.url, firstMedia.poster).then((_) {
//           print('✅ اكتمل التحميل المسبق للفيديو[$index]-ID:$reelId');
//           _preloadManager.preloadInProgress[reelId] = false;
//           _memoryMonitor.activeVideoStatus[reelId] = "محمل مسبقاً - جاهز";
//           _memoryMonitor.preloadedVideos.value++;
//         }).catchError((e) {
//           print('❌ فشل التحميل المسبق للفيديو[$index]-ID:$reelId: $e');
//           _preloadManager.preloadInProgress[reelId] = false;
//           _preloadManager.preloadFailed[reelId] = true;
//           _memoryMonitor.activeVideoStatus.remove(reelId);
//         });
//       } else {
//         print(
//             '⚠️ تخطي التحميل المسبق للفيديو[$index]-ID:$reelId (وصل للحد الأقصى من المتحكمات)');
//       }
//     } else {
//       // تحميل الصورة مسبقاً
//       print('🖼️ بدء التحميل المسبق للصورة[$index]-ID:$reelId');
//       _precacheImageOptimized(firstMedia.url, highPriority: highPriority);
//     }
//   }

//   Future<void> preloadVideo(String id, String url, [String? posterUrl]) async {
//     if (videoControllers.containsKey(id)) {
//       print('⏩ تخطي التحميل المسبق للفيديو-ID:$id (موجود مسبقاً)');
//       return;
//     }

//     print('📥 بدء تهيئة التحميل المسبق للفيديو-ID:$id');
//     _memoryMonitor.updateLastAccessTime(id);

//     try {
//       // تنظيف المتحكمات غير الضرورية عند الحاجة
//       if (!_preloadManager.canPreloadMore(videoControllers) &&
//           videoControllers.isNotEmpty) {
//         final oldestIds = _memoryMonitor.getOldestControllers(
//             videoControllers, 1, currentActiveVideoId ?? "");

//         for (final oldId in oldestIds) {
//           print('🧹 حذف متحكم قديم ($oldId) لإفساح المجال للتحميل المسبق');
//           await disposeController(oldId);
//         }
//       }

//       // تكوين محسن لمتحكم الفيديو
//       final betterPlayerConfiguration = BetterPlayerConfiguration(
//         autoPlay: false,
//         looping: true,
//         fit: BoxFit.contain,
//         expandToFill: false,
//         controlsConfiguration: BetterPlayerControlsConfiguration(
//           showControls: false,
//           enableOverflowMenu: false,
//           enablePlaybackSpeed: false,
//           enableSubtitles: false,
//           enableQualities: false,
//           enablePip: false,
//         ),
//         handleLifecycle: false,
//         autoDispose: false,
//         startAt: Duration.zero,
//         allowedScreenSleep: true,
//         // تحسين التشغيل السريع للفيديو
//         playerVisibilityChangedBehavior: (visibilityFraction) {
//           // لا نفعل شيئاً عند تغير الرؤية خلال التحميل المسبق
//         },
//       );

//       final videoFormat = _getVideoFormat(url);
//       // إعدادات محسنة للتخزين المؤقت والتشغيل
//       final betterPlayerDataSource = BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         url,
//         videoFormat: videoFormat,
//         cacheConfiguration: BetterPlayerCacheConfiguration(
//           useCache: true,
//           maxCacheSize: 100 * 1024 * 1024, // 100MB للتخزين المؤقت
//           maxCacheFileSize: 15 * 1024 * 1024, // 15MB لكل ملف
//           preCacheSize: 3 * 1024 * 1024, // 3MB للتحميل المسبق
//         ),
//         // تحسين إعدادات التخزين المؤقت للتشغيل السريع
//         bufferingConfiguration: BetterPlayerBufferingConfiguration(
//           minBufferMs: 5000, // تقليل الحد الأدنى للتخزين المؤقت لتسريع التشغيل
//           maxBufferMs: 30000, // الحد الأقصى للتخزين المؤقت
//           bufferForPlaybackMs: 500, // خفض المدة المطلوبة قبل البدء
//           bufferForPlaybackAfterRebufferMs:
//               1000, // خفض المدة المطلوبة بعد إعادة التخزين المؤقت
//         ),
//       );

//       final controller = BetterPlayerController(betterPlayerConfiguration);

//       // إضافة مستمع أحداث محسن للتعامل مع المؤشرات
//       controller.addEventsListener((event) {
//         final eventType = event.betterPlayerEventType;

//         if (eventType == BetterPlayerEventType.exception) {
//           print('❌ خطأ في التحميل المسبق للفيديو-ID:$id: ${event.parameters}');
//           _preloadManager.preloadFailed[id] = true;
//           _memoryMonitor.activeVideoStatus.remove(id);
//           controller.dispose();
//         } else if (eventType == BetterPlayerEventType.initialized) {
//           // تحديث نسبة أبعاد الفيديو عند التهيئة
//           try {
//             final videoData = controller.videoPlayerController!.value;
//             if (videoData.size != null &&
//                 videoData.size!.width > 0 &&
//                 videoData.size!.height > 0) {
//               videoAspectRatios[id] =
//                   videoData.size!.width / videoData.size!.height;
//             } else {
//               videoAspectRatios[id] = 9.0 / 16.0; // قيمة افتراضية
//             }
//           } catch (e) {
//             print('⚠️ خطأ في حساب نسبة أبعاد الفيديو-ID:$id: $e');
//             videoAspectRatios[id] = 9.0 / 16.0; // قيمة افتراضية
//           }

//           // تهيئة قيمة التقدم
//           videoProgressValues[id] = 0.0;
//         } else if (eventType == BetterPlayerEventType.progress) {
//           // تحديث قيمة التقدم حتى للفيديوهات المحملة مسبقاً
//           try {
//             final position = controller.videoPlayerController!.value.position;
//             final duration = controller.videoPlayerController!.value.duration;

//             if (duration != null &&
//                 duration.inMilliseconds > 0 &&
//                 position.inMilliseconds > 0) {
//               final progress =
//                   position.inMilliseconds / duration.inMilliseconds;
//               videoProgressValues[id] = progress;
//             }
//           } catch (e) {
//             // تجاهل الأخطاء في تحديث التقدم للفيديوهات المحملة مسبقاً
//           }
//         }
//       });

//       // إعداد مصدر البيانات وكتم الصوت
//       await controller.setupDataSource(betterPlayerDataSource);
//       await controller.setVolume(0.0);
//       await controller.pause();

//       // تخزين المتحكم
//       videoControllers[id] = controller;
//       _memoryMonitor.updateLastAccessTime(id);
//       preloadedVideos[id] = true; // تحديد أن الفيديو تم تحميله مسبقاً

//       print('✅ اكتمل التحميل المسبق للفيديو-ID:$id');

//       // تأخير قصير ثم تحميل جزء من الفيديو مسبقاً
//       await Future.delayed(Duration(milliseconds: 100));
//       try {
//         await controller.seekTo(Duration(seconds: 0)); // البدء من الثانية صفر
//         print('🎬 تم تحميل بداية الفيديو-ID:$id مسبقاً');
//       } catch (seekError) {
//         // تجاهل أخطاء البحث
//       }
//     } catch (e) {
//       print('❌ خطأ عام في التحميل المسبق للفيديو-ID:$id: $e');
//       _preloadManager.preloadFailed[id] = true;
//       _memoryMonitor.activeVideoStatus.remove(id);
//       await disposeController(id);
//     }
//   }

// // تحميل البوستر مسبقاً
//   Future<void> _preloadVideoPoster(String id, String posterUrl) async {
//     try {
//       print('🖼️ تحميل صورة البوستر مسبقاً للفيديو-ID:$id');
//       await precacheImage(CachedNetworkImageProvider(posterUrl), Get.context!);
//       print('✅ اكتمل تحميل صورة البوستر للفيديو-ID:$id');
//     } catch (e) {
//       print('⚠️ فشل تحميل صورة البوستر للفيديو-ID:$id: $e');
//     }
//   }

// // دالة مُحسّنة لتحميل الصورة مسبقاً
//   void _precacheImageOptimized(String url, {bool highPriority = false}) {
//     if (Get.context != null) {
//       try {
//         final priority = highPriority ? "عالية" : "عادية";
//         print('🖼️ تحميل الصورة مسبقاً: $url (أولوية: $priority)');

//         precacheImage(
//           CachedNetworkImageProvider(
//             url,
//             cacheKey: 'preload_$url',
//           ),
//           Get.context!,
//         ).then((_) {
//           print('✅ اكتمل تحميل الصورة مسبقاً: $url');
//         }).catchError((e) {
//           print('⚠️ فشل تحميل الصورة مسبقاً: $url - $e');
//         });
//       } catch (e) {
//         print('❌ خطأ في تحميل الصورة مسبقاً: $url - $e');
//       }
//     }
//   }

//   void toggleLike(int index) async {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];

//     // حفظ الحالة الحالية قبل التغيير للرجوع إليها في حالة الفشل
//     final currentLikeState = likedReels[reel.id] ?? false;
//     final currentLikeCount = reel.counts.likedBy;

//     // التحديث المتفائل - تغيير الحالة فوراً قبل استجابة API
//     final newLikeState = !currentLikeState;

//     // تحديث حالة الإعجاب في الخريطة فوراً
//     likedReels[reel.id] = newLikeState;

//     // تحديث عداد الإعجابات مباشرة
//     if (newLikeState) {
//       // إضافة إعجاب
//       reel.counts.likedBy += 1;
//     } else {
//       // إلغاء إعجاب
//       reel.counts.likedBy -= 1;
//       if (reel.counts.likedBy < 0) reel.counts.likedBy = 0;
//     }

//     // تحديث حالة الإعجاب في الكائن مباشرة
//     reel.isLiked = newLikeState;

//     // تحديث الواجهة فقط
//     update();

//     // الآن نرسل الطلب إلى API (بشكل غير متزامن)
//     try {
//       final success = await _reelsApiService.likeContent(reel.id);

//       if (!success) {
//         // في حالة فشل الطلب، نعيد الحالة السابقة
//         _revertLikeState(index, currentLikeState, currentLikeCount);
//       }
//     } catch (e) {
//       print("خطأ في تحديث الإعجاب: $e");
//       // في حالة حدوث خطأ، نعيد الحالة السابقة
//       _revertLikeState(index, currentLikeState, currentLikeCount);
//     }
//   }

//   // دالة لتبديل حالة توسيع شرح الريل
//   void toggleCaptionExpansion(String reelId) {
//     // تبديل الحالة: من مطوي إلى موسع أو العكس
//     expandedCaptions[reelId] = !(expandedCaptions[reelId] ?? false);

//     // تحديث واجهة المستخدم، فقط للكابشن المحدد
//     update(['caption_$reelId']);
//   }

// // دالة مساعدة لإعادة الحالة في حالة الفشل
//   void _revertLikeState(
//       int index, bool originalLikeState, int originalLikeCount) {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];

//     // إعادة حالة الإعجاب الأصلية
//     likedReels[reel.id] = originalLikeState;

//     // تعديل مباشر للقيم
//     reel.counts.likedBy = originalLikeCount;
//     reel.isLiked = originalLikeState;

//     // تحديث الواجهة فقط
//     update();

//     // يمكنك إضافة إشعار للمستخدم هنا
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
//       // تسجيل النقرة في الباك إند وجلب رابط الواتساب
//       final response = await _reelsApiService.whatsappClick(reel.id);

//       // الحصول على رابط الواتساب من الاستجابة
//       final whatsappLink = response['whatsappLink'];

//       if (whatsappLink != null && whatsappLink.isNotEmpty) {
//         // فتح رابط الواتساب
//         launchWhatsApp(whatsappLink);

//         // تحديث العداد محلياً (اختياري)
//         whatsappedReels[reel.id] = true;
//         reel.counts.whatsappedBy += 1;
//         update();
//       }
//     } catch (e) {
//       print("خطأ في تسجيل نقرة واتساب: $e");
//     }
//   }

// // دالة فتح رابط الواتساب
//   void launchWhatsApp(String url) async {
//     try {
//       // استخدام مكتبة url_launcher
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         // إذا لم يتمكن من فتح الرابط، عرض رسالة

//         CustomToast.showErrorToast(
//             message: 'لا يمكن فتح واتساب. يرجى التأكد من تثبيت التطبيق.');
//       }
//     } catch (e) {
//       print("خطأ في فتح واتساب: $e");
//     }
//   }

//   // Getters
//   Reel get currentReel => reels[currentReelIndex.value];
//   List<String> get currentMediaUrls => currentReel.mediaUrlStrings;

//   void setupPlayStateSynchronizer() {
//     // التحقق من حالة تشغيل الفيديو الحالي كل 500 مللي ثانية
//     Timer.periodic(Duration(milliseconds: 500), (_) {
//       final currentId = currentActiveVideoId;
//       if (currentId != null && videoControllers.containsKey(currentId)) {
//         final controller = videoControllers[currentId];
//         if (controller?.videoPlayerController != null) {
//           final isActuallyPlaying =
//               controller!.videoPlayerController!.value.isPlaying;
//           final isMarkedAsPlaying = playingStates[currentId] ?? false;

//           // إذا لم تتطابق الحالة الفعلية مع الحالة المخزنة
//           if (isActuallyPlaying != isMarkedAsPlaying) {
//             print(
//                 '🔄 مزامنة حالة التشغيل للفيديو-ID:$currentId (فعلي: $isActuallyPlaying، مخزن: $isMarkedAsPlaying)');
//             playingStates[currentId] = isActuallyPlaying;
//             update();
//           }
//         }
//       }
//     });
//   }

//   @override
//   void onInit() {
//     super.onInit();

//     print('🚀 بدء تهيئة ReelsController');

//     // تهيئة نظام الوسائط المتقدم
//     initAdvancedMediaSystem();

//     // إعداد مزامن حالة التشغيل
//     setupPlayStateSynchronizer();

//     // إعداد الانتقالات السلسة
//     setupSmoothTransitions();
//     // تهيئة وحدات التحكم
//     _initControllers();

//     // جلب الريلز
//     _fetchReels().then((_) {
//       // بعد تحميل الريلز، التحقق من وجود طلب تنقل معلق
//       if (pendingDeepLinkReelId.value != null) {
//         final reelId = pendingDeepLinkReelId.value!;
//         print("🔄 العثور على طلب تنقل معلق إلى الريل: $reelId");

//         // تأخير صغير للتأكد من رسم واجهة المستخدم بالكامل
//         Future.delayed(Duration(milliseconds: 100), () {
//           navigateToReelById(reelId, fromDeepLink: true);
//           pendingDeepLinkReelId.value = null;
//         });
//       }
//     });

//     _setupControllerLeakDetection();
//     _startPeriodicMemoryCheck();

//     // إضافة مستمع لتمرير الصفحة
//     pageController.addListener(_onPageScroll);

//     // تفعيل إبقاء الشاشة مضاءة
//     Wakelock.enable();

//     print('✅ اكتملت تهيئة ReelsController');
//   }

//   void initAdvancedMediaSystem() {
//     // إنشاء نظام المراقبة والتحكم
//     _memoryMonitor = MemoryMonitor();
//     _preloadManager = AdvancedPreloadManager(
//       preloadVideoCount: 2, // عدد الفيديوهات للتحميل المسبق
//       maxActiveControllers: 4, // الحد الأقصى للمتحكمات النشطة
//       cleanupInterval: Duration(minutes: 2), // فاصل زمني للتنظيف الدوري
//       memoryMonitor: _memoryMonitor,
//     );

//     // إنشاء نظام إدارة الصوت المتقدم
//     _audioManager = AdvancedAudioManager(isMuted);

//     // جدولة تحديث دوري لحالة الذاكرة
//     Timer.periodic(Duration(seconds: 10), (_) {
//       _memoryMonitor.updateMemoryStats(videoControllers);
//     });

//     // إعداد مراقب دورة الحياة لإدارة التخزين المؤقت بشكل أفضل
//     SystemChannels.lifecycle.setMessageHandler((msg) {
//       _handleAppLifecycleChange(msg ?? '');
//       return Future.value(null);
//     });

//     print('✅ تم تهيئة نظام إدارة الوسائط المتقدم بنجاح');
//   }

//   final pendingDeepLinkReelId = Rx<String?>(null);

//   Future<void> _fetchReels() async {
//     try {
//       isLoading.value = true;
//       hasError.value = false;
//       errorMessage.value = '';

//       // جلب جميع الريلز
//       final fetchedReels = await _reelsApiService.getRelevantReels();

//       // التحقق مما إذا كان هناك طلب تنقل معلق من رابط مشاركة
//       final String? sharedReelId = pendingDeepLinkReelId.value;

//       if (sharedReelId != null) {
//         print("التحقق من وجود الريل المشارك في القائمة: $sharedReelId");

//         // البحث عن الريل المشارك في القائمة المجلوبة
//         final existingIndex =
//             fetchedReels.indexWhere((reel) => reel.id == sharedReelId);

//         if (existingIndex >= 0) {
//           print("الريل المشارك موجود بالفعل في الموقع: $existingIndex");

//           // إذا وجد الريل، نقوم بنقله إلى بداية القائمة
//           if (existingIndex > 0) {
//             final sharedReel = fetchedReels.removeAt(existingIndex);
//             fetchedReels.insert(0, sharedReel);
//             print("تم نقل الريل المشارك إلى بداية القائمة");
//           }
//         } else {
//           print("الريل المشارك غير موجود في القائمة، جلبه بشكل منفصل");

//           // الريل غير موجود في القائمة، نقوم بجلبه بشكل منفصل
//           final specificReel = await _reelsApiService.getReelById(sharedReelId);

//           if (specificReel != null) {
//             // إضافة الريل المشارك في بداية القائمة
//             fetchedReels.insert(0, specificReel);
//             print("تم جلب الريل المشارك بنجاح وإضافته في بداية القائمة");
//           } else {
//             print("تعذر العثور على الريل المشارك");
//           }
//         }

//         // لا نقوم بإعادة تعيين pendingDeepLinkReelId هنا، سيتم ذلك بعد التنقل
//       }

//       if (fetchedReels.isNotEmpty) {
//         // إيقاف جميع الفيديوهات وتنظيف المتحكمات قبل تحديث القائمة
//         stopAllVideosExcept(null);
//         cleanupAllControllers();

//         reels.assignAll(fetchedReels);

//         // تهيئة حالات الإعجاب والمشاهدة
//         for (var reel in fetchedReels) {
//           likedReels[reel.id] = reel.isLiked;
//           viewedReels[reel.id] = reel.isWatched;
//           whatsappedReels[reel.id] = reel.isWhatsapped;
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

//       // استخدام معرف آخر ريل كنقطة بداية للريلز الجديدة
//       final lastReel = reels.last;

//       final moreReels = await _reelsApiService.loadMoreReels(lastReel.id);

//       if (moreReels.isNotEmpty) {
//         reels.addAll(moreReels);

//         // تهيئة حالات الإعجاب والمشاهدة للريلز الجديدة
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

//   // تحديث الريلز (سحب للأسفل)
//   Future<void> refreshReels() async {
//     if (isRefreshing.value) return;

//     try {
//       // قم بتعيين علم التحميل
//       isRefreshing.value = true;

//       // هذا السطر مهم جداً - قم بإعادة تعيين حالة الخطأ قبل المحاولة الجديدة
//       hasError.value = false;

//       // أضف تأخيراً قصيراً ليشعر المستخدم بالتغيير
//       await Future.delayed(Duration(milliseconds: 300));

//       final freshReels = await _reelsApiService.getRelevantReels();

//       if (freshReels.isNotEmpty) {
//         // إيقاف جميع الفيديوهات قبل تحديث القائمة
//         stopAllVideosExcept(null);

//         // تنظيف وحدات التحكم
//         cleanupAllControllers();

//         // تحديث القائمة
//         reels.assignAll(freshReels);

//         // إعادة تهيئة حالات التفاعل
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
//       // تعيين حالة الخطأ ورسالة الخطأ
//       hasError.value = true;
//       errorMessage.value =
//           'حدث خطأ أثناء تحميل البيانات، يرجى المحاولة مرة أخرى';
//     } finally {
//       isRefreshing.value = false;
//     }
//   }

//   // دالة جديدة للتعامل مع المتحكمات التي ربما خرجت عن السيطرة
//   void killAllRunawayControllers() {
//     print('🚨 محاولة إيقاف جميع المتحكمات الخارجة عن السيطرة');

//     try {
//       // 1. أنشئ قائمة المتحكمات للمعالجة
//       final allControllers = videoControllers.keys.toList();
//       if (allControllers.isEmpty) {
//         print('ℹ️ لا توجد متحكمات نشطة لإيقافها');
//         return;
//       }

//       print('🔍 العثور على ${allControllers.length} متحكم للمعالجة');

//       // 2. أوقف صوت كل المتحكمات أولاً - بشكل متزامن
//       for (final id in allControllers) {
//         try {
//           final controller = videoControllers[id];
//           if (controller != null) {
//             controller.setVolume(0.0);
//             _memoryMonitor.activeVideoStatus[id] = "جاري الإيقاف القسري";
//           }
//         } catch (e) {
//           print('⚠️ خطأ في كتم صوت المتحكم-ID:$id: $e');
//         }
//       }

//       // 3. ثم أوقف تشغيل كل متحكم
//       for (final id in allControllers) {
//         try {
//           final controller = videoControllers[id];
//           if (controller != null) {
//             controller.pause();
//             playingStates[id] = false;
//           }
//         } catch (e) {
//           print('⚠️ خطأ في إيقاف المتحكم-ID:$id: $e');
//         }
//       }

//       // 4. ثم حاول إزالة المستمعين والتخلص من المتحكمات
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         for (final id in allControllers) {
//           try {
//             final controller = videoControllers[id];
//             if (controller != null) {
//               // إزالة مستمعي الأحداث
//               controller.removeEventsListener((event) {});
//             }
//           } catch (e) {
//             print('⚠️ خطأ في إزالة مستمعي الأحداث-ID:$id: $e');
//           }
//         }

//         // 5. حذف المتحكمات بالترتيب
//         Future.forEach(allControllers, (String id) async {
//           await disposeController(id);
//         }).then((_) {
//           // 6. تحديث حالة الذاكرة بعد حذف الكونترولرات
//           _memoryMonitor.updateMemoryStats(videoControllers);
//           _memoryMonitor.printMemoryStatus();
//         });
//       });

//       // 7. إعادة تعيين المتغيرات الأساسية
//       currentActiveVideoId = null;
//       _audioManager.muteAllExcept(null);

//       // 8. تأخير قصير ثم تنظيف أي ذاكرة متبقية
//       Future.delayed(Duration(milliseconds: 500), () {
//         // تنظيف الذاكرة المؤقتة للصور إذا كانت هناك ضغط على الذاكرة
//         if (_memoryMonitor.isLowMemory()) {
//           cleanupImageCache();
//         }
//       });

//       // 9. تحديث واجهة المستخدم
//       update();
//     } catch (e) {
//       print('❌ خطأ عام في killAllRunawayControllers: $e');
//     }
//   }

//   DateTime _lastScrollTime = DateTime.now();
//   double _lastScrollPosition = 0.0;
//   bool _isRapidSwiping = false;
//   final int _rapidSwipeThreshold = 200; // تقليل من 300 إلى 200 مللي ثانية
//   bool _isEmergencyCleanupActive = false;
//   int _consecutiveRapidSwipes =
//       0; // متغير جديد لتتبع عدد التقليبات السريعة المتتالية
//   final int _maxConsecutiveSwipesBeforeForceCleanup =
//       3; // بعد 3 تقليبات سريعة متتالية، نفذ تنظيفاً قسرياً

//   void _onPageScroll() {
//     if (pageController.hasClients) {
//       final now = DateTime.now();
//       final currentPosition = pageController.position.pixels;
//       final timeDiff = now.difference(_lastScrollTime).inMilliseconds;

//       // حساب سرعة التمرير فقط إذا كان الفاصل الزمني أكبر من صفر
//       if (timeDiff > 0) {
//         // حساب السرعة (بكسل/مللي ثانية)
//         final pixelsPerMs = (currentPosition - _lastScrollPosition) / timeDiff;
//         // تحويل إلى بكسل/ثانية لمقياس أكثر منطقية
//         final speedPixelsPerSecond = pixelsPerMs * 1000;

//         final wasRapidSwiping = _isRapidSwiping;
//         _isRapidSwiping = speedPixelsPerSecond.abs() >
//             1000; // عتبة معتدلة لاكتشاف التقليب السريع
//         final isExtremelyRapid =
//             speedPixelsPerSecond.abs() > 2500; // عتبة للتقليب السريع جداً

//         // تحديث عداد التقليب السريع المتتالي
//         if (_isRapidSwiping) {
//           if (wasRapidSwiping) {
//             _consecutiveRapidSwipes++;

//             if (_consecutiveRapidSwipes >=
//                     _maxConsecutiveSwipesBeforeForceCleanup &&
//                 !_isEmergencyCleanupActive) {
//               print(
//                   '⚠️⚠️⚠️ تم اكتشاف ${_consecutiveRapidSwipes} تقليبات سريعة متتالية! تنفيذ تنظيف قسري');
//               _forceCleanupAllControllers();
//               _consecutiveRapidSwipes = 0;
//             }
//           } else {
//             _consecutiveRapidSwipes = 1;
//           }
//         } else {
//           // إذا لم يكن هناك تقليب سريع، أعد تعيين العداد
//           _consecutiveRapidSwipes = 0;
//         }

//         // إذا كان التقليب سريعاً جداً، نفذ تنظيفاً طارئاً
//         if (isExtremelyRapid && !_isEmergencyCleanupActive) {
//           print('⚡⚡ تم اكتشاف تقليب سريع جداً، بدء تنظيف طارئ');
//           _performEmergencyCleanup();
//         }
//       }

//       // تحديث القيم للحساب التالي
//       _lastScrollPosition = currentPosition;
//       _lastScrollTime = now;

//       // تحميل المزيد من الريلز عند الاقتراب من النهاية
//       final currentPage = pageController.page?.round() ?? 0;
//       if (currentPage >= reels.length - 3) {
//         loadMoreReels();
//       }

//       // تنظيف دوري للكونترولرات البعيدة
//       if (currentPage % cleanupInterval == 0 && !_isPerformingCleanup) {
//         _isPerformingCleanup = true;
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           cleanupDistantControllers(currentPage);
//           _isPerformingCleanup = false;
//         });
//       }
//     }
//   }

//   void _initControllers() {
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

//   PageController getMediaController(int index) {
//     if (index < 0 || index >= reels.length) return PageController();

//     final reelId = reels[index].id;
//     if (!mediaControllers.containsKey(reelId)) {
//       mediaControllers[reelId] = PageController();
//     }
//     return mediaControllers[reelId]!;
//   }

//   Future<void> preloadVideoPoster(String id, String? posterUrl) async {
//     if (posterUrl == null || posterUrl.isEmpty) return;

//     // تخزين البوستر مسبقاً في الذاكرة المؤقتة
//     try {
//       await precacheImage(CachedNetworkImageProvider(posterUrl), Get.context!);
//     } catch (e) {
//       print("Error preloading poster image: $e");
//     }
//   }

//   // دالة جديدة لتنظيف جميع مصادر الصوت
//   void cleanupAllAudio() {
//     try {
//       final keys = videoControllers.keys.toList();

//       // أولاً: كتم صوت جميع الفيديوهات قبل إيقافها
//       for (var id in keys) {
//         try {
//           final controller = videoControllers[id];
//           if (controller != null) {
//             // الخطوة المهمة: كتم الصوت فوراً لمنع التداخل
//             controller.setVolume(0.0);
//           }
//         } catch (e) {
//           print("خطأ في كتم صوت الفيديو $id: $e");
//         }
//       }

//       // ثانياً: إيقاف تشغيل جميع الفيديوهات
//       for (var id in keys) {
//         try {
//           final controller = videoControllers[id];
//           if (controller != null) {
//             controller.pause();
//             // تحديث حالة التشغيل
//             playingStates[id] = false;
//           }
//         } catch (e) {
//           print("خطأ في إيقاف الفيديو $id: $e");
//         }
//       }

//       // تحديث واجهة المستخدم
//       update();
//     } catch (e) {
//       print("خطأ عام في cleanupAllAudio: $e");
//     }
//   }

//   DateTime _lastPageChangeTime = DateTime.now();

//   void onReelPageChanged(int index) {
//     if (index < 0 || index >= reels.length) return;

//     final previousIndex = currentReelIndex.value;
//     final now = DateTime.now();

//     // حساب الفاصل الزمني بين تغييرات الصفحة
//     final timeSinceLastChange =
//         now.difference(_lastPageChangeTime).inMilliseconds;
//     _lastPageChangeTime = now;

//     // تحديد ما إذا كان التقليب سريعًا
//     _isRapidSwiping = timeSinceLastChange < _rapidSwipeThreshold;

//     print(
//         '📱 تغيير الريل من $previousIndex إلى $index (تقليب سريع: ${_isRapidSwiping ? "نعم" : "لا"})');

//     // في حالة التقليب السريع، قم بتنظيف طارئ لجميع المتحكمات
//     if (_isRapidSwiping && !_isEmergencyCleanupActive) {
//       _performEmergencyCleanup();
//     }

//     // إيقاف جميع الفيديوهات أولاً
//     stopAllVideosExcept(null);

//     // تحديث المؤشرات
//     currentReelIndex.value = index;
//     currentMediaIndex.value = 0;
//     // طباعة حالة الريل الحالي
//     final currentReel = reels[index];
//     print(
//         '📊 الريل الحالي: ${currentReel.id}, عدد الوسائط: ${currentReel.mediaUrls.length}');

//     // تسجيل وقت بدء المشاهدة
//     reelWatchStartTimes[currentReel.id] = DateTime.now();

//     // إضافة تأخير صغير لمنع التحميل المفرط عند التقليب السريع
//     final nowTime = DateTime.now();
//     final timeSinceLastSwitch = nowTime.difference(_lastReelSwitchTime);
//     final isFastSwitching = timeSinceLastSwitch.inMilliseconds < 300;
//     _lastReelSwitchTime = nowTime;

//     final delayMs = isFastSwitching ? 200 : 50;

//     Future.delayed(Duration(milliseconds: delayMs), () {
//       if (currentReelIndex.value != index) {
//         // تم تغيير الريل مرة أخرى، تخطي التحميل
//         print('⏩ تم تخطي تحميل الريل: $index (المستخدم انتقل إلى ريل آخر)');
//         return;
//       }

//       // تحميل الوسائط عندما يكون الريل مستقراً
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
//       final preloadDelayMs = isFastSwitching ? 500 : 50;
//       Future.delayed(Duration(milliseconds: preloadDelayMs), () {
//         // التحقق مرة أخرى من أن الريل لم يتغير
//         if (currentReelIndex.value == index) {
//           preloadAdjacentContent(index);
//         }
//       });
//     });

//     // معالجة الريل السابق
//     if (previousIndex >= 0 && previousIndex < reels.length) {
//       final previousReel = reels[previousIndex];
//       print('👁️ فحص حالة مشاهدة الريل السابق: ${previousReel.id}');
//       checkAndMarkReelAsViewed(previousIndex);
//     }

//     // تنظيف المتحكمات البعيدة بعد فترة للحفاظ على الأداء
//     if (previousIndex != index) {
//       Future.delayed(Duration(milliseconds: 300), () {
//         print('🧹 جدولة تنظيف المتحكمات البعيدة');
//         cleanupDistantControllers(index);
//       });
//     }

//     // طباعة حالة الذاكرة
//     _memoryMonitor.updateMemoryStats(videoControllers).then((_) {
//       _memoryMonitor.printMemoryStatus();
//     });

//     update();
//   }

//   // دالة جديدة للتنظيف الطارئ عند التقليب السريع
//   Future<void> _performEmergencyCleanup() async {
//     if (_isEmergencyCleanupActive) return;
//     _isEmergencyCleanupActive = true;

//     print('🚨 بدء التنظيف الطارئ للمتحكمات بسبب التقليب السريع');

//     try {
//       // 1. كتم جميع الأصوات فوراً
//       _audioManager.muteAllExcept(null);

//       // 2. حظر أي تحميل مسبق جديد
//       _preloadManager.preloadInProgress.clear();

//       // 3. إيقاف جميع الفيديوهات بشكل متزامن
//       final controllers = videoControllers.keys.toList();
//       for (final id in controllers) {
//         try {
//           final controller = videoControllers[id];
//           if (controller != null) {
//             controller.setVolume(0.0);
//             controller.pause();
//             playingStates[id] = false;
//           }
//         } catch (e) {
//           print('⚠️ خطأ في إيقاف المتحكم-ID:$id: $e');
//         }
//       }

//       // 4. حذف المتحكمات القديمة بشكل متوازي - عدا الحالية
//       List<Future<void>> disposeFutures = [];
//       for (final id in controllers) {
//         if (id != currentActiveVideoId) {
//           disposeFutures.add(disposeController(id));
//         }
//       }

//       // انتظار انتهاء عمليات الحذف (مع حد زمني)
//       await Future.wait(
//         disposeFutures,
//         eagerError: false, // السماح ببعض الأخطاء دون توقف العملية
//       ).timeout(
//         Duration(milliseconds: 500), // حد زمني للعملية بأكملها
//         onTimeout: () {
//           print('⚠️ انتهت مهلة انتظار حذف المتحكمات - الاستمرار على أي حال');
//           return disposeFutures;
//         },
//       );

//       // 5. تعطيل التحميل المسبق مؤقتاً
//       _preloadManager.resetFailedPreloads();

//       // 6. تحديث حالة الذاكرة
//       await _memoryMonitor.updateMemoryStats(videoControllers);
//       _memoryMonitor.printMemoryStatus();
//     } catch (e) {
//       print('❌ خطأ أثناء التنظيف الطارئ: $e');
//     } finally {
//       // تأخير قصير قبل السماح بتنظيف طارئ آخر
//       Future.delayed(Duration(milliseconds: 300), () {
//         _isEmergencyCleanupActive = false;
//       });

//       print('✅ اكتمل التنظيف الطارئ');
//     }
//   }

//   // دالة جديدة للتنظيف القسري لجميع المتحكمات
//   void _forceCleanupAllControllers() {
//     print('🔥 بدء التنظيف القسري لجميع المتحكمات');

//     try {
//       // 1. تعطيل كافة أنظمة التحميل المسبق والصوت
//       _audioManager.muteAllExcept(null);
//       _preloadManager.preloadInProgress.clear();
//       _preloadManager.preloadFailed.clear();

//       // 2. مسح كل الخرائط المرتبطة بالكونترولرات
//       playingStates.clear();
//       videoLoadingStates.clear();
//       videoErrorStates.clear();
//       shineAnimationShown.clear();
//       shineAnimationActive.clear();
//       _memoryMonitor.activeVideoStatus.clear();

//       // 3. إعادة تعيين متغير الفيديو النشط
//       currentActiveVideoId = null;

//       // 4. مجموعة قوية من التعليمات لوقف جميع الأنشطة
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         killAllRunawayControllers();
//       });

//       // 5. استدعاء تنظيف ذاكرة النظام (بعد تأخير قصير)
//       Future.delayed(Duration(milliseconds: 100), () {
//         cleanupImageCache();
//       });

//       // 6. إعادة تعيين الحالة العامة المتعلقة بالفيديو
//       _memoryMonitor.preloadedVideos.value = 0;

//       // 7. تعليمات صريحة للمجمع - اختياري، قد يفيد في بعض الحالات
//       // تنبيه: استخدم هذا بحذر لأنه قد يسبب تأثيرات جانبية
//       // Future.delayed(Duration(seconds: 1), () {
//       //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//       //   if (!kReleaseMode) debugPrint('طلب جمع القمامة');
//       // });

//       print('✅ تم الانتهاء من التنظيف القسري');
//     } catch (e) {
//       print('❌ خطأ في التنظيف القسري: $e');
//     }
//   }

// // معالجة تغيير وسائط داخل الريل
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
//       stopAllVideosExcept(null);

//       // تحديث مؤشر الوسائط
//       currentMediaIndex.value = index;

//       // التحقق من صحة المؤشر السابق
//       if (prevMediaIndex < 0 ||
//           prevMediaIndex >= currentReel.mediaUrls.length) {
//         print('⚠️ مؤشر الوسائط السابق خارج النطاق: $prevMediaIndex');
//       } else {
//         // معالجة التغيير بين أنواع الوسائط
//         if (currentReel.isVideoMedia(prevMediaIndex) &&
//             !currentReel.isVideoMedia(index)) {
//           // تغيير من فيديو إلى صورة
//           print('🔄 تغيير من فيديو إلى صورة');
//           stopAllVideosExcept(null);
//           startImageWatchTimer(reelIndex);
//         } else if (!currentReel.isVideoMedia(prevMediaIndex) &&
//             currentReel.isVideoMedia(index)) {
//           // تغيير من صورة إلى فيديو
//           print('🔄 تغيير من صورة إلى فيديو');
//           final mediaUrl = currentReel.mediaUrls[index].url;
//           final posterUrl = currentReel.mediaUrls[index].poster;
//           initializeVideo(currentReel.id, mediaUrl, posterUrl);
//         } else if (currentReel.isVideoMedia(prevMediaIndex) &&
//             currentReel.isVideoMedia(index) &&
//             prevMediaIndex != index) {
//           // تغيير من فيديو إلى فيديو آخر
//           print('🔄 تغيير من فيديو إلى فيديو آخر');
//           stopAllVideosExcept(null);
//           final mediaUrl = currentReel.mediaUrls[index].url;
//           final posterUrl = currentReel.mediaUrls[index].poster;
//           initializeVideo(currentReel.id, mediaUrl, posterUrl);
//         }
//       }

//       // طباعة حالة المتحكمات النشطة
//       print('📊 عدد المتحكمات النشطة: ${videoControllers.length}');
//       update();
//     } catch (e) {
//       print('❌ خطأ في onMediaPageChanged: $e');
//     }
//   }

//   // ------ 9. مراقبة المشاهدة وتسجيلها ------

// // فحص وتسجيل مشاهدة الريل
//   void checkAndMarkReelAsViewed(int index) {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];

//     // تجنب تكرار تسجيل المشاهدة
//     if ((viewedReels[reel.id] ?? false) ||
//         (reelWatchProgress[reel.id] ?? false)) {
//       print('⏩ تخطي تسجيل مشاهدة الريل-ID:${reel.id} (مسجل مسبقاً)');
//       return;
//     }

//     print('👁️ فحص مشاهدة الريل-ID:${reel.id}');

//     // التحقق من وقت بداية المشاهدة
//     final startTime = reelWatchStartTimes[reel.id];
//     if (startTime == null) {
//       print('⚠️ لم يتم العثور على وقت بداية المشاهدة للريل-ID:${reel.id}');
//       return;
//     }

//     // حساب مدة المشاهدة
//     final watchDuration = DateTime.now().difference(startTime);
//     print(
//         '⏱️ مدة مشاهدة الريل-ID:${reel.id}: ${watchDuration.inSeconds} ثانية');

//     // تقدير ما إذا كان المستخدم قد شاهد معظم المحتوى
//     bool hasWatchedEnough = false;

//     // إذا كان الريل فيديو، نستخدم نسبة من وقت الفيديو
//     if (reel.mediaUrls.isNotEmpty && reel.isVideoMedia(0)) {
//       // للفيديوهات، قد تكون القيمة مسجلة بالفعل في videoProgressValues
//       if (videoProgressValues.containsKey(reel.id)) {
//         final progress = videoProgressValues[reel.id]!;
//         hasWatchedEnough = progress >= viewThreshold;
//         print(
//             '📊 تقدم مشاهدة الفيديو-ID:${reel.id}: ${(progress * 100).toStringAsFixed(1)}% (العتبة: ${viewThreshold * 100}%)');
//       } else {
//         // إذا لم تكن القيمة مسجلة، نستخدم وقت المشاهدة
//         hasWatchedEnough = watchDuration >= minWatchDuration;
//         print(
//             '⏱️ المشاهدة عبر الوقت: ${watchDuration.inSeconds}s >= ${minWatchDuration.inSeconds}s');
//       }
//     } else {
//       // للصور، نعتبر المستخدم قد شاهد الصورة إذا بقي عليها لمدة كافية
//       hasWatchedEnough = watchDuration >= minWatchDuration;
//       print(
//           '🖼️ مشاهدة الصورة: ${watchDuration.inSeconds}s >= ${minWatchDuration.inSeconds}s');
//     }

//     // تسجيل المشاهدة إذا تمت مشاهدة محتوى كافٍ
//     if (hasWatchedEnough) {
//       print('✅ المستخدم شاهد محتوى كافياً، تسجيل المشاهدة');
//       reelWatchProgress[reel.id] = true;
//       markAsViewed(index);
//     } else {
//       print('⏳ لم يشاهد المستخدم محتوى كافياً بعد للريل-ID:${reel.id}');
//     }

//     // إعادة تعيين وقت البداية في جميع الحالات
//     reelWatchStartTimes.remove(reel.id);
//   }

// // دالة تسجيل مشاهدة الريل
//   void markAsViewed(int index) async {
//     if (index < 0 || index >= reels.length) {
//       print('⚠️ مؤشر خارج النطاق في markAsViewed: $index');
//       return;
//     }

//     final reel = reels[index];

//     // تجنب تسجيل المشاهدة مرة أخرى
//     if (viewedReels[reel.id] == true) {
//       print('⏩ تخطي markAsViewed - الريل-ID:${reel.id} مشاهد بالفعل');
//       return;
//     }

//     print('👁️ تسجيل مشاهدة للريل-ID:${reel.id}');

//     // تحديث حالة المشاهدة محلياً أولاً (تحديث متفائل)
//     viewedReels[reel.id] = true;
//     reel.counts.viewedBy += 1;
//     reel.isWatched = true;
//     update();

//     try {
//       // إرسال الطلب إلى الخادم
//       print('🔄 إرسال طلب تسجيل المشاهدة إلى الخادم للريل-ID:${reel.id}');
//       final response = await _reelsApiService.viewContent(reel.id);

//       // طباعة الاستجابة للتشخيص
//       print("================================================================");
//       print("استجابة من API: $response");

//       final bool isSuccess = response['success'] == true;

//       if (isSuccess) {
//         // طباعة رسالة نجاح
//         if (response.containsKey('message')) {
//           print("رسالة الخادم: ${response['message']}");
//         }

//         // التحقق من وجود جوهرة
//         final bool hasGem = response['gemClaimed'] == true;

//         if (hasGem) {
//           print('💎 حصل المستخدم على جوهرة');

//           // استخراج بيانات الجوهرة
//           final int gemPoints = response['gemPoints'] is int
//               ? response['gemPoints']
//               : (int.tryParse(response['gemPoints'].toString()) ?? 0);

//           // استخدام اللون الافتراضي حيث أن الاستجابة لا تحتوي على لون
//           const String gemColor = "blue";

//           // عرض الرسوم المتحركة للجوهرة فقط إذا كانت النقاط أكبر من صفر
//           if (gemPoints > 0) {
//             print('💎 عرض رسوم متحركة للجوهرة: $gemPoints نقطة');
//             final gemService = Get.find<GemService>();
//             gemService.showGemAnimation(gemPoints, gemColor);
//           }
//         }

//         // التحقق من النقاط الممنوحة
//         if (response.containsKey('pointsAwarded')) {
//           final int pointsAwarded = response['pointsAwarded'] is int
//               ? response['pointsAwarded']
//               : (int.tryParse(response['pointsAwarded'].toString()) ?? 0);

//           if (pointsAwarded > 0) {
//             print('🏆 تم منح المستخدم $pointsAwarded نقطة لمشاهدة هذا المحتوى');
//           }
//         }
//       } else {
//         print("⚠️ فشل تحديث المشاهدة، إعادة الحالة السابقة");

//         // طباعة رسالة الخطأ من الخادم إن وجدت
//         if (response.containsKey('message')) {
//           print("رسالة خطأ الخادم: ${response['message']}");
//         }

//         // إعادة الحالة السابقة
//         _revertViewState(index, reel.counts.viewedBy);
//       }
//     } catch (e) {
//       print("❌ خطأ في تسجيل المشاهدة: $e");
//       // في حالة حدوث خطأ، نعيد الحالة السابقة
//       _revertViewState(index, reel.counts.viewedBy);
//     }
//   }

// // دالة مساعدة لإعادة الحالة في حالة الفشل
//   void _revertViewState(int index, int originalViewCount) {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];
//     print('⏮️ إعادة حالة المشاهدة الأصلية للريل-ID:${reel.id}');

//     // إعادة حالة المشاهدة الأصلية
//     viewedReels[reel.id] = false;
//     reelWatchProgress[reel.id] = false;

//     reel.counts.viewedBy = originalViewCount;
//     reel.isWatched = false;

//     update();
//   }

//   // التحقق مما إذا كان الرابط هو رابط فيديو
//   bool isVideoUrl(String url) {
//     final lowercaseUrl = url.toLowerCase();
//     return lowercaseUrl.contains('.mp4') ||
//         lowercaseUrl.contains('.m3u8') ||
//         lowercaseUrl.contains('.mpd') ||
//         lowercaseUrl.contains('format=hls') ||
//         lowercaseUrl.contains('format=dash') ||
//         lowercaseUrl.contains('playlist_type=hls');
//   }

// // تحديد تنسيق الفيديو من URL
//   BetterPlayerVideoFormat _getVideoFormat(String url) {
//     final lowercaseUrl = url.toLowerCase();

//     if (lowercaseUrl.contains('.m3u8') ||
//         lowercaseUrl.contains('format=hls') ||
//         lowercaseUrl.contains('playlist_type=hls')) {
//       return BetterPlayerVideoFormat.hls;
//     } else if (lowercaseUrl.contains('.mpd') ||
//         lowercaseUrl.contains('format=dash') ||
//         lowercaseUrl.contains('mpd')) {
//       return BetterPlayerVideoFormat.dash;
//     }

//     return BetterPlayerVideoFormat.other;
//   }

//   void handleAppLifecycleChange(String state) {
//     if (state == 'AppLifecycleState.paused') {
//       cleanupAllAudio();
//       pauseAllVideos();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         stopAllVideosExcept(null);
//       });
//     } else if (state == 'AppLifecycleState.resumed') {
//       // App volviendo a primer plano - restaurar solo el video activo
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (currentActiveVideoId != null) {
//           playVideo(currentActiveVideoId!);
//         }
//       });
//     }
//   }

//   // دالة مساعدة للتحقق مما إذا كان الفيديو لا يزال يعمل بنشاط
//   bool isActivelyPlaying(String id) {
//     if (!videoControllers.containsKey(id)) return false;

//     try {
//       final controller = videoControllers[id];
//       if (controller?.videoPlayerController == null) return false;

//       // التحقق من حالة التشغيل الفعلية
//       final playerValue = controller!.videoPlayerController!.value;
//       // استخدام playerValue.isPlaying إذا كانت متوفرة، وإلا استخدم أي تحقق آخر
//       return playerValue.isPlaying;
//     } catch (e) {
//       print("Error checking if video $id is playing: $e");
//       return false;
//     }
//   }

//   Future<void> preloadAdjacentVideos(int currentIndex) async {
//     if (currentIndex < 0 || currentIndex >= reels.length) return;

//     // Prioritize next video over previous ones
//     // Next video
//     final nextIndex = currentIndex + 1;
//     if (nextIndex < reels.length) {
//       final nextReel = reels[nextIndex];
//       if (nextReel.mediaUrls.isNotEmpty && nextReel.isVideoMedia(0)) {
//         final firstMedia = nextReel.mediaUrls[0];
//         preloadVideo(nextReel.id, firstMedia.url, firstMedia.poster);
//       }
//     }

//     // Then previous video
//     final prevIndex = currentIndex - 1;
//     if (prevIndex >= 0) {
//       final prevReel = reels[prevIndex];
//       if (prevReel.mediaUrls.isNotEmpty && prevReel.isVideoMedia(0)) {
//         final firstMedia = prevReel.mediaUrls[0];
//         preloadVideo(prevReel.id, firstMedia.url, prevReel.mediaUrls[0].poster);
//       }
//     }

//     // Only preload further if device has enough memory
//     if (preloadDistance > 1) {
//       // Further next video with delay
//       final nextIndex2 = currentIndex + 2;
//       if (nextIndex2 < reels.length) {
//         await Future.delayed(Duration(milliseconds: 200));
//         final nextReel2 = reels[nextIndex2];
//         if (nextReel2.mediaUrls.isNotEmpty && nextReel2.isVideoMedia(0)) {
//           final firstMedia = nextReel2.mediaUrls[0];
//           preloadVideo(nextReel2.id, firstMedia.url, firstMedia.poster);
//         }
//       }
//     }
//   }

//   Future<void> _preloadReelContent(int index,
//       {bool highPriority = false}) async {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];

//     // تحميل الوسائط الأولى في الريل
//     if (reel.mediaUrls.isNotEmpty) {
//       final firstMedia = reel.mediaUrls[0];

//       if (reel.isVideoMedia(0)) {
//         // تحميل مسبق للبوستر أولاً بأولوية عالية
//         await preloadVideoPoster(reel.id, firstMedia.poster);

//         // ثم تحميل الفيديو
//         if (highPriority) {
//           preloadVideo(reel.id, firstMedia.url, firstMedia.poster);
//         } else {
//           Future.delayed(Duration(milliseconds: 200), () {
//             preloadVideo(reel.id, firstMedia.url, firstMedia.poster);
//           });
//         }
//       } else {
//         // تحميل الصورة مسبقاً
//         _precacheImageOptimized(firstMedia.url, highPriority: highPriority);
//       }
//     }
//   }

//   // تهيئة وتشغيل الفيديو
//   Future<void> initializeVideo(String id, String url,
//       [String? posterUrl]) async {
//     final startTime = DateTime.now();
//     print('🎬 بدء تهيئة الفيديو-ID:$id');

//     // كتم جميع الفيديوهات وإيقافها فوراً
//     videoLoadingStates[id] = true;
//     videoErrorStates[id] = false;
//     _audioManager.muteAllExcept(null); // كتم الصوت فوراً قبل الإيقاف
//     stopAllVideosExcept(null);
//     update();

//     try {
//       // إذا كان هناك خطأ سابق، قم بتنظيف المتحكم أولاً
//       if (videoErrorStates[id] == true) {
//         await disposeController(id);
//       }

//       // إذا كان المتحكم موجوداً مسبقاً
//       if (videoControllers.containsKey(id)) {
//         final existingController = videoControllers[id];

//         if (existingController != null &&
//             existingController.isVideoInitialized() == true) {
//           print(
//               '♻️ استخدام متحكم مُهيأ مسبقاً-ID:$id - محمل مسبقاً: ${preloadedVideos[id] ?? false}');

//           // تحديث نسبة الأبعاد إذا كانت غير محددة
//           if (!videoAspectRatios.containsKey(id)) {
//             _updateAspectRatio(id);
//           }

//           // كتم الصوت أولاً
//           await existingController.setVolume(0.0);

//           // إعادة تشغيل الفيديو من البداية
//           await existingController.seekTo(Duration.zero);

//           // ضبط حالة متابعة التقدم
//           videoProgressValues[id] = 0.0;

//           // إعداد مستمعي الأحداث للفيديو المحمل مسبقاً إذا لم تكن موجودة بالفعل
//           if (preloadedVideos[id] == true) {
//             // إعادة إنشاء مستمعي الأحداث بشكل كامل للفيديو المحمل مسبقاً
//             _setupVideoListeners(id, existingController, startTime);
//           }

//           // تشغيل الفيديو
//           existingController.play();

//           // تحديث الحالات
//           playingStates[id] = true;
//           currentActiveVideoId = id;
//           videoLoadingStates[id] = false;
//           _memoryMonitor.activeVideoStatus[id] = "قيد التشغيل";
//           _audioManager.registerActiveVideo(id);

//           // استخدام نظام التأخير الديناميكي لتشغيل الصوت
//           _audioManager.scheduleAudioActivation(id, existingController);

//           update();
//           return;
//         }

//         // إذا كان المتحكم موجوداً ولكن غير مُهيأ، تخلص منه
//         await disposeController(id);
//       }

//       // إنشاء متحكم جديد بإعدادات محسنة
//       print('🆕 إنشاء متحكم جديد للفيديو-ID:$id');

//       final betterPlayerConfiguration = BetterPlayerConfiguration(
//         autoPlay: true,
//         looping: true,
//         fit: BoxFit.contain,
//         expandToFill: false,
//         controlsConfiguration: BetterPlayerControlsConfiguration(
//           showControls: false,
//           enableOverflowMenu: false,
//           enablePlaybackSpeed: false,
//           enableSubtitles: false,
//           enableQualities: false,
//           enablePip: false,
//         ),
//         handleLifecycle: true,
//         autoDispose: false,
//         deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
//         placeholderOnTop: false,
//         showPlaceholderUntilPlay: false,
//         placeholder: null,
//         startAt: Duration.zero,
//         allowedScreenSleep: false,
//         // تحسين التشغيل السريع للفيديو
//         playerVisibilityChangedBehavior: (visibilityFraction) {
//           if (visibilityFraction <= 0) {
//             pauseVideo(id);
//           }
//         },
//       );

//       final videoFormat = _getVideoFormat(url);
//       final betterPlayerDataSource = BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         url,
//         videoFormat: videoFormat,
//         cacheConfiguration: BetterPlayerCacheConfiguration(
//           useCache: true,
//           maxCacheSize: 100 * 1024 * 1024, // 100MB
//           maxCacheFileSize: 10 *
//               1024 *
//               1024, // 10MB لكل ملف (أصغر ليسمح بتخزين المزيد من الملفات)
//           preCacheSize:
//               2 * 1024 * 1024, // 2MB للتحميل المسبق (صغيرة لتحميل سريع)
//         ),
//         bufferingConfiguration: BetterPlayerBufferingConfiguration(
//           minBufferMs: 2000, // تقليل إلى 2 ثانية فقط
//           maxBufferMs: 20000, // تقليل إلى 20 ثانية (لتقليل استهلاك الذاكرة)
//           bufferForPlaybackMs:
//               300, // 300 مللي ثانية فقط قبل بدء التشغيل (تشغيل أسرع)
//           bufferForPlaybackAfterRebufferMs:
//               1000, // 1 ثانية فقط بعد إعادة التخزين المؤقت
//         ),
//         notificationConfiguration: BetterPlayerNotificationConfiguration(
//           showNotification: false,
//         ),
//       );

//       final controller = BetterPlayerController(betterPlayerConfiguration);

//       try {
//         // إعداد مصدر البيانات مع كتم الصوت أولاً
//         await controller.setupDataSource(betterPlayerDataSource);
//         await controller.setVolume(0.0); // كتم الصوت دائماً عند البدء

//         // طلب تحميل أعلى جودة متاحة للفيديو
//         controller.setResolution(url);

//         // إعداد مستمعي الأحداث
//         _setupVideoListeners(id, controller, startTime);

//         // تسجيل المتحكم الجديد
//         videoControllers[id] = controller;
//         playingStates[id] = true;
//         currentActiveVideoId = id;
//         _memoryMonitor.activeVideoStatus[id] = "قيد التشغيل";
//         _memoryMonitor.updateLastAccessTime(id);
//         _audioManager.registerActiveVideo(id);
//         preloadedVideos[id] = false; // تحديد أنه ليس محملاً مسبقاً

//         // استخدام نظام التأخير الديناميكي لتشغيل الصوت
//         _audioManager.scheduleAudioActivation(id, controller);

//         update();

//         // تحديث إحصائيات الذاكرة
//         _memoryMonitor.updateMemoryStats(videoControllers);
//       } catch (e) {
//         print('❌ خطأ في تهيئة الفيديو-ID:$id: $e');
//         videoLoadingStates[id] = false;
//         videoErrorStates[id] = true;
//         update();
//       }
//     } catch (e) {
//       print('❌ خطأ عام في تهيئة الفيديو-ID:$id: $e');
//       videoLoadingStates[id] = false;
//       videoErrorStates[id] = true;
//       update();
//     }
//   }

//   // إعداد مستمعي أحداث الفيديو
//   void _setupVideoListeners(
//       String id, BetterPlayerController controller, DateTime startTime) {
//     // أولاً: إزالة جميع المستمعين السابقين لمنع الازدواجية
//     controller.removeEventsListener((event) {});

//     print(
//         '🔄 إعداد مستمعي الأحداث للفيديو-ID:$id - محمل مسبقاً: ${preloadedVideos[id] ?? false}');

//     // ثانياً: إضافة مستمعين جدد
//     controller.addEventsListener((event) {
//       final eventType = event.betterPlayerEventType;

//       switch (eventType) {
//         case BetterPlayerEventType.initialized:
//           print('✅ تمت تهيئة الفيديو-ID:$id');
//           _updateAspectRatio(id);
//           videoLoadingStates[id] = false;
//           videoProgressValues[id] = 0.0;
//           _memoryMonitor.activeVideoStatus[id] = "مُهيأ - قيد التشغيل";

//           // تغيير حالة التشغيل فوراً لإخفاء أيقونة التشغيل
//           playingStates[id] = true;

//           update();
//           break;

//         case BetterPlayerEventType.play:
//           // تحديث حالة التشغيل عند بدء التشغيل
//           playingStates[id] = true;
//           update();
//           break;

//         case BetterPlayerEventType.pause:
//           // تحديث حالة التشغيل عند الإيقاف المؤقت
//           playingStates[id] = false;
//           update();
//           break;

//         case BetterPlayerEventType.progress:
//           // استدعاء دالة تحديث التقدم
//           _updateVideoProgress(id);

//           // التأكد من أن حالة التشغيل صحيحة أثناء التقدم
//           if (controller.isPlaying() ?? false) {
//             playingStates[id] = true;
//           }

//           if (videoLoadingStates[id] == true) {
//             videoLoadingStates[id] = false;
//             update();
//           }
//           break;

//         case BetterPlayerEventType.finished:
//           print('🔄 انتهى الفيديو-ID:$id، إعادة تشغيل');
//           videoProgressValues[id] = 1.0;
//           controller.seekTo(Duration.zero);
//           controller.setVolume(isMuted.value ? 0.0 : 1.0);
//           SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//           // الحفاظ على حالة التشغيل عند إعادة التشغيل
//           playingStates[id] = true;

//           controller.play();
//           update();
//           break;

//         case BetterPlayerEventType.exception:
//           print('❌ استثناء في مشغل الفيديو-ID:$id: ${event.parameters}');
//           videoErrorStates[id] = true;
//           videoLoadingStates[id] = false;
//           _memoryMonitor.activeVideoStatus[id] = "خطأ في التشغيل";
//           update();
//           break;

//         default:
//           break;
//       }
//     });
//   }

//   void _ensureControlsHidden(String id, BetterPlayerController controller) {
//     // التأكد من إخفاء أدوات التحكم فور تهيئة الفيديو
//     controller.setControlsVisibility(false);
//     controller.setControlsAlwaysVisible(false);

//     // جدولة إخفاء أدوات التحكم بشكل دوري
//     Timer.periodic(Duration(milliseconds: 500), (timer) {
//       // التحقق من أن المتحكم لا يزال نشطاً
//       if (currentActiveVideoId != id || !videoControllers.containsKey(id)) {
//         timer.cancel();
//         return;
//       }

//       // التأكد من أن أدوات التحكم مخفية
//       controller.setControlsVisibility(false);

//       // إلغاء المؤقت بعد 3 ثوانٍ (6 محاولات)
//       if (timer.tick >= 6) {
//         timer.cancel();
//       }
//     });
//   }

//   // ------ 10. تحديث تقدم الفيديو ------

//   // دالة تحديث تقدم الفيديو
//   void _updateVideoProgress(String id) {
//     if (!videoControllers.containsKey(id)) return;

//     try {
//       final controller = videoControllers[id];
//       if (controller?.videoPlayerController == null) return;

//       final videoPlayerController = controller!.videoPlayerController!;
//       final position = videoPlayerController.value.position;
//       final duration = videoPlayerController.value.duration;

//       if (duration != null &&
//           duration.inMilliseconds > 0 &&
//           position.inMilliseconds > 0) {
//         // حساب نسبة التقدم (0.0 إلى 1.0)
//         final progress = position.inMilliseconds / duration.inMilliseconds;

//         // طباعة معلومات التقدم للتحقق
//         if (id == currentActiveVideoId) {
//           print(
//               '📊 تقدم الفيديو-ID:$id: ${(progress * 100).toStringAsFixed(1)}%');
//         }

//         // تحديث قيمة التقدم
//         videoProgressValues[id] = progress;

//         final isViewed = viewedReels[id] ?? false;
//         final isWatchProgressRecorded = reelWatchProgress[id] ?? false;

//         // التحقق مما إذا تجاوزنا نقطة المنتصف ولم يتم عرض الرسوم المتحركة بعد
//         if (progress >= viewThreshold &&
//             !(shineAnimationShown[id] ?? false) &&
//             !(shineAnimationActive[id] ?? false)) {
//           // تحديد الرسوم المتحركة كنشطة
//           shineAnimationActive[id] = true;
//           // تحديث واجهة المستخدم فوراً لبدء الرسوم المتحركة
//           update();
//         }

//         // تسجيل المشاهدة إذا تجاوزت النسبة المحددة
//         if (progress >= viewThreshold &&
//             !isViewed &&
//             !isWatchProgressRecorded) {
//           print(
//               '✅ تقدم الفيديو-ID:$id تجاوز عتبة المشاهدة (${(progress * 100).toStringAsFixed(1)}% > ${viewThreshold * 100}%)');
//           reelWatchProgress[id] = true;

//           // البحث عن index الخاص بـ id
//           final reelIndex = reels.indexWhere((reel) => reel.id == id);
//           if (reelIndex != -1) {
//             print('📝 تسجيل المشاهدة للريل-ID:$id (الفهرس: $reelIndex)');
//             markAsViewed(reelIndex);
//           }
//         }
//       }
//     } catch (e) {
//       print("⚠️ خطأ في تحديث تقدم الفيديو-ID:$id: $e");
//     }
//   }

// // تحديث نسبة أبعاد الفيديو
//   void _updateAspectRatio(String id) {
//     if (!videoControllers.containsKey(id)) return;

//     try {
//       final controller = videoControllers[id]!;
//       final videoData = controller.videoPlayerController!.value;

//       // الحصول على الأبعاد الفعلية للفيديو
//       if (videoData.size != null &&
//           videoData.size!.width > 0 &&
//           videoData.size!.height > 0) {
//         // حساب نسبة الأبعاد الأصلية (العرض / الارتفاع)
//         final originalRatio = videoData.size!.width / videoData.size!.height;

//         // تخزين نسبة الأبعاد الأصلية
//         videoAspectRatios[id] = originalRatio;

//         print(
//             '📐 أبعاد الفيديو-ID:$id: ${videoData.size!.width}x${videoData.size!.height}, نسبة الأبعاد: $originalRatio');

//         update();
//       } else {
//         // تحديث القيمة الافتراضية في حالة عدم توفر الأبعاد
//         _setDefaultAspectRatio(id);
//       }
//     } catch (e) {
//       print("⚠️ خطأ في تحديث نسبة أبعاد الفيديو-ID:$id: $e");
//       // تحديث القيمة الافتراضية في حالة حدوث خطأ
//       _setDefaultAspectRatio(id);
//     }
//   }

// // دالة مساعدة لتعيين نسبة أبعاد افتراضية
//   void _setDefaultAspectRatio(String id) {
//     // استخدام نسبة عمودية (9:16) كقيمة افتراضية
//     videoAspectRatios[id] = 9.0 / 16.0;
//     print('📏 استخدام نسبة أبعاد افتراضية (9:16) للفيديو-ID:$id');
//     update();
//   }

//   final Map<String, DateTime> videoLastActiveTimes = {};

//   void cleanupDistantControllers(int currentIndex) {
//     if (_isPerformingCleanup) return;
//     _isPerformingCleanup = true;

//     print('🧹 بدء تنظيف المتحكمات البعيدة (الريل الحالي: $currentIndex)');

//     try {
//       // تحديد نطاق الريلز التي سيتم الاحتفاظ بها
//       final keepIndices = <int>[];
//       final keepIds = <String>{};

//       // الاحتفاظ بالريل الحالي والريلز المجاورة
//       final keepRange = _memoryMonitor.isLowMemory() ? 2 : 3;

//       for (int i = -keepRange; i <= keepRange; i++) {
//         final idx = currentIndex + i;
//         if (idx >= 0 && idx < reels.length) {
//           keepIndices.add(idx);
//           keepIds.add(reels[idx].id);
//         }
//       }

//       print('🔍 الإبقاء على متحكمات الريلز: $keepIndices');

//       // البحث عن المتحكمات القديمة للتخلص منها
//       final idsToRemove =
//           videoControllers.keys.where((id) => !keepIds.contains(id)).toList();

//       if (idsToRemove.isEmpty) {
//         print('✅ لا توجد متحكمات للتنظيف');
//       } else {
//         print('🚮 جدولة حذف ${idsToRemove.length} متحكم غير مستخدم:');

//         for (final id in idsToRemove) {
//           print('   - حذف المتحكم: $id');
//           disposeController(id);
//         }

//         // تحديث إحصائيات الذاكرة بعد التنظيف
//         Future.delayed(Duration(milliseconds: 500), () {
//           _memoryMonitor.updateMemoryStats(videoControllers);
//         });
//       }
//     } catch (e) {
//       print('❌ خطأ أثناء تنظيف المتحكمات: $e');
//     } finally {
//       _isPerformingCleanup = false;
//       print('✅ انتهى تنظيف المتحكمات البعيدة');
//     }
//   }

// // دالة تنظيف جميع المتحكمات
//   void cleanupAllControllers() {
//     print('🧹 بدء تنظيف جميع المتحكمات');

//     try {
//       // كتم صوت جميع الفيديوهات أولاً
//       for (var id in videoControllers.keys.toList()) {
//         try {
//           final controller = videoControllers[id];
//           if (controller != null) {
//             print('🔇 كتم صوت الفيديو-ID:$id');
//             controller.setVolume(0.0);
//             controller.pause();
//           }
//         } catch (e) {
//           print('⚠️ خطأ في كتم صوت الفيديو-ID:$id: $e');
//         }
//       }

//       // ثم التخلص من كل متحكم بشكل آمن
//       final controllerIds = videoControllers.keys.toList();
//       print('🚮 جدولة حذف ${controllerIds.length} متحكم:');

//       for (var id in controllerIds) {
//         try {
//           print('   - حذف المتحكم: $id');
//           disposeController(id);
//         } catch (e) {
//           print('⚠️ خطأ في حذف المتحكم-ID:$id: $e');
//         }
//       }

//       // مسح جميع الخرائط
//       preloadedVideos.clear();
//       playingStates.clear();
//       videoAspectRatios.clear();
//       videoLoadingStates.clear();
//       videoErrorStates.clear();
//       shineAnimationShown.clear();
//       shineAnimationActive.clear();
//       _memoryMonitor.activeVideoStatus.clear();
//       _preloadManager.preloadInProgress.clear();
//       _preloadManager.preloadFailed.clear();

//       // التخلص من متحكمات الوسائط
//       for (var id in mediaControllers.keys.toList()) {
//         try {
//           final controller = mediaControllers[id];
//           if (controller != null) {
//             controller.dispose();
//           }
//         } catch (e) {
//           print('⚠️ خطأ في التخلص من متحكم الوسائط-ID:$id: $e');
//         }
//       }
//       mediaControllers.clear();

//       currentActiveVideoId = null;
//       _memoryMonitor.preloadedVideos.value = 0;

//       // تحديث إحصائيات الذاكرة
//       Future.delayed(Duration(milliseconds: 500), () {
//         _memoryMonitor.updateMemoryStats(videoControllers);
//         _memoryMonitor.printMemoryStatus();
//       });

//       print('✅ تم تنظيف جميع المتحكمات والذاكرة بنجاح');
//     } catch (e) {
//       print('❌ خطأ أثناء تنظيف جميع المتحكمات: $e');
//     }
//   }

//   // التخلص من متحكم فيديو محدد بطريقة آمنة
//   Future<void> disposeController(String id) async {
//     if (!videoControllers.containsKey(id)) {
//       print('⚠️ محاولة حذف متحكم غير موجود-ID:$id');
//       return;
//     }

//     print('🗑️ بدء عملية التخلص من المتحكم-ID:$id');
//     final controller = videoControllers[id];
//     videoControllers.remove(id); // إزالة من الخريطة أولاً لمنع إعادة الاستخدام

//     if (controller != null) {
//       try {
//         // إيقاف الصوت والفيديو أولاً
//         await controller.setVolume(0.0);
//         await controller.pause();
//       } catch (e) {
//         print('⚠️ خطأ في الإيقاف: $e');
//       }

//       try {
//         // إزالة المستمعين
//         controller.removeEventsListener((event) {});
//       } catch (e) {
//         print('⚠️ خطأ في إزالة المستمع: $e');
//       }

//       // محاولات متعددة للتخلص
//       bool disposed = false;
//       for (int i = 0; i < 3; i++) {
//         try {
//           controller.dispose(forceDispose: true); // لا يمكن await
//           await Future.delayed(Duration(milliseconds: 300)); // ننتظر شوية
//           disposed = true;
//           break;
//         } catch (e) {
//           print('⚠️ محاولة #$i فاشلة في التخلص من المتحكم: $e');
//           await Future.delayed(Duration(milliseconds: 500));
//         }
//       }

//       if (!disposed) {
//         print('❌ فشل التخلص من المتحكم-ID:$id بعد 3 محاولات');
//         // هنا ممكن تتخذ إجراء إضافي مثل: تسجيل، إعادة المحاولة لاحقًا، إلخ
//       }
//     }

//     // تنظيف المراجع دائمًا
//     preloadedVideos.remove(id);
//     playingStates.remove(id);
//     videoAspectRatios.remove(id);
//     videoLoadingStates.remove(id);
//     videoErrorStates.remove(id);
//     _memoryMonitor.activeVideoStatus.remove(id);
//     _preloadManager.preloadInProgress.remove(id);
//     _audioManager.cancelPendingAudioActivation(id);

//     if (currentActiveVideoId == id) {
//       currentActiveVideoId = null;
//     }

//     print('✅ تم الانتهاء من عملية التخلص من المتحكم-ID:$id');
//   }

//   // ----- التحسين السابع: إضافة المراقبة والكشف عن تسرب الذاكرة -----

// // دالة جديدة لإضافتها في onInit للمراقبة المستمرة للكونترولرات النشطة
//   void _setupControllerLeakDetection() {
//     // فحص كل فترة للكشف عن تسربات محتملة (تشغيل كل 45 ثانية)
//     Timer.periodic(Duration(seconds: 45), (timer) {
//       if (videoControllers.length > maxActiveControllers * 1.5) {
//         print(
//             '⚠️ تم اكتشاف عدد كبير من المتحكمات النشطة: ${videoControllers.length}');

//         // فحص المتحكمات التي لم تعد مستخدمة
//         final activeIds = <String>{};
//         if (currentReelIndex.value >= 0 &&
//             currentReelIndex.value < reels.length) {
//           // إضافة الريل الحالي والريلز المجاورة له إلى القائمة النشطة
//           for (int i = -2; i <= 2; i++) {
//             final idx = currentReelIndex.value + i;
//             if (idx >= 0 && idx < reels.length) {
//               activeIds.add(reels[idx].id);
//             }
//           }
//         }

//         // البحث عن المتحكمات غير المستخدمة
//         final unusedControllers = videoControllers.keys
//             .where((id) => !activeIds.contains(id))
//             .toList();

//         if (unusedControllers.length > maxActiveControllers / 2) {
//           print(
//               '🚨 تم اكتشاف ${unusedControllers.length} متحكم غير مستخدم - تنظيف');

//           // حذف المتحكمات غير المستخدمة
//           for (final id in unusedControllers) {
//             print('🧹 تنظيف متحكم متسرب: $id');
//             disposeController(id);
//           }
//         }
//       }
//     });
//   }

//   // ----- التحسين السادس: إضافة دالة لكشف ومعالجة نفاد الذاكرة -----
//   Future<void> _checkAndHandleMemoryPressure() async {
//     // 1. تحديث إحصائيات الذاكرة
//     await _memoryMonitor.updateMemoryStats(videoControllers);

//     // 2. التحقق من وجود ضغط على الذاكرة
//     if (_memoryMonitor.isCriticalMemory()) {
//       print('⚠️ تم اكتشاف ضغط حرج على الذاكرة! بدء التنظيف الطارئ');

//       // 3. إذا كان هناك ضغط حرج، نفذ تنظيفاً قوياً
//       _forceCleanupAllControllers();

//       // 4. إعادة تعيين بعض المتغيرات بعد التنظيف
//       _isRapidSwiping = false;
//       _consecutiveRapidSwipes = 0;
//     } else if (_memoryMonitor.isLowMemory()) {
//       print('ℹ️ ذاكرة منخفضة - تنظيف بعض الموارد غير المستخدمة');

//       // 5. إذا كان هناك ضغط معتدل، نظف المتحكمات البعيدة
//       cleanupDistantControllers(currentReelIndex.value);
//     }
//   }

// // جدولة فحص دوري للذاكرة
//   void _startPeriodicMemoryCheck() {
//     Timer.periodic(Duration(seconds: 30), (_) {
//       // تشغيل فقط إذا لم تكن هناك عمليات تنظيف أخرى جارية
//       if (!_isEmergencyCleanupActive && !_isPerformingCleanup) {
//         _checkAndHandleMemoryPressure();
//       }
//     });
//   }

//   // ------ 11. التحقق من حالة الفيديو ------

//   // التحقق من جاهزية الفيديو
//   bool isVideoInitialized(String id) {
//     if (!videoControllers.containsKey(id)) return false;

//     try {
//       final controller = videoControllers[id];
//       if (controller == null) return false;

//       // التحقق من وحدة التحكم الداخلية بطريقة آمنة
//       final isInitialized = controller.isVideoInitialized() ?? false;

//       if (isInitialized) {
//         final videoPlayerValue = controller.videoPlayerController?.value;
//         if (videoPlayerValue != null) {
//           // التحقق من تهيئة الفيديو بالكامل
//           return videoPlayerValue.size != null &&
//               videoPlayerValue.size!.width > 0 &&
//               videoPlayerValue.size!.height > 0;
//         }
//       }
//       return isInitialized;
//     } catch (e) {
//       print("⚠️ خطأ في التحقق من تهيئة الفيديو-ID:$id: $e");
//       return false;
//     }
//   }

// // التحقق من حالة تشغيل الفيديو
//   bool isVideoPlaying(String id) {
//     // تحقق من وجود وحدة التحكم أولاً
//     if (!videoControllers.containsKey(id)) return false;

//     try {
//       // استخدام حالة التشغيل المحفوظة
//       bool statePlaying = playingStates[id] ?? false;

//       // التحقق من حالة التشغيل الفعلية إذا كان ذلك ممكنًا
//       final controller = videoControllers[id];
//       if (controller?.videoPlayerController != null) {
//         bool actuallyPlaying =
//             controller!.videoPlayerController!.value.isPlaying;

//         // إذا كان هناك تعارض بين الحالة المحفوظة والحالة الفعلية، قم بتحديث الحالة المحفوظة فوراً
//         if (statePlaying != actuallyPlaying) {
//           print(
//               '⚠️ تعارض حالة للفيديو-ID:$id: مخزنة=$statePlaying، فعلية=$actuallyPlaying');
//           playingStates[id] = actuallyPlaying;
//           update(); // تحديث واجهة المستخدم فوراً لإخفاء/إظهار أيقونة التشغيل
//           return actuallyPlaying;
//         }
//       }

//       return statePlaying;
//     } catch (e) {
//       print("⚠️ خطأ في التحقق من حالة تشغيل الفيديو-ID:$id: $e");
//       return false;
//     }
//   }
//   // ------ 12. معالجة الأحداث من المستخدم ------

// // تبديل حالة تشغيل الفيديو
//   void toggleVideoPlayback(String id) {
//     if (!videoControllers.containsKey(id)) {
//       print("❌ فشل التبديل: المتحكم غير موجود للفيديو-ID:$id");
//       return;
//     }

//     try {
//       final isPlaying = isVideoPlaying(id);
//       print(
//           '🔄 تبديل حالة تشغيل الفيديو-ID:$id، الحالة الحالية: ${isPlaying ? "قيد التشغيل" : "متوقف"}');

//       if (isPlaying) {
//         // التأكد من الإيقاف باستخدام الدالة المباشرة
//         final controller = videoControllers[id];
//         if (controller != null) {
//           controller.pause();
//           playingStates[id] = false;
//           _memoryMonitor.activeVideoStatus[id] = "متوقف بواسطة المستخدم";
//           print("⏸️ تم إيقاف الفيديو-ID:$id مباشرة");
//         } else {
//           pauseVideo(id);
//         }
//       } else {
//         playVideo(id);
//       }
//       update(); // تحديث الواجهة مباشرةً
//     } catch (e) {
//       print("❌ خطأ في تبديل حالة تشغيل الفيديو-ID:$id: $e");
//     }
//   }

//   // التعامل مع السحب الأفقي
//   void handleHorizontalDrag(DragEndDetails details, int index, int mediaCount) {
//     // التحقق من صحة المؤشرات
//     if (index < 0 ||
//         index >= reels.length ||
//         currentMediaIndex.value < 0 ||
//         currentMediaIndex.value >= mediaCount) {
//       print('⚠️ مؤشرات خارج النطاق في handleHorizontalDrag');
//       return;
//     }

//     final controller = getMediaController(index);
//     final velocity = details.primaryVelocity ?? 0;

//     // استخدام عتبة سرعة للتمييز بين التمرير المقصود والعرضي
//     final velocityThreshold = 200.0;

//     print('👆 سحب أفقي بسرعة: $velocity (العتبة: $velocityThreshold)');

//     // السرعة السالبة للانتقال للصفحة السابقة
//     if (velocity < -velocityThreshold && currentMediaIndex.value > 0) {
//       print('👈 الانتقال للصفحة السابقة');
//       // التمرير للصفحة السابقة
//       controller.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//     // السرعة الموجبة للانتقال للصفحة التالية
//     else if (velocity > velocityThreshold &&
//         currentMediaIndex.value < mediaCount - 1) {
//       print('👉 الانتقال للصفحة التالية');
//       // التمرير للصفحة التالية
//       controller.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

// // التعامل مع النقر المزدوج
//   void handleDoubleTap(int index) {
//     if (index < 0 || index >= reels.length) {
//       print('⚠️ مؤشر خارج النطاق في handleDoubleTap: $index');
//       return;
//     }

//     print('👆👆 نقرة مزدوجة على الريل: $index');
//     toggleLike(index);
//   }

//   // تشغيل فيديو
//   void playVideo(String id) {
//     if (!videoControllers.containsKey(id)) {
//       print('❌ فشل التشغيل: المتحكم غير موجود للفيديو-ID:$id');
//       return;
//     }

//     print('▶️ بدء تشغيل الفيديو-ID:$id');
//     _memoryMonitor.updateLastAccessTime(id);

//     try {
//       final controller = videoControllers[id];

//       if (controller == null) {
//         print('❌ فشل التشغيل: المتحكم فارغ للفيديو-ID:$id');
//         return;
//       }

//       // فحص ما إذا كان الفيديو جاهزاً للتشغيل
//       if (!isVideoInitialized(id)) {
//         print('❌ فشل التشغيل: الفيديو-ID:$id غير مُهيأ بشكل صحيح');
//         return;
//       }

//       // إيقاف جميع الفيديوهات الأخرى أولاً مع كتم صوتها
//       stopAllVideosExcept(id);

//       // كتم صوت الفيديو قبل التشغيل
//       controller.setVolume(0.0);

//       // تشغيل الفيديو مع معالجة الأخطاء
//       try {
//         // ضبط اتجاه الشاشة
//         SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//         // تحديث حالة التشغيل قبل التشغيل فعلياً لإخفاء أيقونة التشغيل على الفور
//         playingStates[id] = true;
//         update();

//         controller.play();

//         // تسجيل الفيديو النشط
//         _audioManager.registerActiveVideo(id);

//         // جدولة تفعيل الصوت مع تأخير مناسب
//         _audioManager.scheduleAudioActivation(id, controller);
//       } catch (playError) {
//         print('❌ خطأ في عملية تشغيل الفيديو-ID:$id: $playError');
//         return;
//       }

//       // تحديث حالة التشغيل
//       playingStates[id] = true;
//       currentActiveVideoId = id;
//       _memoryMonitor.activeVideoStatus[id] = "قيد التشغيل";

//       // تحديث واجهة المستخدم
//       update();

//       print('✅ تم تشغيل الفيديو-ID:$id بنجاح');
//     } catch (e) {
//       print('❌ خطأ عام في تشغيل الفيديو-ID:$id: $e');
//     }
//   }

// // إيقاف جميع الفيديوهات باستثناء فيديو محدد
//   void stopAllVideosExcept(String? exceptId) {
//     print('🛑 إيقاف جميع الفيديوهات باستثناء: ${exceptId ?? "لا يوجد"}');

//     // تعطيل أي تفعيل للصوت معلق
//     _audioManager.muteAllExcept(exceptId);

//     // إنشاء نسخة من المفاتيح لتجنب مشاكل التعديل المتزامن
//     final keys = videoControllers.keys.toList();

//     // كتم صوت جميع الفيديوهات أولاً قبل إيقافها
//     for (var id in keys) {
//       if (id != exceptId) {
//         try {
//           final controller = videoControllers[id];
//           if (controller != null) {
//             print('🔇 كتم صوت الفيديو-ID:$id');
//             controller.setVolume(0.0);
//           }
//         } catch (e) {
//           print('⚠️ خطأ في كتم صوت الفيديو-ID:$id: $e');
//         }
//       }
//     }

//     // ثم إيقاف تشغيل جميع الفيديوهات (بفاصل زمني قصير للتأكد من كتم الصوت أولاً)
//     Future.delayed(Duration(milliseconds: 10), () {
//       for (var id in keys) {
//         if (id != exceptId) {
//           try {
//             final controller = videoControllers[id];
//             if (controller != null) {
//               print('⏹️ إيقاف الفيديو-ID:$id');
//               controller.pause();
//               // تحديث حالة التشغيل
//               playingStates[id] = false;
//               _memoryMonitor.activeVideoStatus[id] = "متوقف";
//             }
//           } catch (e) {
//             print('⚠️ خطأ في إيقاف الفيديو-ID:$id: $e');
//             // تحديد الفيديو للتنظيف
//             videoErrorStates[id] = true;
//           }
//         }
//       }

//       // تحديث معرف الفيديو النشط حالياً
//       currentActiveVideoId = exceptId;
//       update();

//       // جدولة تنظيف الفيديوهات التي بها أخطاء
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         for (var id in keys) {
//           if (id != exceptId && videoErrorStates[id] == true) {
//             disposeController(id);
//           }
//         }
//       });
//     });

//     print('✅ تم إيقاف جميع الفيديوهات بنجاح');
//   }

//   // تبديل حالة كتم الصوت
//   void toggleMute() {
//     final newMuteState = !isMuted.value;
//     isMuted.value = newMuteState;

//     print('🔊 تبديل حالة كتم الصوت: ${newMuteState ? "كتم" : "تشغيل"}');

//     // تحديث حالة كتم الصوت في مدير الصوت
//     _audioManager.updateMuteState(newMuteState, currentActiveVideoId);

//     // تطبيق حالة كتم الصوت على الفيديو النشط
//     if (currentActiveVideoId != null) {
//       final controller = videoControllers[currentActiveVideoId!];
//       if (controller != null) {
//         print(
//             '🔊 تطبيق حالة كتم الصوت على الفيديو النشط-ID:${currentActiveVideoId!}');
//         controller.setVolume(newMuteState ? 0.0 : 1.0);
//       }
//     }

//     update();
//   }

// // تحديث دالة التعامل مع تغييرات دورة حياة التطبيق
//   void _handleAppLifecycleChange(String state) {
//     print('🔄 تغيير حالة دورة حياة التطبيق: $state');

//     if (state == 'AppLifecycleState.paused' ||
//         state == 'AppLifecycleState.inactive') {
//       print('⏸️ التطبيق في الخلفية: إيقاف جميع الوسائط');
//       // إيقاف جميع الوسائط عندما يكون التطبيق في الخلفية
//       _audioManager.muteAllExcept(null); // كتم الصوت فوراً
//       pauseAllVideos();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         stopAllVideosExcept(null);
//       });
//     } else if (state == 'AppLifecycleState.resumed') {
//       print('▶️ التطبيق عاد للمقدمة: استئناف الوسائط النشطة');
//       // استئناف الفيديو النشط فقط عند العودة للمقدمة
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (currentActiveVideoId != null) {
//           playVideo(currentActiveVideoId!);
//         }
//       });

//       // إعادة تعيين الإخفاقات السابقة للسماح بإعادة محاولة التحميل المسبق
//       _preloadManager.resetFailedPreloads();
//     }
//   }

//   // إيقاف فيديو محدد
//   void pauseVideo(String id) {
//     videoLastActiveTimes[id] = DateTime.now();

//     if (!videoControllers.containsKey(id)) {
//       print("Pause failed: No controller found for id $id");
//       return;
//     }

//     try {
//       final controller = videoControllers[id];
//       if (controller == null) {
//         print("Pause failed: Controller is null for id $id");
//         return;
//       }

//       if (controller.videoPlayerController == null) {
//         print("Pause failed: VideoPlayerController is null for id $id");
//         return;
//       }

//       // إيقاف الفيديو مع معالجة الأخطاء
//       try {
//         controller.pause();
//       } catch (pauseError) {
//         print("Error in pause operation for id $id: $pauseError");
//         return;
//       }

//       // تحديث حالة التشغيل
//       playingStates[id] = false;

//       // تحديث واجهة المستخدم
//       update();

//       // طباعة تقرير نجاح الإيقاف
//       print("Video $id successfully paused");
//     } catch (e) {
//       print("Error pausing video $id: $e");
//     }
//   }

//   // إيقاف جميع الفيديوهات
//   void pauseAllVideos() {
//     try {
//       // Primero silenciar todos los videos antes de pausarlos
//       for (var entry in videoControllers.entries) {
//         try {
//           entry.value.setVolume(0.0);
//         } catch (e) {
//           print("Error silenciando video ${entry.key}: $e");
//         }
//       }

//       // Luego pausar todos los videos
//       for (var entry in videoControllers.entries) {
//         try {
//           entry.value.pause();
//           playingStates[entry.key] = false;
//         } catch (e) {
//           print("Error pausando video ${entry.key}: $e");
//         }
//       }
//       update();
//     } catch (e) {
//       print("Error en pauseAllVideos: $e");
//     }
//   }

//   // الحصول على نسبة أبعاد الفيديو
//   double? getVideoAspectRatio(String id) {
//     // استخدام نسبة أبعاد افتراضية إذا لم يتم العثور على النسبة الفعلية
//     return videoAspectRatios[id] ?? 9 / 18;
//   }

//   // تنظيف ذاكرة الصور المؤقتة
//   void cleanupImageCache() {
//     try {
//       // تنظيف الذاكرة المؤقتة للصور غير المعروضة حالياً
//       PaintingBinding.instance.imageCache.clear();
//       PaintingBinding.instance.imageCache.clearLiveImages();

//       // تنظيف مخصص للتخزين المؤقت للصور
//       try {
//         DefaultCacheManager().emptyCache();
//       } catch (e) {
//         print("Error emptying default cache: $e");
//       }

//       // محاولة تنظيف مدير التخزين المؤقت المخصص
//       try {
//         final cacheManager = CacheManager(
//           Config(
//             'reelsImageCache',
//             stalePeriod: const Duration(days: 2),
//             maxNrOfCacheObjects: 500, // زيادة عدد العناصر المخزنة مؤقتًا
//           ),
//         );
//         cacheManager.emptyCache();
//       } catch (e) {
//         print("Error emptying custom cache: $e");
//       }

//       print('Image cache cleaned successfully');
//     } catch (e) {
//       print('Error cleaning image cache: $e');
//     }
//   }

// // تنفيذ آلية تتبع المشاهدة للصور
//   void startImageWatchTimer(int index) {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];

//     // تجنب تكرار تسجيل المشاهدة
//     if ((viewedReels[reel.id] ?? false) ||
//         (reelWatchProgress[reel.id] ?? false)) return;

//     // سجل وقت البداية
//     reelWatchStartTimes[reel.id] = DateTime.now();

//     // أنشئ مؤقت لتسجيل المشاهدة بعد المدة المحددة
//     Future.delayed(minWatchDuration, () {
//       // تحقق مما إذا كان المستخدم لا يزال يشاهد نفس الريل
//       if (currentReelIndex.value == index) {
//         reelWatchProgress[reel.id] = true;
//         markAsViewed(index);
//       }
//     });
//   }

//   // دالة مشاركة الريل مباشرة (للاستخدام من زر المشاركة)
//   void shareReel(int index) {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];

//     // Registrar estadística de compartir
//     _trackShareEvent(reel.id);

//     // Mostrar opciones de compartir
//     _showShareOptions(reel);
//   }

//   void _showShareOptions(Reel reel) {
//     // Construir las opciones de compartir de forma dinámica
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
//               ...options
//                   .map((option) => _buildShareOptionItem(option))
//                   .toList(),
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

//   Widget _buildShareOptionItem(ShareOption option) {
//     return InkWell(
//       onTap: () {
//         Get.back(); // Cerrar el modal primero
//         option.onTap(); // Luego ejecutar la acción
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

//   Future<void> _shareReelLink(Reel reel) async {
//     try {
//       // Generar enlace de deep linking
//       final reelLink = _generateDeepLink(reel);

//       // Mensaje personalizado con branding
//       final shareText = 'شاهد هذا المحتوى المميز من رادار 📱✨\n$reelLink';

//       // Usar Share.share para mostrar el selector nativo del sistema
//       await Share.share(
//         shareText,
//         subject: 'مشاركة من رادار',
//       );

//       // Registrar éxito de compartir
//       print("تمت مشاركة الريل بنجاح: ${reel.id}");
//     } catch (e) {
//       print("خطأ في مشاركة الريل: $e");
//       _showErrorSnackbar('مشاركة الرابط', e.toString());
//     }
//   }

// // Copiar enlace al portapapeles
//   Future<void> _copyReelLink(Reel reel) async {
//     try {
//       // Generar enlace de deep linking
//       final reelLink = _generateDeepLink(reel);

//       // Copiar al portapapeles
//       await Clipboard.setData(ClipboardData(text: reelLink));

//       // Mostrar confirmación
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

// // Compartir a WhatsApp (utilizando la función existente pero mejorada)
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

// // Compartir imagen del reel
//   Future<void> _shareReelImage(Reel reel) async {
//     // Mostrar indicador de carga
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
//       // Verificar la existencia de medios
//       if (reel.mediaUrls.isEmpty) {
//         throw Exception("لا توجد وسائط للمشاركة في هذا الريل");
//       }

//       // Seleccionar la URL adecuada (miniatura para videos, imagen directa para fotos)
//       final mediaUrl = reel.isVideoMedia(0)
//           ? (reel.mediaUrls[0].poster ?? reel.mediaUrls[0].url)
//           : reel.mediaUrls[0].url;

//       // Descargar la imagen
//       final response = await http.get(Uri.parse(mediaUrl));

//       if (response.statusCode != 200) {
//         throw Exception("فشل تحميل صورة الريل (${response.statusCode})");
//       }

//       // Guardar la imagen temporalmente
//       final tempDir = await getTemporaryDirectory();
//       final filePath = '${tempDir.path}/reel_image_${reel.id}.jpg';
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);

//       // Cerrar el diálogo de carga
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       } else {
//         loadingDialogCompleter.complete();
//       }

//       // Compartir la imagen con texto personalizado
//       await Share.shareFiles(
//         [filePath],
//         text: 'شاهد هذا المحتوى المميز من رادار 📱✨',
//         subject: 'مشاركة من رادار',
//       );
//     } catch (e) {
//       print("خطأ أثناء مشاركة صورة الريل: $e");

//       // Cerrar el diálogo de carga si está abierto
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       } else {
//         loadingDialogCompleter.complete();
//       }

//       _showErrorSnackbar('مشاركة الصورة', e.toString());
//     }
//   }

//   String _generateDeepLink(Reel reel) {
//     final baseWebUrl = "https://radar.anycode-sy.com/reel/${reel.id}";

//     final params = {
//       'source': 'app',
//       'utm_source': 'share',
//       'utm_medium': 'app_share',
//       'content_type': reel.isVideoMedia(0) ? 'video' : 'image',
//       'owner': Uri.encodeComponent(reel.ownerName),
//       'share_time': DateTime.now().millisecondsSinceEpoch.toString(),
//       'Url': reel.mediaUrls[0].url
//     };

//     final queryString =
//         params.entries.map((e) => '${e.key}=${e.value}').join('&');

//     return '$baseWebUrl?$queryString';
//   }

//   Future<void> _trackShareEvent(String reelId) async {
//     try {
//       print("Registrando evento de compartir para reel: $reelId");

//       // Ejemplo de cómo sería la llamada a la API:
//       // await _reelsApiService.trackShare(reelId, {
//       //   'timestamp': DateTime.now().toIso8601String(),
//       //   'platform': Platform.isAndroid ? 'android' : 'ios',
//       //   'shareMethod': 'app'
//       // });
//     } catch (e) {
//       print("Error al registrar evento de compartir: $e");
//     }
//   }

//   Future<void> navigateToReelById(String reelId,
//       {bool fromDeepLink = false}) async {
//     print(
//         "ReelsController: معالجة طلب التنقل إلى الريل ID: $reelId, fromDeepLink: $fromDeepLink");

//     // عند بدء التنقل إلى ريل، تأكد من إيقاف جميع الفيديوهات أولاً
//     stopAllVideosExcept(null);

//     // إذا كانت الريلز مازالت قيد التحميل، وكان الطلب من رابط مشاركة
//     if (isLoading.value && fromDeepLink) {
//       // حفظ الطلب ليتم معالجته لاحقاً
//       print("الريلزات قيد التحميل، حفظ طلب التنقل ليتم معالجته لاحقاً");
//       pendingDeepLinkReelId.value = reelId;
//       return;
//     }

//     // إذا كانت الريلز مازالت قيد التحميل، انتظر حتى تنتهي
//     if (isLoading.value) {
//       print("ReelsController: تحميل الريلزات جاري، انتظار انتهاء التحميل...");
//       int attempts = 0;
//       while (isLoading.value && attempts < 10) {
//         await Future.delayed(Duration(milliseconds: 300));
//         attempts++;
//       }
//     }

//     // البحث عن الريل في القائمة الحالية
//     final existingIndex = reels.indexWhere((reel) => reel.id == reelId);

//     if (existingIndex >= 0) {
//       // إذا كان الريل ليس في البداية، قم بنقله
//       if (existingIndex > 0) {
//         final targetReel = reels.removeAt(existingIndex);
//         reels.insert(0, targetReel);
//         print("ReelsController: الريل موجود مسبقًا، تم نقله إلى المقدمة");
//       }

//       // الانتقال إلى الصفحة الأولى
//       _jumpToFirstReel();
//     } else {
//       // جلب الريل
//       print("ReelsController: الريل غير موجود، جلبه من API...");
//       try {
//         isLoading.value = true;
//         final specificReel = await _reelsApiService.getReelById(reelId);

//         if (specificReel != null) {
//           // إضافة الريل في البداية
//           reels.insert(0, specificReel);
//           print("ReelsController: تم جلب الريل بنجاح وإضافته في المقدمة");

//           // تحديث حالات الريل
//           likedReels[specificReel.id] = specificReel.isLiked;
//           viewedReels[specificReel.id] = specificReel.isWatched;
//           whatsappedReels[specificReel.id] = specificReel.isWhatsapped;

//           // الانتقال إلى الصفحة الأولى
//           _jumpToFirstReel();
//         } else {
//           print("ReelsController: لم يتم العثور على الريل المطلوب");
//         }
//       } catch (e) {
//         print("ReelsController: خطأ أثناء جلب الريل من API: $e");
//       } finally {
//         isLoading.value = false;
//       }
//     }

//     // تحديث الواجهة
//     update();
//   }

// // دالة مساعدة للانتقال إلى الريل الأول
//   void _jumpToFirstReel() {
//     if (pageController.hasClients) {
//       pageController.jumpToPage(0);
//     }
//     currentReelIndex.value = 0;
//     currentMediaIndex.value = 0;
//   }

//   // Mostrar mensaje de error
//   void _showErrorSnackbar(String action, String errorDetails) {
//     // Simplificar el mensaje de error para el usuario
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

//   void resetExpandedCaptions() {
//     expandedCaptions.clear();
//     update();
//   }

//   // تحديث دالة onClose لتنظيف موارد إدارة الصوت
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
//     stopAllVideosExcept(null);

//     // تنظيف جميع وحدات التحكم
//     cleanupAllControllers();

//     // تنظيف مدير التحميل المسبق ومدير الصوت
//     _preloadManager.dispose();
//     _audioManager.dispose();

//     // التخلص من وحدات تحكم الرسوم المتحركة
//     storyAnimationController.dispose();
//     reelAnimationController.dispose();
//     pageController.dispose();

//     // تنظيف ذاكرة الصور المؤقتة
//     PaintingBinding.instance.imageCache.clear();

//     // محاولة تنظيف ذاكرة التخزين المؤقت
//     try {
//       DefaultCacheManager().emptyCache();
//     } catch (e) {
//       print("⚠️ خطأ في تفريغ التخزين المؤقت أثناء onClose: $e");
//     }

//     print('✅ تم إغلاق ReelsController بنجاح');
//     super.onClose();
//   }

//   @override
//   void dispose() {
//     print('🔄 بدء dispose لـ ReelsController');
//     // تعطيل إبقاء الشاشة مضاءة
//     Wakelock.disable();
//     print('✅ تم dispose لـ ReelsController بنجاح');
//     super.dispose();
//   }

//   // image proccess

//   // إضافة هذه الدالة إلى ReelsController
//   void preloadImages(int currentIndex) {
//     for (int i = 1; i <= 3; i++) {
//       // تحميل الصور الموجودة في الريلز القادمة
//       final nextIndex = currentIndex + i;
//       if (nextIndex < reels.length) {
//         final nextReel = reels[nextIndex];
//         for (var media in nextReel.mediaUrls) {
//           if (!nextReel.isVideoMedia(nextReel.mediaUrls.indexOf(media))) {
//             _loadImageWithPriority(media.url, priority: i);
//           }
//         }
//       }

//       // تحميل الصور الموجودة في الريلز السابقة
//       final prevIndex = currentIndex - i;
//       if (prevIndex >= 0) {
//         final prevReel = reels[prevIndex];
//         for (var media in prevReel.mediaUrls) {
//           if (!prevReel.isVideoMedia(prevReel.mediaUrls.indexOf(media))) {
//             _loadImageWithPriority(media.url, priority: i);
//           }
//         }
//       }
//     }
//   }

//   void _loadImageWithPriority(String url, {required int priority}) {
//     Future.delayed(Duration(milliseconds: priority * 50), () {
//       if (Get.context != null) {
//         precacheImage(CachedNetworkImageProvider(url), Get.context!);
//       }
//     });
//   }

// // إضافة هذه الدالة في onInit للـ ReelsController
//   void setupAdvancedImageCache() {
//     // تكوين تخزين مؤقت متقدم للصور
//     PaintingBinding.instance.imageCache.maximumSize =
//         150; // تعيين حجم التخزين المؤقت للصور

//     final cacheManager = CacheManager(
//       Config(
//         'reelsImagesCache',
//         stalePeriod: const Duration(hours: 6),
//         maxNrOfCacheObjects: 300, // زيادة حجم التخزين المؤقت
//         fileService: HttpFileService(
//           httpClient: CustomHttpClient(), // يمكن تكوين عميل HTTP مخصص
//         ),
//       ),
//     );

//     // تنظيف دوري للذاكرة
//     Timer.periodic(Duration(minutes: 30), (_) {
//       cleanupDistantControllers(currentReelIndex.value);
//     });
//   }

//   // memory management

//   void optimizeMediaCacheForLowMemory() {
//     // حذف التخزين المؤقت للفيديوهات البعيدة
//     final currentIndex = currentReelIndex.value;
//     if (currentIndex >= 0 && reels.isNotEmpty) {
//       // حذف التخزين المؤقت للريلز البعيدة عن الريل الحالي
//       for (var entry in videoControllers.entries.toList()) {
//         final id = entry.key;
//         final reelIndex = reels.indexWhere((reel) => reel.id == id);

//         if (reelIndex == -1 || (reelIndex - currentIndex).abs() > 5) {
//           disposeController(id);
//         }
//       }

//       // تنظيف ذاكرة التخزين المؤقت للصور
//       if (currentIndex % 10 == 0) {
//         PaintingBinding.instance.imageCache.clear();
//         PaintingBinding.instance.imageCache.clearLiveImages();
//       }
//     }
//   }

// // إضافة تأثيرات انتقالية سلسة عند تغيير الريل
//   void setupSmoothTransitions() {
//     // إضافة تأثيرات انتقالية سلسة بين الريلز
//     Get.config(
//       defaultTransition: Transition.fadeIn,
//       defaultDurationTransition: Duration(milliseconds: 150),
//     );

//     // إضافة تأثير انتقالي سلس للعناصر
//     storyAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 150),
//     );

//     reelAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 150),
//     );
//   }

//   Future<void> showStoreDetails(String storeId) async {
//     pauseAllVideos();
//     // إنشاء متغير مراقب لحالة التحميل
//     final isLoading = true.obs;
//     final storeDataRx = Rxn<Map<String, dynamic>>();
//     final errorMessageRx = RxnString(); // إضافة متغير لرسالة الخطأ

//     // فتح الـ bottom sheet مرة واحدة
//     Get.bottomSheet(
//       Obx(() => Container(
//             height: Get.height * 0.75,
//             decoration: BoxDecoration(
//               color: Color(0xFF1E1E1E),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 // مقبض السحب (يظهر دائماً)
//                 Container(
//                   margin: EdgeInsets.only(top: 10, bottom: 5),
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[600],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),

//                 // محتوى متغير حسب حالة التحميل
//                 Expanded(
//                   child: isLoading.value
//                       ? StoreDetailsSkeleton() // حالة التحميل: عرض السكيلتون
//                       : errorMessageRx.value != null
//                           ? ErrorView(
//                               // حالة الخطأ: عرض شاشة الخطأ
//                               message: errorMessageRx.value,
//                               onRetry: () => _retryLoadStoreDetails(storeId,
//                                   isLoading, storeDataRx, errorMessageRx),
//                             )
//                           : storeDataRx.value != null
//                               ? StoreDetailsContent(
//                                   // حالة النجاح: عرض المحتوى
//                                   storeData: storeDataRx.value!,
//                                   launchWhatsApp: _launchWhatsApp,
//                                 )
//                               : ErrorView(
//                                   // حالة غير متوقعة
//                                   message: 'حدث خطأ غير متوقع',
//                                 ),
//                 ),
//               ],
//             ),
//           )),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       isDismissible: false,
//       enableDrag: true,
//     );

//     // تحميل البيانات
//     _loadStoreDetails(storeId, isLoading, storeDataRx, errorMessageRx);
//   }

//   // دالة لتحميل بيانات المتجر
//   Future<void> _loadStoreDetails(String storeId, RxBool isLoading,
//       Rxn<Map<String, dynamic>> storeDataRx, RxnString errorMessageRx) async {
//     try {
//       // جلب بيانات المتجر
//       final storeData = await _reelsApiService.getStoreDetails(storeId);

//       // تحديث البيانات
//       storeDataRx.value = storeData;
//       errorMessageRx.value = null; // مسح أي رسالة خطأ سابقة
//     } catch (e) {
//       // تحديث رسالة الخطأ
//       errorMessageRx.value =
//           'فشل في تحميل بيانات المتجر، يرجى المحاولة مرة أخرى';

//       // عرض رسالة الخطأ كتوست
//       CustomToast.showErrorToast(
//           message: 'فشل في تحميل بيانات المتجر، يرجى المحاولة مرة أخرى');

//       print("Error loading store details: $e");
//     } finally {
//       // إيقاف حالة التحميل
//       isLoading.value = false;
//     }
//   }

//   // دالة لإعادة محاولة تحميل البيانات
//   Future<void> _retryLoadStoreDetails(String storeId, RxBool isLoading,
//       Rxn<Map<String, dynamic>> storeDataRx, RxnString errorMessageRx) async {
//     // إعادة تنشيط حالة التحميل
//     isLoading.value = true;

//     // إعادة تحميل البيانات
//     await _loadStoreDetails(storeId, isLoading, storeDataRx, errorMessageRx);
//   }

//   // فتح رابط واتساب
//   void _launchWhatsApp(String url) async {
//     try {
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         CustomToast.showErrorToast(message: 'لا يمكن فتح تطبيق واتساب');
//       }
//     } catch (e) {
//       CustomToast.showErrorToast(message: 'حدث خطأ أثناء فتح واتساب');
//       print("Error launching WhatsApp: $e");
//     }
//   }
// }

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

// // تطبيق عميل HTTP مخصص لتحسين الأداء
// class CustomHttpClient extends http.BaseClient {
//   final http.Client _innerClient = http.Client();

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     // تعيين أولويات أعلى لملفات الصور الصغيرة مثل البوستر
//     if (request.url.path.contains('poster')) {
//       request.headers['Priority'] = 'high';
//     }

//     return _innerClient.send(request);
//   }
// }
