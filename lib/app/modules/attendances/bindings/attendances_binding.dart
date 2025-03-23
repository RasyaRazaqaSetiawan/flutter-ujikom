import 'package:get/get.dart';

import '../controllers/attendances_controller.dart';

class AttendancesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendancesController>(
      () => AttendancesController(),
    );
  }
}
