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
          // Large Partner Avatar & Name
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
                  style: AppTypography.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  partner?.email.isNotEmpty == true
                      ? partner!.email
                      : 'Connected & Active',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 12),
                StatusBadge(
                  type: StatusBadgeType.live,
                  customLabel: 'Paired Relationship',
                ),
                const SizedBox(height: 32),

                // Details Card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        label: 'CONNECTION STATUS',
                        value: 'Active & Verified',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        label: 'PAIRED SINCE',
                        value: DateFormatter.formatFullDate(
                          conn?.acceptedAt ?? conn?.createdAt,
                        ),
                        icon: Icons.calendar_today_outlined,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        label: 'PRIVACY PROTOCOL',
                        value: 'Mutual Consent Enabled',
                        icon: Icons.lock_outline,
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
            leadingIcon: Icons.link_off,
            onPressed: controller.confirmDisconnect,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Block Partner',
            variant: AppButtonVariant.danger,
            leadingIcon: Icons.block,
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
        Icon(icon, size: 20, color: color ?? AppColors.secondaryText),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: color ?? AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
