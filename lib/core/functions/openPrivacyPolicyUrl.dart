import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/view/components/ui/CustomToast.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openPrivacyPolicyUrl() async {
  final String pdfUrl = 'https://radar.anycode-sy.com/api/privacy-policy';

  try {
    // عرض مؤشر التحميل

    Get.dialog(
      Center(
        child: Container(
          width: Get.width * 0.85,
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Color(0xFF222222) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة أو لوغو التطبيق (اختياري)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.policy_outlined,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // العنوان
              Text(
                "سياسة الخصوصية",
                style: TextStyle(
                  color: Get.isDarkMode ? Colors.white : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // نص وصفي
              Text(
                "جاري تحميل محتوى سياسة الخصوصية، يرجى الانتظار...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Get.isDarkMode
                      ? Colors.grey[300]
                      : AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),

              // مؤشر التحميل مع نمط مخصص
              Container(
                height: 5,
                width: Get.width * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LinearProgressIndicator(
                  backgroundColor:
                      Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
    );

    // تنزيل الملف أولاً وحفظه محلياً
    try {
      final http.Response response = await http.get(Uri.parse(pdfUrl));

      // إغلاق مؤشر التحميل
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response.statusCode == 200) {
        // تخزين الملف محلياً
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath = tempDir.path;
        final String filePath = '$tempPath/privacy_policy.pdf';

        // حفظ الملف
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // التحقق من صحة الملف
        if (await _isValidPdf(file)) {
          // فتح الملف المحلي بدلاً من الرابط المباشر
          Get.to(() => PDFViewerScreen(filePath: filePath, pdfUrl: pdfUrl));
        } else {
          _openInBrowser(pdfUrl);
          CustomToast.showInfoToast(
            message: "تم فتح سياسة الخصوصية في المتصفح",
          );
        }
      } else {
        CustomToast.showErrorToast(
          message: "فشل في تحميل سياسة الخصوصية (${response.statusCode})",
        );
        _openInBrowser(pdfUrl);
      }
    } catch (e) {
      // إغلاق مؤشر التحميل
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print("خطأ: $e");
      CustomToast.showErrorToast(
        message: "حدث خطأ أثناء فتح سياسة الخصوصية",
      );
      _openInBrowser(pdfUrl);
    }
  } catch (e) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    print("خطأ: $e");
    CustomToast.showErrorToast(
      message: "حدث خطأ أثناء فتح سياسة الخصوصية",
    );

    _openInBrowser(pdfUrl);
  }
}

// التحقق مما إذا كان الملف PDF صالح
Future<bool> _isValidPdf(File file) async {
  try {
    final bytes = await file.readAsBytes();
    // التحقق من سحر PDF (PDF header magic bytes)
    if (bytes.length >= 5) {
      final header = String.fromCharCodes(bytes.sublist(0, 5));
      return header == '%PDF-';
    }
  } catch (e) {
    print("خطأ في التحقق من ملف PDF: $e");
  }
  return false;
}

// فتح الرابط في المتصفح
Future<void> _openInBrowser(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  } catch (e) {
    print("خطأ فتح الرابط في المتصفح: $e");
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String filePath;
  final String pdfUrl;

  const PDFViewerScreen(
      {Key? key, required this.filePath, required this.pdfUrl})
      : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // تأخير بسيط لضمان اكتمال بناء الواجهة قبل تحديث الحالة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // هنا يمكنك استدعاء setState بأمان
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  // دالة آمنة لتحديث حالة التحميل
  void _safeSetLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  // دالة آمنة لتحديث حالة الخطأ
  void _safeSetError(bool error) {
    if (mounted) {
      setState(() {
        _hasError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("سياسة الخصوصية"),
        centerTitle: true,
        backgroundColor: isDarkMode ? Color(0xFF222222) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () => _openInBrowser(),
            tooltip: "فتح في المتصفح",
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(
            File(widget.filePath),
            controller: _pdfViewerController,
            scrollDirection: PdfScrollDirection.vertical,
            enableDoubleTapZooming: true,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              // استخدم Future.microtask لتأخير setState حتى اكتمال البناء الحالي
              Future.microtask(() {
                _safeSetLoading(false);
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              // استخدم Future.microtask لتأخير setState حتى اكتمال البناء الحالي
              Future.microtask(() {
                _safeSetLoading(false);
                _safeSetError(true);

                print("فشل تحميل PDF: ${details.error}");
                CustomToast.showErrorToast(
                  message: "فشل في تحميل ملف سياسة الخصوصية",
                );

                // محاولة فتح الرابط في المتصفح بعد فشل التحميل
                Future.delayed(Duration(seconds: 1), () {
                  _openInBrowser();
                });
              });
            },
          ),

          // مؤشر التحميل
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // رسالة الخطأ
          if (_hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "فشل في تحميل ملف سياسة الخصوصية",
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _openInBrowser,
                      icon: Icon(Icons.open_in_browser),
                      label: Text("فتح في المتصفح"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.blueGrey : Colors.blue,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openInBrowser() async {
    final Uri uri = Uri.parse(widget.pdfUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print("خطأ فتح الرابط في المتصفح: $e");
    }
  }
}
