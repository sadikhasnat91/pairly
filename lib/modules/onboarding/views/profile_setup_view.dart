import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileSetupView extends GetView<AuthController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Profile Setup', style: AppTypography.titleMedium),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personalize Your Profile',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This information will be displayed to your partner once paired.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 32),
              // Avatar circle with camera button
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.cardSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryAccent,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 52,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBackground,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.primaryBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              AppTextField(
                controller: controller.nameController,
                label: 'Display Name',
                hintText: 'Enter your preferred name',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: controller.statusController,
                label: 'Status Message (Optional)',
                hintText: 'e.g. At work, Commuting, Free to call',
                prefixIcon: Icons.edit_note_outlined,
              ),
              const SizedBox(height: 28),
              // Mandatory privacy guarantee card
              AppCard(
                backgroundColor: AppColors.secondaryBackground,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.secondaryAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy First',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.secondaryAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your live location remains disabled by default. You can choose when to share once you connect with your partner.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Obx(
                () => AppButton(
                  text: 'Continue to Pairly',
                  variant: AppButtonVariant.primary,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.completeProfileSetup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
