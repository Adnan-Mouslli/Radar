import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

import '../constant/routes.dart';
import '../services/services.dart';

class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;

  MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {


    if (route == AppRoute.splash) {
      return null; // السماح بعرض السبلاش دائماً
    }

    return const RouteSettings(name: AppRoute.splash);

    // if (myServices.sharedPreferences.getString("onboarding") == null) {

    //   return const RouteSettings(name: AppRoute.onBoarding);
    // }


    // if (myServices.sharedPreferences.getString("loggedin") == "1") {

    //   return const RouteSettings(name: AppRoute.splash);
    // }


    // if (myServices.sharedPreferences.getString("onboarding") == "1") {
    //   return const RouteSettings(name: AppRoute.login);
    // }

    // return null;
  }
}