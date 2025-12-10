import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Login',
              showBackButton: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: const Text(
                          'Belum punya akun? Daftar di sini',
                        ),
                      ),
                      if (controller.errorMessage.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            controller.errorMessage.value!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

