import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final currentUser = Rxn<UserModel>();
  final nameController = TextEditingController();
  final statusController = TextEditingController();

  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authRepo.currentUser;
    nameController.text = currentUser.value?.displayName ?? '';
    statusController.text = currentUser.value?.statusMessage ?? '';

    _authRepo.authStateChanges.listen((user) {
      currentUser.value = user;
      if (user != null) {
        nameController.text = user.displayName;
        statusController.text = user.statusMessage ?? '';
      }
    });
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final status = statusController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Name Required',
        'Display name cannot be empty.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSaving.value = true;
      await _authRepo.updateProfile(displayName: name, statusMessage: status);
      Get.back();
      Get.snackbar(
        'Profile Updated',
        'Your profile details have been saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Update Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> signOut() async {
    final confirmed = await AppDialog.showConfirmation(
      title: 'Sign Out?',
      description: 'You will need to sign in again to view your partner\'s live location.',
      confirmText: 'Sign Out',
      icon: Icons.logout,
    );

    if (confirmed == true) {
      await _authRepo.signOut();
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  Future<void> requestPasswordReset() async {
    final email = currentUser.value?.email;
    if (email != null && email.isNotEmpty) {
      try {
        await _authRepo.sendPasswordReset(email);
        Get.snackbar(
          'Reset Link Sent',
          'Password reset instructions sent to $email',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    statusController.dispose();
    super.onClose();
  }
}
