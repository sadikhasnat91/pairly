import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool hasGlow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 22,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.whiteCards,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.subtleBorders,
          width: 1.2,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryRomanticBlush.withValues(alpha: 0.28),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.deepRomanticPlum.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primaryRomanticBlush.withValues(alpha: 0.1),
          highlightColor: AppColors.softPinkSurface.withValues(alpha: 0.2),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
