import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/modules/dashboard/views/dashboard_view.dart';
import 'package:ujikom/app/modules/login/views/login_view.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  late Timer _pindah;
  final authToken = GetStorage();

  // final count = 0.obs;
  @override
  void onInit() {
    _pindah = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => authToken.read('token') == null
          ? Get.off(
              () => const LoginView(),
              transition: Transition.fade,
            )
          : Get.off(() => const DashboardView()),
    );
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _pindah.cancel();
  }
}
