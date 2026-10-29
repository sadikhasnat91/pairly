import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validator.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.mainText,
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your account email and we\'ll send a secure password reset link.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryTextCol,
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: controller.emailController,
                label: 'Email Address',
                hintText: 'name@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 32),
              Obx(
                () => AppButton(
                  text: 'Send Reset Link',
                  variant: AppButtonVariant.primary,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.sendPasswordReset,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
