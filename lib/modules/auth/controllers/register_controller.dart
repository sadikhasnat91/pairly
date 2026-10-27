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
    final cleanEmail = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (cleanEmail.isEmpty || password.isEmpty) {
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

    final name = cleanEmail.split('@').first;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.register(
        email: cleanEmail,
        password: password,
        displayName: name,
      );
      Get.offAllNamed(AppRoutes.profileSetup);
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('email_address_invalid') ||
          errStr.contains('rate_limit') ||
          errStr.contains('over_email_send_rate_limit')) {
        errorMessage.value =
            'Please turn OFF "Confirm email" in Supabase Dashboard > Authentication > Providers > Email.';
      } else if (errStr.contains('user_already_exists')) {
        errorMessage.value = 'An account with this email already exists. Please sign in.';
      } else {
        errorMessage.value = errStr.replaceAll('Exception:', '').replaceAll('AuthApiException:', '').trim();
      }
      Get.snackbar(
        'Registration Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
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

