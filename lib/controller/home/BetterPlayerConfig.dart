import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// فئة توفر إعدادات مُحسّنة لـ BetterPlayer
/// تساعد على تحسين استهلاك الذاكرة ودعم HLS
class BetterPlayerConfig {
  /// إنشاء مصدر بيانات لتشغيل فيديو HLS
  ///
  /// [url] رابط الفيديو
  /// [posterUrl] رابط صورة البوستر (اختياري)
  /// [isPreload] ما إذا كان للتحميل المسبق أم للتشغيل الفعلي
  static BetterPlayerDataSource createHlsDataSource({
    required String url,
    String? posterUrl,
    bool isPreload = false,
    String? id, // إضافة معرف للفيديو
  }) {
    // تحديد ما إذا كان الفيديو بصيغة HLS
    final isHls = url.contains('.m3u8');
    final videoFormat = isHls ? BetterPlayerVideoFormat.hls : null;

    // استخدام معرف الفيديو كمفتاح للكاش
    final cacheKey = id ?? "${url.hashCode}_video_cache";

    final bufferingConfig = BetterPlayerBufferingConfiguration(
      minBufferMs: isPreload ? 5000 : 15000, // تقليل البفر للتحميل المسبق
      maxBufferMs:
          isPreload ? 10000 : 30000, // تقليل الحد الأقصى للتحميل المسبق
      bufferForPlaybackMs: 1000,
      bufferForPlaybackAfterRebufferMs: 2000,
    );

    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      // إعدادات الكاش المحسنة
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: isPreload
            ? 100 * 1024 * 1024
            : 200 * 1024 * 1024, // حجم أصغر للتحميل المسبق
        maxCacheFileSize: isPreload ? 20 * 1024 * 1024 : 50 * 1024 * 1024,
        preCacheSize: isPreload ? 1 * 1024 * 1024 : 3 * 1024 * 1024,
        key: cacheKey, // استخدام مفتاح فريد
      ),
      // تحديد صيغة الفيديو
      videoFormat: videoFormat,
      // إعدادات التخزين المؤقت المحسنة
      bufferingConfiguration: bufferingConfig,
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: false,
      ),
    );
  }

  static BetterPlayerConfiguration createPlayerConfig({
    String? posterUrl,
    bool lowMemoryMode = false,
  }) {
    return BetterPlayerConfiguration(
        autoPlay: false,
        looping: true,
        placeholder: posterUrl != null
            ? Image.network(
                posterUrl,
                fit: BoxFit.cover,
                // errorBuilder: (context, error, stackTrace) =>
                //     const SizedBox.expand(
                //         child: ColoredBox(color: Colors.black)),
              )
            : const SizedBox.expand(child: ColoredBox(color: Colors.black)),
        handleLifecycle: false, // إدارة دورة الحياة
        allowedScreenSleep: false,
        fit: BoxFit.cover,
        autoDispose: false,
        expandToFill: false,
        showPlaceholderUntilPlay: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
          enablePlayPause: false,
          enableProgressBar: false,
          enableSkips: false,
          enableMute: false,
          enableFullscreen: false,
          enableOverflowMenu: false,
        ),
        deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],
        playerVisibilityChangedBehavior: (visibilityFraction) {
          // إيقاف تشغيل الفيديو عندما لا يكون مرئيًا
          return visibilityFraction >= 0.8;
        },
        useRootNavigator: false);
  }

  /// إنشاء تكوين للتحميل المسبق
  ///
  /// يستخدم إعدادات مبسطة لتوفير الذاكرة
  static BetterPlayerConfiguration createPreloadConfig() {
    return BetterPlayerConfiguration(
      autoPlay: false,
      looping: false,
      handleLifecycle: false,
      allowedScreenSleep: false,
      autoDispose: false,
      // تكوينات مصغرة لتوفير الذاكرة
      showPlaceholderUntilPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
      ),
      // تعطيل الميزات التي تستهلك الذاكرة
      useRootNavigator: false,
    );
  }

  /// مسح ذاكرة التخزين المؤقت والموارد المستخدمة
  static Future<void> clearCache() async {
    try {
      // تنظيف كاش الصور
      if (PaintingBinding.instance != null) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      }
      
      // تنظيف كاش DefaultCacheManager
      try {
        final cacheManager = DefaultCacheManager();
        await cacheManager.emptyCache();
      } catch (e) {
        print('خطأ عند مسح ذاكرة التخزين المؤقت للـ DefaultCacheManager: $e');
      }
      
      // تنظيف موارد النظام إذا أمكن
      try {
        await SystemChannels.platform.invokeMethod('SystemUtils.clearMemory');
      } catch (e) {
        // قد لا تكون هذه الميزة متاحة على جميع الأجهزة
      }
      
      // تنظيف كاش BetterPlayer الخاص
      try {
        await _clearBetterPlayerCache();
      } catch (e) {
        print('خطأ في تنظيف كاش BetterPlayer: $e');
      }
    } catch (e) {
      print('خطأ عند مسح ذاكرة التخزين المؤقت: $e');
    }
  }
  
  /// دالة داخلية لتنظيف كاش BetterPlayer
  static Future<void> _clearBetterPlayerCache() async {
    try {
      // محاولة الوصول إلى مجلد الكاش وحذف الملفات القديمة
      final cacheManager = DefaultCacheManager();
      final cache = await cacheManager.getFileFromCache('better_player_cache');
      if (cache != null && cache.file.existsSync()) {
        final directory = cache.file.parent;
        if (directory.existsSync()) {
          // حذف الملفات الأقدم من ساعتين
          final now = DateTime.now();
          final files = directory.listSync();
          for (var entity in files) {
            if (entity is File) {
              final stat = entity.statSync();
              final fileAge = now.difference(stat.modified);
              if (fileAge.inHours > 2) {
                try {
                  entity.deleteSync();
                } catch (e) {
                  // تجاهل الأخطاء في حذف الملفات الفردية
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // تجاهل الأخطاء - هذه محاولة أفضل جهد
      print('خطأ أثناء محاولة تنظيف كاش BetterPlayer: $e');
    }
  }
  
  /// تهيئة آمنة للفيديو مع محاولات إعادة وآليات التعافي من الأخطاء
  static Future<BetterPlayerController> initializeSafeVideo({
    required String url,
    String? posterUrl,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Exception? lastError;
    
    while (attempts < maxRetries) {
      try {
        // إنشاء تكوين مخصص للمحاولة الحالية
        final config = BetterPlayerConfiguration(
          autoPlay: false,
          looping: true,
          placeholder: posterUrl != null
              ? Image.network(
                  posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.expand(child: ColoredBox(color: Colors.black)),
                )
              : const SizedBox.expand(child: ColoredBox(color: Colors.black)),
          handleLifecycle: false,
          allowedScreenSleep: false,
          fit: BoxFit.cover,
          autoDispose: false,
          showPlaceholderUntilPlay: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: false,
          ),
        );
        
        final controller = BetterPlayerController(config);
        
        // إنشاء مصدر بيانات مع خيارات متقدمة للتعافي من الأخطاء
        final dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
          cacheConfiguration: BetterPlayerCacheConfiguration(
            useCache: true,
            key: "safe_${url.hashCode}_try$attempts",
          ),
          videoFormat: url.contains('.m3u8') ? BetterPlayerVideoFormat.hls : null,
          bufferingConfiguration: BetterPlayerBufferingConfiguration(
            minBufferMs: 15000,
            maxBufferMs: 30000,
            bufferForPlaybackMs: 1000,
            bufferForPlaybackAfterRebufferMs: 2000,
          ),
          // خيارات متقدمة للتعافي من الأخطاء
          
        );
        
        // تهيئة المصدر
        await controller.setupDataSource(dataSource);
        
        // انتظار التهيئة
        int waitAttempts = 0;
        while (waitAttempts < 20 && !(controller.isVideoInitialized() ?? false)) {
          await Future.delayed(Duration(milliseconds: 100));
          waitAttempts++;
        }
        
        // إذا نجحت التهيئة، إرجاع المتحكم
        if (controller.isVideoInitialized() ?? false) {
          return controller;
        }
        
        // إذا فشلت التهيئة، التخلص من المتحكم ومحاولة مرة أخرى
        controller.dispose();
        throw Exception("فشل تهيئة الفيديو بعد الانتظار");
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        // تنظيف وتأخير قبل المحاولة التالية
        await clearCache();
        await Future.delayed(Duration(milliseconds: 500 * (attempts + 1)));
        attempts++;
      }
    }
    
    // جميع المحاولات فشلت
    throw lastError ?? Exception("فشل تهيئة الفيديو بعد $maxRetries محاولات");
  }
}