import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/date_formatter.dart';
import 'app_card.dart';
import 'partner_avatar.dart';
import 'status_badge.dart';

class ConnectionStatusCard extends StatelessWidget {
  final bool isConnected;
  final String? partnerName;
  final String? partnerPhotoUrl;
  final DateTime? connectedAt;
  final bool isPartnerSharing;
  final VoidCallback onInvitePartner;
  final VoidCallback? onManagePartner;

  const ConnectionStatusCard({
    super.key,
    required this.isConnected,
    this.partnerName,
    this.partnerPhotoUrl,
    this.connectedAt,
    this.isPartnerSharing = false,
    required this.onInvitePartner,
    this.onManagePartner,
  });

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return AppCard(
        onTap: onInvitePartner,
        backgroundColor: AppColors.whiteCards,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.blushGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRomanticBlush.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect with Your Partner',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.mainText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Share your invite code to stay close wherever you are',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryTextCol,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.softPinkSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.softRose,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      onTap: onManagePartner,
      backgroundColor: AppColors.whiteCards,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          PartnerAvatar(
            name: partnerName,
            photoUrl: partnerPhotoUrl,
            size: 56,
            isLive: isPartnerSharing,
            isSharing: isPartnerSharing,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        partnerName ?? 'Partner',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.favorite,
                      size: 15,
                      color: AppColors.softRose,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  connectedAt != null
                      ? 'Connected since ${DateFormatter.formatShortDate(connectedAt)}'
                      : 'Connected in heart',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryTextCol,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            type: isPartnerSharing
                ? StatusBadgeType.live
                : StatusBadgeType.paused,
            customLabel: isPartnerSharing ? 'Sharing' : 'Paused',
          ),
        ],
      ),
    );
  }
}
