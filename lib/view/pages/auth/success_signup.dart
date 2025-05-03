// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
//
// import '../../../controller/auth/successsignup_controller.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../components/auth/custombuttonauth.dart';
//
//
//
// class SuccessSignUp extends StatelessWidget {
//   const SuccessSignUp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     SuccessSignUpControllerImp controller = Get.put(SuccessSignUpControllerImp()) ;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: AppColors.primary,
//         elevation: 0.0,
//         title: Text("Success",
//             style: Theme.of(context)
//                 .textTheme
//                 .headline1!
//                 .copyWith(color: AppColors.grey)),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(15),
//         child: Column(children: [
//           const Center(
//               child: Icon(
//                 Icons.check_circle_outline,
//                 size: 200,
//                 color: AppColors.black,
//               )),
//           Text("congratulations" ,
//               style: Theme.of(context)
//                   .textTheme
//                   .headline1!
//                   .copyWith(fontSize: 30)),
//           Text("successfully registered"),
//           const Spacer(),
//           SizedBox(
//             width: double.infinity,
//             child: CustomButtomAuth(
//                 text: "Go To Login",
//                 onPressed: () {
//                    controller.goToPageLogin();
//                 }),
//           ),
//           const SizedBox(height: 30)
//         ]),
//       ),
//     );
//   }
// }