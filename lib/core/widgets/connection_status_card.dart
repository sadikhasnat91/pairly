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
        backgroundColor: AppColors.elevatedCard,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.favorite_outline,
                color: AppColors.primaryAccent,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Partner Connected',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invite your significant other with a private pairing code',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.primaryAccent),
          ],
        ),
      );
    }

    return AppCard(
      onTap: onManagePartner,
      backgroundColor: AppColors.elevatedCard,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              PartnerAvatar(
                name: partnerName,
                photoUrl: partnerPhotoUrl,
                size: 54,
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
                            style: AppTypography.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.favorite,
                          size: 16,
                          color: AppColors.primaryAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connectedAt != null
                          ? 'Connected since ${DateFormatter.formatShortDate(connectedAt)}'
                          : 'Connected Partner',
                      style: AppTypography.bodySmall,
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
        ],
      ),
    );
  }
}
