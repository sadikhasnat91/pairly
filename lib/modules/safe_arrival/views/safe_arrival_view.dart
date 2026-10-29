import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/safe_arrival_controller.dart';

class SafeArrivalView extends GetView<SafeArrivalController> {
  const SafeArrivalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      appBar: AppBar(
        title: Text(
          'Safe Arrival Alerts',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.mainText,
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.softRose),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Romantic Card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.softPinkSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: AppColors.deepRomanticPlum,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Safe Arrival Alert',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Automatically let your love know when you reach home safely.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondaryTextCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: controller.isEnabled.value,
                        activeThumbColor: AppColors.softRose,
                        activeTrackColor:
                            AppColors.primaryRomanticBlush.withValues(alpha: 0.35),
                        inactiveTrackColor: AppColors.softPinkSurface,
                        onChanged: controller.toggleEnabled,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Map Picker & Preview Card
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Home Geofence Area',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Tap map to set pin',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.softRose,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                controller.homeLatitude.value != 0.0
                                    ? controller.homeLatitude.value
                                    : AppConstants.defaultLatitude,
                                controller.homeLongitude.value != 0.0
                                    ? controller.homeLongitude.value
                                    : AppConstants.defaultLongitude,
                              ),
                              zoom: 15.0,
                            ),
                            onMapCreated: controller.onMapCreated,
                            onTap: controller.onMapTap,
                            markers: controller.markers.toSet(),
                            circles: controller.circles.toSet(),
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            compassEnabled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        text: 'Pin Current Location as Home',
                        variant: AppButtonVariant.secondary,
                        leadingIcon: Icons.my_location_rounded,
                        onPressed: () =>
                            controller.setDestinationFromCurrentLocation(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Settings Form Card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: controller.addressController,
                        label: 'Destination Name / Label',
                        hintText: 'e.g. Sweet Home, Apartment',
                        prefixIcon: Icons.home_filled,
                      ),
                      const SizedBox(height: 20),

                      // Radius Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Arrival Perimeter Radius',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${controller.radiusMeters.value.round()} meters',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.softRose,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: controller.radiusMeters.value,
                        min: 50,
                        max: 500,
                        divisions: 9,
                        activeColor: AppColors.softRose,
                        inactiveColor: AppColors.softPinkSurface,
                        onChanged: controller.onRadiusChanged,
                      ),
                      Text(
                        'A 100-200m buffer accounts for typical GPS building drift and ensures dependable arrival detection.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryTextCol,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Obx(
                        () => AppButton(
                          text: controller.hasSavedSettings.value
                              ? 'Update Safe Arrival Settings'
                              : 'Save Home Address',
                          leadingIcon: Icons.favorite_rounded,
                          isLoading: controller.isSaving.value,
                          onPressed: controller.saveSettings,
                        ),
                      ),
                      if (controller.hasSavedSettings.value) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: controller.deleteSettings,
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.errorAccent),
                            label: Text(
                              'Remove Home Geofence',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.errorAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Live Arrival Status Card
                if (controller.hasSavedSettings.value) ...[
                  AppCard(
                    borderColor: controller.hasArrived.value
                        ? AppColors.successAccent
                        : AppColors.subtleBorders,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.addressController.text.trim().isNotEmpty
                                  ? controller.addressController.text.trim()
                                  : 'Home',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.hasArrived.value
                                  ? 'Safely inside home perimeter ❤️'
                                  : (controller.currentDistanceText.value ??
                                      'Calculating distance...'),
                              style: AppTypography.bodySmall.copyWith(
                                color: controller.hasArrived.value
                                    ? AppColors.successAccent
                                    : AppColors.secondaryTextCol,
                                fontWeight: controller.hasArrived.value
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        if (controller.hasArrived.value)
                          const StatusBadge(
                            type: StatusBadgeType.live,
                            customLabel: 'Partner Notified',
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softPinkSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primaryRomanticBlush
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              '${controller.radiusMeters.value.round()}m fence',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.deepRomanticPlum,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Background & Battery Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softPinkSurface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.subtleBorders.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: AppColors.softRose,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Background Location permission is required so Pairly can notify your partner automatically even when your phone is in your pocket or the screen is off.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryTextCol,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
    );
  }
}
