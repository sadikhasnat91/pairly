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
      final errStr = e.toString();
      if (errStr.contains('Failed host lookup') ||
          errStr.contains('SocketException') ||
          errStr.contains('errno = 7')) {
        errorMessage.value =
            'No Internet Connection. Please check your mobile data/Wi-Fi or turn off any active VPN.';
      } else if (errStr.contains('Invalid login credentials')) {
        errorMessage.value = 'Incorrect email or password. Please check and try again.';
      } else {
        errorMessage.value = errStr.replaceAll('Exception:', '').replaceAll('AuthApiException:', '').trim();
      }
      Get.snackbar(
        'Sign In Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
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
