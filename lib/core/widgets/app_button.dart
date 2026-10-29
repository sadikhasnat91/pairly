import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, danger, ghost }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 54,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Gradient? gradient;
    Color foregroundColor;
    BorderSide? borderSide;
    List<BoxShadow>? boxShadow;

    switch (variant) {
      case AppButtonVariant.primary:
        gradient = AppColors.blushGradient;
        foregroundColor = Colors.white;
        boxShadow = [
          BoxShadow(
            color: AppColors.primaryRomanticBlush.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.softPinkSurface;
        foregroundColor = AppColors.deepRomanticPlum;
        borderSide = const BorderSide(color: AppColors.subtleBorders, width: 1.2);
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.softRose;
        borderSide = const BorderSide(
          color: AppColors.softRose,
          width: 1.5,
        );
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.errorBackground;
        foregroundColor = AppColors.errorAccent;
        borderSide = const BorderSide(color: AppColors.errorAccent, width: 1);
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.secondaryTextCol;
        break;
    }

    final isInteractive = onPressed != null && !isLoading;
    final borderRadius = BorderRadius.circular(24);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: gradient == null ? backgroundColor : null,
          gradient: isInteractive ? gradient : null,
          borderRadius: borderRadius,
          border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
          boxShadow: isInteractive ? boxShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isInteractive ? onPressed : null,
            borderRadius: borderRadius,
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            foregroundColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (leadingIcon != null) ...[
                            Icon(leadingIcon, size: 20, color: foregroundColor),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              text,
                              style: AppTypography.buttonText.copyWith(
                                color: foregroundColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (trailingIcon != null) ...[
                            const SizedBox(width: 8),
                            Icon(trailingIcon, size: 20, color: foregroundColor),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
