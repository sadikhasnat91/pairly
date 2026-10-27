import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Incomplete Form',
        'Please complete all required fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Password Mismatch',
        'Passwords do not match.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final name = email.split('@').first;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.register(
        email: email,
        password: password,
        displayName: name,
      );
      Get.offAllNamed(AppRoutes.profileSetup);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Registration Failed',
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
    confirmPasswordController.dispose();
    super.onClose();
  }
}
