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
        color = AppColors.success;
        bgColor = AppColors.successBackground;
        label = customLabel ?? 'Live Location';
        icon = Icons.fiber_manual_record;
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
        bgColor = AppColors.cardSubtle;
        label = customLabel ?? 'Offline';
        icon = Icons.cloud_off;
        break;
      case StatusBadgeType.permissionDenied:
        color = AppColors.error;
        bgColor = AppColors.errorBackground;
        label = customLabel ?? 'Permission Denied';
        icon = Icons.location_disabled;
        break;
      case StatusBadgeType.gpsDisabled:
        color = AppColors.error;
        bgColor = AppColors.errorBackground;
        label = customLabel ?? 'GPS Turned Off';
        icon = Icons.gps_off;
        break;
      case StatusBadgeType.disconnected:
        color = AppColors.secondaryText;
        bgColor = AppColors.cardSubtle;
        label = customLabel ?? 'Disconnected';
        icon = Icons.link_off;
        break;
      case StatusBadgeType.pending:
        color = AppColors.info;
        bgColor = AppColors.infoBackground;
        label = customLabel ?? 'Pending Invite';
        icon = Icons.hourglass_top;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            if (type == StatusBadgeType.live)
              _PulsingDot(color: color)
            else
              Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.7),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
