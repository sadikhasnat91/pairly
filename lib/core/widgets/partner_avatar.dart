import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PartnerAvatar extends StatelessWidget {
  final String? name;
  final String? photoUrl;
  final double size;
  final bool isLive;
  final bool isSharing;
  final VoidCallback? onTap;

  const PartnerAvatar({
    super.key,
    this.name,
    this.photoUrl,
    this.size = 64,
    this.isLive = false,
    this.isSharing = false,
    this.onTap,
  });

  String get initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isLive
        ? AppColors.primaryAccent
        : isSharing
        ? AppColors.secondaryAccent
        : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: isLive ? 2.5 : 1.5),
              boxShadow: isLive
                  ? [
                      BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl!.isNotEmpty
                  ? Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallback(),
                    )
                  : _buildFallback(),
            ),
          ),
          if (isLive)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBackground,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.cardSubtle,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.titleMedium.copyWith(
          color: isLive ? AppColors.primaryAccent : AppColors.primaryText,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
