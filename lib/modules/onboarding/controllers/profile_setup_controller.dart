import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileSetupController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  late TextEditingController nameController;
  late TextEditingController statusController;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill name from the just-registered user
    final currentName = _authRepository.currentUser?.displayName ?? '';
    nameController = TextEditingController(text: currentName);
    statusController = TextEditingController();
  }

  Future<void> completeProfileSetup() async {
    final name = nameController.text.trim();
    final status = statusController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Name Required',
        'Please enter a display name.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authRepository.updateProfile(
        displayName: name,
        statusMessage: status.isNotEmpty ? status : null,
      );
      Get.offAllNamed(AppRoutes.mainLayout);
    } catch (e) {
      Get.snackbar(
        'Setup Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    statusController.dispose();
    super.onClose();
  }
}

