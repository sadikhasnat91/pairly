import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/location_data_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/partner_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/storage_service.dart';

class PrivacyController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final LocationRepository _locationRepo = Get.find<LocationRepository>();
  final PartnerRepository _partnerRepo = Get.find<PartnerRepository>();
  final LocationService _locationService = Get.find<LocationService>();
  final StorageService _storageService = Get.find<StorageService>();

  final isSharing = false.obs;
  final currentUser = Rxn<UserModel>();
  final partnerUser = Rxn<UserModel>();
  final userLocation = Rxn<LocationDataModel>();
  final isDeleting = false.obs;

  StreamSubscription? _locSub;

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  void _bind() {
    currentUser.value = _authRepo.currentUser;
    partnerUser.value = _partnerRepo.partnerUser;
    isSharing.value = _storageService.isSharingLocation;
    userLocation.value = _locationRepo.currentUserLocation;

    _locSub = _locationRepo.userLocationStream.listen((loc) {
      userLocation.value = loc;
    });
  }

  Future<void> toggleSharing() async {
    final user = _authRepo.currentUser;
    if (user == null) return;

    if (isSharing.value) {
      // Turn off
      await _locationService.stopTracking();
      await _locationRepo.setSharingStatus(uid: user.id, enabled: false);
      isSharing.value = false;
      Get.snackbar(
        'Sharing Paused',
        'Your live location is now completely invisible to your partner.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Turn on
      final state = await _locationService.checkServiceAndPermission();
      if (state == LocationServiceState.ready) {
        await _locationService.startTracking(
          onUpdate: (pos) {
            _locationRepo.updateCurrentLocation(
              uid: user.id,
              position: pos,
              isSharing: true,
            );
          },
        );
        await _locationRepo.setSharingStatus(uid: user.id, enabled: true);
        isSharing.value = true;
        Get.snackbar(
          'Sharing Active',
          'Your partner can now see your live coordinates.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Location Unavailable',
          'Please ensure location permissions and GPS are enabled.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void openAppSettings() {
    _locationService.openAppSettings();
  }

  Future<void> deleteAccount() async {
    final confirmed = await AppDialog.showConfirmation(
      title: 'Delete Pairly Account?',
      description: 'This permanently deletes your profile, disconnects your partner, and wipes your location records from our database. This action cannot be undone.',
      confirmText: 'Delete Permanently',
      isDanger: true,
      icon: Icons.delete_forever,
    );

    if (confirmed == true) {
      try {
        isDeleting.value = true;
        await _authRepo.deleteAccount();
        Get.offAllNamed(AppRoutes.welcome);
      } catch (e) {
        Get.snackbar(
          'Deletion Failed',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isDeleting.value = false;
      }
    }
  }

  @override
  void onClose() {
    _locSub?.cancel();
    super.onClose();
  }
}
