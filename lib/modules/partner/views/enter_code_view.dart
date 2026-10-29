import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/partner_controller.dart';

class EnterCodeView extends GetView<PartnerController> {
  const EnterCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      appBar: AppBar(
        title: Text(
          'Enter Code',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.mainText,
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Pairing Code',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type the 6-character code given by your partner to establish your private connection.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryTextCol,
                ),
              ),
              const SizedBox(height: 36),
              AppTextField(
                controller: controller.codeInputController,
                label: 'Partner Code',
                hintText: 'e.g. 7X9K2P',
                prefixIcon: Icons.favorite_border_rounded,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 32),
              Obx(
                () => AppButton(
                  text: 'Connect Partner',
                  variant: AppButtonVariant.primary,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.submitCode,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.softPinkSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.subtleBorders),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.softRose,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Connecting is 100% mutual. You can disconnect or pause location streaming at any time with one tap.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryTextCol,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
