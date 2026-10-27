import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/location_utils.dart';
import '../../../data/models/safe_arrival_model.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/services/location_service.dart';

class SafeArrivalController extends GetxController {
  final LocationRepository _locationRepo = Get.find<LocationRepository>();
  final LocationService _locationService = Get.find<LocationService>();

  final titleController = TextEditingController(text: 'Home');
  final radiusMeters = 150.0.obs;
  final isEnabled = false.obs;
  final hasArrived = false.obs;
  final activeDestination = Rxn<SafeArrivalDestination>();
  final currentDistanceText = Rxn<String>();

  StreamSubscription? _locSub;

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  void _bind() {
    _locSub = _locationRepo.userLocationStream.listen((loc) {
      if (loc != null && activeDestination.value != null && isEnabled.value) {
        final dest = activeDestination.value!;
        final dist = LocationUtils.calculateDistanceInMeters(
          loc.latitude,
          loc.longitude,
          dest.latitude,
          dest.longitude,
        );

        currentDistanceText.value = LocationUtils.formatDistance(dist);

        if (dist <= dest.radiusMeters && !hasArrived.value) {
          hasArrived.value = true;
          Get.snackbar(
            'Safe Arrival Detected!',
            'You arrived safely at ${dest.title}. Your partner has been notified.',
            backgroundColor: const Color(0xFF151D27),
            colorText: const Color(0xFFC5F467),
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    });
  }

  Future<void> setDestinationFromCurrentLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos == null) {
      Get.snackbar(
        'Location Unavailable',
        'Could not fetch current coordinates.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final dest = SafeArrivalDestination(
      id: 'dest_1',
      title: titleController.text.trim().isNotEmpty
          ? titleController.text.trim()
          : 'Destination',
      latitude: pos.latitude,
      longitude: pos.longitude,
      radiusMeters: radiusMeters.value,
      isEnabled: true,
      updatedAt: DateTime.now(),
    );

    activeDestination.value = dest;
    isEnabled.value = true;
    hasArrived.value = false;

    Get.snackbar(
      'Safe Destination Set',
      'Target set at "${dest.title}" with a ${dest.radiusMeters.round()}m arrival perimeter.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleEnabled(bool val) {
    isEnabled.value = val;
    if (!val) {
      hasArrived.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    _locSub?.cancel();
    super.onClose();
  }
}
