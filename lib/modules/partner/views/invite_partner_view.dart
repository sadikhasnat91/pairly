import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/partner_controller.dart';

class InvitePartnerView extends GetView<PartnerController> {
  const InvitePartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate code on first open if none generated
    if (controller.activeInvite.value == null &&
        !controller.isGeneratingCode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.generateNewInviteCode();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Invite Partner', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'Share Your Pairing Code',
                style: AppTypography.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Send this single-use 6-digit code to your partner. It remains valid for 24 hours.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Code Display Card
              Obx(() {
                final invite = controller.activeInvite.value;
                final isLoading = controller.isGeneratingCode.value;

                if (isLoading) {
                  return Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: AppColors.primaryAccent,
                    ),
                  );
                }

                final code = invite?.code ?? '------';

                return AppCard(
                  hasGlow: true,
                  borderColor: AppColors.primaryAccent.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'PAIRING CODE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondaryText,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        code,
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 10,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.tertiaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Expires in 24 hours',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Action buttons: Copy & Share Sheet
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Copy Code',
                      variant: AppButtonVariant.secondary,
                      leadingIcon: Icons.copy,
                      onPressed: () {
                        final code = controller.activeInvite.value?.code;
                        if (code != null) {
                          Clipboard.setData(ClipboardData(text: code));
                          Get.snackbar(
                            'Copied!',
                            'Pairing code copied to clipboard.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Share Invite',
                      variant: AppButtonVariant.primary,
                      leadingIcon: Icons.share,
                      onPressed: controller.shareInviteCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: controller.generateNewInviteCode,
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
                label: Text(
                  'Generate a new code',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              const Spacer(),
              // Instruction step indicators
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildStepRow('1', 'Your partner installs Pairly'),
                    const SizedBox(height: 10),
                    _buildStepRow('2', 'They select "Enter Partner\'s Code"'),
                    const SizedBox(height: 10),
                    _buildStepRow(
                      '3',
                      'Once matched, you both can enable sharing',
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

  Widget _buildStepRow(String step, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.cardSubtle,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
