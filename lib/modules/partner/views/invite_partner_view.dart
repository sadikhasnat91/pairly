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
      backgroundColor: AppColors.warmCreamBackground,
      appBar: AppBar(
        title: Text(
          'Invite Partner',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'Share Your Pairing Code',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.mainText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Send this single-use 6-digit code to your partner. It remains valid for 24 hours.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryTextCol,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Code Display Card
              Obx(() {
                final invite = controller.activeInvite.value;
                final isLoading = controller.isGeneratingCode.value;

                if (isLoading) {
                  return Container(
                    height: 140,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: AppColors.softRose,
                    ),
                  );
                }

                final code = invite?.code ?? '------';

                return AppCard(
                  hasGlow: true,
                  borderColor: AppColors.primaryRomanticBlush.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'PAIRING CODE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondaryTextCol,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        code,
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10,
                          color: AppColors.deepRomanticPlum,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.secondaryTextCol,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Expires in 24 hours',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryTextCol,
                            ),
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
                      leadingIcon: Icons.copy_rounded,
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
                      leadingIcon: Icons.share_rounded,
                      onPressed: controller.shareInviteCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: controller.generateNewInviteCode,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: AppColors.softRose,
                ),
                label: Text(
                  'Generate a new code',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.softRose,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              // Instruction step indicators
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.softPinkSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.subtleBorders),
                ),
                child: Column(
                  children: [
                    _buildStepRow('1', 'Your partner opens Pairly'),
                    const SizedBox(height: 10),
                    _buildStepRow('2', 'They select "Enter Partner\'s Code"'),
                    const SizedBox(height: 10),
                    _buildStepRow(
                      '3',
                      'Once matched, both can share live location',
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
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.whiteCards,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryRomanticBlush.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.softRose,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mainText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
