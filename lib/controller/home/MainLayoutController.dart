import 'package:get/get.dart';
import 'package:radar/controller/home/reel_controller.dart';

class MainLayoutController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt previousIndex = 0.obs;

  void changePage(int index) {
    previousIndex.value = currentIndex.value;

    if (currentIndex.value == 0 && index != 0) {
      _pauseReelsVideos();
    }

    if (previousIndex.value != 0 && index == 0) {
      _prepareReelsForReturn();
    }

    currentIndex.value = index;
  }

  // Método para pausar videos al salir de la pantalla de reels
  void _pauseReelsVideos() {
    try {
      if (Get.isRegistered<ReelsController>()) {
        final reelsController = Get.find<ReelsController>();
        // Detener todos los videos y limpiar
        reelsController.stopAllVideosExcept(null);
        reelsController.toggleMute();
      }
    } catch (e) {
      print("Error al intentar detener videos: $e");
    }
  }

  void _prepareReelsForReturn() {
    try {
      if (Get.isRegistered<ReelsController>()) {
        final reelsController = Get.find<ReelsController>();

        reelsController.toggleMute();

        reelsController.refreshReels();
      }
    } catch (e) {
      print("Error al preparar los reels para el regreso: $e");
    }
  }
}
