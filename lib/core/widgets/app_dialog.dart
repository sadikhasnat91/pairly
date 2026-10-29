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
    IconData icon = Icons.favorite_border_rounded,
  }) {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: AppColors.whiteCards,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.subtleBorders),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isDanger
                      ? AppColors.errorBackground
                      : AppColors.softPinkSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDanger ? AppColors.errorAccent : AppColors.softRose,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryTextCol,
                ),
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
    IconData icon = Icons.favorite_rounded,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.whiteCards,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.subtleBorders),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: AppColors.softPinkSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.softRose, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryTextCol,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
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
