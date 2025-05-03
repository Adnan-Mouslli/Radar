import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:radar/controller/auth/ForgetPasswordController.dart';
import 'package:radar/view/pages/Splash/SplashScreen.dart';
import 'package:radar/view/pages/auth/ForgetPasswordScreen.dart';
import 'package:radar/view/pages/auth/OtpVerificationCodeScreen.dart';
import 'package:radar/view/pages/auth/OtpVerificationScreen.dart';

import 'package:radar/view/pages/auth/login.dart';
import 'package:radar/view/pages/auth/signUp.dart';
import 'package:radar/view/pages/google_play/ForceUpdateScreen.dart';

import 'package:radar/view/pages/home/HomeScreen.dart';
import 'package:radar/view/pages/home/MainLayout.dart';
import 'package:radar/view/pages/home/MarketScreen.dart';
import 'package:radar/view/pages/home/ReelsScreen.dart';
import 'package:radar/view/pages/interests/InterestsManagementScreen.dart';
import 'package:radar/view/pages/onBoarding/OnBoarding.dart';
import 'package:radar/view/pages/profile/ProfileScreen.dart';
import 'core/constant/routes.dart';

List<GetPage<dynamic>>? routes = [
  // GetPage(
  //     name: "/",
  //     page: () => const OnBoarding(),
  //     middlewares: [MyMiddleWare()]
  // ),


  GetPage(
    name: "/",
    page: () => SplashScreen(),
  ),

  GetPage(name: AppRoute.login, page: () => const Login()),
  GetPage(
    name: AppRoute.signup,
    page: () => SignUpScreen(),
  ),

  // GetPage(name: AppRoute.successSignUp, page: () => const SuccessSignUp()),
  GetPage(name: AppRoute.onBoarding, page: () => const OnBoarding()),
  GetPage(name: AppRoute.homePage, page: () => ReelsScreen()),

  GetPage(
    name: AppRoute.main,
    page: () => MainLayout(),
  ),
  GetPage(
    name: AppRoute.home,
    page: () => HomeScreen(),
  ),

  GetPage(
    name: AppRoute.market,
    page: () => MarketScreen(),
  ),
  // GetPage(
  //   name: AppRoute.favorites,
  //   page: () => FavoritesScreen(),
  // ),
  GetPage(
    name: AppRoute.profile,
    page: () => ProfileScreen(),
  ),

  GetPage(
    name: AppRoute.splash,
    page: () => SplashScreen(),
  ),

  GetPage(
    name: AppRoute.interestsManagement,
    page: () => InterestsManagementScreen(),
  ),

  GetPage(
    name: AppRoute.otpVerification,
    page: () => OtpVerificationScreen(),
    transition: Transition.fadeIn,
  ),

  GetPage(
    name: AppRoute.forceUpdate,
    page: () => const ForceUpdateScreen(),
  ),

  GetPage(
    name: AppRoute.forgetPassword, 
    page: () => const ForgetPasswordScreen(),
    binding: BindingsBuilder(() {
      Get.put(ForgetPasswordController());
    }),
  ),
  
  GetPage(
    name: AppRoute.otpVerificationCode, 
    page: () {
      // Asegurarse de que el controller ya esté registrado
      if (!Get.isRegistered<ForgetPasswordController>()) {
        Get.put(ForgetPasswordController());
      }
      return OtpVerificationCodeScreen(
        phoneNumber: Get.arguments['phoneNumber'] ?? '0xxxxxxxxx',
      );
    }
  ),
  
];
