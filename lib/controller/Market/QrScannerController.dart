import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radar/controller/Market/MarketController.dart';
import 'package:radar/core/services/QrScannerService.dart';
import 'dart:async'; // For Timer

class QrScannerController extends GetxController {
  // المتغيرات الرئيسية
  final MarketController marketController;
  final QrScannerService scannerService = QrScannerService();
  MobileScannerController? cameraController;

  // حالة المسح والقراءة
  final RxBool isScanning = false.obs;
  final RxBool showReward = false.obs;
  final RxInt pointsWon = 0.obs;
  final RxString scanMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxBool hasCameraPermission = false.obs;
  final RxBool isTorchOn = false.obs;
  final RxString scanResult = ''.obs;

  // متغيرات جديدة للواجهة المحسّنة
  final RxBool isQrDetected = false.obs; // حالة اكتشاف كود QR
  final RxDouble scanProgressValue = 0.0.obs; // قيمة تقدم عملية المسح (0-1)
  Timer? _scanProgressTimer; // مؤقت 4 ثواني
  BarcodeCapture? _detectedCapture; // تخزين الـ QR المكتشف مؤقتًا

  // متغير جديد لتتبع حالة المعالجة
  final RxBool isProcessing = false.obs; // لمنع المسح المتعدد أثناء المعالجة

  // البناء مع المكونات المطلوبة
  QrScannerController({required this.marketController});

  @override
  void onInit() {
    super.onInit();
    // نقوم فقط بالتحقق من الإذن في onInit
    _checkCameraPermission();
  }

  // التحقق من إذن الكاميرا
  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    hasCameraPermission.value = status.isGranted;
  }

  // تهيئة الكاميرا - يتم استدعاؤها فقط عند بدء المسح
  void _initializeCamera() {
    try {
      // نتأكد من إغلاق الكونترولر القديم إن وجد
      if (cameraController != null) {
        cameraController!.dispose();
      }

      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: [BarcodeFormat.qrCode], // تحديد تنسيق QR لتحسين الأداء
      );
    } catch (e) {
      printError(info: 'خطأ في تهيئة كونترولر الكاميرا: $e');
    }
  }

  // تنظيف الموارد عند الإغلاق
  @override
  void onClose() {
    _cancelScanTimer(); // إلغاء المؤقت عند الإغلاق
    disposeCamera();
    super.onClose();
  }

  // إلغاء مؤقت المسح
  void _cancelScanTimer() {
    if (_scanProgressTimer != null) {
      _scanProgressTimer!.cancel();
      _scanProgressTimer = null;
    }
  }

  // إغلاق الكاميرا وتحرير الموارد
  void disposeCamera() {
    try {
      if (cameraController != null) {
        if (isScanning.value) {
          cameraController!.stop();
          isScanning.value = false;
        }
        cameraController!.dispose();
        cameraController = null;
      }
    } catch (e) {
      printError(info: 'خطأ عند إغلاق الكاميرا: $e');
    }
  }

  // تبديل الفلاش
  Future<void> toggleTorch() async {
    try {
      if (cameraController != null) {
        await cameraController!.toggleTorch();
        isTorchOn.value = !isTorchOn.value;

        // تقديم تغذية راجعة حسية عند تبديل الفلاش
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      printError(info: 'خطأ في تبديل الفلاش: $e');
    }
  }

  // استقبال وبدء مؤقت لمسح كود QR (4 ثواني)
  void handleQrDetection(BarcodeCapture capture) {
    // تحقق من عدم وجود عملية مسح قيد التنفيذ
    if (isProcessing.value ||
        isQrDetected.value ||
        hasError.value ||
        showReward.value) {
      return; // تجاهل المسح الجديد إذا كانت هناك عملية قيد التنفيذ
    }

    // تعيين حالة المعالجة إلى نشطة
    isProcessing.value = true;

    // تخزين الكود المكتشف
    _detectedCapture = capture;

    // تعيين حالة اكتشاف الكود
    isQrDetected.value = true;

    // تغذية راجعة حسية خفيفة لإشعار المستخدم بالاكتشاف
    HapticFeedback.lightImpact();

    // إعادة ضبط قيمة تقدم المسح
    scanProgressValue.value = 0.0;

    // إلغاء أي مؤقت سابق
    _cancelScanTimer();

    // بدء مؤقت جديد (4 ثواني)
    const totalDuration = 4000; // 4 ثواني
    const tickInterval = 50; // تحديث كل 50 مللي ثانية
    int elapsedTime = 0;

    _scanProgressTimer =
        Timer.periodic(Duration(milliseconds: tickInterval), (timer) {
      elapsedTime += tickInterval;

      // تحديث قيمة التقدم (0-1)
      scanProgressValue.value = elapsedTime / totalDuration;

      // عند انتهاء المدة
      if (elapsedTime >= totalDuration) {
        timer.cancel();

        // بعد 4 ثواني، نبدأ المعالجة الفعلية
        if (_detectedCapture != null && isQrDetected.value) {
          // إيقاف عرض الفحص
          isQrDetected.value = false;

          // معالجة الكود QR مباشرة
          processQrResult(_detectedCapture!);
        }
      }
    });
  }

  // إعادة ضبط الماسح للبدء من جديد
  void resetScanner() {
    // إعادة ضبط جميع الحالات
    hasError.value = false;
    isQrDetected.value = false;
    scanProgressValue.value = 0.0;
    isProcessing.value = false; // إعادة تعيين حالة المعالجة
    _cancelScanTimer();
    _detectedCapture = null;

    // إعادة تمكين المسح
    if (!isScanning.value && hasCameraPermission.value) {
      startScanning();
    }
  }

  // بدء المسح
  Future<void> startScanning() async {
    print("scanning");
    // إعادة ضبط الحالات أولاً
    hasError.value = false;
    scanMessage.value = '';
    isQrDetected.value = false;
    scanProgressValue.value = 0.0;
    isProcessing.value = false; // إعادة تعيين حالة المعالجة
    _cancelScanTimer();
    _detectedCapture = null;

    // التحقق من إذن الكاميرا
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        hasError.value = true;
        scanMessage.value = 'يرجى السماح بالوصول للكاميرا لاستخدام هذه الميزة';
        return;
      }
    }

    hasCameraPermission.value = true;

    // تهيئة الكاميرا - نقلناها هنا للتأكد من إنشاء كونترولر جديد عند كل استخدام
    _initializeCamera();

    // إعادة ضبط باقي الحالات
    isScanning.value = true;
    isTorchOn.value = false;
    scanResult.value = '';
    showReward.value = false;
  }

  // إيقاف المسح
  void stopScanning() {
    isScanning.value = false;
    isQrDetected.value = false;
    isProcessing.value = false; // إعادة تعيين حالة المعالجة
    _cancelScanTimer();

    // نتأكد من إيقاف الكاميرا
    try {
      if (cameraController != null) {
        cameraController!.stop();
      }
    } catch (e) {
      printError(info: 'خطأ عند إيقاف الكاميرا: $e');
    }

    // إعادة اتجاه الشاشة إلى الوضع الطبيعي
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  // معالجة نتيجة المسح
  Future<void> processQrResult(BarcodeCapture capture) async {
    // إذا لم تكن هناك باركودات، نعود
    if (capture.barcodes.isEmpty) {
      isProcessing.value = false; // إعادة تعيين حالة المعالجة
      resetScanner();
      return;
    }

    // نأخذ أول باركود
    final barcode = capture.barcodes.first;
    String? qrData = barcode.rawValue;
    scanResult.value = qrData ?? '';

    if (qrData == null || qrData.isEmpty) {
      hasError.value = true;
      scanMessage.value = 'كود QR غير مقروء، حاول مرة أخرى';
      isProcessing.value = false; // إعادة تعيين حالة المعالجة
      return;
    }

    try {
      // تقديم تغذية راجعة حسية عند بدء المعالجة
      HapticFeedback.mediumImpact();

      // معالجة الكود QR مباشرة
      final result = await scannerService.scanQrCode(qrData);

      if (result['success'] == true) {
        // إيقاف المسح عند النجاح
        stopScanning();

        // إضافة النقاط للمستخدم
        pointsWon.value = result['points'] ?? 0;
        final currentPoints =
            marketController.profileController.profile.value?.user.points ?? 0;
        marketController.profileController
            .updateUserPoints(currentPoints + pointsWon.value);

        // إخفاء أي رسائل خطأ
        hasError.value = false;


        // إظهار واجهة الربح
        showReward.value = true;

        // اهتزاز الهاتف للإشعار بنجاح المسح
        HapticFeedback.heavyImpact();

        // نبقي حالة المعالجة نشطة حتى يغلق المستخدم الواجهة
      } else {
        // عرض الخطأ وإيقاف المسح مؤقتاً
        hasError.value = true;

        // تعديل رسائل الخطأ إلى العربية
        if (result['statusCode'] == 400) {
          scanMessage.value = 'لقد قمت بمسح هذا الكود مسبقاً';
        } else if (result['message']?.contains('expired') == true) {
          scanMessage.value = 'انتهت صلاحية هذا الكود';
        } else if (result['message']?.contains('invalid') == true) {
          scanMessage.value = 'هذا الكود غير صالح';
        } else {
          scanMessage.value = result['message'] ?? 'حدث خطأ غير معروف';
        }

        // اهتزاز خفيف عند الخطأ
        HapticFeedback.lightImpact();

        // نبقي حالة المعالجة نشطة حتى يغلق المستخدم نافذة الخطأ
      }
    } catch (e) {
      // عرض الخطأ
      hasError.value = true;
      scanMessage.value = 'حدث خطأ: ${e.toString()}';
      // نبقي حالة المعالجة نشطة حتى يغلق المستخدم نافذة الخطأ
    }
  }

  // إغلاق شاشة المكافأة والعودة للشاشة الرئيسية
  void closeRewardScreen() {
    showReward.value = false;
    isProcessing.value = false; // إعادة تعيين حالة المعالجة
    Get.back(); // العودة إلى الشاشة السابقة

    // عرض رسالة نجاح للمستخدم في الشاشة الرئيسية
    Future.delayed(Duration(milliseconds: 300), () {
      Get.snackbar(
        'مبروك!',
        'تم إضافة ${pointsWon.value} نقطة إلى رصيدك',
        backgroundColor:
            Colors.amber.withOpacity(0.7), // تغيير لون الخلفية إلى ذهبي
        colorText: Colors.black, // تغيير لون النص إلى أسود للتباين
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 10,
        icon: Icon(
          Icons.emoji_events, // تغيير الأيقونة إلى كأس الفوز
          color: Colors.black,
        ),
      );
    });
  }

  // للتعامل مع الروابط المباشرة
  Future<void> handleDeepLink(String id) async {
    // تحقق من عدم وجود عملية مسح قيد التنفيذ
    if (isProcessing.value) {
      return; // تجاهل الرابط المباشر إذا كانت هناك عملية قيد التنفيذ
    }

    // تعيين حالة المعالجة إلى نشطة
    isProcessing.value = true;

    try {
      final result = await scannerService.handleQrScanViaUrl(id);

      if (result['success'] == true) {
        // إضافة النقاط للمستخدم
        pointsWon.value = result['points'] ?? 0;
        final currentPoints =
            marketController.profileController.profile.value?.user.points ?? 0;
        marketController.profileController
            .updateUserPoints(currentPoints + pointsWon.value);

        // إظهار واجهة الربح الذهبية (نفس الواجهة المستخدمة عند مسح QR)
        showReward.value = true;

        // اهتزاز الهاتف للإشعار بنجاح المسح
        HapticFeedback.heavyImpact();

        // في حالة أن المستخدم لم يكن في صفحة المسح أصلاً، نقوم بفتح نافذة منبثقة خاصة
        if (!Get.currentRoute.contains('QrScannerScreen')) {
          Get.dialog(
            Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(0),
              child: Container(
                width: Get.width,
                height: Get.height,
                color: Colors.black.withOpacity(0.9),
                child: Center(
                  child: Container(
                    width: Get.width * 0.85,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // أيقونة الفوز
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 70,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'مبروك!',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'لقد ربحت ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: '${pointsWon.value}',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' نقطة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // إظهار الرصيد الحالي
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'رصيدك الحالي',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '$currentPoints',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'نقطة',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 36),
                        ElevatedButton(
                          onPressed: () {
                            Get.back(); // إغلاق النافذة المنبثقة
                            isProcessing.value =
                                false; // إعادة تعيين حالة المعالجة

                            // عرض رسالة نجاح ذهبية
                            Get.snackbar(
                              'مبروك!',
                              'تم إضافة ${pointsWon.value} نقطة إلى رصيدك',
                              backgroundColor: Colors.amber.withOpacity(0.7),
                              colorText: Colors.black,
                              duration: Duration(seconds: 3),
                              snackPosition: SnackPosition.TOP,
                              margin: EdgeInsets.all(16),
                              borderRadius: 10,
                              icon: Icon(
                                Icons.emoji_events,
                                color: Colors.black,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'رائع!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            barrierDismissible: false,
          ).then((_) {
            // reset processing state when dialog is closed
            isProcessing.value = false;
          });
        }
      } else {
        // تعديل رسائل الخطأ في الروابط المباشرة أيضاً
        String message = '';
        if (result['message']?.contains('already been scanned') == true) {
          message = 'لقد قمت بمسح هذا الكود مسبقاً';
        } else if (result['message']?.contains('expired') == true) {
          message = 'انتهت صلاحية هذا الكود';
        } else if (result['message']?.contains('invalid') == true) {
          message = 'هذا الكود غير صالح';
        } else {
          message = result['message'] ?? 'حدث خطأ غير معروف';
        }

        // عرض نافذة خطأ منبثقة بدلاً من snackbar
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(0),
            child: Container(
              width: Get.width,
              height: Get.height,
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: Container(
                  width: Get.width * 0.85,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'تنبيه',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 36),
                      ElevatedButton(
                        onPressed: () {
                          Get.back(); // إغلاق النافذة المنبثقة
                          isProcessing.value =
                              false; // إعادة تعيين حالة المعالجة
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'حسناً',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        ).then((_) {
          // reset processing state when dialog is closed
          isProcessing.value = false;
        });
      }
    } catch (e) {
      // عرض نافذة خطأ منبثقة بدلاً من snackbar
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            width: Get.width,
            height: Get.height,
            color: Colors.black.withOpacity(0.9),
            child: Center(
              child: Container(
                width: Get.width * 0.85,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'خطأ',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'حدث خطأ أثناء معالجة الرابط',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 36),
                    ElevatedButton(
                      onPressed: () {
                        Get.back(); // إغلاق النافذة المنبثقة
                        isProcessing.value = false; // إعادة تعيين حالة المعالجة
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'حسناً',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      ).then((_) {
        // reset processing state when dialog is closed
        isProcessing.value = false;
      });
    }
  }
}
