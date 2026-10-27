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
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Privacy & Trust Center', style: AppTypography.titleMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shield Banner
              AppCard(
                backgroundColor: AppColors.secondaryBackground,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security,
                        color: AppColors.primaryAccent,
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
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pairly never tracks you silently or sells your data. You decide who sees you and when.',
                            style: AppTypography.bodySmall,
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
                  color: AppColors.secondaryText,
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
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.cardSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          partner != null ? Icons.person : Icons.person_off,
                          color: partner != null
                              ? AppColors.primaryAccent
                              : AppColors.secondaryText,
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
                              style: AppTypography.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              partner != null
                                  ? (isSharing
                                        ? 'Streaming active right now'
                                        : 'Paused by you')
                                  : 'Connect with a partner to enable sharing',
                              style: AppTypography.bodySmall,
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
                  color: AppColors.secondaryText,
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
                              style: AppTypography.labelLarge,
                            ),
                            const SizedBox(height: 2),
                            Obx(
                              () => Text(
                                controller.isSharing.value
                                    ? 'Your partner can see your coordinates'
                                    : 'Location streaming is stopped',
                                style: AppTypography.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        Obx(
                          () => Switch(
                            value: controller.isSharing.value,
                            activeThumbColor: AppColors.primaryAccent,
                            activeTrackColor: AppColors.primaryAccent
                                .withValues(alpha: 0.3),
                            inactiveTrackColor: AppColors.cardSubtle,
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
                            style: AppTypography.bodyMedium,
                          ),
                          Text(
                            loc != null
                                ? DateFormatter.timeAgo(loc.updatedAt)
                                : 'Not recorded',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Retention Explanation (Requirement 9 & 11)
              Text(
                'Data Retention & Integrity',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicyRow(
                      icon: Icons.history_toggle_off,
                      title: 'No Historical Breadcrumb Logging',
                      desc: 'Pairly stores only your single latest GPS coordinate. Old coordinates are never stockpiled or tracked historically.',
                    ),
                    const SizedBox(height: 14),
                    _buildPolicyRow(
                      icon: Icons.shield,
                      title: 'Immediate Access Revocation',
                      desc: 'Pausing sharing or disconnecting a partner immediately revokes read permissions across Cloud Firestore.',
                    ),
                    const SizedBox(height: 14),
                    _buildPolicyRow(
                      icon: Icons.settings_suggest_outlined,
                      title: 'Android System Permissions',
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
                leadingIcon: Icons.settings,
                onPressed: controller.openAppSettings,
              ),
              const SizedBox(height: 14),

              // Danger Zone: Account Deletion
              Obx(
                () => AppButton(
                  text: 'Delete Account & Purge Data',
                  variant: AppButtonVariant.danger,
                  leadingIcon: Icons.delete_outline,
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
        Icon(icon, size: 20, color: AppColors.secondaryAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(desc, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
