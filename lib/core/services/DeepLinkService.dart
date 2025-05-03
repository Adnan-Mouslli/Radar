import 'dart:async';
import 'package:get/get.dart';
import 'package:radar/core/constant/routes.dart';
import 'package:radar/core/services/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';
import 'package:radar/controller/home/reel_controller.dart';

class DeepLinkService extends GetxService {
  StreamSubscription? _sub;
  final _isDeepLinkHandled = false.obs;
  final _pendingReelId = Rx<String?>(null);

  final MyServices services = MyServices.instance;

  // Add a timer to handle navigation attempts
  Timer? _navigationTimer;
  int _navigationAttempts = 0;
  final int _maxNavigationAttempts = 10;

  Future<DeepLinkService> init() async {
    // Handle the initial link (when the app is opened from a closed state)
    try {
      final initialLink = await getInitialLink();
      print("Initial link received: $initialLink");
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } on PlatformException catch (e) {
      print("Error retrieving initial link: $e");
    }

    // Set up a listener for links when the app is in the background or active
    _sub = linkStream.listen((String? link) {
      print("Real-time link received: $link");
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print("Error in link stream: $err");
    });

    return this;
  }

  void _handleDeepLink(String link) {
    // Prevent multiple processing of the same link
    if (_isDeepLinkHandled.value) {
      print("Link is already being processed, ignoring");
      return;
    }

    _isDeepLinkHandled.value = true;
    print("Processing link: $link");

    try {
      // Extract the reel ID from the link
      Uri uri = Uri.parse(link);

      // Log the URI structure for debugging
      print(
          "URI Structure - Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}, Segments: ${uri.pathSegments}");

      // Handle multiple link formats
      if (_isReelLink(uri)) {
        final reelId = _extractReelId(uri);
        if (reelId != null && reelId.isNotEmpty) {
          print("Extracted Reel ID: $reelId");
          _attemptNavigation(reelId);
        } else {
          print("Could not extract a valid Reel ID from the link");
        }
      } else {
        print("The link does not correspond to a reel: $link");
      }
    } catch (e) {
      print("Error parsing link: $e");
    }

    // Reset flag after a short delay
    Future.delayed(Duration(seconds: 1), () {
      _isDeepLinkHandled.value = false;
    });
  }

  bool _isReelLink(Uri uri) {
    // Check different formats of reel links

    // Format 1: radar://reel/{id}
    if (uri.scheme == 'radar' &&
        uri.host == 'reel' &&
        uri.pathSegments.isNotEmpty) {
      return true;
    }

    // Format 2: https://radar.anycode-sy.com/reel/{id}
    if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.contains('radar.anycode-sy.com') ||
            uri.host.contains('radar.app')) &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'reel') {
      return true;
    }

    return false;
  }

  String? _extractReelId(Uri uri) {
    // Format 1: radar://reel/{id}
    if (uri.scheme == 'radar' &&
        uri.host == 'reel' &&
        uri.pathSegments.isNotEmpty) {
      return uri.pathSegments[
          0]; // في هذا التنسيق، معرف الريل هو العنصر الأول في pathSegments
    }

    // Format 2: https://radar.anycode-sy.com/reel/{id}
    if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'reel') {
      return uri.pathSegments[
          1]; // في هذا التنسيق، معرف الريل هو العنصر الثاني في pathSegments
    }

    return null;
  }

  void _attemptNavigation(String reelId) {
    // Cancel any existing timer
    _navigationTimer?.cancel();
    _navigationAttempts = 0;
    _pendingReelId.value = reelId;

    // Try to navigate immediately if possible
    if (Get.context != null) {
      _navigateToReel(reelId);
    } else {
      // If not possible, schedule repeated attempts
      print("GetMaterialApp is not ready, scheduling navigation attempts...");
      _scheduleNavigationAttempt();
    }
  }

  void _scheduleNavigationAttempt() {
    _navigationTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _navigationAttempts++;

      if (_pendingReelId.value == null) {
        print("No pending reel ID, canceling attempts");
        timer.cancel();
        return;
      }

      if (_navigationAttempts > _maxNavigationAttempts) {
        print("Exceeded maximum navigation attempts");
        timer.cancel();
        _pendingReelId.value = null;
        return;
      }

      print(
          "Attempt #$_navigationAttempts to navigate to reel: ${_pendingReelId.value}");

      if (Get.context != null) {
        final reelId = _pendingReelId.value!;
        _pendingReelId.value = null;
        timer.cancel();
        _navigateToReel(reelId);
      }
    });
  }

  // 1. تعديل في DeepLinkService.dart - تحسين دالة _navigateToReel

  Future<void> _navigateToReel(String reelId) async {
    print("بدء التنقل إلى الريل: $reelId");

    try {
      // التنقل إلى الشاشة الرئيسية أولاً إذا لم نكن عليها بالفعل
      if (Get.currentRoute != AppRoute.main) {
        services.saveData("isDeepLink", true);
        Get.offAllNamed(AppRoute.main);
        // انتظار لإتمام التنقل
        await Future.delayed(Duration(milliseconds: 500));
      }

      // محاولة الحصول على متحكم الريلز
      ReelsController? controller;

      try {
        // التحقق مما إذا كان المتحكم مسجلاً بالفعل
        if (Get.isRegistered<ReelsController>()) {
          controller = Get.find<ReelsController>();
          print("تم العثور على متحكم الريلز");
        } else {
          // إذا لم يكن مسجلاً، أنشئ مثيلاً جديداً ولكن لا تنتقل مباشرة
          // سيتم التنقل عندما يكتمل تحميل الريلزات
          controller = Get.put(ReelsController());
          print("تم إنشاء متحكم ريلز جديد");

          // تعيين معرف الريل المطلوب العثور عليه بعد التحميل
          controller!.pendingDeepLinkReelId.value = reelId;

          // السماح بالمتابعة دون محاولة التنقل مباشرة - سيتم التنقل تلقائياً بعد تحميل الريلزات
          return;
        }

        // إذا وصلنا هنا، فإن المتحكم مسجل بالفعل
        // التحقق مما إذا كانت الريلزات محملة
        if (controller.reels.isEmpty || controller.isLoading.value) {
          // إذا كانت فارغة، يمكننا تعيين معرف الريل ليتم التنقل إليه بعد التحميل
          controller.pendingDeepLinkReelId.value = reelId;
        } else {
          // الريلزات محملة بالفعل، يمكننا التنقل إلى الريل مباشرة
          controller.navigateToReelById(reelId, fromDeepLink: true);
        }
      } catch (e) {
        print("خطأ في الوصول إلى متحكم الريلز: $e");
      }
    } catch (e) {
      print("خطأ عام في التنقل إلى الريل: $e");
    }
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    _sub?.cancel();
    super.onClose();
  }
}
