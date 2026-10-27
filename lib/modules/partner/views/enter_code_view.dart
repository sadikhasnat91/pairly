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
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Enter Code', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter Pairing Code', style: AppTypography.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Type the 6-character code given by your partner to establish your private connection.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 36),
              AppTextField(
                controller: controller.codeInputController,
                label: 'Partner Code',
                hintText: 'e.g. 7X9K2P',
                prefixIcon: Icons.lock_open,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.secondaryAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Connecting is 100% reciprocal. You can disconnect or pause location streaming at any time with one tap.',
                        style: AppTypography.bodySmall,
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
