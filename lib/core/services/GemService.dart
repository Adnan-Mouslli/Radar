import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:radar/view/pages/home/GemAnimation.dart';

class GemService extends GetxService {
  // حالة عرض الجوهرة
  final isShowingGem = false.obs;

  // متغيرات لتخزين معلومات الجوهرة الحالية
  final currentGemPoints = 0.obs;
  final currentGemColor = 'blue'.obs;

  // إجمالي النقاط التي ربحها المستخدم من الجواهر
  final totalGemPoints = 0.obs;

  // تاريخ الجواهر المربوحة
  final gemHistory = <GemRecord>[].obs;

  // الصوت الذي يتم تشغيله عند ربح جوهرة
  late AudioPlayer? gemSound;

  // طريقة تهيئة الخدمة
  Future<GemService> init() async {
    // تهيئة مشغل الصوت (استخدم مكتبة الصوت المفضلة لديك)
    // هذا مجرد مثال، يرجى استبداله بالتنفيذ الفعلي
    try {
      gemSound = null; // يمكنك تهيئة مشغل الصوت هنا
    } catch (e) {
      print("فشل تهيئة صوت الجوهرة: $e");
    }

    // تحميل التاريخ المخزن محلياً - يمكن تنفيذه باستخدام مكتبة التخزين المحلي
    _loadGemHistory();

    return this;
  }

  // عرض رسم متحرك للجوهرة
  void showGemAnimation(int points, String color) {
    try {
      // التأكد من تحويل القيم إلى الأنواع الصحيحة
      final safePoints = points;
      final safeColor = color;

      // تحديث المتغيرات العامة
      currentGemPoints.value = safePoints;
      currentGemColor.value = safeColor;
      isShowingGem.value = true;

      // تشغيل صوت الجوهرة (يعتمد على المكتبة المستخدمة)
      _playGemSound();

      // اهتزاز الجهاز (للشعور بالفوز)
      HapticFeedback.mediumImpact();

      // عرض رسوم الجوهرة
      final gem = GemModel(points: safePoints, color: safeColor);

      // استخدام ModernGemAnimation بدلاً من GemAnimation
      Get.dialog(
        Material(
          color: Colors.transparent,
          child: ModernGemAnimation(
            gem: gem,
            onAnimationComplete: () {
              // إغلاق العرض وتحديث الحالة
              Get.back();
              isShowingGem.value = false;

              // تحديث إجمالي النقاط
              totalGemPoints.value += safePoints;

              // إضافة السجل الجديد
              _addGemRecord(GemRecord(
                points: safePoints,
                color: safeColor,
                timestamp: DateTime.now(),
              ));

              // عرض تنبيه بعد الانتهاء
              _showSuccessToast(safePoints);
            },
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      print("خطأ في عرض الجوهرة: $e");
      // في حالة الفشل، نعرض رسالة بسيطة
      _showSimpleGemToast(points);
    }
  }

  // تشغيل صوت الجوهرة
  void _playGemSound() {
    try {
      // تشغيل الصوت - استبدل هذا بتنفيذك الخاص
      // إذا كانت لديك مكتبة صوت مثبتة
      // مثال: gemSound?.play();
    } catch (e) {
      print("خطأ في تشغيل صوت الجوهرة: $e");
    }
  }

  // عرض تنبيه بسيط في حالة فشل العرض المتحرك
  void _showSimpleGemToast(int points) {
    Get.snackbar(
      'مبروك!',
      'لقد ربحت $points نقطة!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(10),
      borderRadius: 10,
      icon: Icon(Icons.diamond, color: Colors.pink),
    );
  }

  // عرض تنبيه بعد انتهاء العرض المتحرك
  void _showSuccessToast(int points) {
    // تحديث تصميم التنبيه ليكون أكثر عصرية
    Get.snackbar(
      'تم إضافة النقاط!',
      'تم إضافة $points نقطة إلى رصيدك',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.all(10),
      borderRadius: 10,
      icon: Icon(Icons.check_circle, color: Colors.pink),
    );
  }

  // إضافة سجل جديد
  void _addGemRecord(GemRecord record) {
    gemHistory.add(record);
    // حفظ التاريخ محلياً
    _saveGemHistory();
  }

  // تحميل تاريخ الجواهر من التخزين المحلي
  void _loadGemHistory() {
    // يمكنك تنفيذ هذا باستخدام مكتبة مثل shared_preferences
    // هذا مجرد مثال، تحتاج لتنفيذه فعليا
    try {
      // مثال:
      // final prefs = await SharedPreferences.getInstance();
      // final historyJson = prefs.getString('gem_history') ?? '[]';
      // final List<dynamic> decoded = jsonDecode(historyJson);
      // gemHistory.value = decoded.map((item) => GemRecord.fromJson(item)).toList();
      // totalGemPoints.value = gemHistory.fold(0, (sum, record) => sum + record.points);
    } catch (e) {
      print("خطأ في تحميل تاريخ الجواهر: $e");
    }
  }

  // حفظ تاريخ الجواهر في التخزين المحلي
  void _saveGemHistory() {
    // يمكنك تنفيذ هذا باستخدام مكتبة مثل shared_preferences
    // هذا مجرد مثال، تحتاج لتنفيذه فعليا
    try {
      // مثال:
      // final prefs = await SharedPreferences.getInstance();
      // final historyJson = jsonEncode(gemHistory.map((item) => item.toJson()).toList());
      // prefs.setString('gem_history', historyJson);
    } catch (e) {
      print("خطأ في حفظ تاريخ الجواهر: $e");
    }
  }
}

// فئة لتمثيل سجل ربح الجوهرة
class GemRecord {
  final int points;
  final String color;
  final DateTime timestamp;

  GemRecord({
    required this.points,
    required this.color,
    required this.timestamp,
  });

  // طريقة تحويل السجل إلى JSON للتخزين
  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'color': color,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // طريقة إنشاء سجل من بيانات JSON
  factory GemRecord.fromJson(Map<String, dynamic> json) {
    return GemRecord(
      points: json['points'] as int,
      color: json['color'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// واجهة مشغل الصوت (استبدلها بمكتبة الصوت المفضلة لديك)
abstract class AudioPlayer {
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}
