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
        defaultIcon = Icons.info_outline;
        break;
      case BannerVariant.warning:
        bg = AppColors.warningBackground;
        border = AppColors.warning.withValues(alpha: 0.3);
        textColor = AppColors.warning;
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case BannerVariant.error:
        bg = AppColors.errorBackground;
        border = AppColors.error.withValues(alpha: 0.3);
        textColor = AppColors.error;
        defaultIcon = Icons.error_outline;
        break;
      case BannerVariant.success:
        bg = AppColors.successBackground;
        border = AppColors.success.withValues(alpha: 0.3);
        textColor = AppColors.success;
        defaultIcon = Icons.check_circle_outline;
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
                color: AppColors.primaryText,
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
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.labelSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
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
