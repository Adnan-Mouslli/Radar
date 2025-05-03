import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/services/interestsService.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/controller/profile/ProfileController.dart';
import 'package:radar/view/components/ui/CustomDialog.dart';
import 'package:radar/view/components/ui/CustomToast.dart';

class InterestsManagementController extends GetxController {
  final InterestsApiService _interestsApiService = InterestsApiService();
  final ProfileController _profileController = Get.find<ProfileController>();

  // قائمة جميع الاهتمامات المتاحة
  final RxList<Map<String, dynamic>> allInterests =
      <Map<String, dynamic>>[].obs;

  // قائمة الاهتمامات المحددة حالياً (للعرض والتعديل المحلي)
  final RxList<String> selectedInterestIds = <String>[].obs;

  // قائمة معرفات الاهتمامات الأصلية للمستخدم
  final RxList<String> originalInterestIds = <String>[].obs;

  // حالات الواجهة
  final RxBool isLoadingInterests = false.obs; // تحميل الاهتمامات
  final RxBool isSaving = false.obs; // حفظ التغييرات

  // حالة البحث
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> filteredInterests =
      <Map<String, dynamic>>[].obs;

  // متغير للتحكم في عرض النجاح أو الفشل
  final RxBool showSuccessMessage = false.obs;
  final RxBool showErrorMessage = false.obs;
  final RxString resultMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    // جلب الاهتمامات المتاحة وتهيئة اهتمامات المستخدم بالتوازي
    await Future.wait([
      fetchAllInterests(),
      initializeUserInterests(),
    ]);
  }

  // جلب جميع الاهتمامات المتاحة
  Future<void> fetchAllInterests() async {
    try {
      isLoadingInterests.value = true;
      final interests = await _interestsApiService.getAllInterestsList();
      allInterests.value = interests;
      applySearchFilter(); // تطبيق تصفية البحث المبدئية
    } catch (e) {
      print("Error fetching interests: $e");
      // استخدام التوست المخصص بدلاً من Get.snackbar
      CustomToast.showErrorToast(
        message: 'حدث خطأ أثناء جلب الاهتمامات',
      );
    } finally {
      isLoadingInterests.value = false;
    }
  }

  // تهيئة اهتمامات المستخدم الحالية
  Future<void> initializeUserInterests() async {
    if (_profileController.profile.value != null) {
      // استخراج معرفات الاهتمامات من نموذج المستخدم
      final userInterestIds = _profileController.profile.value!.interests
          .map((interest) => interest.id)
          .toList();

      // تهيئة القوائم
      selectedInterestIds.value = List<String>.from(userInterestIds);
      originalInterestIds.value = List<String>.from(userInterestIds);
    }
  }

  // وظيفة لتطبيق تصفية البحث
  void applySearchFilter() {
    if (searchQuery.isEmpty) {
      filteredInterests.value = List<Map<String, dynamic>>.from(allInterests);
    } else {
      filteredInterests.value = allInterests
          .where((interest) => (interest['name'] as String)
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }
  }

  // وظيفة تغيير قيمة البحث
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applySearchFilter();
  }

  // تحديد ما إذا كان الاهتمام محدداً
  bool isInterestSelected(String interestId) {
    return selectedInterestIds.contains(interestId);
  }

  // إضافة/حذف اهتمام من القائمة المحددة (محلياً فقط - بدون API)
  void toggleInterest(String interestId) {
    if (isInterestSelected(interestId)) {
      // التحقق من أن إزالة الاهتمام لن تترك القائمة فارغة
      if (selectedInterestIds.length > 1) {
        selectedInterestIds.remove(interestId);
      } else {
        // تنبيه المستخدم أنه يجب اختيار اهتمام واحد على الأقل
        CustomToast.showWarningToast(
          message: 'يجب اختيار اهتمام واحد على الأقل',
        );
      }
    } else {
      selectedInterestIds.add(interestId);
    }
  }

  // الحصول على اسم الاهتمام من المعرف
  String getInterestName(String interestId) {
    final interest =
        allInterests.firstWhereOrNull((element) => element['id'] == interestId);
    return interest != null ? interest['name'] : '';
  }

  // الحصول على قائمة كائنات الاهتمامات المحددة
  List<Map<String, dynamic>> get selectedInterests {
    return selectedInterestIds.map((id) {
      final interest =
          allInterests.firstWhereOrNull((element) => element['id'] == id);
      return interest ?? {'id': id, 'name': getInterestName(id)};
    }).toList();
  }

  // حساب هل هناك تغييرات لم يتم حفظها
  bool get hasUnsavedChanges {
    // المقارنة بين القائمتين
    if (selectedInterestIds.length != originalInterestIds.length) {
      return true;
    }

    // التحقق من وجود عناصر مضافة أو محذوفة
    for (var id in selectedInterestIds) {
      if (!originalInterestIds.contains(id)) {
        return true;
      }
    }

    for (var id in originalInterestIds) {
      if (!selectedInterestIds.contains(id)) {
        return true;
      }
    }

    return false;
  }

  // حفظ التغييرات في الاهتمامات
  Future<void> saveInterests() async {
    // إذا لم يكن هناك تغييرات، نعود مباشرة
    if (!hasUnsavedChanges) {
      Get.back();
      return;
    }

    // التحقق من وجود اهتمام واحد على الأقل
    if (selectedInterestIds.isEmpty) {
      CustomToast.showWarningToast(
        message: 'يجب اختيار اهتمام واحد على الأقل',
      );
      return;
    }

    try {
      isSaving.value = true;

      // الاهتمامات التي يجب إضافتها (موجودة في القائمة المحددة وغير موجودة في الأصلية)
      final interestsToAdd = selectedInterestIds
          .where((id) => !originalInterestIds.contains(id))
          .toList();

      // الاهتمامات التي يجب حذفها (موجودة في الأصلية وغير موجودة في المحددة)
      final interestsToRemove = originalInterestIds
          .where((id) => !selectedInterestIds.contains(id))
          .toList();

      bool success = true;

      // إضافة الاهتمامات الجديدة إذا وجدت
      if (interestsToAdd.isNotEmpty) {
        final addResult =
            await _interestsApiService.addUserInterests(interestsToAdd);
        if (!addResult) {
          success = false;
        }
      }

      // حذف الاهتمامات غير المطلوبة إذا وجدت
      if (interestsToRemove.isNotEmpty) {
        final removeResult =
            await _interestsApiService.removeUserInterests(interestsToRemove);
        if (!removeResult) {
          success = false;
        }
      }

      if (success) {
        // تحديث نموذج البيانات في ProfileController
        _profileController.refreshProfile();

        // تحديث القائمة الأصلية بعد الحفظ بنجاح
        originalInterestIds.value = List<String>.from(selectedInterestIds);

        CustomToast.showSuccessToast(
          message: 'تم حفظ الاهتمامات بنجاح',
        );

        // إغلاق الشاشة بعد فترة قصيرة
        Future.delayed(Duration(milliseconds: 1500), () {
          Get.back();
        });
      } else {
        CustomToast.showErrorToast(
          message: 'فشل في حفظ الاهتمامات، يرجى المحاولة مرة أخرى',
        );
      }
    } catch (e) {
      print("Error saving interests: $e");
      CustomToast.showErrorToast(
        message: 'حدث خطأ أثناء حفظ الاهتمامات',
      );
    } finally {
      isSaving.value = false;
    }
  }

  // التحقق قبل مغادرة الشاشة إذا كان هناك تغييرات غير محفوظة
  Future<bool> onWillPopExplained() async {
    if (hasUnsavedChanges) {
      // إنشاء Completer لتحويل استدعاء الدالة إلى Future
      // يمكن أن ينتظر الكود حتى يتم إغلاق الحوار واتخاذ القرار
      final completer = Completer<bool>();

      CustomDialog.show(
        title: 'هل تريد مغادرة الصفحة؟',
        message: 'لديك تغييرات غير محفوظة. هل تريد المغادرة بدون حفظ؟',
        cancelText: 'البقاء',
        confirmText: 'مغادرة',
        icon: Icons.exit_to_app,
        iconColor: AppColors.primary,
        confirmButtonColor: AppColors.primary,

        // عند الضغط على "مغادرة"، نكمل Completer بقيمة true
        onConfirm: () {
          completer.complete(true); // السماح بالمغادرة
        },

        // عند الضغط على "البقاء"، نكمل Completer بقيمة false
        onCancel: () {
          completer.complete(false); // البقاء في الصفحة
        },
      );

      // انتظار نتيجة الحوار (true للمغادرة، false للبقاء)
      return await completer.future;
    }

    // بقية الكود كما هو...
    return true;
  }
}
