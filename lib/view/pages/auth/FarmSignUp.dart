// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controller/auth/FarmSignUpControlerImp.dart';
// import '../../../core/class/handlingdataview.dart';
// import '../../../core/functions/alertexitapp.dart';
// import '../../../core/functions/validinput.dart';
// import '../../../core/theme/app_colors.dart';
//
//
//
// class FarmSignUp extends StatelessWidget {
//   const FarmSignUp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Get.put(FarmSignUpControlerImp());
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: AppColors.primary,
//         elevation: 0.0,
//         title: Text(
//           'Farm Sign Up',
//           style: Theme.of(context).textTheme.headline1!.copyWith(color: AppColors.grey),
//         ),
//       ),
//       body: WillPopScope(
//         onWillPop: () async {
//           return alertExitApp();
//         },
//         child: GetBuilder<FarmSignUpControlerImp>(builder: (controller) {
//           return HandlingDataRequest(
//             statusRequest: controller.statusRequest!,
//             widget: Container(
//               child: Form(
//                 key: controller.formstate,
//                 child: ListView(
//                   children: [
//                     SizedBox(height: 20),
//                     CustomTextTitleAuth(text: "Create Your Farm Account"),
//                     SizedBox(height: 5),
//                     CustomTextBodyAuth(text: "Please enter your farm details to register."),
//                     SizedBox(height: 20),
//
//                     // زر اختيار صورة المزرعة
//                     Center(
//                       child: InkWell(
//                         onTap: () {
//                         },
//                         child: CircleAvatar(
//                           radius: 60,
//                           backgroundColor: AppColors.grey,
//                           backgroundImage: controller.farmImage != null
//                               ? FileImage(controller.farmImage!)
//                               : null,
//                           child: controller.farmImage == null
//                               ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
//                               : null,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     CustomTextFormAuth(
//                       isnumber: false,
//                       valid: (val) {
//                         return validInput(val!, 3, 30, "name");
//                       },
//                       mycontroller: controller.name,
//                       hinttext: "Enter Farm Name",
//                       iconData: Icons.person_outline,
//                       labeltext: "Farm Name",
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextFormAuth(
//                       isnumber: false,
//                       valid: (val){
//                         return validInput(val! , 5 , 100 ,"email" );
//                       },
//                       mycontroller: controller.email,
//                       hinttext: "Enter Your Email",
//                       iconData: Icons.email_outlined,
//                       labeltext: "Email",
//                       // mycontroller: ,
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextFormAuth(
//                       isnumber: false,
//                       valid: (val) {
//                         return validInput(val!, 3, 100, "address");
//                       },
//                       mycontroller: controller.address,
//                       hinttext: "Enter Farm Address",
//                       iconData: Icons.location_on_outlined,
//                       labeltext: "Address",
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextFormAuth(
//                       isnumber: true,
//                       valid: (val) {
//                         return validInput(val!, 9, 11, "phone");
//                       },
//                       mycontroller: controller.phone,
//                       hinttext: "Enter Phone",
//                       iconData: Icons.phone_outlined,
//                       labeltext: "Phone",
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextFormAuth(
//                       isnumber: false,
//                       valid: (val) {
//                         return validInput(val!, 5, 30, "description");
//                       },
//                       mycontroller: controller.description,
//                       hinttext: "Enter Farm Description",
//                       iconData: Icons.description_outlined,
//                       labeltext: "Description",
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextFormAuth(
//                       isnumber: false,
//                       valid: (val) {
//                         return validInput(val!, 5, 30, "password");
//                       },
//                       mycontroller: controller.password,
//                       hinttext: "Enter Password",
//                       iconData: Icons.lock_outline,
//                       labeltext: "Password",
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextFormAuth(
//                       isnumber: true,
//                       valid: (val) {
//                         return validInput(val!, 1, 10, "price");
//                       },
//                       mycontroller: controller.price,
//                       hinttext: "Enter Price",
//                       iconData: Icons.attach_money_outlined,
//                       labeltext: "Price",
//                     ),
//                     SizedBox(height: 30),
//                     CustomButtomAuth(
//                       text: "Sign Up",
//                       onPressed: () async {
//                         await controller.signUp(context);
//                       },
//                     ),
//                     SizedBox(height: 10),
//                     CustomButtomAuth(
//                       text: "Login",
//                       onPressed: () async {
//                         Get.offNamed("");
//                       },
//                     ),
//                     SizedBox(height: 15),
//
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
