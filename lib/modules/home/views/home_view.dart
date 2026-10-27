import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/connection_status_card.dart';
import '../../../core/widgets/location_sharing_card.dart';
import '../../../core/widgets/partner_avatar.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting & Header
              _buildHeader(),
              const SizedBox(height: 20),

              // Permission / GPS Warning Banners
              Obx(() {
                if (controller.locationPermissionDenied.value) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppBanner(
                      message: 'Location permission is denied. Pairly cannot stream live location.',
                      actionLabel: 'Settings',
                      variant: BannerVariant.error,
                      onAction: controller.openAppSettings,
                    ),
                  );
                }
                if (controller.gpsServiceDisabled.value) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppBanner(
                      message: 'Device location (GPS) is turned off. Please enable GPS to share location.',
                      actionLabel: 'Enable',
                      variant: BannerVariant.warning,
                      onAction: controller.openLocationSettings,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Partner Connection Status Card
              Obx(() {
                final conn = controller.connection.value;
                final isConnected = conn != null && conn.isActive;
                final partner = controller.partnerUser.value;

                return ConnectionStatusCard(
                  isConnected: isConnected,
                  partnerName: partner?.displayName,
                  partnerPhotoUrl: partner?.photoUrl,
                  connectedAt: conn?.acceptedAt,
                  isPartnerSharing: controller.isPartnerSharing.value,
                  onInvitePartner: controller.navigateToPartner,
                  onManagePartner: controller.navigateToPartner,
                );
              }),
              const SizedBox(height: 18),

              // Location Sharing Status Card (User's own stream)
              Obx(() {
                final partner = controller.partnerUser.value;
                return LocationSharingCard(
                  isSharing: controller.isSharing.value,
                  isLoading: controller.isLoadingSharing.value,
                  lastUpdate: controller.userLocation.value?.updatedAt,
                  accuracyMeters: controller.userLocation.value?.accuracy,
                  partnerName: partner?.displayName,
                  onToggleSharing: controller.toggleLocationSharing,
                );
              }),
              const SizedBox(height: 22),

              // Partner Live Location Status Card
              _buildPartnerStatusSection(),
              const SizedBox(height: 22),

              // Quick Actions Row
              _buildQuickActions(),
              const SizedBox(height: 22),

              // Interactive Map Preview Card
              _buildMapPreview(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final name = controller.currentUser.value?.displayName ?? 'there';
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: controller.navigateToPrivacy,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildPartnerStatusSection() {
    return Obx(() {
      final conn = controller.connection.value;
      final isConnected = conn != null && conn.isActive;
      final partner = controller.partnerUser.value;
      final pLoc = controller.partnerLocation.value;
      final isSharing = controller.isPartnerSharing.value;
      final distance = controller.calculatedDistance.value;

      if (!isConnected) {
        return const SizedBox.shrink();
      }

      return AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PartnerAvatar(
                      name: partner?.displayName,
                      photoUrl: partner?.photoUrl,
                      size: 44,
                      isLive: isSharing && pLoc != null && !pLoc.isStale,
                      isSharing: isSharing,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${partner?.displayName ?? "Partner"}\'s Status',
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSharing
                              ? (distance ?? 'Live coordinates available')
                              : 'Location sharing is paused',
                          style: AppTypography.bodySmall.copyWith(
                            color: isSharing
                                ? AppColors.primaryAccent
                                : AppColors.secondaryText,
                            fontWeight: isSharing
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                StatusBadge(
                  type: !isSharing
                      ? StatusBadgeType.paused
                      : pLoc == null
                      ? StatusBadgeType.offline
                      : pLoc.isStale
                      ? StatusBadgeType.stale
                      : StatusBadgeType.live,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LAST KNOWN UPDATE', style: AppTypography.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      pLoc != null
                          ? DateFormatter.timeAgo(pLoc.updatedAt)
                          : 'No recent ping',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: controller.navigateToLiveMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardSubtle,
                    foregroundColor: AppColors.primaryAccent,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('Open Map'),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.my_location,
                title: 'Live Map',
                subtitle: 'Mutual Radar',
                color: AppColors.primaryAccent,
                onTap: controller.navigateToLiveMap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                icon: Icons.shield,
                title: 'Safe Arrival',
                subtitle: 'Destination Alerts',
                color: AppColors.secondaryAccent,
                onTap: controller.navigateToSafeArrival,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: AppColors.elevatedCard,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return AppCard(
      onTap: controller.navigateToLiveMap,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF0D131A),
            ),
            child: CustomPaint(painter: _MapGridPainter()),
          ),
          Container(
            height: 160,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primaryBackground.withValues(alpha: 0.85),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.pin_drop,
                              color: AppColors.primaryAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live Map Radar',
                              style: AppTypography.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to inspect live map & partner coordinates',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.primaryBackground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2836)
      ..strokeWidth = 1.0;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Concentric radar ring
    final radarPaint = Paint()
      ..color = AppColors.primaryAccent.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, radarPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 70, radarPaint);

    final dotPaint = Paint()
      ..color = AppColors.primaryAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
