import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/date_formatter.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'status_badge.dart';

class LocationSharingCard extends StatelessWidget {
  final bool isSharing;
  final bool isLoading;
  final DateTime? lastUpdate;
  final double? accuracyMeters;
  final VoidCallback onToggleSharing;
  final String? partnerName;

  const LocationSharingCard({
    super.key,
    required this.isSharing,
    required this.isLoading,
    this.lastUpdate,
    this.accuracyMeters,
    required this.onToggleSharing,
    this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hasGlow: isSharing,
      borderColor: isSharing
          ? AppColors.primaryAccent.withValues(alpha: 0.4)
          : AppColors.border,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSharing
                          ? AppColors.primaryAccent.withValues(alpha: 0.15)
                          : AppColors.cardSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSharing ? Icons.near_me : Icons.location_off_outlined,
                      color: isSharing
                          ? AppColors.primaryAccent
                          : AppColors.secondaryText,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Location Stream',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        partnerName != null
                            ? (isSharing
                                  ? 'Visible to $partnerName'
                                  : 'Hidden from $partnerName')
                            : (isSharing
                                  ? 'Live sharing active'
                                  : 'Sharing is turned off'),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              StatusBadge(
                type: isSharing ? StatusBadgeType.live : StatusBadgeType.paused,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  label: 'LAST UPDATE',
                  value: lastUpdate != null
                      ? DateFormatter.timeAgo(lastUpdate)
                      : 'Not shared',
                  icon: Icons.access_time,
                ),
                Container(width: 1, height: 28, color: AppColors.border),
                _buildMetric(
                  label: 'GPS ACCURACY',
                  value: accuracyMeters != null
                      ? '±${accuracyMeters!.round()} m'
                      : 'Waiting for GPS',
                  icon: Icons.gps_fixed,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            text: isSharing
                ? 'Pause Location Sharing'
                : 'Start Sharing Location',
            variant: isSharing
                ? AppButtonVariant.danger
                : AppButtonVariant.primary,
            leadingIcon: isSharing ? Icons.pause : Icons.play_arrow,
            isLoading: isLoading,
            onPressed: onToggleSharing,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.tertiaryText),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.labelSmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
