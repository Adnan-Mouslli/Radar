import 'package:get/get.dart';
import 'package:radar/controller/Market/MarketController.dart';
import 'package:radar/controller/Market/QrScannerController.dart';
import 'package:radar/controller/OffersRadar/AppLifecycleController.dart';
import 'package:radar/controller/profile/ProfileController.dart';
import '../core/class/crud.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    // Get.lazyPut(() => ReelsController().onInit());

    // Get.put(ProfileController());
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);

    Get.put(AppLifecycleController());

    if (!Get.isRegistered<MarketController>()) {
      Get.put(MarketController());
    }

    Get.put(QrScannerController(
      marketController: Get.find<MarketController>(),
    ));

    // Get.lazyPut<FavoritesController>(() => FavoritesController(), fenix: true);
  }
}
