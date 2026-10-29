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
      backgroundColor: AppColors.warmCreamBackground,
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRomanticBlush.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.appName,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.mainText,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Romantic Hero Headline
              Text(
                'Connected by heart.\nSynced by location.',
                style: AppTypography.displayLarge.copyWith(
                  height: 1.18,
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Pairly gives couples peace of mind through mutual, consent-first location sharing. Always intimate, always in your control.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.secondaryTextCol,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Romantic Value Props
              _buildFeatureRow(
                icon: Icons.favorite_border_rounded,
                title: 'Private 1:1 Couple Space',
                desc: 'Only you and your significant other can ever see each other.',
              ),
              const SizedBox(height: 18),
              _buildFeatureRow(
                icon: Icons.near_me_rounded,
                title: 'Live Map & Real-time Closeness',
                desc: 'Know when your partner is on their way or safe at home.',
              ),
              const SizedBox(height: 18),
              _buildFeatureRow(
                icon: Icons.shield_outlined,
                title: 'Full Mutual Transparency',
                desc: 'No secret tracking. Pause or resume sharing anytime in one tap.',
              ),
              const Spacer(),
              // CTA Buttons
              AppButton(
                text: 'Create Couple Account',
                variant: AppButtonVariant.primary,
                trailingIcon: Icons.arrow_forward_rounded,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.softPinkSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryRomanticBlush.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.softRose),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryTextCol,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
