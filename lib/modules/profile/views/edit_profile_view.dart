import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validator.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: controller.nameController,
                label: 'Display Name',
                hintText: 'Enter your name',
                prefixIcon: Icons.badge_outlined,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: controller.statusController,
                label: 'Status Message',
                hintText: 'e.g. On my way, In a meeting',
                prefixIcon: Icons.edit_note_outlined,
              ),
              const SizedBox(height: 36),
              Obx(
                () => AppButton(
                  text: 'Save Changes',
                  variant: AppButtonVariant.primary,
                  isLoading: controller.isSaving.value,
                  onPressed: controller.saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
