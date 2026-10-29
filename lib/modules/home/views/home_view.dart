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
import '../../../app/routes/app_routes.dart';
import '../../video_call/controllers/video_call_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Romantic Greeting & Header
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
                      message: 'Device GPS is turned off. Please enable GPS to share location.',
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
      final hour = DateTime.now().hour;
      final greeting = hour < 12
          ? 'Good morning'
          : hour < 17
              ? 'Good afternoon'
              : 'Good evening';

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 13,
                    color: AppColors.softRose,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    greeting,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryTextCol,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                name,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.mainText,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: controller.navigateToPrivacy,
            tooltip: 'Privacy Center',
            icon: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.whiteCards,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.subtleBorders),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepRomanticPlum.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 20,
                color: AppColors.deepRomanticPlum,
              ),
            ),
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
                Expanded(
                  child: Row(
                    children: [
                      PartnerAvatar(
                        name: partner?.displayName,
                        photoUrl: partner?.photoUrl,
                        size: 48,
                        isLive: isSharing && pLoc != null && !pLoc.isStale,
                        isSharing: isSharing,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${partner?.displayName ?? "Partner"}\'s Location',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isSharing
                                  ? (distance ?? 'Live coordinates available')
                                  : 'Location sharing is paused',
                              style: AppTypography.bodySmall.copyWith(
                                color: isSharing
                                    ? AppColors.softRose
                                    : AppColors.secondaryTextCol,
                                fontWeight: isSharing
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LAST KNOWN UPDATE', style: AppTypography.labelSmall),
                      const SizedBox(height: 4),
                      Text(
                        pLoc != null
                            ? DateFormatter.timeAgo(pLoc.updatedAt)
                            : 'No recent ping',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mainText,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Request Live Video',
                  onPressed: () {
                    final conn = controller.connection.value;
                    final partner = controller.partnerUser.value;
                    if (conn != null && partner != null) {
                      final videoCtrl = Get.find<VideoCallController>();
                      Get.toNamed(AppRoutes.videoCall);
                      videoCtrl.initiateCall(
                        partnerId: partner.id,
                        connectionId: conn.id,
                        partnerDisplayName: partner.displayName.isNotEmpty
                            ? partner.displayName
                            : 'Partner',
                      );
                    }
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.softPinkSurface,
                    foregroundColor: AppColors.softRose,
                    side: const BorderSide(color: AppColors.subtleBorders),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 20, color: AppColors.softRose),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: controller.navigateToLiveMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softPinkSurface,
                    foregroundColor: AppColors.softRose,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.subtleBorders),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.near_me_rounded, size: 16),
                  label: Text(
                    'Open Map',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.softRose,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
            color: AppColors.secondaryTextCol,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.near_me_rounded,
                title: 'Live Map',
                subtitle: 'Mutual Radar',
                color: AppColors.softRose,
                onTap: controller.navigateToLiveMap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                icon: Icons.shield_rounded,
                title: 'Safe Arrival',
                subtitle: 'Destination Alerts',
                color: AppColors.successAccent,
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
      backgroundColor: AppColors.whiteCards,
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
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
            height: 165,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFFFBF4F2),
            ),
            child: CustomPaint(painter: _RomanticMapPreviewPainter()),
          ),
          Container(
            height: 165,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.warmCreamBackground.withValues(alpha: 0.88),
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
                              Icons.favorite_rounded,
                              color: AppColors.softRose,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live Map Radar',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.mainText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to inspect live map & partner coordinates',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryTextCol,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        gradient: AppColors.blushGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x35F4A6B8),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
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

class _RomanticMapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.subtleBorders.withValues(alpha: 0.7)
      ..strokeWidth = 1.0;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Concentric romantic radar rings
    final ringPaint = Paint()
      ..color = AppColors.primaryRomanticBlush.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 42, ringPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 74, ringPaint);

    // Center romantic heart dot
    final dotPaint = Paint()
      ..color = AppColors.softRose
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
