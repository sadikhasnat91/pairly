import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  late TextEditingController emailController;
  late TextEditingController passwordController;

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> signIn() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please enter your email and password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.signIn(email: email, password: password);
      Get.offAllNamed(AppRoutes.mainLayout);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Sign In Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
