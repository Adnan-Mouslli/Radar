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

//   void toggleMute() {
//     isMuted.value = !isMuted.value;

//     // تطبيق حالة كتم الصوت على الفيديو النشط
//     if (currentActiveVideoId != null) {
//       final controller = videoControllers[currentActiveVideoId!];
//       controller?.setVolume(isMuted.value ? 0.0 : 1.0);
//     }

//     update();
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

//   // تسجيل مشاهدة للمحتوى
//   void markAsViewed(int index) async {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];
//     // تجنب تسجيل المشاهدة مرة أخرى
//     if (viewedReels[reel.id] == true) return;

//     // تحديث حالة المشاهدة محلياً أولاً (Optimistic Update)
//     viewedReels[reel.id] = true;

//     reel.counts.viewedBy += 1;
//     reel.isWatched = true;
//     update(); // تحديث واجهة المستخدم فقط

//     try {
//       // إرسال الطلب إلى الخادم
//       final response = await _reelsApiService.viewContent(reel.id);

//       // طباعة الاستجابة للتشخيص
//       print("================================================================");
//       print("Response from API: $response");

//       final bool isSuccess = response['success'] == true;

//       if (isSuccess) {
//         // طباعة رسالة نجاح
//         if (response.containsKey('message')) {
//           print("Server message: ${response['message']}");
//         }

//         // التحقق من وجود جوهرة
//         final bool hasGem = response['gemClaimed'] == true;

//         if (hasGem) {
//           // استخراج بيانات الجوهرة
//           final int gemPoints = response['gemPoints'] is int
//               ? response['gemPoints']
//               : (int.tryParse(response['gemPoints'].toString()) ?? 0);

//           // استخدام اللون الافتراضي حيث أن الاستجابة لا تحتوي على لون
//           const String gemColor = "blue";

//           // عرض الرسوم المتحركة للجوهرة فقط إذا كانت النقاط أكبر من صفر
//           if (gemPoints > 0) {
//             final gemService = Get.find<GemService>();
//             gemService.showGemAnimation(gemPoints, gemColor);
//           }
//         }

//         // التحقق من النقاط الممنوحة (قد تكون مختلفة عن نقاط الجوهرة)
//         if (response.containsKey('pointsAwarded')) {
//           final int pointsAwarded = response['pointsAwarded'] is int
//               ? response['pointsAwarded']
//               : (int.tryParse(response['pointsAwarded'].toString()) ?? 0);

//           if (pointsAwarded > 0) {
//             print(
//                 "User awarded $pointsAwarded points for viewing this content");
//             // يمكنك هنا إضافة منطق لتحديث نقاط المستخدم في واجهة المستخدم إذا لزم الأمر
//           }
//         }
//       } else {
//         print("التحديث فشل، إعادة الحالة السابقة");

//         // طباعة رسالة الخطأ من الخادم إن وجدت
//         if (response.containsKey('message')) {
//           print("Server error message: ${response['message']}");
//         }

//         // إعادة الحالة السابقة
//         _revertViewState(index, reel.counts.viewedBy);
//       }
//     } catch (e) {
//       print("خطأ في تسجيل المشاهدة: $e");
//       // في حالة حدوث خطأ، نعيد الحالة السابقة
//       _revertViewState(index, reel.counts.viewedBy);
//     }
//   }

// // دالة مساعدة لإعادة الحالة في حالة الفشل
//   void _revertViewState(int index, int originalViewCount) {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];

//     // إعادة حالة المشاهدة الأصلية
//     viewedReels[reel.id] = false;
//     reelWatchProgress[reel.id] = false;

//     reel.counts.viewedBy = originalViewCount;
//     reel.isWatched = false;

//     update();
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

//   @override
//   void onInit() {
//     super.onInit();

//     setupSmoothTransitions();

//     _initControllers();
//     _fetchReels().then((_) {
//       // After reels are loaded, check if there's a pending navigation request
//       if (pendingDeepLinkReelId.value != null) {
//         final reelId = pendingDeepLinkReelId.value!;
//         print("Found pending navigation request to reel: $reelId");

//         // Small delay to ensure UI is fully rendered
//         Future.delayed(Duration(milliseconds: 100), () {
//           navigateToReelById(reelId, fromDeepLink: true);
//           pendingDeepLinkReelId.value = null;
//         });
//       }
//     });

//     pageController.addListener(_onPageScroll);

//     // Improve app lifecycle handling
//     SystemChannels.lifecycle.setMessageHandler((msg) async {
//       handleAppLifecycleChange(msg ?? '');
//       return null;
//     });

//     SystemChannels.platform.invokeMethod(
//         'SystemNavigator.setSystemUiOverlayStyle',
//         '{"statusBarColor": "#000000", "systemNavigationBarColor": "#000000"}');

//     // Set up image processing
//     setupAdvancedImageCache();

//     Wakelock.enable();
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

//   void _onPageScroll() {
//     // تحميل المزيد من البيانات عند الاقتراب من نهاية القائمة
//     final currentPage = pageController.page?.round() ?? 0;
//     if (currentPage >= reels.length - 3) {
//       // loadMoreReels();
//     }

//     // تنظيف وحدات التحكم البعيدة عند التمرير
//     if (currentPage >= cleanupInterval && !isPerformingCleanup) {
//       isPerformingCleanup = true;
//       // استخدام addPostFrameCallback لضمان عدم حدوث تغييرات في الواجهة أثناء التحديث
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         cleanupDistantControllers(currentPage);
//         isPerformingCleanup = false;
//       });
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

//   // تحسين وظيفة التنقل بين الريلز
//   void onReelPageChanged(int index) {
//     if (index < 0 || index >= reels.length) return;

//     // إيقاف جميع الأصوات أولاً
//     cleanupAllAudio();
//     stopAllVideosExcept(null);

//     final previousIndex = currentReelIndex.value;
//     currentReelIndex.value = index;
//     currentMediaIndex.value = 0;

//     // تحميل الفيديو مع تأخير قصير
//     final currentReel = reels[index];
//     reelWatchStartTimes[currentReel.id] = DateTime.now();

//     Future.delayed(Duration(milliseconds: 50), () {
//       if (currentReel.mediaUrls.isNotEmpty) {
//         final firstMedia = currentReel.mediaUrls[0];

//         if (currentReel.isVideoMedia(0)) {
//           initializeVideo(currentReel.id, firstMedia.url, firstMedia.poster);
//         } else {
//           startImageWatchTimer(index);
//         }
//       }

//       preloadAdjacentContent(index);
//     });

//     // معالجة الريل السابق
//     if (previousIndex >= 0 && previousIndex < reels.length) {
//       final previousReel = reels[previousIndex];
//       checkAndMarkReelAsViewed(previousIndex);
//     }

//     // Limpiar controladores distantes
//     if (previousIndex != index) {
//       Future.delayed(Duration(milliseconds: 200), () {
//         cleanupDistantControllers(index);
//       });
//     }

//     update();
//   }

//   void checkAndMarkReelAsViewed(int index) {
//     if (index < 0 || index >= reels.length) return;

//     final reel = reels[index];

//     // تجنب تكرار تسجيل المشاهدة
//     if ((viewedReels[reel.id] ?? false) ||
//         (reelWatchProgress[reel.id] ?? false)) return;

//     // التحقق من وقت بداية المشاهدة
//     final startTime = reelWatchStartTimes[reel.id];
//     if (startTime == null) return;

//     // حساب مدة المشاهدة
//     final watchDuration = DateTime.now().difference(startTime);

//     // تقدير ما إذا كان المستخدم قد شاهد معظم المحتوى
//     bool hasWatchedEnough = false;

//     // إذا كان الريل فيديو، نستخدم نسبة من وقت الفيديو
//     if (reel.mediaUrls.isNotEmpty && reel.isVideoMedia(0)) {
//       // للفيديوهات، قد تكون القيمة مسجلة بالفعل في videoProgressValues
//       if (videoProgressValues.containsKey(reel.id)) {
//         hasWatchedEnough = videoProgressValues[reel.id]! >= viewThreshold;
//       } else {
//         // إذا لم تكن القيمة مسجلة، نستخدم وقت المشاهدة
//         hasWatchedEnough = watchDuration >= minWatchDuration;
//       }
//     } else {
//       // للصور، نعتبر المستخدم قد شاهد الصورة إذا بقي عليها لمدة كافية
//       hasWatchedEnough = watchDuration >= minWatchDuration;
//     }

//     // تسجيل المشاهدة إذا تمت مشاهدة محتوى كافٍ
//     if (hasWatchedEnough) {
//       reelWatchProgress[reel.id] = true;
//       markAsViewed(index);
//     }

//     // إعادة تعيين وقت البداية في جميع الحالات
//     reelWatchStartTimes.remove(reel.id);
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

//   // إيقاف جميع الفيديوهات باستثناء فيديو محدد
//   void stopAllVideosExcept(String? exceptId) {
//     // Crear una copia de las claves para evitar problemas de modificación concurrente
//     final keys = videoControllers.keys.toList();

//     for (var key in keys) {
//       if (key != exceptId && videoControllers.containsKey(key)) {
//         try {
//           final controller = videoControllers[key];
//           if (controller != null && controller.videoPlayerController != null) {
//             // Establecer el volumen a 0 primero para prevenir fugas de audio
//             controller.setVolume(0.0);
//             // Asegurarse de que el video esté pausado
//             controller.pause();

//             // Actualizar el estado de reproducción
//             playingStates[key] = false;
//           }
//         } catch (e) {
//           print("Error stopping video $key: $e");
//           // Marcar para limpieza pero no intentar disponer aquí
//           videoErrorStates[key] = true;
//         }
//       }
//     }

//     // Actualizar el ID activo actualmente
//     currentActiveVideoId = exceptId;
//     update();

//     // Programar limpieza de videos con error para el siguiente frame para evitar condiciones de carrera
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       for (var key in keys) {
//         if (key != exceptId && videoErrorStates[key] == true) {
//           disposeController(key);
//         }
//       }
//     });
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

//   Future<void> preloadAdjacentContent(int currentIndex) async {
//     // تحميل الريل التالي بأولوية عالية
//     await _preloadReelContent(currentIndex + 1, highPriority: true);

//     // تحميل الريل السابق بأولوية متوسطة
//     await _preloadReelContent(currentIndex - 1);

//     // تحميل ريلز إضافية بأولوية منخفضة
//     Future.delayed(Duration(milliseconds: 100), () {
//       _preloadReelContent(currentIndex + 2);
//       _preloadReelContent(currentIndex + 3);
//     });
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

//   void _precacheImageOptimized(String url, {bool highPriority = false}) {
//     if (Get.context != null) {
//       try {
//         // تحميل الصورة مسبقاً في الذاكرة المؤقتة
//         precacheImage(
//           CachedNetworkImageProvider(
//             url,
//             cacheKey: 'preload_$url',
//           ),
//           Get.context!,
//         );
//       } catch (e) {
//         print("Error precaching image: $e");
//       }
//     }
//   }

//   // تحديد تنسيق الفيديو بناءً على الرابط
//   BetterPlayerVideoFormat _getVideoFormat(String url) {
//     final lowercaseUrl = url.toLowerCase();

//     if (lowercaseUrl.contains('.m3u8')) {
//       return BetterPlayerVideoFormat.hls;
//     } else if (lowercaseUrl.contains('.mpd')) {
//       return BetterPlayerVideoFormat.dash;
//     } else if (lowercaseUrl.contains('format=hls') ||
//         lowercaseUrl.contains('playlist_type=hls')) {
//       return BetterPlayerVideoFormat.hls;
//     } else if (lowercaseUrl.contains('format=dash') ||
//         lowercaseUrl.contains('mpd')) {
//       return BetterPlayerVideoFormat.dash;
//     }

//     // استخدام تنسيق عام كقيمة افتراضية
//     return BetterPlayerVideoFormat.other;
//   }

//   Future<void> preloadVideo(String id, String url, [String? posterUrl]) async {
//     if (preloadedVideos[id] == true || videoControllers.containsKey(id)) {
//       return;
//     }

//     // تحميل البوستر أولاً إذا كان متاحاً
//     if (posterUrl != null && posterUrl.isNotEmpty) {
//       await preloadVideoPoster(id, posterUrl);
//     }
    
//     try {
//       final betterPlayerConfiguration = BetterPlayerConfiguration(
//         autoPlay: false,
//         looping: true,
//         fit: BoxFit.contain,
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
//       );

//       final betterPlayerDataSource = BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         url,
//         videoFormat: _getVideoFormat(url),
//         cacheConfiguration: BetterPlayerCacheConfiguration(
//           useCache: true,
//           maxCacheSize: 50 * 1024 * 1024,
//           maxCacheFileSize: 10 * 1024 * 1024,
//           preCacheSize: 2 * 1024 * 1024,
//         ),
//         bufferingConfiguration: BetterPlayerBufferingConfiguration(
//           minBufferMs: 10000,
//           maxBufferMs: 30000,
//           bufferForPlaybackMs: 50,
//           bufferForPlaybackAfterRebufferMs: 100,
//         ),
//       );

//       final controller = BetterPlayerController(betterPlayerConfiguration);

//       // إضافة مستمع للأحداث للتعامل مع الأخطاء
//       controller.addEventsListener((event) {
//         if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
//           print("Preload error for video $id: ${event.parameters}");
//           preloadedVideos.remove(id);
//           controller.dispose();
//         }
//       });

//       await controller.setupDataSource(betterPlayerDataSource);
//       await controller.setVolume(0.0);

//       // بدء التحميل المسبق بدون تشغيل
//       await controller.pause();

//       videoControllers[id] = controller;
//       preloadedVideos[id] = true;

//       // تأخير قصير قبل التحميل المسبق
//       await Future.delayed(Duration(milliseconds: 100));
//       await controller.seekTo(Duration(seconds: 5));
//     } catch (e) {
//       print("Error preloading video $id: $e");
//       preloadedVideos.remove(id);
//       await disposeController(id);
//     }
//   }

//   // تهيئة وتشغيل الفيديو
//   Future<void> initializeVideo(String id, String url,
//       [String? posterUrl]) async {
//     final startTime = DateTime.now();

//     // تعيين حالات التحميل وإيقاف كل الأصوات أولاً
//     videoLoadingStates[id] = false;
//     videoErrorStates[id] = false;
//     cleanupAllAudio();
//     stopAllVideosExcept(null);
//     update();

//     // تخزين صورة البوستر مسبقاً
//     if (posterUrl != null && posterUrl.isNotEmpty) {
//       try {
//         await preloadVideoPoster(id, posterUrl);
//       } catch (e) {
//         print("خطأ في تحميل صورة البوستر: $e");
//       }
//     }

//     try {
//       // إذا كان هناك خطأ سابق، قم بتنظيف المتحكم أولاً
//       if (videoErrorStates[id] == true) {
//         await disposeController(id);
//       }

//       // إذا كان المتحكم موجود مسبقاً
//       if (videoControllers.containsKey(id)) {
//         final existingController = videoControllers[id];

//         if (existingController != null &&
//             existingController.isVideoInitialized() == true) {
//           print("استخدام متحكم مهيأ مسبقاً لـ ID $id");

//           // تحديث نسبة الأبعاد إذا كانت غير محددة
//           if (!videoAspectRatios.containsKey(id)) {
//             _updateAspectRatio(id);
//           }

//           // إيقاف أي صوت أولاً
//           await existingController.setVolume(0.0);

//           // إعادة تشغيل الفيديو من البداية
//           await existingController.seekTo(Duration.zero);
//           existingController.play();

//           // تحديث الحالات
//           playingStates[id] = true;
//           currentActiveVideoId = id;
//           videoLoadingStates[id] = false;

//           // مهم جداً: استخدام تأخير لتشغيل الصوت
//           Future.delayed(Duration(milliseconds: 100), () {
//             // تأكد أن هذا الفيديو هو الفيديو النشط حالياً قبل تشغيل الصوت
//             if (currentActiveVideoId == id &&
//                 currentReelIndex.value ==
//                     reels.indexWhere((reel) => reel.id == id)) {
//               existingController.setVolume(isMuted.value ? 0.0 : 1.0);
//               print("تم تشغيل الصوت للفيديو $id");
//             }
//           });

//           update();
//           return;
//         }

//         // إذا كان المتحكم موجوداً ولكن غير مهيأ، تخلص منه
//         await disposeController(id);
//       }

//       // إنشاء متحكم جديد
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
//       );

//       final videoFormat = _getVideoFormat(url);
//       final betterPlayerDataSource = BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         url,
//         videoFormat: videoFormat,
//         cacheConfiguration: BetterPlayerCacheConfiguration(
//           useCache: true,
//           maxCacheSize: 200 * 1024 * 1024,
//           maxCacheFileSize: 50 * 1024 * 1024,
//           preCacheSize: 3 * 1024 * 1024,
//           key: "${id}_video_cache",
//         ),
//         bufferingConfiguration: BetterPlayerBufferingConfiguration(
//           minBufferMs: 15000, // الحد الأدنى 15 ثانية للتخزين المؤقت
//           maxBufferMs: 30000, // الحد الأقصى 30 ثانية (مثالي للاتصالات البطيئة)
//           bufferForPlaybackMs: 2000, // 2.5 ثانية قبل بدء التشغيل
//           bufferForPlaybackAfterRebufferMs:
//               5000, // 5 ثوان بعد إعادة التخزين المؤقت
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

//         _setupVideoListeners(id, controller, startTime);

//         // تسجيل المتحكم الجديد
//         videoControllers[id] = controller;
//         playingStates[id] = true;
//         currentActiveVideoId = id;

//         // مهم: تشغيل الصوت فقط بعد مدة من التحميل والتأكد من أن الفيديو الحالي هو المطلوب
//         Future.delayed(Duration(milliseconds: 200), () {
//           // التحقق من أن هذا الفيديو هو الفيديو النشط حالياً قبل تشغيل الصوت
//           if (currentActiveVideoId == id &&
//               currentReelIndex.value ==
//                   reels.indexWhere((reel) => reel.id == id)) {
//             controller.setVolume(isMuted.value ? 0.0 : 1.0);
//             print("تم تشغيل الصوت للفيديو $id بعد التأخير");
//           }
//         });

//         update();
//       } catch (e) {
//         print("خطأ في تهيئة الفيديو $id: $e");
//         videoLoadingStates[id] = false;
//         videoErrorStates[id] = true;
//         update();
//       }
//     } catch (e) {
//       print("خطأ عام في تهيئة الفيديو $id: $e");
//       videoLoadingStates[id] = false;
//       videoErrorStates[id] = true;
//       update();
//     }
//   }

//   void _setupVideoListeners(
//       String id, BetterPlayerController controller, DateTime startTime) {
//     controller.removeEventsListener((event) {});

//     controller.addEventsListener((event) {
//       final eventType = event.betterPlayerEventType;

//       switch (eventType) {
//         case BetterPlayerEventType.initialized:
//           _updateAspectRatio(id);
//           videoLoadingStates[id] = false;
//           videoProgressValues[id] = 0.0;
//           update();
//           break;

//         case BetterPlayerEventType.exception:
//           print(
//               "Excepción de reproductor de video para id $id: ${event.parameters}");
//           videoErrorStates[id] = true;
//           videoLoadingStates[id] = false;
//           update();
//           break;

//         case BetterPlayerEventType.progress:
//           if (videoControllers.containsKey(id)) {
//             try {
//               final controller = videoControllers[id];
//               if (controller?.videoPlayerController != null) {
//                 final videoPlayerController =
//                     controller!.videoPlayerController!;
//                 final position = videoPlayerController.value.position;
//                 final duration = videoPlayerController.value.duration;

//                 if (duration != null &&
//                     duration.inMilliseconds > 0 &&
//                     position.inMilliseconds > 0) {
//                   final progress =
//                       position.inMilliseconds / duration.inMilliseconds;
//                   videoProgressValues[id] = progress;

//                   final isViewed = viewedReels[id] ?? false;
//                   final isWatchProgressRecorded =
//                       reelWatchProgress[id] ?? false;

//                   if (progress >= viewThreshold &&
//                       !(shineAnimationShown[id] ?? false) &&
//                       !(shineAnimationActive[id] ?? false)) {
//                     shineAnimationActive[id] = true;
//                     update();
//                   }

//                   if (progress >= viewThreshold &&
//                       !isViewed &&
//                       !isWatchProgressRecorded) {
//                     reelWatchProgress[id] = true;
//                     final reelIndex = reels.indexWhere((reel) => reel.id == id);
//                     if (reelIndex != -1) {
//                       markAsViewed(reelIndex);
//                     }
//                   }
//                 }
//               }
//             } catch (e) {}
//           }

//           if (videoLoadingStates[id] == true) {
//             videoLoadingStates[id] = false;
//             update();
//           }
//           break;

//         case BetterPlayerEventType.finished:
//           videoProgressValues[id] = 1.0;
//           controller.seekTo(Duration.zero);
//           controller.setVolume(isMuted.value ? 0.0 : 1.0);
//           SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//           controller.play();
//           break;

//         default:
//           break;
//       }
//     });
//   }

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

//         // تحديث قيمة التقدم
//         videoProgressValues[id] = progress;

//         final isViewed = viewedReels[id] ?? false;
//         final isWatchProgressRecorded = reelWatchProgress[id] ?? false;

//         // Check if we've passed the halfway point and haven't shown animation yet
//         if (progress >= viewThreshold &&
//             !(shineAnimationShown[id] ?? false) &&
//             !(shineAnimationActive[id] ?? false)) {
//           // Mark animation as active
//           shineAnimationActive[id] = true;
//           // Update UI immediately to start animation
//           update();
//         }

//         // تسجيل المشاهدة إذا تجاوزت النسبة المحددة
//         if (progress >= viewThreshold &&
//             !isViewed &&
//             !isWatchProgressRecorded) {
//           reelWatchProgress[id] = true;

//           // البحث عن index الخاص بـ id
//           final reelIndex = reels.indexWhere((reel) => reel.id == id);
//           if (reelIndex != -1) {
//             markAsViewed(reelIndex);
//           }
//         }

//         // تحديث واجهة المستخدم
//         update();
//       }
//     } catch (e) {
//       print("خطأ في تحديث تقدم الفيديو: $e");
//     }
//   }

//   // تحديث نسبة أبعاد الفيديو
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
//             "Video dimensions: ${videoData.size!.width}x${videoData.size!.height}");
//         print("Using original aspect ratio: $originalRatio for video $id");

//         // تحديث واجهة المستخدم
//         update();
//       } else {
//         // تحديث القيمة الافتراضية في حالة عدم توفر الأبعاد
//         _setDefaultAspectRatio(id);
//       }
//     } catch (e) {
//       print("Error updating aspect ratio for video $id: $e");
//       // تحديث القيمة الافتراضية في حالة حدوث خطأ
//       _setDefaultAspectRatio(id);
//     }
//   }

// // دالة مساعدة لتعيين نسبة أبعاد افتراضية
//   void _setDefaultAspectRatio(String id) {
//     // استخدام نسبة عمودية (9:16) كقيمة افتراضية
//     videoAspectRatios[id] = 9.0 / 16.0;
//     print("Using default aspect ratio (9:16) for video $id");
//     update();
//   }

//   final Map<String, DateTime> videoLastActiveTimes = {};

//   // تنظيف وحدات التحكم البعيدة
//   void cleanupDistantControllers(int currentIndex) {
//     if (isPerformingCleanup) return;
//     isPerformingCleanup = true;

//     try {
//       final keepIds = <String>{};
//       final currentTime = DateTime.now();

//       // الاحتفاظ بـ 3 ريلز قبل و3 ريلز بعد الحالي
//       for (int i = -3; i <= 3; i++) {
//         final index = currentIndex + i;
//         if (index >= 0 && index < reels.length) {
//           keepIds.add(reels[index].id);
//         }
//       }

//       // تحديد وحدات التحكم التي يجب إزالتها
//       final idsToRemove = videoControllers.keys.where((id) {
//         if (keepIds.contains(id)) return false;

//         // إذا كان الفيديو غير نشط لأكثر من 30 ثانية
//         final lastActive = videoLastActiveTimes[id];
//         if (lastActive != null &&
//             currentTime.difference(lastActive) > Duration(seconds: 30)) {
//           return true;
//         }

//         return false;
//       }).toList();

//       for (final id in idsToRemove) {
//         disposeController(id);
//       }
//     } catch (e) {
//       print("Error during cleanup: $e");
//     } finally {
//       isPerformingCleanup = false;
//     }
//   }

//   // تنظيف جميع وحدات التحكم
//   void cleanupAllControllers() {
//     try {
//       // First, pause all videos to prevent audio leaks
//       for (var id in videoControllers.keys.toList()) {
//         try {
//           final controller = videoControllers[id];
//           if (controller != null) {
//             controller.pause();
//             controller.setVolume(0.0);
//           }
//         } catch (e) {
//           print("Error pausing controller during cleanup: $e");
//         }
//       }

//       // Then safely dispose each controller
//       for (var id in videoControllers.keys.toList()) {
//         disposeController(id);
//       }

//       // Clear all maps
//       preloadedVideos.clear();
//       playingStates.clear();
//       videoAspectRatios.clear();
//       videoLoadingStates.clear();
//       videoErrorStates.clear();
//       shineAnimationShown.clear();
//       shineAnimationActive.clear();

//       // Dispose media controllers
//       for (var id in mediaControllers.keys.toList()) {
//         try {
//           final controller = mediaControllers[id];
//           if (controller != null) {
//             controller.dispose();
//           }
//         } catch (e) {
//           print("Error disposing media controller: $e");
//         }
//       }
//       mediaControllers.clear();

//       currentActiveVideoId = null;
//     } catch (e) {
//       print("Error in cleanupAllControllers: $e");
//     }
//   }

//   // التخلص من وحدة تحكم فيديو
//   Future<void> disposeController(String id) async {
//     if (!videoControllers.containsKey(id)) return;

//     try {
//       final controller = videoControllers[id];

//       // Eliminar del mapa primero para prevenir condiciones de carrera
//       videoControllers.remove(id);

//       if (controller != null) {
//         // Detener toda actividad primero
//         try {
//           controller.pause();
//           controller.setVolume(0.0);
//         } catch (controlError) {
//           print("Error pausando controlador para id $id: $controlError");
//         }

//         // Eliminar oyentes de eventos de forma segura
//         try {
//           controller.removeEventsListener((event) {});
//         } catch (listenerError) {
//           print(
//               "Error eliminando oyente de eventos para id $id: $listenerError");
//         }

//         // Usar enfoque de eliminación seguro con try-catch
//         try {
//           // Primero disponer BetterPlayerController
//           controller.dispose(forceDispose: true);
//         } catch (disposeError) {
//           print(
//               "Error durante eliminación de controlador para id $id: $disposeError");
//         }
//       }
//     } catch (e) {
//       print("Error durante eliminación de controlador para id $id: $e");
//     } finally {
//       // Limpiar todas las referencias incluso si ocurrieron errores
//       preloadedVideos.remove(id);
//       playingStates.remove(id);
//       videoAspectRatios.remove(id);
//       videoLoadingStates.remove(id);
//       videoErrorStates.remove(id);

//       // Actualizar ID activo si es necesario
//       if (currentActiveVideoId == id) {
//         currentActiveVideoId = null;
//       }
//     }
//   }

//   // التعامل مع تغيير الوسائط
//   void onMediaPageChanged(int index) {
//     try {
//       // التحقق من صحة المؤشرات
//       final reelIndex = currentReelIndex.value;
//       if (reelIndex < 0 || reelIndex >= reels.length) {
//         return;
//       }

//       final currentReel = reels[reelIndex];
//       if (index < 0 || index >= currentReel.mediaUrls.length) {
//         return;
//       }

//       cleanupAllAudio();

//       final prevMediaIndex = currentMediaIndex.value;
//       currentMediaIndex.value = index;

//       // التحقق من صحة المؤشر السابق
//       if (prevMediaIndex < 0 ||
//           prevMediaIndex >= currentReel.mediaUrls.length) {
//         return;
//       }

//       // إذا كان هناك تغيير من فيديو إلى صورة
//       if (currentReel.isVideoMedia(prevMediaIndex) &&
//           !currentReel.isVideoMedia(index)) {
//         stopAllVideosExcept(null);
//       }
//       // إذا كان هناك تغيير من صورة إلى فيديو
//       else if (!currentReel.isVideoMedia(prevMediaIndex) &&
//           currentReel.isVideoMedia(index)) {
//         final mediaUrl = currentReel.mediaUrls[index].url;
//         initializeVideo(currentReel.id, mediaUrl);
//       }
//       // إذا كان هناك تغيير من فيديو إلى فيديو آخر داخل نفس الريل
//       else if (currentReel.isVideoMedia(prevMediaIndex) &&
//           currentReel.isVideoMedia(index) &&
//           prevMediaIndex != index) {
//         stopAllVideosExcept(null);
//         final mediaUrl = currentReel.mediaUrls[index].url;
//         initializeVideo(currentReel.id, mediaUrl);
//       }
//     } catch (e) {
//       print("Error in onMediaPageChanged: $e");
//     }

//     update();
//   }

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
//       print("Error checking video initialization for id $id: $e");
//       return false;
//     }
//   }

//   // التحقق من حالة تشغيل الفيديو بطريقة محسنة
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

//         // إذا كان هناك تعارض بين الحالة المحفوظة والحالة الفعلية، قم بتحديث الحالة المحفوظة
//         if (statePlaying != actuallyPlaying) {
//           print(
//               "State mismatch for video $id: stored=$statePlaying, actual=$actuallyPlaying");
//           playingStates[id] = actuallyPlaying;
//           update();
//           return actuallyPlaying;
//         }
//       }

//       return statePlaying;
//     } catch (e) {
//       print("Error checking if video $id is playing: $e");
//       return false;
//     }
//   }

//   // تبديل حالة تشغيل الفيديو
//   void toggleVideoPlayback(String id) {
//     if (!videoControllers.containsKey(id)) {
//       print("Toggle failed: No controller found for id $id");
//       return;
//     }

//     try {
//       final isPlaying = isVideoPlaying(id);
//       print(
//           "Toggle video playback for id $id, current state: ${isPlaying ? 'playing' : 'paused'}");

//       if (isPlaying) {
//         // التأكد من الإيقاف باستخدام الدالة المباشرة
//         final controller = videoControllers[id];
//         if (controller != null) {
//           controller.pause();
//           playingStates[id] = false;
//           print("Video $id paused directly");
//         } else {
//           pauseVideo(id);
//         }
//       } else {
//         playVideo(id);
//       }
//       update(); // تحديث الواجهة مباشرةً
//     } catch (e) {
//       print("Error toggling video playback for id $id: $e");
//     }
//   }

//   // تشغيل فيديو محدد
//   void playVideo(String id) {
//     videoLastActiveTimes[id] = DateTime.now();

//     if (!videoControllers.containsKey(id)) {
//       print("Play failed: No controller found for id $id");
//       return;
//     }

//     try {
//       final controller = videoControllers[id];

//       if (controller == null) {
//         print("Play failed: Controller is null for id $id");
//         return;
//       }

//       // فحص إذا كان الفيديو جاهزاً للتشغيل
//       if (!isVideoInitialized(id)) {
//         print("Play failed: Video not initialized properly for id $id");
//         return;
//       }

//       // إيقاف جميع الفيديوهات الأخرى أولاً
//       stopAllVideosExcept(id);

//       // تشغيل الفيديو مع معالجة الأخطاء
//       try {
//         SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//         controller.setVolume(isMuted.value ? 0.0 : 1.0);
//         controller.play();

//         if (!isMuted.value) {
//           controller.setVolume(1.0);
//         }
//       } catch (playError) {
//         print("Error in play operation for id $id: $playError");
//         return;
//       }

//       // تحديث حالة التشغيل
//       playingStates[id] = true;
//       currentActiveVideoId = id;

//       // تحديث واجهة المستخدم
//       update();

//       // طباعة تقرير نجاح التشغيل
//       print("Video $id successfully playing");
//     } catch (e) {
//       print("Error playing video $id: $e");
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

//   // التعامل مع السحب الأفقي
//   void handleHorizontalDrag(DragEndDetails details, int index, int mediaCount) {
//     // التحقق من صحة المؤشرات
//     if (index < 0 ||
//         index >= reels.length ||
//         currentMediaIndex.value < 0 ||
//         currentMediaIndex.value >= mediaCount) {
//       return;
//     }

//     final controller = getMediaController(index);
//     final velocity = details.primaryVelocity ?? 0;

//     // استخدام عتبة سرعة للتمييز بين التمرير المقصود والعرضي
//     final velocityThreshold = 200.0;

//     // السرعة السالبة للانتقال للصفحة السابقة (عكس الاتجاه السابق)
//     if (velocity < -velocityThreshold && currentMediaIndex.value > 0) {
//       // التمرير للصفحة السابقة
//       controller.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//     // السرعة الموجبة للانتقال للصفحة التالية (عكس الاتجاه السابق)
//     else if (velocity > velocityThreshold &&
//         currentMediaIndex.value < mediaCount - 1) {
//       // التمرير للصفحة التالية
//       controller.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   // التعامل مع النقر المزدوج
//   void handleDoubleTap(int index) {
//     if (index < 0 || index >= reels.length) return;

//     toggleLike(index);
//     // يمكن إضافة تأثير رسوم متحركة هنا إذا كان مطلوبًا
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

//   // إنهاء الكونترولر وتنظيف الموارد
//   @override
//   void onClose() {
//     expandedCaptions.clear();

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
//       print("Error emptying cache during onClose: $e");
//     }

//     super.onClose();
//   }

//   @override
//   void dispose() {
//     Wakelock.disable();
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
