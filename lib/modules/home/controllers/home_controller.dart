import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/location_data_model.dart';
import '../../../data/models/partner_connection_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/partner_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/utils/location_utils.dart';
import '../../main_layout/controllers/main_layout_controller.dart';

class HomeController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final PartnerRepository _partnerRepo = Get.find<PartnerRepository>();
  final LocationRepository _locationRepo = Get.find<LocationRepository>();
  final LocationService _locationService = Get.find<LocationService>();
  final StorageService _storageService = Get.find<StorageService>();

  final currentUser = Rxn<UserModel>();
  final partnerUser = Rxn<UserModel>();
  final connection = Rxn<PartnerConnectionModel>();
  final userLocation = Rxn<LocationDataModel>();
  final partnerLocation = Rxn<LocationDataModel>();

  final isSharing = false.obs;
  final isPartnerSharing = false.obs;
  final isLoadingSharing = false.obs;
  final locationPermissionDenied = false.obs;
  final gpsServiceDisabled = false.obs;
  final calculatedDistance = Rxn<String>();

  StreamSubscription? _authSub;
  StreamSubscription? _connSub;
  StreamSubscription? _userLocSub;
  StreamSubscription? _partnerLocSub;
  StreamSubscription? _partnerShareSub;

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  void _bindStreams() {
    currentUser.value = _authRepo.currentUser;
    _authSub = _authRepo.authStateChanges.listen((user) {
      currentUser.value = user;
    });

    isSharing.value = _storageService.isSharingLocation;

    _connSub = _partnerRepo.connectionStream.listen((conn) {
      connection.value = conn;
      partnerUser.value = _partnerRepo.partnerUser;
      _recalculateDistance();
    });

    _userLocSub = _locationRepo.userLocationStream.listen((loc) {
      userLocation.value = loc;
      _recalculateDistance();
    });

    _partnerLocSub = _locationRepo.partnerLocationStream.listen((loc) {
      partnerLocation.value = loc;
      _recalculateDistance();
    });

    _partnerShareSub = _locationRepo.partnerSharingStream.listen((sharing) {
      isPartnerSharing.value = sharing;
    });

    // If preference was previously enabled, attempt restoring foreground stream
    if (isSharing.value) {
      startLocationSharing();
    }
  }

  void _recalculateDistance() {
    final userLoc = userLocation.value;
    final pLoc = partnerLocation.value;

    if (userLoc != null && pLoc != null && isPartnerSharing.value) {
      final meters = LocationUtils.calculateDistanceInMeters(
        userLoc.latitude,
        userLoc.longitude,
        pLoc.latitude,
        pLoc.longitude,
      );
      calculatedDistance.value = LocationUtils.formatDistance(meters);
    } else {
      calculatedDistance.value = null;
    }
  }

  Future<void> toggleLocationSharing() async {
    if (isSharing.value) {
      await stopLocationSharing();
    } else {
      await startLocationSharing();
    }
  }

  Future<void> startLocationSharing() async {
    isLoadingSharing.value = true;
    locationPermissionDenied.value = false;
    gpsServiceDisabled.value = false;

    final state = await _locationService.checkServiceAndPermission();
    if (state == LocationServiceState.disabled) {
      gpsServiceDisabled.value = true;
      isLoadingSharing.value = false;
      Get.snackbar(
        'GPS Disabled',
        'Please turn on system location (GPS) on your device.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    } else if (state == LocationServiceState.permissionDenied ||
        state == LocationServiceState.permissionDeniedForever) {
      locationPermissionDenied.value = true;
      isLoadingSharing.value = false;
      Get.snackbar(
        'Permission Denied',
        'Pairly requires location permission to share live coordinates with your partner.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Get current position first
    final currentPos = await _locationService.getCurrentPosition();
    final uid = currentUser.value?.id;
    if (currentPos != null && uid != null) {
      await _locationRepo.updateCurrentLocation(
        uid: uid,
        position: currentPos,
        isSharing: true,
      );
    }

    // Start stream
    final success = await _locationService.startTracking(
      onUpdate: (position) {
        if (uid != null) {
          _locationRepo.updateCurrentLocation(
            uid: uid,
            position: position,
            isSharing: true,
          );
        }
      },
      onError: (err) {
        Get.snackbar(
          'Location Stream Error',
          err.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    if (success) {
      isSharing.value = true;
      if (uid != null) {
        await _locationRepo.setSharingStatus(uid: uid, enabled: true);
      }
    }

    isLoadingSharing.value = false;
  }

  Future<void> stopLocationSharing() async {
    isLoadingSharing.value = true;
    await _locationService.stopTracking();
    final uid = currentUser.value?.id;
    if (uid != null) {
      await _locationRepo.setSharingStatus(uid: uid, enabled: false);
    }
    isSharing.value = false;
    isLoadingSharing.value = false;
  }

  void openAppSettings() {
    _locationService.openAppSettings();
  }

  void openLocationSettings() {
    _locationService.openLocationSettings();
  }

  void navigateToLiveMap() {
    Get.find<MainLayoutController>().changePage(1);
  }

  void navigateToPartner() {
    Get.find<MainLayoutController>().changePage(2);
  }

  void navigateToPrivacy() {
    Get.find<MainLayoutController>().changePage(3);
  }

  void navigateToSafeArrival() {
    Get.toNamed(AppRoutes.safeArrival);
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _connSub?.cancel();
    _userLocSub?.cancel();
    _partnerLocSub?.cancel();
    _partnerShareSub?.cancel();
    super.onClose();
  }
}
