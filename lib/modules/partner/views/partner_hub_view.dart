import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/partner_controller.dart';
import 'connected_partner_view.dart';

class PartnerHubView extends GetView<PartnerController> {
  const PartnerHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      appBar: AppBar(
        title: Text(
          'Partner Connection',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final conn = controller.activeConnection.value;
          if (conn != null && conn.isActive) {
            return const ConnectedPartnerView();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Pairly Heart Illustration Motif
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.blushGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRomanticBlush.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Connect with Your Partner',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.mainText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Pairly is an intimate 1:1 space. Once connected, both of you can choose to share your live location at any time.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.secondaryTextCol,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Option 1: Invite Partner Card
                AppCard(
                  onTap: () => Get.toNamed(AppRoutes.invitePartner),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.softPinkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.subtleBorders),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: AppColors.softRose,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Generate Pairing Code',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a secure 6-character code for your partner to enter.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondaryTextCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.softRose,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Option 2: Enter Partner's Code Card
                AppCard(
                  onTap: () => Get.toNamed(AppRoutes.enterCode),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.softPinkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.subtleBorders),
                        ),
                        child: const Icon(
                          Icons.pin_outlined,
                          color: AppColors.deepRomanticPlum,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Partner\'s Code',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Got a code from your partner? Type it in to connect instantly.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondaryTextCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.softRose,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Consent guarantee banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softPinkSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.subtleBorders),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 20,
                        color: AppColors.softRose,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pairing does not automatically activate location sharing. Sharing always requires explicit manual activation.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryTextCol,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
