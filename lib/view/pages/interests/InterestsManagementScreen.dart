import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/interests/InterestsManagementController%20.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';

class InterestsManagementScreen extends StatelessWidget {
  final InterestsManagementController controller =
      Get.put(InterestsManagementController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.onWillPopExplained,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'إدارة الاهتمامات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: AppFonts.bold,
            ),
          ),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            Obx(
              () => controller.isSaving.value
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Obx(
                      () => AnimatedOpacity(
                        opacity: controller.hasUnsavedChanges ? 1.0 : 0.5,
                        duration: Duration(milliseconds: 200),
                        child: IconButton(
                          icon: Icon(
                            Icons.check,
                            color: AppColors.primary,
                          ),
                          onPressed: controller.hasUnsavedChanges
                              ? controller.saveInterests
                              : null,
                          tooltip: 'حفظ التغييرات',
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoadingInterests.value &&
              controller.allInterests.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return Column(
            children: [
              // المؤشر الرسومي للاهتمامات المختارة
              _buildSelectedInterestsCounter(),

              // حقل البحث
              _buildSearchField(),

              // عرض رسالة النجاح أو الفشل
              _buildResultMessage(),

              // قائمة الاهتمامات
              Expanded(
                child: _buildInterestsList(),
              ),

              // زر الحفظ السفلي
              // _buildSaveButton(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSelectedInterestsCounter() {
    return Obx(() {
      int count = controller.selectedInterestIds.length;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bookmark,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: 8),
            Row(
              children: [
                Text(
                  'تم اختيار ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: AppFonts.medium,
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: AppFonts.bold,
                  ),
                ),
                Text(
                  ' من الاهتمامات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ],
            ),

            Spacer(),
            // إضافة مؤشر للتغييرات غير المحفوظة
            Obx(
              () => controller.hasUnsavedChanges
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'تغييرات غير محفوظة',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: AppFonts.medium,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'بحث عن اهتمامات...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
        ),
        onChanged: controller.updateSearchQuery,
      ),
    );
  }

  Widget _buildResultMessage() {
    return Obx(() {
      if (controller.showSuccessMessage.value) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.resultMessage.value,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      } else if (controller.showErrorMessage.value) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.red.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.resultMessage.value,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  Widget _buildInterestsList() {
    return Obx(() {
      final interests = controller.filteredInterests;

      if (interests.isEmpty) {
        if (controller.searchQuery.isNotEmpty) {
          return Center(
            child: Text(
              'لا توجد نتائج مطابقة للبحث',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          );
        } else {
          return Center(
            child: Text(
              'لا توجد اهتمامات متاحة',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          );
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: interests.length,
          itemBuilder: (context, index) {
            final interest = interests[index];
            final interestId = interest['id'] as String;

            return Obx(() {
              final isSelected = controller.isInterestSelected(interestId);

              return InkWell(
                onTap: () => controller.toggleInterest(interestId),
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          interest['name'],
                          style: TextStyle(
                            color:
                                isSelected ? AppColors.primary : Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? AppFonts.semiBold
                                : AppFonts.regular,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }

  Widget _buildSaveButton() {
    return Obx(() {
      bool hasChanges = controller.hasUnsavedChanges;

      return AnimatedOpacity(
        opacity: hasChanges ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: hasChanges ? 70 : 0,
          padding: EdgeInsets.symmetric(
              horizontal: 16, vertical: hasChanges ? 12 : 0),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: hasChanges
              ? ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveInterests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 46),
                  ),
                  child: controller.isSaving.value
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'حفظ التغييرات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                )
              : null,
        ),
      );
    });
  }
}

final InterestsManagementController controller =
    Get.put(InterestsManagementController());

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text(
        'إدارة الاهتمامات',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: AppFonts.bold,
        ),
      ),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              Icons.check,
              color: AppColors.primary,
            ),
            onPressed: controller.saveInterests,
            tooltip: 'حفظ التغييرات',
          ),
        ),
      ],
    ),
    body: Obx(() {
      if (controller.isLoadingInterests.value &&
          controller.allInterests.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      }

      return Column(
        children: [
          // المؤشر الرسومي للاهتمامات المختارة
          _buildSelectedInterestsCounter(),

          _buildInstructionBanner(),

          // حقل البحث
          _buildSearchField(),

          // عرض رسالة النجاح أو الفشل
          _buildResultMessage(),

          // قائمة الاهتمامات
          Expanded(
            child: _buildInterestsList(),
          ),
        ],
      );
    }),
  );
}

Widget _buildInstructionBanner() {
  return Container(
    margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.amber.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.amber.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.info_outline,
          color: Colors.amber,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'يجب اختيار اهتمام واحد على الأقل من القائمة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: AppFonts.medium,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSelectedInterestsCounter() {
  return Obx(() {
    int count = controller.selectedInterests.length;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bookmark,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'تم اختيار $count من الاهتمامات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: AppFonts.medium,
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildSearchField() {
  return Container(
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: TextField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'بحث عن اهتمامات...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        border: InputBorder.none,
        icon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
      ),
      onChanged: controller.updateSearchQuery,
    ),
  );
}

Widget _buildResultMessage() {
  return Obx(() {
    if (controller.showSuccessMessage.value) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.resultMessage.value,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else if (controller.showErrorMessage.value) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.resultMessage.value,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  });
}

Widget _buildInterestsList() {
  return Obx(() {
    final interests = controller.filteredInterests;

    if (interests.isEmpty) {
      if (controller.searchQuery.isNotEmpty) {
        return Center(
          child: Text(
            'لا توجد نتائج مطابقة للبحث',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        );
      } else {
        return Center(
          child: Text(
            'لا توجد اهتمامات متاحة',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: interests.length,
        itemBuilder: (context, index) {
          final interest = interests[index];
          final interestId = interest['id'] as String;
          final isSelected = controller.isInterestSelected(interestId);

          return GestureDetector(
            onTap: () => controller.toggleInterest(interest['id'] as String),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      interest['name'],
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.white,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? AppFonts.semiBold : AppFonts.regular,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  });
}
