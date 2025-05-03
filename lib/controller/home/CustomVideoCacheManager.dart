import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomVideoCacheManager {
  static const key = 'videoCustomCache';
  static CustomVideoCacheManager? _instance;
  final BaseCacheManager _cacheManager;

  // معلومات الملفات المخزنة مؤقتًا
  final Map<String, String> _cachedFilePaths = {}; // id -> filePath
  final Map<String, DateTime> _lastAccessTime = {}; // id -> lastAccessTime

  CustomVideoCacheManager._()
      : _cacheManager = CacheManager(
          Config(
            key,
            stalePeriod:
                const Duration(days: 7), // الاحتفاظ بالملفات لمدة 7 أيام
            maxNrOfCacheObjects: 50, // زيادة العدد الأقصى للملفات المخزنة
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );

  factory CustomVideoCacheManager() {
    _instance ??= CustomVideoCacheManager._();
    return _instance!;
  }

  // الحصول على مسار ملف من ذاكرة التخزين المؤقت أو تنزيله إذا لم يكن موجودًا
  Future<String?> getFilePathForVideo(String url, String videoId) async {
    try {
      // تحديث وقت آخر وصول
      _lastAccessTime[videoId] = DateTime.now();

      // التحقق إذا كان لدينا المسار مخزنًا بالفعل
      if (_cachedFilePaths.containsKey(videoId) &&
          await File(_cachedFilePaths[videoId]!).exists()) {
        print('💾 استخدام ملف فيديو مخزن مؤقتًا: $videoId');
        return _cachedFilePaths[videoId];
      }

      // تنزيل أو استرجاع الملف من مدير التخزين المؤقت
      final fileInfo = await _cacheManager.getFileFromCache(url);

      if (fileInfo != null) {
        // الملف موجود في ذاكرة التخزين المؤقت
        _cachedFilePaths[videoId] = fileInfo.file.path;
        print('📂 استرجاع ملف فيديو من ذاكرة التخزين المؤقت: $videoId');
        return fileInfo.file.path;
      }

      // تنزيل الملف إلى ذاكرة التخزين المؤقت
      final file = await _cacheManager.downloadFile(url);
      _cachedFilePaths[videoId] = file.file.path;
      print('⬇️ تنزيل ملف فيديو جديد إلى ذاكرة التخزين المؤقت: $videoId');
      return file.file.path;
    } catch (e) {
      print('❌ خطأ في الحصول على ملف فيديو: $e');
      return null;
    }
  }

  // تحميل ملف في ذاكرة التخزين المؤقت بدون انتظار النتيجة (للتحميل المسبق)
  void preloadFile(String url, String videoId) {
    _cacheManager.downloadFile(url).then((fileInfo) {
      _cachedFilePaths[videoId] = fileInfo.file.path;
      _lastAccessTime[videoId] = DateTime.now();
      print('🔄 تم التحميل المسبق للفيديو في ذاكرة التخزين المؤقت: $videoId');
    }).catchError((e) {
      print('⚠️ خطأ في التحميل المسبق للفيديو: $e');
    });
  }

  // التحقق مما إذا كان الفيديو مخزنًا مؤقتًا بالفعل
  Future<bool> isVideoCached(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(url);
    return fileInfo != null && await fileInfo.file.exists();
  }

  // تنظيف الملفات القديمة
  Future<void> cleanupOldFiles() async {
    try {
      await _cacheManager.emptyCache();
      print('🧹 تم تنظيف ذاكرة التخزين المؤقت للفيديو');
    } catch (e) {
      print('⚠️ خطأ في تنظيف ذاكرة التخزين المؤقت: $e');
    }
  }

  // الحصول على معلومات التخزين المؤقت
  Map<String, dynamic> getCacheInfo() {
    return {
      'cachedVideos': _cachedFilePaths.length,
      'lastCleanupTime': DateTime.now().toString(),
    };
  }
}
