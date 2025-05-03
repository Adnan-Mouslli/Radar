// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:radar/controller/auth/ForgetPasswordController.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_fonts.dart';
// import '../../components/auth/CustomButton.dart';
// import '../../components/auth/CustomTextFormField.dart';

// class ResetPasswordScreen extends StatelessWidget {
//   const ResetPasswordScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ForgetPasswordController());
//     final screenSize = MediaQuery.of(context).size;

//     // تحديد الألوان بناءً على وضع السمة الحالي
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     // ألوان متوافقة مع الوضع الداكن والفاتح
//     final backgroundColor = isDarkMode ? Color(0xFF1A1A1A) : AppColors.white;
//     final textPrimaryColor = isDarkMode ? Colors.white : AppColors.textPrimary;
//     final textSecondaryColor = isDarkMode ? Colors.grey[400] : AppColors.textSecondary;
//     final cardColor = isDarkMode ? Color(0xFF222222) : Colors.white;

//     // ألوان العلامة التجارية ثابتة بغض النظر عن وضع السمة
//     final primaryColor = AppColors.primary;
//     final primaryLightColor = AppColors.primaryLight;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: textPrimaryColor,
//             size: 20,
//           ),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           'تغيير كلمة المرور',
//           style: TextStyle(
//             color: textPrimaryColor,
//             fontSize: 18,
//             fontWeight: AppFonts.semiBold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Directionality(
//             textDirection: TextDirection.rtl,
//             child: Form(
//               key: controller.resetFormKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(height: screenSize.height * 0.05),

//                   // أيقونة القفل الجديد
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: LinearGradient(
//                         colors: [
//                           primaryColor.withOpacity(0.1),
//                           primaryLightColor.withOpacity(0.05),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.lock_reset_rounded,
//                         color: primaryColor,
//                         size: 60,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),
                  
//                   // بطاقة تغيير كلمة المرور
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: cardColor,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: isDarkMode 
//                         ? [] 
//                         : [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 15,
//                               offset: const Offset(0, 5),
//                             ),
//                           ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // عنوان وشرح
//                           Text(
//                             "كلمة مرور جديدة",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: AppFonts.bold,
//                               color: textPrimaryColor,
//                             ),
//                           ),
                          
//                           const SizedBox(height: 10),
                          
//                           Text(
//                             "قم بإنشاء كلمة مرور قوية للحفاظ على أمان حسابك",
//                             style: TextStyle(
//                               color: textSecondaryColor,
//                               fontSize: 14,
//                               height: 1.4,
//                             ),
//                           ),
                          
//                           const SizedBox(height: 30),

//                           // كلمة المرور الجديدة
//                           GetBuilder<ForgetPasswordController>(
//                             builder: (controller) => CustomTextFormField(
//                               controller: controller.newPasswordController,
//                               label: "كلمة المرور الجديدة",
//                               hintText: "******",
//                               prefixIcon: Icons.lock_outline,
//                               isPassword: controller.isPasswordHidden,
//                               isDarkMode: isDarkMode,
//                               onPasswordToggle: controller.togglePasswordVisibility,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'الرجاء إدخال كلمة المرور';
//                                 }
//                                 if (value.length < 8) {
//                                   return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
//                                 }
//                                 if (!value.contains(RegExp(r'[A-Z]'))) {
//                                   return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
//                                 }
//                                 if (!value.contains(RegExp(r'[a-z]'))) {
//                                   return 'يجب أن تحتوي على حرف صغير واحد على الأقل';
//                                 }
//                                 if (!value.contains(RegExp(r'[0-9]'))) {
//                                   return 'يجب أن تحتوي على رقم واحد على الأقل';
//                                 }
//                                 if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
//                                   return 'يجب أن تحتوي على رمز خاص واحد على الأقل';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),

//                           const SizedBox(height: 20),

//                           // تأكيد كلمة المرور
//                           GetBuilder<ForgetPasswordController>(
//                             builder: (controller) => CustomTextFormField(
//                               controller: controller.confirmPasswordController,
//                               label: "تأكيد كلمة المرور",
//                               hintText: "******",
//                               prefixIcon: Icons.lock_outline,
//                               isPassword: controller.isPasswordHidden,
//                               isDarkMode: isDarkMode,
//                               onPasswordToggle: controller.togglePasswordVisibility,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'الرجاء تأكيد كلمة المرور';
//                                 }
//                                 if (value != controller.newPasswordController.text) {
//                                   return 'كلمات المرور غير متطابقة';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),

//                           // مؤشر قوة كلمة المرور
//                           const SizedBox(height: 20),
//                           GetBuilder<ForgetPasswordController>(
//                             builder: (controller) {
//                               final strength = controller.passwordStrength;
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         "قوة كلمة المرور: ",
//                                         style: TextStyle(
//                                           color: textSecondaryColor,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       Text(
//                                         _getPasswordStrengthText(strength),
//                                         style: TextStyle(
//                                           color: _getPasswordStrengthColor(strength),
//                                           fontWeight: AppFonts.semiBold,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   LinearProgressIndicator(
//                                     value: strength / 4,
//                                     backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       _getPasswordStrengthColor(strength),
//                                     ),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),

//                           const SizedBox(height: 30),

//                           // زر تأكيد
//                           GetBuilder<ForgetPasswordController>(
//                             builder: (controller) => CustomButton(
//                               text: "تغيير كلمة المرور",
//                               isLoading: controller.isLoading,
//                               onPressed: controller.resetPassword,
//                               useGradient: true,
//                               height: 55,
//                               borderRadius: 15,
//                               elevation: 3,
//                               fontWeight: AppFonts.bold,
//                               fontSize: 17,
//                               prefixIcon: Icons.save_rounded,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _getPasswordStrengthText(int strength) {
//     switch (strength) {
//       case 0:
//         return "ضعيفة جداً";
//       case 1:
//         return "ضعيفة";
//       case 2:
//         return "متوسطة";
//       case 3:
//         return "قوية";
//       case 4:
//         return "قوية جداً";
//       default:
//         return "ضعيفة";
//     }
//   }

//   Color _getPasswordStrengthColor(int strength) {
//     switch (strength) {
//       case 0:
//         return Colors.red;
//       case 1:
//         return Colors.orange;
//       case 2:
//         return Colors.yellow;
//       case 3:
//         return Colors.lightGreen;
//       case 4:
//         return Colors.green;
//       default:
//         return Colors.red;
//     }
//   }
// }