import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validator.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Start sharing and staying connected with your partner.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: controller.emailController,
                label: 'Email Address',
                hintText: 'name@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),
              Obx(
                () => AppTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  hintText: 'Minimum 6 characters',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  validator: Validators.validatePassword,
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => AppTextField(
                  controller: controller.confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                  validator: (val) => Validators.validateConfirmPassword(
                    val,
                    controller.passwordController.text,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => AppButton(
                  text: 'Create Account',
                  variant: AppButtonVariant.primary,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.register,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTypography.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Get.offNamed(AppRoutes.login),
                    child: Text(
                      'Sign In',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primaryAccent,
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
