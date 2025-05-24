import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/Market/QrScannerController.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart'; // Import Lottie for better animations

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late QrScannerController controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<QrScannerController>();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _animationController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startScanning();
    });
  }

  void _toggleTorch() {
    controller.toggleTorch();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() => Stack(
              children: [
                _buildScannerView(),
                _buildOverlay(context),
                if (controller.hasError.value) _buildErrorMessage(),
                if (controller.showReward.value) _buildRewardOverlay(context),
                if (controller.isQrDetected.value)
                  _buildPreProcessingIndicator(),
              ],
            )),
      ),
    );
  }

  Widget _buildScannerView() {
    if (!controller.isScanning.value ||
        !controller.hasCameraPermission.value ||
        controller.cameraController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.qrcode,
                    color: AppColors.primary.withOpacity(0.8),
                    size: 70,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                controller.hasCameraPermission.value
                    ? 'جاري تهيئة الكاميرا...'
                    : 'يرجى السماح بالوصول للكاميرا',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: AppFonts.medium,
                ),
                textAlign: TextAlign.center,
              ),
              if (!controller.hasCameraPermission.value)
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: ElevatedButton.icon(
                    onPressed: () => controller.startScanning(),
                    icon: Icon(Icons.camera_alt, size: 22),
                    label: Text('السماح بالوصول للكاميرا'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Camera view - taking full screen with no overlay
        MobileScanner(
          controller: controller.cameraController!,
          onDetect: (capture) {
            // نتحقق من عدم وجود أي عملية قيد التنفيذ قبل بدء مسح جديد
            if (capture.barcodes.isNotEmpty &&
                controller.isScanning.value &&
                !controller.isProcessing.value &&
                !controller.isQrDetected.value &&
                !controller.hasError.value &&
                !controller.showReward.value) {
              // When QR is detected, set detection state and start a 4-second countdown
              controller.handleQrDetection(capture);
            }
          },
        ),
      ],
    );
  }

  // New widget for pre-processing indicator (4-second wait)
  Widget _buildPreProcessingIndicator() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: AppColors.primary.withOpacity(0.7),
                    strokeWidth: 3,
                    // Show progress for 4 seconds
                    value: controller.scanProgressValue.value,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Icon(
                  FontAwesomeIcons.qrcode,
                  color: AppColors.primary.withOpacity(0.8),
                  size: 30,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'جارِ مسح الكود...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: AppFonts.semiBold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'الرجاء الثبات',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: AppFonts.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Stack(
            children: [
            if (!controller.isQrDetected.value && 
                !controller.hasError.value && 
                !controller.showReward.value && 
                !controller.isProcessing.value)
                _buildScannerCorners(),

              // Only show scan line if not detecting or processing
              if (!controller.isQrDetected.value && 
                  !controller.hasError.value && 
                  !controller.showReward.value && 
                  !controller.isProcessing.value)
                _buildSimpleScanLine(),

              // Instructions - repositioned to be visible
              if (!controller.isQrDetected.value && 
                  !controller.hasError.value && 
                  !controller.showReward.value && 
                  !controller.isProcessing.value)
                _buildInstructions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScannerCorners() {
    final scannerSize = Get.width * 0.75;
    final left = (Get.width - scannerSize) / 2;
    // Center the scanner vertically
    final top = (Get.height - scannerSize) / 2;

    return Positioned(
      left: left,
      top: top - 120,
      width: scannerSize,
      height: scannerSize,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Light border for the scanning area
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Top-left corner
            Positioned(
              top: 0,
              left: 0,
              child: _buildCorner('topLeft'),
            ),
            // Top-right corner
            Positioned(
              top: 0,
              right: 0,
              child: _buildCorner('topRight'),
            ),
            // Bottom-left corner
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCorner('bottomLeft'),
            ),
            // Bottom-right corner
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCorner('bottomRight'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(String position) {
    final double size = 25;
    final double thickness = 3.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: position.startsWith('top')
              ? BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          bottom: position.startsWith('bottom')
              ? BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          left: position.endsWith('Left')
              ? BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          right: position.endsWith('Right')
              ? BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
        ),
      ),
    );
  }

  // Scan line animation
  Widget _buildSimpleScanLine() {
    final scannerSize = Get.width * 0.75;
    // Center the scanner vertically
    final verticalCenter = (Get.height - scannerSize) / 2 - 120;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          left: (Get.width - scannerSize) / 2,
          top: verticalCenter + (scannerSize * _animationController.value),
          width: scannerSize,
          height: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.5),
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.5),
                  Colors.transparent,
                ],
                stops: [0.0, 0.2, 0.5, 0.8, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Flash button repositioned
  Widget _buildFlashButtonSmall() {
    return GestureDetector(
      onTap: _toggleTorch,
      child: Obx(() => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: controller.isTorchOn.value
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: controller.isTorchOn.value
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              controller.isTorchOn.value ? Icons.flash_on : Icons.flash_off,
              color:
                  controller.isTorchOn.value ? AppColors.primary : Colors.white,
              size: 20,
            ),
          )),
    );
  }

  // Instructions box with better positioning and background for readability
  Widget _buildInstructions() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary.withOpacity(0.9),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'وجه الكاميرا إلى كود QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: AppFonts.medium,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'يمكنك العثور على أكواد QR في المتاجر والفعاليات المشاركة',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Opacity(
              opacity: 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Colors.white.withOpacity(0.7),
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'استخدم زر الفلاش للإضاءة عند الحاجة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Lighter gradient for app bar
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.2),
            Colors.transparent,
          ],
          stops: [0.0, 0.7, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                controller.stopScanning();
                Get.back();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary.withOpacity(0.8),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'مسح كود QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildFlashButtonSmall(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      width: double.infinity,
      height: double.infinity,
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
                  fontWeight: AppFonts.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                controller.scanMessage.value,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: AppFonts.medium,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  controller.resetScanner();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'حسناً',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: AppFonts.semiBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardOverlay(BuildContext context) {
    // Get current points from user profile
    final currentPoints = controller.marketController.profileController.profile.value?.user.points ?? 0;
    
    return Container(
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
                color: Colors.amber.withOpacity(0.3), // تغيير اللون إلى ذهبي
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: Colors.amber.withOpacity(0.5), // تغيير حدود الإطار إلى ذهبي
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Animation or Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15), // تغيير الخلفية إلى ذهبي
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2), // تغيير الخلفية إلى ذهبي
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events, // تغيير الأيقونة إلى كأس الفوز
                      color: Colors.amber, // تغيير لون الأيقونة إلى ذهبي
                      size: 70,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'مبروك!',
                style: TextStyle(
                  color: Colors.amber, // تغيير اللون إلى ذهبي
                  fontSize: 28,
                  fontWeight: AppFonts.bold,
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
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                    TextSpan(
                      text: '${controller.pointsWon.value}',
                      style: TextStyle(
                        color: Colors.amber, // تغيير اللون إلى ذهبي
                        fontSize: 24,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' نقطة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Add current points balance
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3), // تغيير اللون إلى ذهبي
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
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: Colors.amber, // تغيير اللون إلى ذهبي
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$currentPoints',
                          style: TextStyle(
                            color: Colors.amber, // تغيير اللون إلى ذهبي
                            fontSize: 24,
                            fontWeight: AppFonts.bold,
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
                onPressed: controller.closeRewardScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // تغيير اللون إلى ذهبي
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'رائع!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: AppFonts.semiBold,
                    color: Colors.black, // تغيير لون النص للتباين مع الخلفية الذهبية
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}