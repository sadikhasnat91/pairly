import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class LocationRepository {
  final FirebaseService firebaseService;
  final StorageService storageService;

  final _userLocationController = StreamController<LocationDataModel?>.broadcast();
  Stream<LocationDataModel?> get userLocationStream => _userLocationController.stream;

  final _partnerLocationController = StreamController<LocationDataModel?>.broadcast();
  Stream<LocationDataModel?> get partnerLocationStream => _partnerLocationController.stream;

  final _partnerSharingController = StreamController<bool>.broadcast();
  Stream<bool> get partnerSharingStream => _partnerSharingController.stream;

  LocationDataModel? _currentUserLocation;
  LocationDataModel? get currentUserLocation => _currentUserLocation;

  LocationDataModel? _partnerLocation;
  LocationDataModel? get partnerLocation => _partnerLocation;

  bool _isPartnerSharing = false;
  bool get isPartnerSharing => _isPartnerSharing;

  StreamSubscription? _partnerLocSubscription;
  StreamSubscription? _partnerSharingSubscription;

  LocationRepository({
    required this.firebaseService,
    required this.storageService,
  });

  /// Update current user's live coordinates in Firestore `locations/{uid}`
  Future<void> updateCurrentLocation({
    required String uid,
    required Position position,
    required bool isSharing,
  }) async {
    final now = DateTime.now();
    final model = LocationDataModel(
      uid: uid,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      updatedAt: now,
      isSharing: isSharing,
    );

    _currentUserLocation = model;
    _userLocationController.add(model);

    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      try {
        await firebaseService.firestore!.collection('locations').doc(uid).set(
              model.toJson(),
              SetOptions(merge: true),
            );
      } catch (_) {}
    }
  }

  /// Toggle or update sharing status in `locationSharing/{uid}`
  Future<void> setSharingStatus({
    required String uid,
    required bool enabled,
  }) async {
    await storageService.setSharingLocation(enabled);

    if (_currentUserLocation != null) {
      _currentUserLocation = _currentUserLocation!.copyWith(isSharing: enabled);
      _userLocationController.add(_currentUserLocation);
    }

    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      try {
        await firebaseService.firestore!.collection('locationSharing').doc(uid).set({
          'enabled': enabled,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        // Also reflect in latest location document
        await firebaseService.firestore!.collection('locations').doc(uid).set({
          'isSharing': enabled,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// Listen to partner's location updates and sharing status
  void listenToPartnerLocation(String? partnerUid) {
    _partnerLocSubscription?.cancel();
    _partnerSharingSubscription?.cancel();

    if (partnerUid == null || partnerUid.isEmpty) {
      _partnerLocation = null;
      _isPartnerSharing = false;
      _partnerLocationController.add(null);
      _partnerSharingController.add(false);
      return;
    }

    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      // 1. Listen to partner's sharing status
      _partnerSharingSubscription = firebaseService.firestore!
          .collection('locationSharing')
          .doc(partnerUid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          final enabled = doc.data()!['enabled'] as bool? ?? false;
          _isPartnerSharing = enabled;
          _partnerSharingController.add(enabled);
        } else {
          _isPartnerSharing = false;
          _partnerSharingController.add(false);
        }
      });

      // 2. Listen to partner's coordinate document
      _partnerLocSubscription = firebaseService.firestore!
          .collection('locations')
          .doc(partnerUid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          final loc = LocationDataModel.fromJson(doc.data()!);
          _partnerLocation = loc;
          _partnerLocationController.add(loc);
        } else {
          _partnerLocation = null;
          _partnerLocationController.add(null);
        }
      });
    } else {
      // Local demo mode: provide simulated partner location nearby
      _isPartnerSharing = true;
      _partnerSharingController.add(true);

      final now = DateTime.now();
      final simulated = LocationDataModel(
        uid: partnerUid,
        latitude: 37.7833,
        longitude: -122.4167,
        accuracy: 12.0,
        updatedAt: now.subtract(const Duration(minutes: 2)),
        isSharing: true,
      );
      _partnerLocation = simulated;
      _partnerLocationController.add(simulated);
    }
  }

  void stopListeningPartner() {
    _partnerLocSubscription?.cancel();
    _partnerSharingSubscription?.cancel();
  }

  void dispose() {
    stopListeningPartner();
    _userLocationController.close();
    _partnerLocationController.close();
    _partnerSharingController.close();
  }
}
