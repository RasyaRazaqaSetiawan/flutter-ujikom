import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/modules/dashboard/views/dashboard_view.dart';
import 'package:ujikom/app/utils/api.dart';

class LoginController extends GetxController {
  final _getConnect = GetConnect();
  final loginFormKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final authToken = GetStorage();
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void loginNow() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;

    final response = await _getConnect.post(BaseUrl.login, {
      'email': emailController.text,
      'password': passwordController.text,
    });

    isLoading.value = false;

    if (response.statusCode == 200) {
      final token = response.body['data']['access_token'];
      final user = response.body['data']['user'];

      if (token != null && user != null) {
        await authToken.write('token', token);
        await authToken.write('user_id', user['id']);

        Get.offAll(() => const DashboardView());
      } else {
        Get.snackbar(
          'Login Gagal',
          'Token atau data user tidak ditemukan.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } else {
      Get.snackbar(
        'Login Gagal',
        'Email atau password salah.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
