import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/partner_avatar.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/live_map_controller.dart';

class LiveMapView extends GetView<LiveMapController> {
  const LiveMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial target computed once for initial camera position
    final uLoc = controller.userLocation.value;
    final pLoc = controller.partnerLocation.value;
    final initialTarget = uLoc != null
        ? LatLng(uLoc.latitude, uLoc.longitude)
        : pLoc != null
        ? LatLng(pLoc.latitude, pLoc.longitude)
        : const LatLng(
            AppConstants.defaultLatitude,
            AppConstants.defaultLongitude,
          );

    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      body: Stack(
        children: [
          // Stable Interactive Google Map with reactive markers & circles
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: AppConstants.defaultZoom,
              ),
              onMapCreated: controller.onMapCreated,
              markers: controller.markers.toSet(),
              circles: controller.circles.toSet(),
              myLocationEnabled: false, // Prevents duplicate blue dot overlapping with custom marker
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
            ),
          ),

          // Top Status Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildTopOverlay(),
              ),
            ),
          ),

          // Floating Map Action Buttons
          Positioned(right: 16, bottom: 220, child: _buildMapControls()),

          // Bottom Partner Information Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPartnerSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Obx(() {
      final pLoc = controller.partnerLocation.value;
      final isSharing = controller.isPartnerSharing.value;
      final partner = controller.partnerUser.value;

      StatusBadgeType badgeType;
      if (partner == null) {
        badgeType = StatusBadgeType.disconnected;
      } else if (!isSharing) {
        badgeType = StatusBadgeType.paused;
      } else if (pLoc == null) {
        badgeType = StatusBadgeType.offline;
      } else if (pLoc.isStale) {
        badgeType = StatusBadgeType.stale;
      } else {
        badgeType = StatusBadgeType.live;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.whiteCards.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.subtleBorders),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepRomanticPlum.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.softRose,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Radar',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(type: badgeType),
        ],
      );
    });
  }

  Widget _buildMapControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircleButton(
          icon: Icons.all_inclusive_rounded,
          tooltip: 'Fit both partners',
          onTap: controller.fitBothMarkers,
        ),
        const SizedBox(height: 10),
        _buildCircleButton(
          icon: Icons.my_location_rounded,
          tooltip: 'Recenter on me',
          onTap: controller.recenterUser,
        ),
        const SizedBox(height: 10),
        _buildCircleButton(
          icon: Icons.favorite_rounded,
          iconColor: AppColors.softRose,
          tooltip: 'Recenter on partner',
          onTap: controller.recenterPartner,
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.whiteCards.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.subtleBorders, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepRomanticPlum.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.deepRomanticPlum,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPartnerSheet() {
    return Obx(() {
      final partner = controller.partnerUser.value;
      final pLoc = controller.partnerLocation.value;
      final isSharing = controller.isPartnerSharing.value;
      final dist = controller.distanceText.value;
      final eta = controller.travelTimeEstimate.value;

      return Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 94),
        child: AppCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: AppColors.whiteCards.withValues(alpha: 0.96),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  PartnerAvatar(
                    name: partner?.displayName,
                    photoUrl: partner?.photoUrl,
                    size: 52,
                    isLive: isSharing && pLoc != null && !pLoc.isStale,
                    isSharing: isSharing,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                partner?.displayName ?? 'No Partner Connected',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (dist != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.softPinkSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.primaryRomanticBlush.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  dist,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.softRose,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSharing
                              ? (eta != null
                                  ? '$eta away • Updated ${DateFormatter.timeAgo(pLoc?.updatedAt)}'
                                  : 'Sharing active')
                              : 'Partner has paused location sharing',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryTextCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (pLoc != null && isSharing) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softPinkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.subtleBorders,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.gps_fixed_rounded,
                            size: 14,
                            color: AppColors.secondaryTextCol,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Accuracy: ±${pLoc.accuracy.round()}m',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondaryTextCol,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.secondaryTextCol,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.formatTimestamp(pLoc.updatedAt),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondaryTextCol,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
