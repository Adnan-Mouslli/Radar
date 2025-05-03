import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/theme/app_colors.dart';

bool alertExitApp() {
  Get.defaultDialog(
      title: "تنبيه",
      titleStyle: const TextStyle(
          color: AppColors.primary, fontWeight: FontWeight.bold),
      middleText: "هل تريد الخروج من التطبيق",
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.primary)),
            onPressed: () {
              exit(0);
            },
            child: const Text("تاكيد")),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.primary)),
            onPressed: () {
              Get.back();
            },
            child: const Text("الغاء"))
      ]);
  return true;
}
