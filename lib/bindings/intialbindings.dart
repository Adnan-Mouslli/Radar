import 'package:get/get.dart';
import 'package:radar/controller/profile/ProfileController.dart';
import '../core/class/crud.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    // Get.lazyPut(() => ReelsController().onInit());

    // Get.put(ProfileController());
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    // Get.lazyPut<FavoritesController>(() => FavoritesController(), fenix: true);
  }
}
