import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/modules/dashboard/views/dashboard_view.dart';
import 'package:ujikom/app/utils/api.dart';

class LoginController extends GetxController {
  final _getConnect = GetConnect();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final authToken = GetStorage();
  final loginFormKey = GlobalKey<FormState>();
  var isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void loginNow() async {
    final response = await _getConnect.post(BaseUrl.login, {
      'email': emailController.text,
      'password': passwordController.text,
    });

    if (response.statusCode == 200) {
      var token = response.body['data']['access_token'];
      var user = response.body['data']['user'];

      if (token != null && user != null) {
        await authToken.write('token', token);
        await authToken.write('user_id', user['id']); // Menyimpan user_id

        // print("Token disimpan: $token");
        // print("User ID disimpan: ${user['id']}");

        // Cek token yang disimpan
        // var storedToken = authToken.read('token');
        // var storedUserId = authToken.read('user_id');
        // print("Token yang tersimpan: $storedToken");
        // print("User ID yang tersimpan: $storedUserId");

        Get.offAll(() =>   const DashboardView());
      } else {
        print("Token atau data user tidak ditemukan di response");
        Get.snackbar(
          'Error',
          'Token atau data user tidak ditemukan di response',
          icon: const Icon(Icons.error),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        response.body['error'].toString(),
        icon: const Icon(Icons.error),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        forwardAnimationCurve: Curves.bounceIn,
        margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
