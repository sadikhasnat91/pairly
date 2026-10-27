import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/location_utils.dart';
import '../../../data/models/location_data_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/partner_repository.dart';
import '../../../data/services/location_service.dart';

class LiveMapController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final PartnerRepository _partnerRepo = Get.find<PartnerRepository>();
  final LocationRepository _locationRepo = Get.find<LocationRepository>();
  final LocationService _locationService = Get.find<LocationService>();

  GoogleMapController? mapController;

  final markers = <Marker>{}.obs;
  final circles = <Circle>{}.obs;
  final isMapLoading = true.obs;

  final currentUser = Rxn<UserModel>();
  final partnerUser = Rxn<UserModel>();
  final userLocation = Rxn<LocationDataModel>();
  final partnerLocation = Rxn<LocationDataModel>();
  final isPartnerSharing = false.obs;
  final isUserSharing = false.obs;

  final distanceText = Rxn<String>();
  final travelTimeEstimate = Rxn<String>();
  final hasPermissionError = false.obs;

  StreamSubscription? _userLocSub;
  StreamSubscription? _partnerLocSub;
  StreamSubscription? _partnerShareSub;
  StreamSubscription? _connSub;

  @override
  void onInit() {
    super.onInit();
    _initData();
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      final pos = await _locationService.getCurrentPosition();
      final uid = _authRepo.currentUser?.id;
      if (pos != null && uid != null) {
        await _locationRepo.updateCurrentLocation(
          uid: uid,
          position: pos,
          isSharing: true,
        );
        final latLng = LatLng(pos.latitude, pos.longitude);
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: AppConstants.defaultZoom),
          ),
        );
      }
    } catch (_) {}
  }

  void _initData() {
    currentUser.value = _authRepo.currentUser;
    partnerUser.value = _partnerRepo.partnerUser;
    userLocation.value = _locationRepo.currentUserLocation;
    partnerLocation.value = _locationRepo.partnerLocation;
    isPartnerSharing.value = _locationRepo.isPartnerSharing;

    _connSub = _partnerRepo.connectionStream.listen((conn) {
      partnerUser.value = _partnerRepo.partnerUser;
      _updateMapEntities();
    });

    _userLocSub = _locationRepo.userLocationStream.listen((loc) {
      userLocation.value = loc;
      if (loc != null) isUserSharing.value = loc.isSharing;
      _updateMapEntities();
    });

    _partnerLocSub = _locationRepo.partnerLocationStream.listen((loc) {
      partnerLocation.value = loc;
      _updateMapEntities();
    });

    _partnerShareSub = _locationRepo.partnerSharingStream.listen((sharing) {
      isPartnerSharing.value = sharing;
      _updateMapEntities();
    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    isMapLoading.value = false;
    _updateMapEntities();
    fetchCurrentLocation();
    fitBothMarkers();
  }

  Future<void> _updateMapEntities() async {
    final newMarkers = <Marker>{};
    final newCircles = <Circle>{};

    final uLoc = userLocation.value;
    final pLoc = partnerLocation.value;
    final pUser = partnerUser.value;
    final uUser = currentUser.value;

    // 1. Current user marker & accuracy circle
    if (uLoc != null) {
      final uLatLng = LatLng(uLoc.latitude, uLoc.longitude);
      final uIcon = await _createCustomMarkerBitmap(
        label: uUser?.displayName.isNotEmpty == true
            ? uUser!.displayName[0].toUpperCase()
            : 'ME',
        borderColor: AppColors.primaryAccent,
        fillColor: AppColors.primaryBackground,
      );

      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_me'),
          position: uLatLng,
          icon: uIcon,
          zIndexInt: 2,
          infoWindow: InfoWindow(
            title: 'You',
            snippet: uLoc.isSharing ? 'Streaming live' : 'Sharing paused',
          ),
        ),
      );

      newCircles.add(
        Circle(
          circleId: const CircleId('user_accuracy'),
          center: uLatLng,
          radius: uLoc.accuracy.clamp(10, 100),
          fillColor: AppColors.primaryAccent.withValues(alpha: 0.12),
          strokeColor: AppColors.primaryAccent.withValues(alpha: 0.4),
          strokeWidth: 1,
        ),
      );
    }

    // 2. Partner marker & accuracy circle (only if partner is sharing & location available)
    if (pLoc != null && isPartnerSharing.value) {
      final pLatLng = LatLng(pLoc.latitude, pLoc.longitude);
      final isFresh = !pLoc.isStale;
      final pColor = isFresh ? AppColors.secondaryAccent : AppColors.warning;

      final pIcon = await _createCustomMarkerBitmap(
        label: pUser?.displayName.isNotEmpty == true
            ? pUser!.displayName[0].toUpperCase()
            : 'P',
        borderColor: pColor,
        fillColor: AppColors.primaryBackground,
      );

      newMarkers.add(
        Marker(
          markerId: const MarkerId('partner_marker'),
          position: pLatLng,
          icon: pIcon,
          zIndexInt: 3,
          infoWindow: InfoWindow(
            title: pUser?.displayName ?? 'Partner',
            snippet: isFresh ? 'Live location' : 'Outdated location',
          ),
        ),
      );

      newCircles.add(
        Circle(
          circleId: const CircleId('partner_accuracy'),
          center: pLatLng,
          radius: pLoc.accuracy.clamp(10, 150),
          fillColor: pColor.withValues(alpha: 0.1),
          strokeColor: pColor.withValues(alpha: 0.35),
          strokeWidth: 1,
        ),
      );
    }

    markers.assignAll(newMarkers);
    circles.assignAll(newCircles);

    // Compute metrics
    if (uLoc != null && pLoc != null && isPartnerSharing.value) {
      final meters = LocationUtils.calculateDistanceInMeters(
        uLoc.latitude,
        uLoc.longitude,
        pLoc.latitude,
        pLoc.longitude,
      );
      distanceText.value = LocationUtils.formatDistance(meters);
      travelTimeEstimate.value = LocationUtils.estimateTravelTime(meters);
    } else {
      distanceText.value = null;
      travelTimeEstimate.value = null;
    }
  }

  /// Generates a crisp canvas bitmap marker with initials and colored ring
  Future<BitmapDescriptor> _createCustomMarkerBitmap({
    required String label,
    required Color borderColor,
    required Color fillColor,
  }) async {
    const size = 110.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

    // Outer glow / shadow
    final shadowPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(const Offset(size / 2, size / 2), 44, shadowPaint);

    // Background circle
    final bgPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), 40, bgPaint);

    // Border ring
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(const Offset(size / 2, size / 2), 40, borderPaint);

    // Text label (Initial)
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: borderColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes == null) {
      return BitmapDescriptor.defaultMarker;
    }
    return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
  }

  /// Recenter camera on user's location
  void recenterUser() {
    final loc = userLocation.value;
    if (loc != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(loc.latitude, loc.longitude),
            zoom: AppConstants.defaultZoom,
          ),
        ),
      );
    }
  }

  /// Recenter camera on partner's location
  void recenterPartner() {
    final loc = partnerLocation.value;
    if (loc != null && isPartnerSharing.value && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(loc.latitude, loc.longitude),
            zoom: AppConstants.defaultZoom,
          ),
        ),
      );
    }
  }

  /// Fit both user and partner within screen bounds
  void fitBothMarkers() {
    final uLoc = userLocation.value;
    final pLoc = partnerLocation.value;

    if (mapController == null) return;

    if (uLoc != null && pLoc != null && isPartnerSharing.value) {
      final bounds = LocationUtils.createBounds(
        LatLng(uLoc.latitude, uLoc.longitude),
        LatLng(pLoc.latitude, pLoc.longitude),
      );
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } else if (uLoc != null) {
      recenterUser();
    } else if (pLoc != null) {
      recenterPartner();
    }
  }

  void openAppSettings() {
    _locationService.openAppSettings();
  }

  @override
  void onClose() {
    _userLocSub?.cancel();
    _partnerLocSub?.cancel();
    _partnerShareSub?.cancel();
    _connSub?.cancel();
    mapController?.dispose();
    super.onClose();
  }
}
