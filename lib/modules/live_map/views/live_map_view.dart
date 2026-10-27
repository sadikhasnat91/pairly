import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/map_style.dart';
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
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          // Interactive Google Map with Error Fallback
          Obx(() {
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

            return _buildMapBody(initialTarget);
          }),

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

  Widget _buildMapBody(LatLng initialTarget) {
    Widget mapWidget;
    try {
      mapWidget = GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialTarget,
          zoom: AppConstants.defaultZoom,
        ),
        style: MapStyle.darkThemeJson,
        onMapCreated: controller.onMapCreated,
        markers: controller.markers,
        circles: controller.circles,
        myLocationEnabled: false, // Prevents duplicate blue dot overlapping with custom ME marker
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: true,
        mapToolbarEnabled: false,
      );
    } catch (e) {
      mapWidget = _buildMapFallback(initialTarget);
    }

    return mapWidget;
  }

  Widget _buildMapFallback(LatLng target) {
    return Container(
      color: const Color(0xFF0D131A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                color: AppColors.primaryAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Live Map Radar',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${target.latitude.toStringAsFixed(4)}, Lng: ${target.longitude.toStringAsFixed(4)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
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
              color: AppColors.secondaryBackground.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.radar,
                  color: AppColors.primaryAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Radar',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
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
          icon: Icons.all_inclusive,
          tooltip: 'Fit both partners',
          onTap: controller.fitBothMarkers,
        ),
        const SizedBox(height: 10),
        _buildCircleButton(
          icon: Icons.my_location,
          tooltip: 'Recenter on me',
          onTap: controller.recenterUser,
        ),
        const SizedBox(height: 10),
        _buildCircleButton(
          icon: Icons.favorite,
          iconColor: AppColors.secondaryAccent,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.primaryAccent,
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
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
        child: AppCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: AppColors.elevatedCard.withValues(alpha: 0.96),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  PartnerAvatar(
                    name: partner?.displayName,
                    photoUrl: partner?.photoUrl,
                    size: 50,
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
                                style: AppTypography.titleMedium,
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
                                  color: AppColors.primaryAccent.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  dist,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primaryAccent,
                                    fontWeight: FontWeight.w700,
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
                          style: AppTypography.bodySmall,
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
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.gps_fixed,
                            size: 14,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Accuracy: ±${pLoc.accuracy.round()}m',
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.formatTimestamp(pLoc.updatedAt),
                            style: AppTypography.labelSmall,
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
