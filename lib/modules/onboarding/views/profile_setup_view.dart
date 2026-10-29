import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/profile_setup_controller.dart';

class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      appBar: AppBar(
        title: Text(
          'Profile Setup',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
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
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This information will be displayed to your partner once paired.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryTextCol,
                ),
              ),
              const SizedBox(height: 32),
              // Romantic Avatar Circle with Camera Button
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColors.softPinkSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.softRose,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRomanticBlush.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 54,
                          color: AppColors.softRose,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.softRose,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.whiteCards,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepRomanticPlum.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
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
                hintText: 'e.g. Thinking of you, At work, Commuting',
                prefixIcon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 28),
              // Romantic Privacy Guarantee Card
              AppCard(
                backgroundColor: AppColors.whiteCards,
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softPinkSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.softRose,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy & Closeness',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.mainText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your live location remains disabled by default. You have full mutual control over when to share.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryTextCol,
                              height: 1.35,
                            ),
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
