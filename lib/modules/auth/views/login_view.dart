import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validator.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small branding icon
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
              const SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to stay close with your partner in real time.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryTextCol,
                ),
              ),
              const SizedBox(height: 36),
              AppTextField(
                controller: controller.emailController,
                label: 'Email Address',
                hintText: 'name@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),
              Obx(
                () => AppTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: AppColors.secondaryTextCol,
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  validator: Validators.validatePassword,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  child: Text(
                    'Forgot password?',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.softRose,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => AppButton(
                  text: 'Sign In',
                  variant: AppButtonVariant.primary,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.signIn,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.secondaryTextCol,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.offNamed(AppRoutes.register),
                    child: Text(
                      'Sign Up',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.softRose,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}