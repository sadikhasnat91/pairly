import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum BannerVariant { info, warning, error, success }

class AppBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final BannerVariant variant;
  final IconData? icon;

  const AppBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.variant = BannerVariant.warning,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;
    IconData defaultIcon;

    switch (variant) {
      case BannerVariant.info:
        bg = AppColors.infoBackground;
        border = AppColors.info.withValues(alpha: 0.3);
        textColor = AppColors.info;
        defaultIcon = Icons.info_outline_rounded;
        break;
      case BannerVariant.warning:
        bg = AppColors.warningBackground;
        border = AppColors.warning.withValues(alpha: 0.3);
        textColor = AppColors.warning;
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case BannerVariant.error:
        bg = AppColors.errorBackground;
        border = AppColors.errorAccent.withValues(alpha: 0.3);
        textColor = AppColors.errorAccent;
        defaultIcon = Icons.error_outline_rounded;
        break;
      case BannerVariant.success:
        bg = AppColors.successBackground;
        border = AppColors.successAccent.withValues(alpha: 0.3);
        textColor = AppColors.successAccent;
        defaultIcon = Icons.check_circle_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon ?? defaultIcon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mainText,
                height: 1.35,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.labelSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
