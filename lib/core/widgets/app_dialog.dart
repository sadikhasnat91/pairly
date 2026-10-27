import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> showConfirmation({
    required String title,
    required String description,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: AppColors.elevatedCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDanger
                      ? AppColors.errorBackground
                      : AppColors.warningBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDanger ? AppColors.error : AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: cancelText,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: confirmText,
                      variant: isDanger
                          ? AppButtonVariant.danger
                          : AppButtonVariant.primary,
                      onPressed: () => Get.back(result: true),
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

  static void showNotice({
    required String title,
    required String message,
    String buttonText = 'Understood',
    IconData icon = Icons.info_outline,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.elevatedCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.infoBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.info, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppButton(
                text: buttonText,
                variant: AppButtonVariant.primary,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
