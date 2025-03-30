import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HistoryController extends GetxController {
  //TODO: Implement HistoryController

  @override
  void onInit() {
    super.onInit();
  }

  // Logout function
  void logout() {
    GetStorage().erase();
    Get.offAllNamed('/login');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
