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
        ? AppColors.softRose
        : isSharing
        ? AppColors.primaryRomanticBlush
        : AppColors.subtleBorders;

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
              border: Border.all(
                color: borderColor,
                width: isLive ? 2.5 : 1.5,
              ),
              boxShadow: isLive
                  ? [
                      BoxShadow(
                        color: AppColors.primaryRomanticBlush.withValues(alpha: 0.4),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.deepRomanticPlum.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: AppColors.successAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.whiteCards,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successAccent.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.softPinkSurface,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.deepRomanticPlum,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
