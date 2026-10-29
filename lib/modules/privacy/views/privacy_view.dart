import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/privacy_controller.dart';

class PrivacyView extends GetView<PrivacyController> {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      appBar: AppBar(
        title: Text(
          'Privacy & Trust Center',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shield Banner
              AppCard(
                backgroundColor: AppColors.whiteCards,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softPinkSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.subtleBorders),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
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
                            'Mutual Transparency',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pairly never tracks you silently. You decide who sees your location and when.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryTextCol,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active Access Breakdown
              Text(
                'Who Can See My Location',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.secondaryTextCol,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final partner = controller.partnerUser.value;
                final isSharing = controller.isSharing.value;

                return AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.softPinkSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          partner != null ? Icons.favorite_rounded : Icons.person_off_rounded,
                          color: partner != null
                              ? AppColors.softRose
                              : AppColors.secondaryTextCol,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partner != null
                                  ? partner.displayName
                                  : 'No one has access',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              partner != null
                                  ? (isSharing
                                        ? 'Streaming active right now'
                                        : 'Paused by you')
                                  : 'Connect with a partner to enable sharing',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondaryTextCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        type: isSharing
                            ? StatusBadgeType.live
                            : StatusBadgeType.paused,
                        customLabel: isSharing ? 'Sharing' : 'Off',
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Current Location Stream Controls
              Text(
                'Stream Controls',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.secondaryTextCol,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Sharing Switch',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(
                              () => Text(
                                controller.isSharing.value
                                    ? 'Your partner can see your coordinates'
                                    : 'Location streaming is stopped',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.secondaryTextCol,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Obx(
                          () => Switch(
                            value: controller.isSharing.value,
                            activeThumbColor: AppColors.softRose,
                            activeTrackColor: AppColors.primaryRomanticBlush
                                .withValues(alpha: 0.35),
                            inactiveTrackColor: AppColors.softPinkSurface,
                            onChanged: (_) => controller.toggleSharing(),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Obx(() {
                      final loc = controller.userLocation.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last Upload Timestamp',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.mainText,
                            ),
                          ),
                          Text(
                            loc != null
                                ? DateFormatter.timeAgo(loc.updatedAt)
                                : 'Not recorded',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.secondaryTextCol,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Retention Explanation
              Text(
                'Data Retention & Integrity',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.secondaryTextCol,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicyRow(
                      icon: Icons.history_toggle_off_rounded,
                      title: 'No Historical Breadcrumb Logging',
                      desc: 'Pairly stores only your single latest GPS coordinate. Old coordinates are never stockpiled or tracked historically.',
                    ),
                    const SizedBox(height: 14),
                    _buildPolicyRow(
                      icon: Icons.shield_rounded,
                      title: 'Immediate Access Revocation',
                      desc: 'Pausing sharing or disconnecting a partner immediately revokes read permissions across the database.',
                    ),
                    const SizedBox(height: 14),
                    _buildPolicyRow(
                      icon: Icons.settings_suggest_rounded,
                      title: 'Device System Permissions',
                      desc: 'Manage fine & coarse location access directly in Android settings at any time.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Settings shortcut
              AppButton(
                text: 'Open Android System Permissions',
                variant: AppButtonVariant.secondary,
                leadingIcon: Icons.settings_rounded,
                onPressed: controller.openAppSettings,
              ),
              const SizedBox(height: 14),

              // Danger Zone: Account Deletion
              Obx(
                () => AppButton(
                  text: 'Delete Account & Purge Data',
                  variant: AppButtonVariant.danger,
                  leadingIcon: Icons.delete_outline_rounded,
                  isLoading: controller.isDeleting.value,
                  onPressed: controller.deleteAccount,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.softPinkSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.softRose),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.mainText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryTextCol,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
