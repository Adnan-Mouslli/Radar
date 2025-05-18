import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// مدير وحدات تحكم الفيديو والذاكرة التخزينية المحسّن مع مكتبة video_player الرسمية
class VideoManager extends GetxController {
  // خريطة تخزين متحكمات الفيديو
  final Map<String, VideoPlayerController> _controllers = {};

  // حالة تهيئة المتحكمات
  final Map<String, bool> _controllerInitStatus = {};

  // قائمة المتحكمات قيد التهيئة
  final Set<String> _initializingControllers = {};

  // تتبع أولوية المتحكمات (استخدام كاونتر تصاعدي)
  final Map<String, int> _controllerPriority = {};
  int _priorityCounter = 0;

  // سجل أوقات استخدام المتحكمات
  final Map<String, DateTime> _controllerLastUsedTime = {};

  // متغير لحالة كتم الصوت
  final RxBool isMuted = false.obs;

  // متحكم التشغيل الحالي
  String? _activeVideoId;

  // حد أقصى للمتحكمات النشطة
  final int _maxControllers;

  // حد أقصى للمتحكمات في حالة التقليب السريع
  final int _maxControllersInRapidSwipe;

  // عدد طلبات التهيئة المتزامنة
  int _pendingInitializations = 0;

  // حد أقصى لطلبات التهيئة المتزامنة
  final int _maxConcurrentInitializations;

  // متغير لحالة الاتصال
  ConnectivityResult _connectionType = ConnectivityResult.none;

  // حالة التقليب السريع
  bool _isRapidSwiping = false;

  // المؤشر الحالي للريل المرئي
  int _currentVisibleReelIndex = 0;

  // مؤقت لتقييم حالة الذاكرة
  Timer? _memoryCheckTimer;

  // مؤقت لمراقبة حالة النظام
  Timer? _stateMonitorTimer;

  /// إنشاء المدير
  VideoManager({
    int maxControllers = 10, // تقليل عدد المتحكمات المتزامنة لتحسين الأداء
    int maxControllersInRapidSwipe =
        3, // تقليل العدد أثناء التقليب السريع لتحسين الأداء
    int maxConcurrentInitializations = 2,
  })  : _maxControllers = maxControllers,
        _maxControllersInRapidSwipe = maxControllersInRapidSwipe,
        _maxConcurrentInitializations = maxConcurrentInitializations {
    _setupConnectivityMonitor();
    _startMemoryMonitoring();
    _startStateMonitoring();
  }

  @override
  void onClose() {
    disposeAllControllers();
    _memoryCheckTimer?.cancel();
    _stateMonitorTimer?.cancel();
    super.onClose();
  }

  /// مراقبة حالة الاتصال
  void _setupConnectivityMonitor() {
    Connectivity().onConnectivityChanged.listen((results) {
      // استخدام النتيجة الأولى من القائمة أو اعتبار الاتصال غير موجود
      _connectionType =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (kDebugMode) {
        print('📶 تغيير حالة الاتصال: $_connectionType');
      }
    });

    Connectivity().checkConnectivity().then((results) {
      // استخدام النتيجة الأولى من القائمة أو اعتبار الاتصال غير موجود
      _connectionType =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
    });
  }

  /// بدء مراقبة استخدام الذاكرة
  void _startMemoryMonitoring() {
    _memoryCheckTimer = Timer.periodic(const Duration(seconds: 120), (_) {
      cleanupIfMemoryPressure();
    });
  }

  /// بدء مراقبة حالة المدير
  void _startStateMonitoring() {
    _stateMonitorTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _validateAndFixInternalState();
    });
  }

  /// تحديث أولوية المتحكم عند استخدامه
  void _updateControllerPriority(String id) {
    _priorityCounter++;
    _controllerPriority[id] = _priorityCounter;
    _controllerLastUsedTime[id] = DateTime.now();
  }

  /// الحصول على المتحكمات بترتيب الأولوية (الأقدم أولاً)
  List<String> _getSortedControllersByPriority() {
    final List<MapEntry<String, int>> entries =
        _controllerPriority.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries.map((e) => e.key).toList();
  }

  /// تعيين حالة التقليب السريع
  void setRapidSwipingState(bool isRapidSwiping) {
    if (_isRapidSwiping != isRapidSwiping) {
      _isRapidSwiping = isRapidSwiping;

      if (kDebugMode) {
        print('🔄 تغيير حالة التقليب السريع: $_isRapidSwiping');
      }

      // إذا انتهى التقليب السريع، قم بتنظيف تدريجي
      if (!_isRapidSwiping) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _cleanupExcessControllersGradually();
        });
      }
      // إذا بدأ التقليب السريع وتجاوزنا الحد، قم بتنظيف سريع
      else if (_controllers.length > _maxControllersInRapidSwipe + 2) {
        _cleanupExcessControllersForRapidSwipe();
      }
    }
  }

  /// معرفة ما إذا كان الاتصال بطيئًا
  bool isSlowConnection() {
    return _connectionType == ConnectivityResult.mobile ||
        _connectionType == ConnectivityResult.none;
  }

  /// تحديث الريل المرئي حاليًا
  void updateCurrentVisibleReelIndex(int index) {
    if (_currentVisibleReelIndex != index) {
      _currentVisibleReelIndex = index;
      if (kDebugMode) {
        print('📱 تحديث الريل المرئي حاليًا إلى: $index');
      }
    }
  }

  /// تهيئة وتشغيل فيديو
  Future<VideoPlayerController> initializeVideo(String id, String url,
      [int? reelIndex]) async {
    if (kDebugMode) {
      print('🎬 بدء تهيئة الفيديو-ID:$id, reelIndex:$reelIndex');
    }

    // تخزين مؤشر الريل الذي ينتمي إليه هذا الفيديو
    final int? targetReelIndex = reelIndex;

    // تحديث ترتيب الأولوية
    _updateControllerPriority(id);

    // إذا كان المتحكم موجودًا ومهيأ
    if (_controllers.containsKey(id) && _controllerInitStatus[id] == true) {
      if (kDebugMode) {
        print('♻️ استخدام متحكم موجود بالفعل: $id');
      }
      final controller = _controllers[id]!;

      try {
        // تحديث المتحكم النشط
        _activeVideoId = id;
        await controller.setLooping(true);

        // تحقق ما إذا كان هذا هو الريل الذي يجب تشغيله
        final bool shouldPlay = targetReelIndex == null ||
            targetReelIndex == _currentVisibleReelIndex;

        // إذا كان هذا هو الريل الحالي، قم بتشغيله
        if (shouldPlay) {
          if (!controller.value.isPlaying) {
            await controller.play();
          }
          // تحديث مستوى الصوت
          await controller.setVolume(isMuted.value ? 0.0 : 1.0);
        } else {
          // إذا لم يكن الريل الحالي، تأكد من إيقافه
          if (controller.value.isPlaying) {
            await controller.pause();
            await controller.setVolume(0.0);
          }
        }

        return controller;
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ خطأ في استخدام المتحكم الموجود: $e');
        }
        // في حالة الخطأ، المتابعة لإعادة إنشاء المتحكم
      }
    }

    // إذا كان المتحكم قيد التهيئة حالياً، انتظر الانتهاء
    if (_initializingControllers.contains(id)) {
      if (kDebugMode) {
        print('⏳ المتحكم قيد التهيئة، انتظار: $id');
      }

      int waitAttempts = 0;
      // انتظار حتى تكتمل التهيئة - مع حد أقصى للانتظار
      while (_initializingControllers.contains(id) && waitAttempts < 50) {
        await Future.delayed(const Duration(milliseconds: 50));
        waitAttempts++;
      }

      // إذا تجاوزنا وقت الانتظار، إزالة المتحكم من قائمة التهيئة
      if (waitAttempts >= 50 && _initializingControllers.contains(id)) {
        _initializingControllers.remove(id);
        if (kDebugMode) {
          print('⚠️ تجاوز وقت انتظار تهيئة المتحكم: $id');
        }
      }

      // التحقق مرة أخرى بعد الانتظار
      if (_controllers.containsKey(id) && _controllerInitStatus[id] == true) {
        final controller = _controllers[id]!;
        await controller.seekTo(Duration.zero);
        _activeVideoId = id;

        // تحقق ما إذا كان هذا هو الريل الذي يجب تشغيله
        final bool shouldPlay = targetReelIndex == null ||
            targetReelIndex == _currentVisibleReelIndex;

        if (shouldPlay) {
          await controller.play();
          await controller.setVolume(isMuted.value ? 0.0 : 1.0);
        } else {
          await controller.pause();
          await controller.setVolume(0.0);
        }
        return controller;
      }
    }

    // تصحيح عداد التهيئات إذا كان عالقًا
    if (_pendingInitializations > _maxConcurrentInitializations * 2) {
      if (kDebugMode) {
        print(
            '⚠️ إعادة تعيين عداد التهيئات بسبب قيمة غير طبيعية: $_pendingInitializations');
      }
      _pendingInitializations = 0;
    }

    // انتظار إذا وصلنا للحد الأقصى من التهيئات المتزامنة
    int waitCount = 0;
    while (_pendingInitializations >= _maxConcurrentInitializations) {
      await Future.delayed(const Duration(milliseconds: 100));
      waitCount++;

      if (waitCount > 10) {
        if (kDebugMode) {
          print('⚠️ تصحيح _pendingInitializations بعد انتظار طويل');
        }
        _pendingInitializations = _initializingControllers.length;
        break;
      }

      // التحقق إذا تم تهيئة المتحكم خلال الانتظار
      if (_controllers.containsKey(id) && _controllerInitStatus[id] == true) {
        if (kDebugMode) {
          print('✅ تم تهيئة المتحكم أثناء الانتظار: $id');
        }
        final controller = _controllers[id]!;

        await controller.seekTo(Duration.zero);
        _activeVideoId = id;

        // تحقق ما إذا كان هذا هو الريل الذي يجب تشغيله
        final bool shouldPlay = targetReelIndex == null ||
            targetReelIndex == _currentVisibleReelIndex;

        if (shouldPlay) {
          await controller.play();
          await controller.setVolume(isMuted.value ? 0.0 : 1.0);
        } else {
          await controller.pause();
          await controller.setVolume(0.0);
        }
        return controller;
      }
    }

    _pendingInitializations++;
    _initializingControllers.add(id);

    try {
      // تنظيف المتحكمات إذا تجاوزنا الحد الأقصى
      await _cleanupIfNeeded();

      // إنشاء متحكم جديد
      if (!_controllers.containsKey(id)) {
        if (kDebugMode) {
          print('🆕 إنشاء متحكم جديد: $id');
        }

        // استخدام VideoPlayerController من video_player بدلاً من cached_video_player
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
          ),
        );

        // تخزين المتحكم قبل التهيئة
        _controllers[id] = controller;
        _controllerInitStatus[id] = false;

        // تهيئة المتحكم
        await controller.initialize();

        // تكوين المتحكم
        await controller.setLooping(true);

        // تحقق ما إذا كان هذا هو الريل الذي يجب تشغيله
        final bool shouldPlay = targetReelIndex == null ||
            targetReelIndex == _currentVisibleReelIndex;

        if (shouldPlay) {
          await controller.setVolume(isMuted.value ? 0.0 : 1.0);
          await controller.play();
        } else {
          await controller.setVolume(0.0);
          await controller.pause();
        }

        // تحديث حالة التهيئة
        _controllerInitStatus[id] = true;
        _activeVideoId = id;

        return controller;
      } else {
        // المتحكم موجود ولكن غير مهيأ
        if (kDebugMode) {
          print('⏳ انتظار تهيئة متحكم موجود: $id');
        }

        final controller = _controllers[id]!;
        await controller.initialize();
        await controller.setLooping(true);

        // تحقق ما إذا كان هذا هو الريل الذي يجب تشغيله
        final bool shouldPlay = targetReelIndex == null ||
            targetReelIndex == _currentVisibleReelIndex;

        if (shouldPlay) {
          await controller.setVolume(isMuted.value ? 0.0 : 1.0);
          await controller.play();
        } else {
          await controller.setVolume(0.0);
          await controller.pause();
        }

        _controllerInitStatus[id] = true;
        _activeVideoId = id;

        return controller;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في تهيئة الفيديو-ID:$id: $e');
      }
      // إزالة المتحكم في حالة فشل التهيئة
      if (_controllers.containsKey(id)) {
        try {
          await _controllers[id]!.dispose();
        } catch (_) {}
        _controllers.remove(id);
        _controllerInitStatus.remove(id);
        _controllerPriority.remove(id);
        _controllerLastUsedTime.remove(id);
      }
      throw e;
    } finally {
      _pendingInitializations =
          (_pendingInitializations - 1).clamp(0, double.infinity).toInt();
      _initializingControllers.remove(id);
    }
  }

  /// تحميل فيديو مسبقًا
  Future<void> preloadVideo(String id, String url, [int? reelIndex]) async {
    // تجاهل إذا كان المتحكم موجودًا بالفعل
    if (_controllers.containsKey(id)) {
      _updateControllerPriority(id);
      return;
    }

    // حساب القيود بناءً على حالة التطبيق
    final int controllerLimit = _isRapidSwiping
        ? (_maxControllersInRapidSwipe)
        : (_maxControllers * 0.8).round();

    // تجاهل التحميل المسبق على اتصالات بطيئة إذا وصلنا للحد
    if (isSlowConnection() &&
        _controllers.length >= (controllerLimit * 0.7).round()) {
      if (kDebugMode) {
        print('⏩ تخطي التحميل المسبق للفيديو-ID:$id بسبب بطء الاتصال');
      }
      return;
    }

    // تجاهل إذا تجاوزنا حد المتحكمات
    if (_controllers.length >= controllerLimit) {
      if (kDebugMode) {
        print('⏩ تخطي التحميل المسبق للفيديو-ID:$id بسبب الوصول للحد الأقصى');
      }
      return;
    }

    // تصحيح عداد التهيئات إذا كان عالقًا
    if (_pendingInitializations > _maxConcurrentInitializations * 2) {
      if (kDebugMode) {
        print(
            '⚠️ إعادة تعيين عداد التهيئات في preloadVideo: $_pendingInitializations');
      }
      _pendingInitializations = _initializingControllers.length;
    }

    // تجاهل إذا وصلنا للحد الأقصى من التهيئات المتزامنة
    if (_pendingInitializations >= _maxConcurrentInitializations) {
      if (kDebugMode) {
        print(
            '⏩ تخطي التحميل المسبق بسبب تجاوز عدد التهيئات المتزامنة: $id ($_pendingInitializations/$_maxConcurrentInitializations)');
      }
      return;
    }

    // تجاهل إذا كان المتحكم قيد التهيئة حاليًا
    if (_initializingControllers.contains(id)) {
      if (kDebugMode) {
        print('⏩ تخطي التحميل المسبق لأن الفيديو قيد التهيئة بالفعل: $id');
      }
      return;
    }

    _pendingInitializations++;
    _initializingControllers.add(id);

    try {
      // تنظيف المتحكمات إذا لزم الأمر
      await _cleanupIfNeeded();

      if (kDebugMode) {
        print('🔄 بدء التحميل المسبق للفيديو-ID:$id');
      }

      // إنشاء متحكم للتحميل المسبق
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
        ),
      );

      // تخزين المتحكم قبل التهيئة
      _controllers[id] = controller;
      _controllerInitStatus[id] = false;
      _updateControllerPriority(id);

      // تهيئة أساسية
      await controller.initialize();

      // تحديث حالة التهيئة
      _controllerInitStatus[id] = true;

      // تأكد من أن الفيديو الذي تم تحميله مسبقًا لا يعمل تلقائيًا
      final bool shouldPlay =
          reelIndex != null && reelIndex == _currentVisibleReelIndex;

      if (!shouldPlay) {
        try {
          await controller.pause();
          await controller.setVolume(0.0);
        } catch (_) {}
      }

      if (kDebugMode) {
        print('✅ تم التحميل المسبق للفيديو-ID:$id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ خطأ في التحميل المسبق للفيديو-ID:$id: $e');
      }

      // إزالة المتحكم في حالة فشل التحميل المسبق
      if (_controllers.containsKey(id)) {
        try {
          await _controllers[id]!.dispose();
        } catch (_) {}
        _controllers.remove(id);
        _controllerInitStatus.remove(id);
        _controllerPriority.remove(id);
        _controllerLastUsedTime.remove(id);
      }
    } finally {
      _pendingInitializations =
          (_pendingInitializations - 1).clamp(0, double.infinity).toInt();
      _initializingControllers.remove(id);
    }
  }

  /// التحقق من صحة الحالة الداخلية وإصلاحها
  void _validateAndFixInternalState() {
    // التحقق من تطابق قوائم المتحكمات
    if (_controllers.length != _controllerInitStatus.length ||
        _controllers.length != _controllerPriority.length) {
      if (kDebugMode) {
        print('⚠️ عدم تطابق في قوائم المتحكمات، إجراء تصحيح');
      }

      // مزامنة القوائم
      final validIds = _controllers.keys.toSet();

      _controllerInitStatus.removeWhere((id, _) => !validIds.contains(id));
      _controllerPriority.removeWhere((id, _) => !validIds.contains(id));
      _controllerLastUsedTime.removeWhere((id, _) => !validIds.contains(id));

      // إضافة مفاتيح مفقودة
      for (final id in validIds) {
        if (!_controllerInitStatus.containsKey(id)) {
          _controllerInitStatus[id] = false;
        }
        if (!_controllerPriority.containsKey(id)) {
          _updateControllerPriority(id);
        }
        if (!_controllerLastUsedTime.containsKey(id)) {
          _controllerLastUsedTime[id] = DateTime.now();
        }
      }
    }

    // التحقق من عداد التهيئات المعلقة
    final pendingCount = _initializingControllers.length;
    if (_pendingInitializations != pendingCount) {
      if (kDebugMode) {
        print(
            '⚠️ عدم تطابق في عداد التهيئات: $_pendingInitializations != $pendingCount');
      }
      _pendingInitializations = pendingCount;
    }

    // إزالة المتحكمات قيد التهيئة لفترة طويلة (عالقة)
    final now = DateTime.now();
    final stuckInitializers = <String>[];

    for (final id in _initializingControllers) {
      final lastUsed = _controllerLastUsedTime[id];
      if (lastUsed != null) {
        final timeSinceUpdate = now.difference(lastUsed).inSeconds;
        // إذا كان المتحكم قيد التهيئة لأكثر من 30 ثانية
        if (timeSinceUpdate > 30) {
          stuckInitializers.add(id);
        }
      } else {
        // إذا لم يكن له وقت استخدام، إضافته للمتعلقين
        stuckInitializers.add(id);
      }
    }

    // إزالة المتحكمات العالقة
    if (stuckInitializers.isNotEmpty) {
      if (kDebugMode) {
        print('⚠️ إزالة ${stuckInitializers.length} متحكم عالق في التهيئة');
      }
      for (final id in stuckInitializers) {
        _initializingControllers.remove(id);
        // إزالة المتحكم إذا كان موجودًا
        if (_controllers.containsKey(id)) {
          try {
            _controllers[id]!.dispose();
          } catch (_) {}
          _controllers.remove(id);
          _controllerInitStatus.remove(id);
          _controllerPriority.remove(id);
          _controllerLastUsedTime.remove(id);
        }
      }

      // تحديث عداد التهيئات
      _pendingInitializations = _initializingControllers.length;
    }
  }

  /// تنظيف المتحكمات القديمة إذا تجاوزنا الحد الأقصى
  Future<void> _cleanupIfNeeded() async {
    // التحقق من عدد المتحكمات
    if (_controllers.length < _maxControllers) {
      return;
    }

    if (kDebugMode) {
      print(
          '🧹 تنظيف المتحكمات القديمة (إجمالي المتحكمات: ${_controllers.length})');
    }

    // الحصول على المتحكمات الأقدم استخداماً
    final sortedIds = _getSortedControllersByPriority();

    // استبعاد المتحكم النشط
    if (_activeVideoId != null) {
      sortedIds.remove(_activeVideoId);
    }

    // التخلص من متحكم أو اثنين على الأقل
    int cleanupCount = 0;
    for (final id in sortedIds) {
      await disposeController(id);
      cleanupCount++;

      if (cleanupCount >= 2 || _controllers.length <= _maxControllers * 0.8) {
        break;
      }
    }

    if (kDebugMode) {
      print('🗑️ تم تنظيف $cleanupCount متحكم');
    }
  }

  /// تنظيف المتحكمات في حالة ضغط الذاكرة
  Future<void> cleanupIfMemoryPressure() async {
    final isMemoryPressure = _controllers.length > _maxControllers * 0.7;

    if (isMemoryPressure) {
      if (kDebugMode) {
        print(
            '🧹 تنظيف دوري للذاكرة (إجمالي المتحكمات: ${_controllers.length})');
      }

      // الحصول على المتحكمات الأقدم
      final sortedIds = _getSortedControllersByPriority();

      // استبعاد المتحكم النشط
      if (_activeVideoId != null) {
        sortedIds.remove(_activeVideoId);
      }

      // التخلص من متحكمات حتى نصل إلى 60% من الحد الأقصى
      final targetCount = (_maxControllers * 0.6).round();
      int cleanupCount = 0;

      for (final id in sortedIds) {
        if (_controllers.length <= targetCount) break;

        // تجنب تنظيف المتحكمات المستخدمة حديثاً
        final lastUsed = _controllerLastUsedTime[id];
        if (lastUsed != null) {
          final now = DateTime.now();
          final timeSinceLastUsed = now.difference(lastUsed).inSeconds;

          // تجاهل المتحكمات المستخدمة خلال الـ 30 ثانية الماضية
          if (timeSinceLastUsed < 30) continue;
        }

        await disposeController(id);
        cleanupCount++;
      }

      if (cleanupCount > 0 && kDebugMode) {
        print('🗑️ تنظيف ذاكرة دوري: تم التخلص من $cleanupCount متحكم');
      }
    }
  }

  /// تنظيف المتحكمات الزائدة في حالة التقليب السريع
  Future<void> _cleanupExcessControllersForRapidSwipe() async {
    if (kDebugMode) {
      print('🧹 تنظيف المتحكمات الزائدة في حالة التقليب السريع');
    }

    // الحصول على المتحكمات مرتبة حسب الأقدم
    final sortedIds = _getSortedControllersByPriority();

    // استبعاد المتحكم النشط
    if (_activeVideoId != null) {
      sortedIds.remove(_activeVideoId);
    }

    // حساب عدد المتحكمات الزائدة
    final excessCount = _controllers.length - _maxControllersInRapidSwipe;

    if (excessCount > 0 && sortedIds.isNotEmpty) {
      // التخلص من المتحكمات الزائدة
      int count = 0;
      for (final id in sortedIds) {
        if (count >= excessCount) break;
        await disposeController(id);
        count++;
      }

      if (kDebugMode) {
        print('🗑️ تنظيف سريع: تم التخلص من $count متحكم');
      }
    }
  }

  /// تنظيف تدريجي للمتحكمات الزائدة
  Future<void> _cleanupExcessControllersGradually() async {
    // تنظيف تدريجي بعد انتهاء التقليب السريع
    final targetCount = (_maxControllers * 0.7).round();

    if (_controllers.length > targetCount) {
      if (kDebugMode) {
        print(
            '🧹 تنظيف تدريجي للمتحكمات: ${_controllers.length}/$_maxControllers');
      }

      // الحصول على المتحكمات بترتيب الأقدم
      final sortedIds = _getSortedControllersByPriority();

      // استبعاد المتحكم النشط
      if (_activeVideoId != null) {
        sortedIds.remove(_activeVideoId);
      }

      // تنظيف المتحكمات القديمة تدريجياً (واحد أو اثنين في كل مرة)
      int count = 0;
      for (final id in sortedIds) {
        await disposeController(id);
        count++;

        // تنظيف متحكم أو متحكمين في كل مرة
        if (count >= 2 || _controllers.length <= targetCount) break;
      }

      if (kDebugMode) {
        print('🗑️ تم تنظيف $count متحكم تدريجياً');
      }
    }
  }

  /// تشغيل فيديو
  Future<void> playVideo(String id) async {
    if (!_controllers.containsKey(id)) {
      throw Exception('المتحكم غير موجود');
    }

    _updateControllerPriority(id);

    // إيقاف الفيديوهات الأخرى
    await stopAllVideosExcept(id);

    // الحصول على المتحكم
    final controller = _controllers[id]!;

    // تشغيل الفيديو
    await controller.setVolume(isMuted.value ? 0.0 : 1.0);
    await controller.play();

    // تحديث الفيديو النشط
    _activeVideoId = id;
  }

  /// إيقاف فيديو
  Future<void> pauseVideo(String id) async {
    if (!_controllers.containsKey(id)) {
      return;
    }

    // الحصول على المتحكم
    final controller = _controllers[id]!;

    // إيقاف الفيديو
    await controller.pause();
  }

  /// إيقاف جميع الفيديوهات عدا واحد
  Future<void> stopAllVideosExcept(String? exceptId) async {
    // قائمة المتحكمات للإيقاف
    final idsToStop = _controllers.keys.where((id) => id != exceptId).toList();

    // كتم صوت جميع الفيديوهات أولاً
    for (final id in idsToStop) {
      try {
        if (_controllerInitStatus[id] == true) {
          final controller = _controllers[id]!;
          await controller.setVolume(0.0);
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ خطأ في كتم صوت الفيديو $id: $e');
        }
      }
    }

    // ثم إيقاف جميع الفيديوهات
    for (final id in idsToStop) {
      try {
        if (_controllerInitStatus[id] == true) {
          final controller = _controllers[id]!;
          await controller.pause();
          await controller.seekTo(Duration.zero);
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ خطأ في إيقاف الفيديو $id: $e');
        }
      }
    }

    // تحديث الفيديو النشط
    _activeVideoId = exceptId;

    // تحديث ترتيب الاستخدام للفيديو النشط
    if (exceptId != null) {
      _updateControllerPriority(exceptId);
    }
  }

  /// تبديل حالة تشغيل فيديو
  Future<void> togglePlayback(String id) async {
    if (!_controllers.containsKey(id) || _controllerInitStatus[id] != true) {
      return;
    }

    _updateControllerPriority(id);
    final controller = _controllers[id]!;
    final isPlaying = controller.value.isPlaying;

    if (isPlaying) {
      await pauseVideo(id);
    } else {
      await playVideo(id);
    }
  }

  /// تبديل حالة كتم الصوت
  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;

    // تطبيق حالة كتم الصوت على الفيديو النشط
    if (_activeVideoId != null &&
        _controllers.containsKey(_activeVideoId!) &&
        _controllerInitStatus[_activeVideoId!] == true) {
      await _controllers[_activeVideoId!]!.setVolume(isMuted.value ? 0.0 : 1.0);
    }
  }

  /// التخلص من متحكم
  Future<void> disposeController(String id) async {
    if (!_controllers.containsKey(id)) {
      return;
    }

    if (kDebugMode) {
      print('🗑️ التخلص من متحكم: $id');
    }

    final controller = _controllers[id]!;

    // إزالة المتحكم من جميع القوائم
    _controllers.remove(id);
    _controllerInitStatus.remove(id);
    _controllerPriority.remove(id);
    _controllerLastUsedTime.remove(id);

    try {
      // إيقاف الفيديو أولاً إذا كان مهيأ
      if (_controllerInitStatus[id] == true) {
        await controller.setVolume(0.0);
        await controller.pause();
      }

      // التخلص من المتحكم
      await controller.dispose();

      // إعادة تعيين المتحكم النشط إذا لزم الأمر
      if (_activeVideoId == id) {
        _activeVideoId = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ خطأ في التخلص من المتحكم: $e');
      }
    }
  }

  /// التخلص من جميع المتحكمات
  Future<void> disposeAllControllers() async {
    if (kDebugMode) {
      print('🧹 التخلص من جميع المتحكمات');
    }

    final ids = _controllers.keys.toList();

    for (final id in ids) {
      await disposeController(id);
    }

    _controllers.clear();
    _controllerInitStatus.clear();
    _controllerPriority.clear();
    _controllerLastUsedTime.clear();
    _activeVideoId = null;

    // إلغاء المؤقتات
    _memoryCheckTimer?.cancel();
    _stateMonitorTimer?.cancel();
  }

  /// التحقق مما إذا كان الفيديو مهيأ
  bool isVideoInitialized(String id) {
    return _controllers.containsKey(id) && _controllerInitStatus[id] == true;
  }

  /// التحقق مما إذا كان الفيديو قيد التشغيل
  bool isVideoPlaying(String id) {
    if (!_controllers.containsKey(id) || _controllerInitStatus[id] != true) {
      return false;
    }

    return _controllers[id]!.value.isPlaying;
  }

  /// الحصول على نسبة أبعاد الفيديو
  double getAspectRatio(String id) {
    if (!_controllers.containsKey(id) ||
        _controllerInitStatus[id] != true ||
        !_controllers[id]!.value.isInitialized) {
      return 9.0 / 16.0; // القيمة الافتراضية للريلز
    }

    final size = _controllers[id]!.value.size;
    if (size == null || size.width == 0 || size.height == 0) {
      return 9.0 / 16.0;
    }

    return size.width / size.height;
  }

  /// الحصول على المتحكم
  VideoPlayerController? getController(String id) {
    if (!_controllers.containsKey(id)) {
      return null;
    }
    return _controllers[id];
  }

  /// الحصول على جميع المتحكمات
  Map<String, VideoPlayerController> getAllControllers() {
    return Map.unmodifiable(_controllers);
  }

  /// الحصول على حالة كتم الصوت
  bool getMuteStatus() {
    return isMuted.value;
  }

  /// الحصول على معرف الفيديو النشط
  String? getActiveVideoId() {
    return _activeVideoId;
  }

  /// الحصول على عدد المتحكمات المُهيأة
  int getInitializedControllersCount() {
    return _controllerInitStatus.values.where((status) => status).length;
  }

  /// الحصول على إجمالي عدد المتحكمات
  int getTotalControllersCount() {
    return _controllers.length;
  }

  /// الحصول على معلومات تشخيصية
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'totalControllers': _controllers.length,
      'initializedControllers': getInitializedControllersCount(),
      'pendingInitializations': _pendingInitializations,
      'isRapidSwiping': _isRapidSwiping,
      'activeVideoId': _activeVideoId,
      'connectionType': _connectionType.toString(),
      'isSlowConnection': isSlowConnection(),
      'controllersInUse': _controllerPriority.length,
      'isMuted': isMuted.value,
      'currentVisibleReelIndex': _currentVisibleReelIndex,
    };
  }
}
