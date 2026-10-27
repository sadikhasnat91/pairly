import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Safe Arrival Alert', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automatic Arrival Alert',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Let your partner know the moment you arrive safely at your destination without having to remember to text.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Destination Config Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: controller.titleController,
                      label: 'Destination Name',
                      hintText: 'e.g. Home, Office, Gym',
                      prefixIcon: Icons.place_outlined,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Perimeter Radius',
                          style: AppTypography.labelLarge,
                        ),
                        Obx(
                          () => Text(
                            '${controller.radiusMeters.value.round()} meters',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Slider(
                        value: controller.radiusMeters.value,
                        min: 50,
                        max: 500,
                        divisions: 9,
                        activeColor: AppColors.primaryAccent,
                        inactiveColor: AppColors.cardSubtle,
                        onChanged: (val) => controller.radiusMeters.value = val,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Set Current Location as Target',
                      variant: AppButtonVariant.secondary,
                      leadingIcon: Icons.my_location,
                      onPressed: controller.setDestinationFromCurrentLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active Status Card
              Obx(() {
                final dest = controller.activeDestination.value;
                if (dest == null) {
                  return const SizedBox.shrink();
                }

                return AppCard(
                  borderColor: controller.isEnabled.value
                      ? AppColors.primaryAccent
                      : AppColors.border,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dest.title,
                                style: AppTypography.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.hasArrived.value
                                    ? 'Arrived safely!'
                                    : (controller.currentDistanceText.value ??
                                          'Monitoring in progress'),
                                style: AppTypography.bodySmall.copyWith(
                                  color: controller.hasArrived.value
                                      ? AppColors.success
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: controller.isEnabled.value,
                            activeThumbColor: AppColors.primaryAccent,
                            onChanged: controller.toggleEnabled,
                          ),
                        ],
                      ),
                      if (controller.hasArrived.value) ...[
                        const SizedBox(height: 14),
                        const StatusBadge(
                          type: StatusBadgeType.live,
                          customLabel: 'Partner Notified',
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
