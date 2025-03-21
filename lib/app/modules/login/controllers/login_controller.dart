import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:ujikom/app/modules/dashboard/views/dashboard_view.dart';
import 'package:ujikom/app/utils/api.dart';

class LoginController extends GetxController {
  final _getConnect = GetConnect();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final authToken = GetStorage();
  var isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void loginNow() async {
    try {
      final response = await _getConnect.post(
        BaseUrl.login,
        jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      _handleResponse(response);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        icon: const Icon(Icons.error),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handleResponse(Response response) {
    if (response.statusCode == 200 && response.body['data'] != null) {
      authToken.write('token', response.body['data']['access_token']);
      Get.offAll(() => const DashboardView());
    } else {
      Get.snackbar(
        'Login Gagal',
        response.body['message'] ?? 'Terjadi kesalahan saat login',
        icon: const Icon(Icons.error),
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
