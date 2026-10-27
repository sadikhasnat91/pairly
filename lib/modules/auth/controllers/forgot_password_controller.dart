import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  late TextEditingController emailController;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Enter Email',
        'Please enter your email address to receive reset instructions.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authRepository.sendPasswordReset(email);
      Get.snackbar(
        'Reset Email Sent',
        'Check your inbox for password reset instructions.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Reset Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
