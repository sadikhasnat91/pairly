import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/location_utils.dart';
import '../../../data/models/safe_arrival_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/partner_repository.dart';
import '../../../data/repositories/safe_arrival_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/notification_service.dart';

class SafeArrivalController extends GetxController {
  final SafeArrivalRepository _safeArrivalRepo =
      Get.find<SafeArrivalRepository>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final LocationRepository _locationRepo = Get.find<LocationRepository>();
  final LocationService _locationService = Get.find<LocationService>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final PartnerRepository _partnerRepo = Get.find<PartnerRepository>();

  final addressController = TextEditingController(text: 'Home');

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isEnabled = true.obs;
  final hasSavedSettings = false.obs;
  final hasArrived = false.obs;

  final homeLatitude = 0.0.obs;
  final homeLongitude = 0.0.obs;
  final homeAddress = ''.obs;
  final radiusMeters = 150.0.obs;

  final currentDistanceMeters = Rxn<double>();
  final currentDistanceText = Rxn<String>();

  final markers = <Marker>{}.obs;
  final circles = <Circle>{}.obs;

  GoogleMapController? mapController;
  StreamSubscription? _locSub;
  StreamSubscription? _partnerArrivalSub;

  // Geofence evaluation state
  bool _isInsideGeofence = false;
  int _consecutiveInsideCount = 0;
  DateTime? _lastArrivalNotificationTime;

  @override
  void onInit() {
    super.onInit();
    _loadSavedSettings();
    _bindLocationStream();
    _listenToPartnerArrivals();
  }

  Future<void> _loadSavedSettings() async {
    final currentUser = _authRepo.currentUser;
    if (currentUser == null) return;

    isLoading.value = true;
    try {
      final settings = await _safeArrivalRepo.getSettings(currentUser.id);
      if (settings != null) {
        hasSavedSettings.value = true;
        isEnabled.value = settings.isEnabled;
        homeLatitude.value = settings.homeLatitude;
        homeLongitude.value = settings.homeLongitude;
        homeAddress.value = settings.homeAddress ?? 'Home';
        addressController.text = homeAddress.value;
        radiusMeters.value = settings.geofenceRadiusMeters;
        _updateMapOverlay();
      } else {
        // Default to current location
        await setDestinationFromCurrentLocation(showSnackbar: false);
      }
    } catch (e) {
      debugPrint('[SafeArrivalController] Load settings error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _bindLocationStream() {
    _locSub = _locationRepo.userLocationStream.listen((loc) {
      if (loc == null || !hasSavedSettings.value || !isEnabled.value) return;

      final dist = LocationUtils.calculateDistanceInMeters(
        loc.latitude,
        loc.longitude,
        homeLatitude.value,
        homeLongitude.value,
      );

      currentDistanceMeters.value = dist;
      currentDistanceText.value = LocationUtils.formatDistance(dist);

      _evaluateGeofence(dist, loc.accuracy);
    });
  }

  /// Geofence engine with dwell verification, accuracy filtering & anti-flapping hysteresis
  void _evaluateGeofence(double distanceMeters, double accuracy) {
    // 1. Discard inaccurate readings to prevent false triggers from GPS drift
    if (accuracy > 60.0) {
      debugPrint(
          '[SafeArrivalController] Ignored GPS reading due to poor accuracy ($accuracy m)');
      return;
    }

    final radius = radiusMeters.value;
    final outerHysteresis = radius + 50.0;

    // 2. Check transition from OUTSIDE to INSIDE
    if (distanceMeters <= radius) {
      _consecutiveInsideCount++;

      // Require at least 2 consecutive valid readings inside geofence
      if (!_isInsideGeofence && _consecutiveInsideCount >= 2) {
        _isInsideGeofence = true;
        _onConfirmedArrival();
      }
    } else if (distanceMeters > outerHysteresis) {
      // Transition OUTSIDE only when beyond perimeter + hysteresis buffer
      _isInsideGeofence = false;
      _consecutiveInsideCount = 0;
      hasArrived.value = false;
    }
  }

  /// Trigger arrival notification workflow
  Future<void> _onConfirmedArrival() async {
    hasArrived.value = true;

    // Cooldown check (prevent multiple triggers within 30 minutes)
    final now = DateTime.now();
    if (_lastArrivalNotificationTime != null &&
        now.difference(_lastArrivalNotificationTime!).inMinutes < 30) {
      debugPrint('[SafeArrivalController] Arrival ignored due to cooldown window.');
      return;
    }
    _lastArrivalNotificationTime = now;

    final currentUser = _authRepo.currentUser;
    if (currentUser == null) return;

    final connection = _partnerRepo.currentConnection;
    final partner = _partnerRepo.partnerUser;

    // Unique idempotency key based on user and hour-block
    final idempotencyKey =
        'arrival_${currentUser.id}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}';

    // 1. Record event in Supabase
    final eventModel = SafeArrivalEventModel(
      userId: currentUser.id,
      connectionId: connection?.id,
      eventType: 'arrival',
      eventTimestamp: now,
      idempotencyKey: idempotencyKey,
      processingStatus: 'pending',
    );

    final createdEvent = await _safeArrivalRepo.createArrivalEvent(eventModel);

    // 2. Invoke Edge Function to deliver push notification to partner
    if (createdEvent?.id != null) {
      _safeArrivalRepo.invokeNotifyFunction(
        eventId: createdEvent!.id!,
        idempotencyKey: idempotencyKey,
      );
    }

    // 3. UI feedback
    final partnerName = partner?.displayName ?? 'your partner';
    Get.snackbar(
      '❤️ Arrived Home Safely',
      'You are safely home! $partnerName has been notified.',
      backgroundColor: AppColors.deepRomanticPlum,
      colorText: AppColors.warmCreamBackground,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Map camera created
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (homeLatitude.value != 0.0 && homeLongitude.value != 0.0) {
      _animateToLocation(homeLatitude.value, homeLongitude.value);
    }
  }

  /// Set location from Map Tap
  void onMapTap(LatLng position) {
    homeLatitude.value = position.latitude;
    homeLongitude.value = position.longitude;
    _updateMapOverlay();
  }

  /// Pick current device location as Home
  Future<void> setDestinationFromCurrentLocation({bool showSnackbar = true}) async {
    final pos = await _locationService.getCurrentPosition();
    if (pos == null) {
      if (showSnackbar) {
        Get.snackbar(
          'Location Unavailable',
          'Could not fetch your current GPS position.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }

    homeLatitude.value = pos.latitude;
    homeLongitude.value = pos.longitude;
    if (addressController.text.trim().isEmpty) {
      addressController.text = 'Home';
    }

    _updateMapOverlay();
    _animateToLocation(pos.latitude, pos.longitude);

    if (showSnackbar) {
      Get.snackbar(
        'Home Location Updated',
        'Coordinates pinned to your current location.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Save settings to Supabase
  Future<void> saveSettings() async {
    final currentUser = _authRepo.currentUser;
    if (currentUser == null) {
      Get.snackbar('Error', 'Please sign in to save settings.');
      return;
    }

    if (homeLatitude.value == 0.0 && homeLongitude.value == 0.0) {
      Get.snackbar('Missing Location', 'Please choose a valid home location.');
      return;
    }

    isSaving.value = true;
    try {
      final name = addressController.text.trim().isNotEmpty
          ? addressController.text.trim()
          : 'Home';

      final model = SafeArrivalSettingsModel(
        userId: currentUser.id,
        homeLatitude: homeLatitude.value,
        homeLongitude: homeLongitude.value,
        homeAddress: name,
        geofenceRadiusMeters: radiusMeters.value,
        isEnabled: isEnabled.value,
      );

      final saved = await _safeArrivalRepo.saveSettings(model);
      if (saved != null) {
        hasSavedSettings.value = true;
        homeAddress.value = name;
        Get.snackbar(
          'Safe Arrival Saved',
          'Your home perimeter has been successfully saved.',
          backgroundColor: AppColors.deepRomanticPlum,
          colorText: AppColors.warmCreamBackground,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', 'Failed to save settings. Please try again.');
      }
    } catch (e) {
      debugPrint('[SafeArrivalController] saveSettings error: $e');
      Get.snackbar('Error', 'Failed to save settings: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete settings
  Future<void> deleteSettings() async {
    final currentUser = _authRepo.currentUser;
    if (currentUser == null) return;

    final success = await _safeArrivalRepo.deleteSettings(currentUser.id);
    if (success) {
      hasSavedSettings.value = false;
      hasArrived.value = false;
      _isInsideGeofence = false;
      markers.clear();
      circles.clear();
      Get.snackbar('Safe Arrival Removed', 'Home address setting deleted.');
    }
  }

  /// Toggle feature enabled/disabled
  Future<void> toggleEnabled(bool val) async {
    isEnabled.value = val;
    if (!val) {
      hasArrived.value = false;
      _isInsideGeofence = false;
      _consecutiveInsideCount = 0;
    }

    // Persist enable state if already saved
    if (hasSavedSettings.value) {
      saveSettings();
    }
  }

  void onRadiusChanged(double newRadius) {
    radiusMeters.value = newRadius;
    _updateMapOverlay();
  }

  void _updateMapOverlay() {
    if (homeLatitude.value == 0.0 && homeLongitude.value == 0.0) return;

    final position = LatLng(homeLatitude.value, homeLongitude.value);

    // Marker
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('safe_home_target'),
        position: position,
        infoWindow: InfoWindow(
          title: addressController.text.trim().isNotEmpty
              ? addressController.text.trim()
              : 'Safe Arrival Location',
          snippet: 'Perimeter: ${radiusMeters.value.round()}m',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ),
    );

    // Circular Geofence Perimeter
    circles.clear();
    circles.add(
      Circle(
        circleId: const CircleId('safe_home_perimeter'),
        center: position,
        radius: radiusMeters.value,
        strokeWidth: 2,
        strokeColor: AppColors.softRose,
        fillColor: AppColors.primaryRomanticBlush.withValues(alpha: 0.25),
      ),
    );
  }

  void _animateToLocation(double lat, double lng) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 16.0,
        ),
      ),
    );
  }

  void _listenToPartnerArrivals() {
    final partner = _partnerRepo.partnerUser;
    if (partner != null) {
      _notificationService.listenToPartnerArrivalEvents(
        partnerId: partner.id,
        partnerName: partner.displayName.isNotEmpty
            ? partner.displayName
            : 'Your partner',
      );
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    _locSub?.cancel();
    _partnerArrivalSub?.cancel();
    super.onClose();
  }
}
