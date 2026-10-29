import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum StatusBadgeType {
  live,
  paused,
  stale,
  offline,
  permissionDenied,
  gpsDisabled,
  disconnected,
  pending,
}

class StatusBadge extends StatelessWidget {
  final StatusBadgeType type;
  final String? customLabel;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.type,
    this.customLabel,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    String label;
    IconData? icon;

    switch (type) {
      case StatusBadgeType.live:
        color = AppColors.successAccent;
        bgColor = AppColors.successBackground;
        label = customLabel ?? 'Live Location';
        icon = Icons.favorite;
        break;
      case StatusBadgeType.paused:
        color = AppColors.warning;
        bgColor = AppColors.warningBackground;
        label = customLabel ?? 'Sharing Paused';
        icon = Icons.pause_circle_outline;
        break;
      case StatusBadgeType.stale:
        color = AppColors.warning;
        bgColor = AppColors.warningBackground;
        label = customLabel ?? 'Outdated Location';
        icon = Icons.schedule;
        break;
      case StatusBadgeType.offline:
        color = AppColors.tertiaryText;
        bgColor = AppColors.softPinkSurface;
        label = customLabel ?? 'Offline';
        icon = Icons.cloud_off;
        break;
      case StatusBadgeType.permissionDenied:
        color = AppColors.errorAccent;
        bgColor = AppColors.errorBackground;
        label = customLabel ?? 'Permission Denied';
        icon = Icons.location_disabled;
        break;
      case StatusBadgeType.gpsDisabled:
        color = AppColors.errorAccent;
        bgColor = AppColors.errorBackground;
        label = customLabel ?? 'GPS Turned Off';
        icon = Icons.gps_off;
        break;
      case StatusBadgeType.disconnected:
        color = AppColors.secondaryTextCol;
        bgColor = AppColors.softPinkSurface;
        label = customLabel ?? 'Disconnected';
        icon = Icons.link_off;
        break;
      case StatusBadgeType.pending:
        color = AppColors.softRose;
        bgColor = AppColors.softPinkSurface;
        label = customLabel ?? 'Pending Invite';
        icon = Icons.favorite_border;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            if (type == StatusBadgeType.live)
              _PulsingHeart(color: color)
            else
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ] else ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingHeart extends StatefulWidget {
  final Color color;

  const _PulsingHeart({required this.color});

  @override
  State<_PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<_PulsingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.6),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}