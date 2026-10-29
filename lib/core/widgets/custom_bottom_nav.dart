import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 20, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.whiteCards.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.subtleBorders, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepRomanticPlum.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              index: 0,
              label: 'Home',
              icon: Icons.favorite_border_rounded,
              activeIcon: Icons.favorite_rounded,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              index: 1,
              label: 'Live Map',
              icon: Icons.near_me_outlined,
              activeIcon: Icons.near_me_rounded,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              index: 2,
              label: 'Partner',
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              index: 3,
              label: 'Privacy',
              icon: Icons.shield_outlined,
              activeIcon: Icons.shield_rounded,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              index: 4,
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softPinkSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: AppColors.primaryRomanticBlush.withValues(alpha: 0.5),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected
                  ? AppColors.softRose
                  : AppColors.secondaryTextCol,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.deepRomanticPlum
                    : AppColors.secondaryTextCol,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
