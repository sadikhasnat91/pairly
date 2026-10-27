import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // App Brand Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.appName,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Hero Headline
              Text(
                'Connected by heart.\nSynced by location.',
                style: AppTypography.displayLarge.copyWith(height: 1.15),
              ),
              const SizedBox(height: 16),
              Text(
                'Pairly gives couples peace of mind through mutual, consent-first location sharing. Always transparent, always in your control.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              // Value Props
              _buildFeatureRow(
                icon: Icons.lock_outline,
                title: 'Private & Secure 1:1 Pairing',
                desc: 'Only you and your partner can ever see each other.',
              ),
              const SizedBox(height: 20),
              _buildFeatureRow(
                icon: Icons.near_me_outlined,
                title: 'Live Map & Real-time Distance',
                desc: 'Know when they reach home or work safely.',
              ),
              const SizedBox(height: 20),
              _buildFeatureRow(
                icon: Icons.power_settings_new,
                title: 'Instant Pause at Any Time',
                desc: 'Tracking is never secret. Turn sharing off whenever you need.',
              ),
              const Spacer(),
              // CTA Buttons
              AppButton(
                text: 'Create Account',
                variant: AppButtonVariant.primary,
                trailingIcon: Icons.arrow_forward,
                onPressed: controller.onGetStarted,
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'I already have an account',
                variant: AppButtonVariant.ghost,
                onPressed: controller.onSignIn,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.elevatedCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.primaryAccent, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(desc, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
