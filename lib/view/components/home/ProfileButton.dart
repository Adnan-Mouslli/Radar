import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/view/pages/profile/ProfileScreen.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top +
          10, // لضمان ظهوره بعد نتوء الشاشة
      right: 16,
      child: GestureDetector(
        onTap: () {
          Get.to(() => ProfileScreen());
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.7),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
