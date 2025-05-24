import 'dart:async';
import 'package:cached_video_player_fork/cached_video_player.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// مدير وحدات تحكم الفيديو والذاكرة التخزينية المحسّن
class VideoManager {
  // خريطة تخزين متحكمات الفيديو
  final Map<String, CachedVideoPlayerController> _controllers = {};

  // حالة تهيئة المتحكمات
  final Map<String, bool> _controllerInitStatus = {};

  // قائمة المتحكمات قيد التهيئة
  final Set<String> _initializingControllers = {};

  // تتبع أولوية المتحكمات (استخدام كاونتر تصاعدي)
  final Map<String, int> _controllerPriority = {};
  int _priorityCounter = 0;

  // خريطة تخزين مؤشرات الريل
  final Map<String, int> _reelIndexMap = {};

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

  // عدد طلبات التهيئة عالية الأولوية المتزامنة
  int _pendingHighPriorityInitializations = 0;

  // حد أقصى لطلبات التهيئة المتزامنة
  final int _maxConcurrentInitializations;

  // حد أقصى لطلبات التهيئة عالية الأولوية المتزامنة
  final int _maxHighPriorityInitializations;

  // متغير لحالة الاتصال
  ConnectivityResult _connectionType = ConnectivityResult.none;

  // حالة التقليب السريع
  bool _isRapidSwiping = false;

  // مؤقت لتقييم حالة الذاكرة
  Timer? _memoryCheckTimer;

  // مؤشر الريل الحالي
  int _currentVisibleReelIndex = 0;

  // إنشاء المدير
  VideoManager({
    int maxControllers = 15,
    int maxControllersInRapidSwipe = 5,
    int maxConcurrentInitializations = 3,
    int maxHighPriorityInitializations = 2,
  })  : _maxControllers = maxControllers,
        _maxControllersInRapidSwipe = maxControllersInRapidSwipe,
        _maxConcurrentInitializations = maxConcurrentInitializations,
        _maxHighPriorityInitializations = maxHighPriorityInitializations {
    _setupConnectivityMonitor();
    _startMemoryMonitoring();
    _startStateMonitoring();
  }

  // مراقبة حالة الاتصال
  void _setupConnectivityMonitor() {
    Connectivity().onConnectivityChanged.listen((result) {
      _connectionType = result;
      print('📶 تغيير حالة الاتصال: $_connectionType');

      // إعادة تقييم استراتيجية التحميل عند تغير حالة الاتصال
      _adjustLoadingStrategy();
    });

    Connectivity().checkConnectivity().then((result) {
      _connectionType = result;
    });
  }

  // ضبط استراتيجية التحميل بناءً على حالة الاتصال
  void _adjustLoadingStrategy() {
    if (isSlowConnection()) {
      // في حالة الاتصال البطيء، تنظيف المتحكمات غير المهمة
      _cleanupLowPriorityControllers();
    }
  }

  // تنظيف المتحكمات ذات الأولوية المنخفضة
  Future<void> _cleanupLowPriorityControllers() async {
    // الاحتفاظ فقط بالفيديو الحالي والفيديو التالي
    if (_controllers.length <= 3) return;

    print(
        '🧹 تنظيف المتحكمات منخفضة الأولوية لتحسين الأداء على الاتصال البطيء');

    final sortedIds = _getSortedControllersByPriority();

    // استبعاد المتحكمات ذات الأولوية العالية من التنظيف
    final highPriorityIds = <String>{};
    if (_activeVideoId != null) {
      highPriorityIds.add(_activeVideoId!);

      // الاحتفاظ بالفيديو التالي وفيديو بعد التالي
      for (final id in _controllers.keys) {
        if (_reelIndexMap.containsKey(id) && _currentVisibleReelIndex != null) {
          int relIndex = _reelIndexMap[id]! - _currentVisibleReelIndex;
          if (relIndex == 1 || relIndex == 2) {
            highPriorityIds.add(id);
          }
        }
      }
    }

    int cleanupCount = 0;
    for (final id in sortedIds) {
      if (!highPriorityIds.contains(id)) {
        await disposeController(id);
        cleanupCount++;

        // الاحتفاظ بعدد صغير من المتحكمات (3-4 فقط)
        if (_controllers.length <= 3) {
          break;
        }
      }
    }

    print('🗑️ تم تنظيف $cleanupCount متحكم منخفض الأولوية');
  }

  // بدء مراقبة استخدام الذاكرة
  void _startMemoryMonitoring() {
    _memoryCheckTimer = Timer.periodic(Duration(seconds: 120), (_) {
      _cleanupIfMemoryPressure();
    });
  }

  // تحديث أولوية المتحكم عند استخدامه
  void _updateControllerPriority(String id, [int? reelIndex]) {
    _priorityCounter++;

    // تخزين مؤشر الريل إذا تم توفيره
    if (reelIndex != null) {
      _reelIndexMap[id] = reelIndex;
    }

    // حساب الأولوية بناءً على القرب من الفيديو الحالي
    if (_reelIndexMap.containsKey(id)) {
      int distance = (_reelIndexMap[id]! - _currentVisibleReelIndex).abs();

      // حساب علاوة القرب - الفيديو الحالي له أعلى أولوية، يليه الفيديو التالي مباشرة
      int proximityBonus = 0;
      if (distance == 0) {
        proximityBonus = 10000; // الفيديو الحالي
      } else if (distance == 1 &&
          _reelIndexMap[id]! > _currentVisibleReelIndex) {
        proximityBonus = 5000; // الفيديو التالي
      } else if (distance == 2 &&
          _reelIndexMap[id]! > _currentVisibleReelIndex) {
        proximityBonus = 1000; // الفيديو بعد التالي
      } else if (distance == 1 &&
          _reelIndexMap[id]! < _currentVisibleReelIndex) {
        proximityBonus = 500; // الفيديو السابق
      }

      _controllerPriority[id] = _priorityCounter + proximityBonus;
    } else {
      _controllerPriority[id] = _priorityCounter;
    }

    _controllerLastUsedTime[id] = DateTime.now();
  }

  // الحصول على المتحكمات بترتيب الأولوية (الأقل أولوية أولاً للتنظيف)
  List<String> _getSortedControllersByPriority() {
    // تحضير القائمة مع معلومات المسافة من الفيديو الحالي والأولوية
    final List<MapEntry<String, dynamic>> entries = _controllers.keys.map((id) {
      int distance = 999; // قيمة افتراضية عالية
      int relativePosition =
          0; // القيمة السالبة = قبل الفيديو الحالي، الموجبة = بعد الفيديو الحالي

      if (_reelIndexMap.containsKey(id)) {
        distance = (_reelIndexMap[id]! - _currentVisibleReelIndex).abs();
        relativePosition = _reelIndexMap[id]! - _currentVisibleReelIndex;
      }

      int priority =
          _controllerPriority.containsKey(id) ? _controllerPriority[id]! : 0;

      return MapEntry(id, {
        'id': id,
        'distance': distance,
        'relativePosition': relativePosition,
        'priority': priority
      });
    }).toList();

    // ترتيب المتحكمات للتنظيف:
    // 1. الأبعد من الفيديو الحالي أولاً
    // 2. الفيديوهات السابقة قبل اللاحقة (عند تساوي المسافة)
    // 3. الأقدم استخدامًا (عند تساوي المسافة والموقع النسبي)
    entries.sort((a, b) {
      // المقارنة الأولى حسب المسافة (الأبعد أولاً)
      int distanceCompare = b.value['distance'].compareTo(a.value['distance']);
      if (distanceCompare != 0) return distanceCompare;

      // عند تساوي المسافة، نفضل الاحتفاظ بالفيديوهات اللاحقة
      // (الأرقام الموجبة تعني فيديوهات بعد الحالي، السالبة قبل الحالي)
      int positionCompare =
          a.value['relativePosition'].compareTo(b.value['relativePosition']);
      if (positionCompare != 0) return positionCompare;

      // عند تساوي المسافة والموقع النسبي، قارن حسب الأولوية (الأقدم أولاً)
      return a.value['priority'].compareTo(b.value['priority']);
    });

    return entries.map((e) => e.value['id'] as String).toList();
  }

  // تعيين حالة التقليب السريع
  void setRapidSwipingState(bool isRapidSwiping) {
    if (_isRapidSwiping != isRapidSwiping) {
      _isRapidSwiping = isRapidSwiping;

      print('🔄 تغيير حالة التقليب السريع: $_isRapidSwiping');

      // إذا انتهى التقليب السريع، قم بتنظيف تدريجي
      if (!_isRapidSwiping) {
        Future.delayed(Duration(milliseconds: 500), () {
          _cleanupExcessControllersGradually();
        });
      }
      // إذا بدأ التقليب السريع، احتفظ فقط بالفيديوهات اللاحقة
      else {
        _optimizeForRapidSwiping();
      }
    }
  }

  // تحسين إدارة الذاكرة للتقليب السريع
  Future<void> _optimizeForRapidSwiping() async {
    print('⚡ تحسين إدارة الذاكرة للتقليب السريع');

    // إلغاء الفيديوهات السابقة أولاً
    final previousVideos = <String>[];

    for (final id in _controllers.keys) {
      if (_reelIndexMap.containsKey(id) &&
          _reelIndexMap[id]! < _currentVisibleReelIndex) {
        previousVideos.add(id);
      }
    }

    // إلغاء الفيديوهات السابقة
    for (final id in previousVideos) {
      if (id != _activeVideoId) {
        await disposeController(id);
      }
    }

    // ثم تنظيف الزائد إذا لزم الأمر
    if (_controllers.length > _maxControllersInRapidSwipe) {
      await _cleanupExcessControllersForRapidSwipe();
    }
  }

  // معرفة ما إذا كان الاتصال بطيئًا
  bool isSlowConnection() {
    return _connectionType == ConnectivityResult.mobile ||
        _connectionType == ConnectivityResult.none;
  }

  // هل الفيديو ذو أولوية عالية (الحالي أو التالي)
  bool _isHighPriorityVideo(int? reelIndex) {
    if (reelIndex == null) return false;

    int distance = (reelIndex - _currentVisibleReelIndex).abs();

    // الفيديو الحالي والتالي فقط لهما أولوية عالية
    return distance == 0 ||
        (distance == 1 && reelIndex > _currentVisibleReelIndex);
  }

  // تحميل الفيديوهات التالية مسبقًا
  Future<void> _preloadNextVideos(int currentIndex) async {
    // التحميل المسبق للفيديو التالي والذي بعده - يتم استدعاؤها بعد تشغيل فيديو
    // يتم تنفيذها في الخلفية دون انتظار
    Future(() async {
      try {
        // لا داعي للتحميل المسبق في حالة التقليب السريع - سيتم تحميل الفيديوهات عند الحاجة فقط
        if (_isRapidSwiping) return;

        // البحث عن الفيديو التالي في خريطة الريل
        final Map<int, String> indexToIdMap = {};
        final Map<int, String> indexToUrlMap = {};

        // استخراج معلومات الريل من الذاكرة المؤقتة (هذا مثال، يجب تكييفه حسب هيكل بياناتك)
        // في التطبيق الحقيقي، يجب أن تستدعي دالة تحصل على معلومات الفيديوهات التالية
        for (final entry in _reelIndexMap.entries) {
          indexToIdMap[entry.value] = entry.key;
          // هنا يجب الحصول على URL الفيديو، هذا مجرد مثال توضيحي
          // في التطبيق الحقيقي، يجب أن تكون لديك طريقة للحصول على URL من معرّف الفيديو
        }

        // تحميل الفيديو التالي مسبقًا (أعلى أولوية)
        final nextIndex = currentIndex + 1;
        if (indexToIdMap.containsKey(nextIndex) &&
            indexToUrlMap.containsKey(nextIndex)) {
          final nextId = indexToIdMap[nextIndex]!;
          final nextUrl = indexToUrlMap[nextIndex]!;

          if (!_controllers.containsKey(nextId)) {
            print('🔄 التحميل المسبق للفيديو التالي: $nextId');
            await preloadVideo(nextId, nextUrl, null, nextIndex);
          }
        }

        // تحميل الفيديو الذي بعد التالي (أولوية أقل)
        final afterNextIndex = currentIndex + 2;
        if (indexToIdMap.containsKey(afterNextIndex) &&
            indexToUrlMap.containsKey(afterNextIndex)) {
          final afterNextId = indexToIdMap[afterNextIndex]!;
          final afterNextUrl = indexToUrlMap[afterNextIndex]!;

          if (!_controllers.containsKey(afterNextId)) {
            print('🔄 التحميل المسبق للفيديو بعد التالي: $afterNextId');
            await preloadVideo(afterNextId, afterNextUrl, null, afterNextIndex);
          }
        }
      } catch (e) {
        print('⚠️ خطأ في التحميل المسبق للفيديوهات التالية: $e');
      }
    });
  }

  // تهيئة وتشغيل فيديو
  Future<CachedVideoPlayerController> initializeVideo(String id, String url,
      [String? posterUrl, int? reelIndex]) async {
    print('🎬 بدء تهيئة الفيديو-ID:$id, reelIndex:$reelIndex');

    // تحديد ما إذا كان الفيديو ذو أولوية عالية
    final bool isHighPriority = _isHighPriorityVideo(reelIndex);

    // تخزين مؤشر الريل الذي ينتمي إليه هذا الفيديو
    if (reelIndex != null) {
      _reelIndexMap[id] = reelIndex;
    }

    // تحديث ترتيب الأولوية
    _updateControllerPriority(id, reelIndex);

    // إذا كان المتحكم موجودًا ومهيأ
    if (_controllers.containsKey(id) && _controllerInitStatus[id] == true) {
      print('♻️ استخدام متحكم موجود بالفعل: $id');
      final controller = _controllers[id]!;

      await controller.setLooping(true);

      try {
        // تحديث المتحكم النشط قبل إجراء أي عمليات
        _activeVideoId = id;

        // تحقق ما إذا كان هذا هو الريل الذي يجب تشغيله
        final bool shouldPlay =
            reelIndex == null || reelIndex == _currentVisibleReelIndex;

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

        // بعد استخدام المتحكم الحالي، قم بتحميل الفيديو التالي مسبقًا
        if (shouldPlay && reelIndex != null) {
          _preloadNextVideos(reelIndex);
        }

        return controller;
      } catch (e) {
        print('⚠️ خطأ في استخدام المتحكم الموجود: $e');
        // في حالة الخطأ، المتابعة لإعادة إنشاء المتحكم
      }
    }
    
    // إذا كان المتحكم قيد التهيئة حالياً، انتظر الانتهاء
    if (_initializingControllers.contains(id)) {
      print('⏳ المتحكم قيد التهيئة، انتظار: $id');

      int waitAttempts = 0;
      // انتظار حتى تكتمل التهيئة - مع حد أقصى للانتظار
      while (_initializingControllers.contains(id) && waitAttempts < 50) {
        await Future.delayed(Duration(milliseconds: 50));
        waitAttempts++;
      }

      // إذا تجاوزنا وقت الانتظار، إزالة المتحكم من قائمة التهيئة
      if (waitAttempts >= 50 && _initializingControllers.contains(id)) {
        _initializingControllers.remove(id);
        print('⚠️ تجاوز وقت انتظار تهيئة المتحكم: $id');
      }

      // التحقق مرة أخرى بعد الانتظار
      if (_controllers.containsKey(id) && _controllerInitStatus[id] == true) {
        final controller = _controllers[id]!;
        await controller.seekTo(Duration.zero);
        _activeVideoId = id;

        // تحقق ما إذا كان هذا هو الريل الذي يجب تشغيله
        final bool shouldPlay =
            reelIndex == null || reelIndex == _currentVisibleReelIndex;

        if (shouldPlay) {
          await controller.play();
          await controller.setVolume(isMuted.value ? 0.0 : 1.0);

          // تحميل الفيديوهات التالية مسبقًا
          if (reelIndex != null) {
            _preloadNextVideos(reelIndex);
          }
        } else {
          await controller.pause();
          await controller.setVolume(0.0);
        }
        return controller;
      }
    }

    // التعامل مع أولويات التهيئة بشكل مختلف للفيديوهات عالية الأولوية والمنخفضة
    if (isHighPriority) {
      // انتظار الفيديوهات عالية الأولوية فقط في حدود معينة
      int waitCount = 0;
      while (_pendingHighPriorityInitializations >=
          _maxHighPriorityInitializations) {
        await Future.delayed(Duration(milliseconds: 100));
        waitCount++;

        if (waitCount > 5) {
          // بعد انتظار قصير، نجبر التهيئة للفيديوهات عالية الأولوية
          break;
        }
      }

      _pendingHighPriorityInitializations++;
    } else {
      // بالنسبة للفيديوهات العادية، انتظار أطول إذا وصلنا للحد
      int waitCount = 0;
      while (_pendingInitializations >= _maxConcurrentInitializations) {
        await Future.delayed(Duration(milliseconds: 100));
        waitCount++;

        // إذا انتظرنا أكثر من 10 مرات، إعادة ضبط العداد
        if (waitCount > 10) {
          print('⚠️ تصحيح _pendingInitializations بعد انتظار طويل');
          // إحصاء المتحكمات قيد التهيئة الفعلية
          _pendingInitializations = _initializingControllers.length;
          break;
        }

        // إذا كان المتحكم تم تهيئته خلال الانتظار
        if (_controllers.containsKey(id) && _controllerInitStatus[id] == true) {
          print('✅ تم تهيئة المتحكم أثناء الانتظار: $id');
          final controller = _controllers[id]!;

          await controller.seekTo(Duration.zero);
          _activeVideoId = id;

          final bool shouldPlay =
              reelIndex == null || reelIndex == _currentVisibleReelIndex;

          if (shouldPlay) {
            await controller.play();
            await controller.setVolume(isMuted.value ? 0.0 : 1.0);

            // تحميل الفيديوهات التالية مسبقًا
            if (reelIndex != null) {
              _preloadNextVideos(reelIndex);
            }
          } else {
            await controller.pause();
            await controller.setVolume(0.0);
          }
          return controller;
        }
      }
    }

    _pendingInitializations++;
    _initializingControllers.add(id);

    if (isHighPriority) {
      _pendingHighPriorityInitializations =
          (_pendingHighPriorityInitializations + 1)
              .clamp(0, double.infinity)
              .toInt();
    }

    try {
      // تنظيف المتحكمات إذا تجاوزنا الحد الأقصى - للفيديوهات غير عالية الأولوية فقط
      if (!isHighPriority) {
        await _cleanupIfNeeded();
      }

      // تكييف جودة الفيديو بناءً على حالة الاتصال
      String effectiveUrl = url;

      // خفض جودة الفيديو على الاتصالات البطيئة للفيديوهات غير الحالية
      if (isSlowConnection() &&
          reelIndex != null &&
          reelIndex != _currentVisibleReelIndex) {
        // هذه مجرد مثال - يجب تخصيصه حسب كيفية تخزين الفيديوهات في تطبيقك
        if (url.contains('high_quality')) {
          effectiveUrl = url.replaceAll('high_quality', 'low_quality');
          print('📱 استخدام نسخة منخفضة الجودة للفيديو: $id');
        }
      }

      // إنشاء متحكم جديد إذا لم يكن موجودًا
      if (!_controllers.containsKey(id)) {
        print('🆕 إنشاء متحكم جديد: $id');
        final controller = CachedVideoPlayerController.network(
          effectiveUrl,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
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
        final bool shouldPlay =
            reelIndex == null || reelIndex == _currentVisibleReelIndex;

        if (shouldPlay) {
          await controller.setVolume(isMuted.value ? 0.0 : 1.0);
          await controller.play();

          // تحميل الفيديوهات التالية مسبقًا
          if (reelIndex != null) {
            _preloadNextVideos(reelIndex);
          }
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
        print('⏳ انتظار تهيئة متحكم موجود: $id');

        final controller = _controllers[id]!;
        await controller.initialize();

        await controller.setLooping(true);

        // تحقق ما إذا كان هذا هو الريل الذي يجب تشغيله
        final bool shouldPlay =
            reelIndex == null || reelIndex == _currentVisibleReelIndex;

        if (shouldPlay) {
          await controller.setVolume(isMuted.value ? 0.0 : 1.0);
          await controller.play();

          // تحميل الفيديوهات التالية مسبقًا
          if (reelIndex != null) {
            _preloadNextVideos(reelIndex);
          }
        } else {
          await controller.setVolume(0.0);
          await controller.pause();
        }

        _controllerInitStatus[id] = true;
        _activeVideoId = id;

        return controller;
      }
    } catch (e) {
      print('❌ خطأ في تهيئة الفيديو-ID:$id: $e');
      // إزالة المتحكم في حالة فشل التهيئة
      if (_controllers.containsKey(id)) {
        try {
          await _controllers[id]!.dispose();
        } catch (_) {}
        _controllers.remove(id);
        _controllerInitStatus.remove(id);
        _controllerPriority.remove(id);
        _controllerLastUsedTime.remove(id);
        _reelIndexMap.remove(id);
      }
      throw e;
    } finally {
      _pendingInitializations =
          (_pendingInitializations - 1).clamp(0, double.infinity).toInt();

      if (isHighPriority) {
        _pendingHighPriorityInitializations =
            (_pendingHighPriorityInitializations - 1)
                .clamp(0, double.infinity)
                .toInt();
      }

      _initializingControllers.remove(id);
    }
  }

  // تحميل فيديو مسبقًا
  Future<void> preloadVideo(String id, String url,
      [String? posterUrl, int? reelIndex]) async {
    // تحديد الأولوية بناءً على مؤشر الريل
    final bool isHighPriority = _isHighPriorityVideo(reelIndex);

    // تجاهل إذا كان المتحكم موجودًا بالفعل
    if (_controllers.containsKey(id)) {
      _updateControllerPriority(id, reelIndex);
      return;
    }

    // تخزين مؤشر الريل إذا تم توفيره
    if (reelIndex != null) {
      _reelIndexMap[id] = reelIndex;
    }

    // حساب القيود بناءً على حالة التطبيق
    final int controllerLimit = _isRapidSwiping
        ? (_maxControllersInRapidSwipe)
        : (_maxControllers * 0.8).round();

    // تجاهل التحميل المسبق على اتصالات بطيئة للفيديوهات منخفضة الأولوية
    if (isSlowConnection() &&
        !isHighPriority &&
        _controllers.length >= (controllerLimit * 0.5).round()) {
      print('⏩ تخطي التحميل المسبق للفيديو-ID:$id بسبب بطء الاتصال');
      return;
    }

    // الاستمرار بالتحميل للفيديوهات عالية الأولوية حتى لو تجاوزنا الحد
    if (!isHighPriority && _controllers.length >= controllerLimit) {
      print('⏩ تخطي التحميل المسبق للفيديو-ID:$id بسبب الوصول للحد الأقصى');
      return;
    }

    // إذا كان هناك متحكم قيد التهيئة لنفس الفيديو، تجاهل
    if (_initializingControllers.contains(id)) {
      print('⏩ تخطي التحميل المسبق لأن الفيديو قيد التهيئة بالفعل: $id');
      return;
    }

    // تخطي التحميل المسبق للفيديوهات القديمة (قبل الفيديو الحالي)
    if (reelIndex != null && reelIndex < _currentVisibleReelIndex) {
      print('⏩ تخطي التحميل المسبق لفيديو سابق: $id');
      return;
    }

    // الانتظار المختلف حسب الأولوية
    if (isHighPriority) {
      // للفيديوهات عالية الأولوية، وقت انتظار قصير
      int waitCount = 0;
      while (_pendingHighPriorityInitializations >=
              _maxHighPriorityInitializations &&
          waitCount < 3) {
        await Future.delayed(Duration(milliseconds: 50));
        waitCount++;
      }

      if (_pendingHighPriorityInitializations >=
          _maxHighPriorityInitializations) {
        // لا ننتظر كثيرًا للفيديوهات ذات الأولوية العالية
        print('⚡ إجبار التحميل المسبق للفيديو عالي الأولوية: $id');
      }

      _pendingHighPriorityInitializations++;
    } else {
      // للفيديوهات العادية، نتجنب تحميلها إذا وصلنا للحد بدلاً من الانتظار
      if (_pendingInitializations >= _maxConcurrentInitializations) {
        print('⏩ تخطي التحميل المسبق بسبب تجاوز عدد التهيئات المتزامنة: $id');
        return;
      }
    }

    _pendingInitializations++;
    _initializingControllers.add(id);

    try {
      // تنظيف المتحكمات للفيديوهات غير عالية الأولوية
      if (!isHighPriority) {
        await _cleanupIfNeeded();
      }

      print('🔄 بدء التحميل المسبق للفيديو-ID:$id');

      // تكييف جودة الفيديو حسب حالة الاتصال
      String effectiveUrl = url;

      // خفض جودة الفيديو المحمل مسبقًا على الاتصالات البطيئة
      if (isSlowConnection() && !isHighPriority) {
        // هذا مثال - يجب تكييفه حسب كيفية تخزين الفيديوهات
        if (url.contains('high_quality')) {
          effectiveUrl = url.replaceAll('high_quality', 'low_quality');
          print('📱 استخدام نسخة منخفضة الجودة للتحميل المسبق: $id');
        }
      }

      // إنشاء متحكم للتحميل المسبق
      final controller = CachedVideoPlayerController.network(
        effectiveUrl,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      // تخزين المتحكم قبل التهيئة
      _controllers[id] = controller;
      _controllerInitStatus[id] = false;
      _updateControllerPriority(id, reelIndex);

      // تهيئة أساسية - الإعدادات الأدنى للتحميل المسبق
      await controller.initialize();

      // تحديث حالة التهيئة
      _controllerInitStatus[id] = true;

      // تأكد من أن الفيديو الذي تم تحميله مسبقًا لا يعمل تلقائيًا
      try {
        await controller.pause();
        await controller.setVolume(0.0);
      } catch (_) {}

      print('✅ تم التحميل المسبق للفيديو-ID:$id');
    } catch (e) {
      print('⚠️ خطأ في التحميل المسبق للفيديو-ID:$id: $e');

      // إزالة المتحكم في حالة فشل التحميل المسبق
      if (_controllers.containsKey(id)) {
        try {
          await _controllers[id]!.dispose();
        } catch (_) {}
        _controllers.remove(id);
        _controllerInitStatus.remove(id);
        _controllerPriority.remove(id);
        _controllerLastUsedTime.remove(id);
        _reelIndexMap.remove(id);
      }
    } finally {
      _pendingInitializations =
          (_pendingInitializations - 1).clamp(0, double.infinity).toInt();

      if (isHighPriority) {
        _pendingHighPriorityInitializations =
            (_pendingHighPriorityInitializations - 1)
                .clamp(0, double.infinity)
                .toInt();
      }

      _initializingControllers.remove(id);
    }
  }

  // دالة جديدة لتحديث الريل المرئي حاليًا
  void updateCurrentVisibleReelIndex(int index) {
    if (_currentVisibleReelIndex != index) {
      // حفظ المؤشر السابق لمقارنة اتجاه التمرير
      final int previousIndex = _currentVisibleReelIndex;
      _currentVisibleReelIndex = index;
      print('📱 تحديث الريل المرئي حاليًا إلى: $index');

      // تحميل الفيديوهات التالية مسبقًا
      _preloadNextVideos(index);

      // إذا كان المستخدم يتنقل للأمام، نقوم بتنظيف الفيديوهات السابقة
      if (index > previousIndex + 1) {
        // تنظيف الفيديوهات القديمة فقط إذا تجاوزنا الحد
        if (_controllers.length > _maxControllers * 0.7) {
          _cleanupPreviousVideos(index, previousIndex);
        }
      }
    }
  }

  // تنظيف الفيديوهات السابقة عند الانتقال للأمام
  Future<void> _cleanupPreviousVideos(
      int currentIndex, int previousIndex) async {
    // لا نقوم بالتنظيف إلا إذا تحركنا للأمام عدة فيديوهات
    final threshold = 2; // تنظيف إذا تحركنا أكثر من فيديوهين للأمام
    if (currentIndex - previousIndex <= threshold) {
      return;
    }

    print('🧹 تنظيف الفيديوهات السابقة بعد التنقل للأمام');

    // جمع معرفات الفيديوهات القديمة
    final videosToCleanup = <String>[];
    for (final entry in _reelIndexMap.entries) {
      // الاحتفاظ بفيديو سابق واحد فقط للرجوع للخلف
      if (entry.value < currentIndex - 1) {
        videosToCleanup.add(entry.key);
      }
    }

    // تنظيف الفيديوهات القديمة
    int cleanupCount = 0;
    for (final id in videosToCleanup) {
      if (id != _activeVideoId) {
        await disposeController(id);
        cleanupCount++;
      }
    }

    if (cleanupCount > 0) {
      print('🗑️ تم تنظيف $cleanupCount فيديو سابق');
    }
  }

  // إضافة دالة جديدة في VideoManager
  void _startStateMonitoring() {
    Timer.periodic(Duration(seconds: 10), (_) {
      _validateAndFixInternalState();
    });
  }

  // التحقق من صحة الحالة الداخلية وإصلاحها
  void _validateAndFixInternalState() {
    // التحقق من تطابق قوائم المتحكمات
    if (_controllers.length != _controllerInitStatus.length ||
        _controllers.length != _controllerPriority.length) {
      print('⚠️ عدم تطابق في قوائم المتحكمات، إجراء تصحيح');

      // مزامنة القوائم
      final validIds = _controllers.keys.toSet();

      _controllerInitStatus.removeWhere((id, _) => !validIds.contains(id));
      _controllerPriority.removeWhere((id, _) => !validIds.contains(id));
      _controllerLastUsedTime.removeWhere((id, _) => !validIds.contains(id));
      _reelIndexMap.removeWhere((id, _) => !validIds.contains(id));

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
      print(
          '⚠️ عدم تطابق في عداد التهيئات: $_pendingInitializations != $pendingCount');
      _pendingInitializations = pendingCount;
    }

    // تصحيح عداد التهيئات عالية الأولوية
    final int highPriorityCount = _initializingControllers.where((id) {
      return _reelIndexMap.containsKey(id) &&
          _isHighPriorityVideo(_reelIndexMap[id]);
    }).length;

    if (_pendingHighPriorityInitializations != highPriorityCount) {
      print(
          '⚠️ تصحيح عداد التهيئات عالية الأولوية: $_pendingHighPriorityInitializations -> $highPriorityCount');
      _pendingHighPriorityInitializations = highPriorityCount;
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
      print('⚠️ إزالة ${stuckInitializers.length} متحكم عالق في التهيئة');
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
          _reelIndexMap.remove(id);
        }
      }

      // تحديث عداد التهيئات
      _pendingInitializations = _initializingControllers.length;

      // تحديث عداد التهيئات عالية الأولوية
      _pendingHighPriorityInitializations =
          _initializingControllers.where((id) {
        return _reelIndexMap.containsKey(id) &&
            _isHighPriorityVideo(_reelIndexMap[id]);
      }).length;
    }

    // إصلاح أي مشاكل تتعلق بالفيديو النشط
    if (_activeVideoId != null && !_controllers.containsKey(_activeVideoId!)) {
      print('⚠️ تصحيح الفيديو النشط: $_activeVideoId غير موجود');
      _activeVideoId = null;
    }
  }

  // تنظيف المتحكمات القديمة إذا تجاوزنا الحد الأقصى
  Future<void> _cleanupIfNeeded() async {
    // التحقق من عدد المتحكمات
    if (_controllers.length < _maxControllers) {
      return;
    }

    print(
        '🧹 تنظيف المتحكمات القديمة (إجمالي المتحكمات: ${_controllers.length})');

    // الحصول على المتحكمات للتنظيف
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

    print('🗑️ تم تنظيف $cleanupCount متحكم');
  }

  // تنظيف المتحكمات في حالة ضغط الذاكرة
  Future<void> _cleanupIfMemoryPressure() async {
    final isMemoryPressure = _controllers.length > _maxControllers * 0.7;

    if (isMemoryPressure) {
      print('🧹 تنظيف دوري للذاكرة (إجمالي المتحكمات: ${_controllers.length})');

      // الحصول على المتحكمات للتنظيف
      final sortedIds = _getSortedControllersByPriority();

      // استبعاد المتحكم النشط
      if (_activeVideoId != null) {
        sortedIds.remove(_activeVideoId);
      }

      // استبعاد الفيديو التالي والذي بعده من التنظيف
      final highPriorityVideos = <String>{};
      if (_activeVideoId != null &&
          _reelIndexMap.containsKey(_activeVideoId!)) {
        final currentIndex = _reelIndexMap[_activeVideoId!]!;

        // البحث عن الفيديو التالي والذي بعده
        for (final entry in _reelIndexMap.entries) {
          if (entry.value == currentIndex + 1 ||
              entry.value == currentIndex + 2) {
            highPriorityVideos.add(entry.key);
          }
        }
      }

      // إزالة الفيديوهات ذات الأولوية العالية من قائمة التنظيف
      sortedIds.removeWhere((id) => highPriorityVideos.contains(id));

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

      if (cleanupCount > 0) {
        print('🗑️ تنظيف ذاكرة دوري: تم التخلص من $cleanupCount متحكم');
      }
    }
  }

  // تنظيف المتحكمات الزائدة في حالة التقليب السريع
  Future<void> _cleanupExcessControllersForRapidSwipe() async {
    print('🧹 تنظيف المتحكمات الزائدة في حالة التقليب السريع');

    // في حالة التقليب السريع، نحتفظ فقط بالفيديو الحالي والفيديوهات التالية
    final currentAndNextVideos = <String>{};

    // إضافة الفيديو الحالي
    if (_activeVideoId != null) {
      currentAndNextVideos.add(_activeVideoId!);

      // البحث عن الفيديوهات التالية فقط
      if (_reelIndexMap.containsKey(_activeVideoId!)) {
        final currentIndex = _reelIndexMap[_activeVideoId!]!;

        // إضافة الفيديوهات التالية (3 فيديوهات تالية كحد أقصى)
        for (final entry in _reelIndexMap.entries) {
          if (entry.value > currentIndex && entry.value <= currentIndex + 3) {
            currentAndNextVideos.add(entry.key);
          }
        }
      }
    }

    // تجميع الفيديوهات للتنظيف
    final videosToCleanup = _controllers.keys
        .where((id) => !currentAndNextVideos.contains(id))
        .toList();

    // تنظيف الفيديوهات
    int cleanupCount = 0;
    for (final id in videosToCleanup) {
      await disposeController(id);
      cleanupCount++;

      // التوقف إذا وصلنا للحد المطلوب
      if (_controllers.length <= _maxControllersInRapidSwipe) {
        break;
      }
    }

    print('🗑️ تنظيف سريع: تم التخلص من $cleanupCount متحكم');
  }

  // تنظيف تدريجي للمتحكمات الزائدة
  Future<void> _cleanupExcessControllersGradually() async {
    // تنظيف تدريجي بعد انتهاء التقليب السريع
    final targetCount = (_maxControllers * 0.7).round();

    if (_controllers.length > targetCount) {
      print(
          '🧹 تنظيف تدريجي للمتحكمات: ${_controllers.length}/$_maxControllers');

      // الحصول على المتحكمات بترتيب الأقدم
      final sortedIds = _getSortedControllersByPriority();

      // استبعاد المتحكم النشط والفيديو التالي له
      final excludedVideos = <String>{};
      if (_activeVideoId != null) {
        excludedVideos.add(_activeVideoId!);

        // البحث عن الفيديو التالي
        if (_reelIndexMap.containsKey(_activeVideoId!)) {
          final currentIndex = _reelIndexMap[_activeVideoId!]!;

          for (final entry in _reelIndexMap.entries) {
            if (entry.value == currentIndex + 1) {
              excludedVideos.add(entry.key);
              break;
            }
          }
        }
      }

      // إزالة الفيديوهات المستثناة من قائمة التنظيف
      sortedIds.removeWhere((id) => excludedVideos.contains(id));

      // تنظيف المتحكمات القديمة تدريجياً (واحد أو اثنين في كل مرة)
      int count = 0;
      for (final id in sortedIds) {
        await disposeController(id);
        count++;

        // تنظيف متحكم أو متحكمين في كل مرة
        if (count >= 2 || _controllers.length <= targetCount) break;
      }

      print('🗑️ تم تنظيف $count متحكم تدريجياً');
    }
  }

  // تشغيل فيديو
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

    // تحميل الفيديوهات التالية مسبقًا
    if (_reelIndexMap.containsKey(id)) {
      _preloadNextVideos(_reelIndexMap[id]!);
    }
  }

  // إيقاف فيديو
  Future<void> pauseVideo(String id) async {
    if (!_controllers.containsKey(id)) {
      return;
    }

    // الحصول على المتحكم
    final controller = _controllers[id]!;

    // إيقاف الفيديو
    await controller.pause();
  }

  // إيقاف جميع الفيديوهات عدا واحد
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
        print('⚠️ خطأ في كتم صوت الفيديو $id: $e');
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
        print('⚠️ خطأ في إيقاف الفيديو $id: $e');
      }
    }

    // تحديث الفيديو النشط
    _activeVideoId = exceptId;

    // تحديث ترتيب الاستخدام للفيديو النشط
    if (exceptId != null) {
      _updateControllerPriority(exceptId);
    }
  }

  // تبديل حالة تشغيل فيديو
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

  // تبديل حالة كتم الصوت
  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;

    // تطبيق حالة كتم الصوت على الفيديو النشط
    if (_activeVideoId != null &&
        _controllers.containsKey(_activeVideoId!) &&
        _controllerInitStatus[_activeVideoId!] == true) {
      await _controllers[_activeVideoId!]!.setVolume(isMuted.value ? 0.0 : 1.0);
    }
  }

// التخلص من متحكم
  Future<void> disposeController(String id) async {
    if (!_controllers.containsKey(id)) {
      return;
    }

    print('🗑️ التخلص من متحكم: $id');

    final controller = _controllers[id]!;

    // إزالة المتحكم من جميع القوائم
    _controllers.remove(id);
    _controllerInitStatus.remove(id);
    _controllerPriority.remove(id);
    _controllerLastUsedTime.remove(id);
    _reelIndexMap.remove(id);

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
      print('⚠️ خطأ في التخلص من المتحكم: $e');
    }
  }

// التخلص من جميع المتحكمات
  Future<void> disposeAllControllers() async {
    print('🧹 التخلص من جميع المتحكمات');

    final ids = _controllers.keys.toList();

    for (final id in ids) {
      await disposeController(id);
    }

    _controllers.clear();
    _controllerInitStatus.clear();
    _controllerPriority.clear();
    _controllerLastUsedTime.clear();
    _reelIndexMap.clear();
    _activeVideoId = null;

    // إلغاء المؤقتات
    _memoryCheckTimer?.cancel();
  }

// التحقق مما إذا كان الفيديو مهيأ
  bool isVideoInitialized(String id) {
    return _controllers.containsKey(id) && _controllerInitStatus[id] == true;
  }

// التحقق مما إذا كان الفيديو قيد التشغيل
  bool isVideoPlaying(String id) {
    if (!_controllers.containsKey(id) || _controllerInitStatus[id] != true) {
      return false;
    }

    return _controllers[id]!.value.isPlaying;
  }

// الحصول على نسبة أبعاد الفيديو
  double? getAspectRatio(String id) {
    if (!_controllers.containsKey(id) ||
        _controllerInitStatus[id] != true ||
        !_controllers[id]!.value.isInitialized) {
      return 9.0 / 16.0; // القيمة الافتراضية
    }

    final size = _controllers[id]!.value.size;
    if (size == null || size.width == 0 || size.height == 0) {
      return 9.0 / 16.0;
    }

    return size.width / size.height;
  }

// الحصول على المتحكم
  CachedVideoPlayerController? getController(String id) {
    if (!_controllers.containsKey(id)) {
      return null;
    }
    return _controllers[id];
  }

// الحصول على جميع المتحكمات
  Map<String, CachedVideoPlayerController> getAllControllers() {
    return Map.unmodifiable(_controllers);
  }

// الحصول على حالات تهيئة المتحكمات
  Map<String, bool> getInitializationStatus() {
    return Map.unmodifiable(_controllerInitStatus);
  }

// الحصول على معرف الفيديو النشط
  String? getActiveVideoId() {
    return _activeVideoId;
  }

// الحصول على عدد المتحكمات المُهيأة
  int getInitializedControllersCount() {
    return _controllerInitStatus.values.where((status) => status).length;
  }

// الحصول على إجمالي عدد المتحكمات
  int getTotalControllersCount() {
    return _controllers.length;
  }

// الحصول على معلومات تشخيصية
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'totalControllers': _controllers.length,
      'initializedControllers': getInitializedControllersCount(),
      'pendingInitializations': _pendingInitializations,
      'pendingHighPriorityInitializations': _pendingHighPriorityInitializations,
      'isRapidSwiping': _isRapidSwiping,
      'activeVideoId': _activeVideoId,
      'connectionType': _connectionType.toString(),
      'isSlowConnection': isSlowConnection(),
      'controllersInUse': _controllerPriority.length,
      'memoryPressure': _controllers.length > _maxControllers * 0.7,
      'currentVisibleReel': _currentVisibleReelIndex,
      'reelIndexMapSize': _reelIndexMap.length,
    };
  }
}
