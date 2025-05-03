import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/services/ProfileApiService.dart';
import 'package:radar/data/model/UserProfile.dart';
import 'package:radar/core/services/services.dart';
import 'package:radar/core/constant/routes.dart';
import 'package:radar/view/components/ui/CustomDialog.dart';
import 'package:radar/view/components/ui/CustomToast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ProfileController extends GetxController {
  final Rx<ProfileResponseModel?> profile = Rx<ProfileResponseModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // متغيرات خاصة بتعديل الملف الشخصي
  var isEditingName = false.obs;
  var isUploadingPhoto = false.obs;
  var nameController = TextEditingController().obs;
  final ImagePicker _imagePicker = ImagePicker();
  var selectedImage = Rx<File?>(null);

  var isProcessingDelete = false.obs;
  var passwordController = TextEditingController().obs;

  final ProfileApiService _apiService = ProfileApiService();
  final MyServices _services = Get.find<MyServices>();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  void showDeleteAccountConfirmation() {
    CustomDialog.showConfirmation(
      title: 'حذف الحساب',
      message:
          'هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟ لا يمكن التراجع عن هذه العملية.',
      confirmText: 'متابعة',
      cancelText: 'إلغاء',
      onConfirm: () {
        // عرض مربع حوار إدخال كلمة المرور
        showPasswordConfirmationDialog();
      },
    );
  }

  void showPasswordConfirmationDialog() {
    // إعادة تعيين قيمة حقل كلمة المرور
    passwordController.value.text = '';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'تأكيد حذف الحساب',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'يرجى إدخال كلمة المرور لتأكيد حذف حسابك',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Obx(() => TextField(
                    controller: passwordController.value,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      errorText: passwordController.value.text.isEmpty &&
                              isProcessingDelete.value
                          ? 'يرجى إدخال كلمة المرور'
                          : null,
                    ),
                    style: TextStyle(color: Colors.white),
                  )),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Obx(() => ElevatedButton(
                        onPressed: isProcessingDelete.value
                            ? null
                            : () => deleteAccount(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isProcessingDelete.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'حذف الحساب',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> deleteAccount() async {
    if (passwordController.value.text.isEmpty) {
      isProcessingDelete.value = true;
      Future.delayed(Duration(milliseconds: 500), () {
        isProcessingDelete.value = false;
      });
      return;
    }

    isProcessingDelete.value = true;

    try {
      final result =
          await _apiService.deleteAccount(passwordController.value.text);

      if (result) {
        Get.back(); // إغلاق مربع الحوار

        // تسجيل الخروج وحذف البيانات المحلية
        await _services.saveData("loggedin", "0");
        await _services.removeToken();

        // عرض رسالة نجاح قبل التوجيه
        CustomToast.showSuccessToast(message: "تم حذف حسابك بنجاح");

        // توجيه المستخدم إلى صفحة تسجيل الدخول
        Get.offAllNamed(AppRoute.login);
      } else {
        Get.back(); // إغلاق مربع الحوار
        CustomToast.showErrorToast(
            message: "فشل في حذف الحساب، يرجى التحقق من كلمة المرور");
      }
    } catch (e) {
      Get.back(); // إغلاق مربع الحوار
      CustomToast.showErrorToast(
          message: "فشل في حذف الحساب، الرجاء المحاولة مرة أخرى لاحقاً");
      print("خطأ في حذف الحساب: $e");
    } finally {
      isProcessingDelete.value = false;
    }
  }

  // دالة لعرض تأكيد تسجيل الخروج
  void showLogoutConfirmation() {
    CustomDialog.showLogout(onConfirm: () {
      logout();
      Get.offAllNamed('/login');
    });
  }

  void fetchUserProfile() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final ProfileResponseModel? data = await _apiService.getUserProfileData();

      if (data != null) {
        profile.value = data;
      } else {
        throw Exception('بيانات المستخدم غير متوفرة');
      }
    } catch (e) {
      hasError.value = true;
      // تحسين رسائل الخطأ للمستخدم
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage.value = 'لا يمكن الاتصال بالإنترنت';
      } else if (e.toString().contains('Timeout')) {
        errorMessage.value = 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
      } else {
        errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
      }
      print("خطأ في جلب بيانات المستخدم: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void refreshProfile() {
    fetchUserProfile();
  }

  // تسجيل الخروج - تم تحديثها للحفاظ على الخدمات
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // تحديث حالة تسجيل الدخول إلى "0"
      await _services.saveData("loggedin", "0");

      // حذف بيانات المستخدم مع الحفاظ على بعض البيانات الأساسية
      // حذف التوكن فقط بدلاً من حذف كل البيانات
      await _services.removeToken();

      // توجيه المستخدم إلى صفحة تسجيل الدخول
      Get.offAllNamed(AppRoute.login);
    } catch (e) {
      print("Error during logout: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // أساليب مساعدة للحصول على البيانات
  String getGenderText() {
    if (profile.value == null) return '';
    switch (profile.value!.user.gender) {
      case 'MALE':
        return 'ذكر';
      case 'FEMALE':
        return 'أنثى';
      default:
        return 'غير محدد';
    }
  }

  String getFormattedBirthDate() {
    if (profile.value == null) return '';
    final birthDate = profile.value!.user.dateOfBirth;
    return '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
  }

  int getAge() {
    if (profile.value == null) return 0;
    final birthDate = profile.value!.user.dateOfBirth;
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void updateUserPoints(int newPointsValue) {
    if (profile.value != null) {
      // Create a new user object with updated points
      profile.value!.user.points = newPointsValue;
      update();
    }
  }

  // -------------- وظائف تعديل الملف الشخصي --------------

  // طريقة اختيار صورة جديدة
  // طريقة اختيار صورة جديدة
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        // تحديد تنسيق الصورة بشكل صريح
        preferredCameraDevice: CameraDevice.rear,
        // تحديد التنسيق المطلوب للصورة
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        // التحقق من امتداد الملف
        final String ext = image.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
          // إذا كان الامتداد غير مدعوم، حاول تحويل الصورة
          final File originalFile = File(image.path);
          final Directory tempDir = await getTemporaryDirectory();
          final String targetPath =
              '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // استخدام مكتبة image لتحويل الصورة إلى JPG
          final List<int> imageBytes = await originalFile.readAsBytes();
          final img.Image? decodedImage =
              img.decodeImage(Uint8List.fromList(imageBytes));

          if (decodedImage != null) {
            final List<int> jpgBytes = img.encodeJpg(decodedImage, quality: 85);
            await File(targetPath).writeAsBytes(jpgBytes);

            selectedImage.value = File(targetPath);
          } else {
            throw Exception("فشل في تحويل الصورة");
          }
        } else {
          // الامتداد مدعوم، استخدم الملف مباشرة
          selectedImage.value = File(image.path);
        }

        // تحديث الصورة للسيرفر
        uploadProfilePhoto();
      }
    } catch (e) {
      print('Error picking image: $e');
      CustomToast.showErrorToast(message: "فشل في اختيار الصورة");
    }
  }

  // طريقة لعرض خيارات اختيار الصورة
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر صورة الملف الشخصي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title:
                    Text('التقاط صورة', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('اختيار من المعرض',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                  pickImage(ImageSource.gallery);
                },
              ),
              if (profile.value?.user.profilePhoto != null &&
                  profile.value!.user.profilePhoto!.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('حذف الصورة الحالية',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    removeProfilePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // تحميل الصورة إلى السيرفر
  Future<void> uploadProfilePhoto() async {
    if (selectedImage.value == null || profile.value == null) return;

    isUploadingPhoto.value = true;

    try {
      final userId = profile.value!.user.id;
      final result = await _apiService.updateProfilePicture(
          userId, selectedImage.value!.path);

      if (result) {
        CustomToast.showSuccessToast(
            message: "تم تحديث صورة الملف الشخصي بنجاح");
        // تحديث البروفايل بعد التحميل
        fetchUserProfile();
      } else {
        throw Exception("فشل في تحديث الصورة");
      }
    } catch (e) {
      print('Error uploading profile photo: $e');
      CustomToast.showErrorToast(message: "فشل في تحديث صورة الملف الشخصي");
    } finally {
      isUploadingPhoto.value = false;
      selectedImage.value = null;
    }
  }

  // حذف صورة البروفايل
  Future<void> removeProfilePhoto() async {
    if (profile.value == null) return;

    try {
      final userId = profile.value!.user.id;

      // ارسال طلب لحذف الصورة
      Map<String, dynamic> data = {'profilePhoto': null};

      final result = await _apiService.updateUserProfile(userId, data);

      if (result) {
        CustomToast.showSuccessToast(message: "تم حذف صورة الملف الشخصي");
        // تحديث البروفايل
        fetchUserProfile();
      } else {
        throw Exception("فشل في حذف الصورة");
      }
    } catch (e) {
      print('Error removing profile photo: $e');
      CustomToast.showErrorToast(message: "فشل في حذف صورة الملف الشخصي");
    }
  }

  // بدء تعديل الاسم
  void startEditingName() {
    if (profile.value != null) {
      nameController.value.text = profile.value!.user.name;
      isEditingName.value = true;
    }
  }

  // حفظ الاسم الجديد
  Future<void> saveNewName() async {
    if (nameController.value.text.trim().isEmpty) {
      CustomToast.showErrorToast(message: "الاسم لا يمكن أن يكون فارغاً");
      return;
    }

    if (profile.value == null) return;

    try {
      final userId = profile.value!.user.id;

      // تحديث الاسم عبر API
      Map<String, dynamic> data = {'name': nameController.value.text.trim()};

      final result = await _apiService.updateUserProfile(userId, data);

      if (result) {
        CustomToast.showSuccessToast(message: "تم تحديث الاسم بنجاح");
        // تحديث البروفايل
        fetchUserProfile();
      } else {
        throw Exception("فشل في تحديث الاسم");
      }
    } catch (e) {
      print('Error updating name: $e');
      CustomToast.showErrorToast(message: "فشل في تحديث الاسم");
    } finally {
      isEditingName.value = false;
    }
  }

  // إلغاء التعديل
  void cancelNameEdit() {
    isEditingName.value = false;
  }

  @override
  void onClose() {
    nameController.value.dispose();
    passwordController.value.dispose();
    super.onClose();
  }
}
