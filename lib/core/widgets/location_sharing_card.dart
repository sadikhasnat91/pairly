import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/date_formatter.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'status_badge.dart';

class LocationSharingCard extends StatelessWidget {
  final bool isSharing;
  final String? partnerName;
  final DateTime? lastUpdate;
  final double? accuracyMeters;
  final bool isLoading;
  final VoidCallback onToggleSharing;

  const LocationSharingCard({
    super.key,
    required this.isSharing,
    this.partnerName,
    this.lastUpdate,
    this.accuracyMeters,
    required this.isLoading,
    required this.onToggleSharing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hasGlow: isSharing,
      borderColor: isSharing
          ? AppColors.primaryRomanticBlush.withValues(alpha: 0.5)
          : AppColors.subtleBorders,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSharing
                      ? AppColors.softRose.withValues(alpha: 0.15)
                      : AppColors.softPinkSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSharing ? Icons.near_me_rounded : Icons.location_off_rounded,
                  color: isSharing
                      ? AppColors.softRose
                      : AppColors.secondaryTextCol,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Location Stream',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      partnerName != null
                          ? (isSharing
                                ? 'Visible to $partnerName'
                                : 'Hidden from $partnerName')
                          : (isSharing
                                ? 'Live sharing active'
                                : 'Sharing is paused'),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryTextCol,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                type: isSharing ? StatusBadgeType.live : StatusBadgeType.paused,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.softPinkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.subtleBorders,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    label: 'LAST SYNCED',
                    value: lastUpdate != null
                        ? DateFormatter.timeAgo(lastUpdate)
                        : 'Not shared yet',
                    icon: Icons.access_time_rounded,
                  ),
                ),
                Container(width: 1, height: 26, color: AppColors.subtleBorders),
                Expanded(
                  child: _buildMetric(
                    label: 'ACCURACY',
                    value: accuracyMeters != null
                        ? '±${accuracyMeters!.round()} m'
                        : 'Waiting for GPS',
                    icon: Icons.gps_fixed_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: isSharing
                ? 'Pause Location Sharing'
                : 'Share Live Location with Partner',
            variant: isSharing
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            leadingIcon: isSharing
                ? Icons.pause_circle_outline_rounded
                : Icons.favorite_rounded,
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.secondaryTextCol),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.secondaryTextCol,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.mainText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
