import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/partner_avatar.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/partner_controller.dart';

class ConnectedPartnerView extends GetView<PartnerController> {
  const ConnectedPartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Large Romantic Partner Avatar & Name
          Obx(() {
            final partner = controller.partnerUser.value;
            final conn = controller.activeConnection.value;

            return Column(
              children: [
                PartnerAvatar(
                  name: partner?.displayName,
                  photoUrl: partner?.photoUrl,
                  size: 96,
                  isLive: true,
                  isSharing: true,
                ),
                const SizedBox(height: 18),
                Text(
                  partner?.displayName ?? 'Your Partner',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.mainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  partner?.email.isNotEmpty == true
                      ? partner!.email
                      : 'Connected in heart',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.secondaryTextCol,
                  ),
                ),
                const SizedBox(height: 12),
                const StatusBadge(
                  type: StatusBadgeType.live,
                  customLabel: 'Paired Relationship',
                ),
                const SizedBox(height: 32),

                // Details Card
                AppCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        label: 'CONNECTION STATUS',
                        value: 'Active & Verified',
                        icon: Icons.favorite_rounded,
                        color: AppColors.softRose,
                      ),
                      const Divider(height: 28),
                      _buildDetailRow(
                        label: 'PAIRED SINCE',
                        value: DateFormatter.formatFullDate(
                          conn?.acceptedAt ?? conn?.createdAt,
                        ),
                        icon: Icons.calendar_today_rounded,
                      ),
                      const Divider(height: 28),
                      _buildDetailRow(
                        label: 'PRIVACY PROTOCOL',
                        value: 'Mutual Consent Enabled',
                        icon: Icons.shield_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 32),

          // Actions
          AppButton(
            text: 'Disconnect Partner',
            variant: AppButtonVariant.secondary,
            leadingIcon: Icons.link_off_rounded,
            onPressed: controller.confirmDisconnect,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Block Partner',
            variant: AppButtonVariant.danger,
            leadingIcon: Icons.block_rounded,
            onPressed: controller.confirmBlock,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.softPinkSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color ?? AppColors.secondaryTextCol),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.secondaryTextCol,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: color ?? AppColors.mainText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
