import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil instance LoginController tanpa membuat ulang
    LoginController controller = Get.put(LoginController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(child: Image.asset('assets/images/login.jpg', height: 200)),

            const SizedBox(height: 20),
            const Text(
              'Login',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.alternate_email_outlined, color: Colors.grey),
                      labelText: 'Email',
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Masukkan email atau username' : null,
                  ),
                  const SizedBox(height: 15),
                  Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: controller.togglePasswordVisibility,
                            icon: Icon(controller.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Masukkan password Anda' : null,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Button Login dengan warna primary
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.loginNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Login", style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
