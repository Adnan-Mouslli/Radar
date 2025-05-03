
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:radar/core/class/statusrequest.dart';

// import '../constant/imagasset.dart';


// class HandlingDataView extends StatelessWidget {
//   final StatusRequest statusRequest;
//   final Widget widget;
//   const HandlingDataView(
//       {Key? key, required this.statusRequest, required this.widget})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return statusRequest == StatusRequest.loading
//         ? Center(
//             child: Container()
//             // Lottie.asset(AppImageAsset.loading_1, width: 250, height: 250)

//             )
//         : statusRequest == StatusRequest.offlinefailure
//             ? Center(
//                 child:Container())
//                 // Lottie.asset(AppImageAsset.noInternet,
//                 //     width: 250, height: 250))
//             : statusRequest == StatusRequest.serverfailure
//                 ? Container()
//               // Center(child: Lottie.asset(AppImageAsset.noInternet,
//               //           width: 250, height: 250))
//                 : statusRequest == StatusRequest.failure
//                     ? Container()
//                       // Center(
//                       //   child: Lottie.asset(AppImageAsset.NotData,
//                       //       width: 250, height: 250, repeat: true))
//                     : widget;
//   }
// }

// class HandlingDataRequest extends StatelessWidget {
//   final StatusRequest statusRequest;
//   final Widget widget;
//   const HandlingDataRequest(
//       {Key? key, required this.statusRequest, required this.widget})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return statusRequest == StatusRequest.loading
//         ? Center(
//             child: Lottie.asset(AppImageAsset.loading_2, width: 250, height: 250))
//         : statusRequest == StatusRequest.offlinefailure
//             ? Center(
//                 child: Lottie.asset(AppImageAsset.noInternet,
//                     width: 250, height: 250))
//             : statusRequest == StatusRequest.serverfailure
//                 ? Center(
//                     child: Lottie.asset(AppImageAsset.noInternet,
//                         width: 250, height: 250))
//                 : widget;
//   }
// }
