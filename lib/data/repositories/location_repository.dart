import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data_model.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class LocationRepository {
  final SupabaseService supabaseService;
  final StorageService storageService;

  final _userLocationController =
      StreamController<LocationDataModel?>.broadcast();
  Stream<LocationDataModel?> get userLocationStream =>
      _userLocationController.stream;

  final _partnerLocationController =
      StreamController<LocationDataModel?>.broadcast();
  Stream<LocationDataModel?> get partnerLocationStream =>
      _partnerLocationController.stream;

  final _partnerSharingController = StreamController<bool>.broadcast();
  Stream<bool> get partnerSharingStream => _partnerSharingController.stream;

  LocationDataModel? _currentUserLocation;
  LocationDataModel? get currentUserLocation => _currentUserLocation;

  LocationDataModel? _partnerLocation;
  LocationDataModel? get partnerLocation => _partnerLocation;

  bool _isPartnerSharing = false;
  bool get isPartnerSharing => _isPartnerSharing;

  StreamSubscription? _partnerLocSubscription;
  Timer? _partnerPollTimer;

  LocationDataModel? _pendingUploadModel;
  DateTime? _lastUploadedAt;

  LocationRepository({
    required this.supabaseService,
    required this.storageService,
  });

  /// Update current user's live coordinates in Supabase `locations` table
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

    // Throttle identical stationary uploads if less than 5s apart to save battery & bandwidth
    if (_lastUploadedAt != null &&
        now.difference(_lastUploadedAt!).inSeconds < 5 &&
        _pendingUploadModel == null) {
      return;
    }

    if (supabaseService.isConfigured && supabaseService.client != null) {
      try {
        await supabaseService.client!.from('locations').upsert(
              model.toJson(),
              onConflict: 'uid',
            );
        _lastUploadedAt = now;
        _pendingUploadModel = null;
      } catch (e) {
        debugPrint('[LocationRepository] updateCurrentLocation error: $e');
        _pendingUploadModel = model;
      }
    } else {
      _pendingUploadModel = model;
    }
  }

  /// Toggle or update sharing status in `locations` table
  Future<void> setSharingStatus({
    required String uid,
    required bool enabled,
  }) async {
    await storageService.setSharingLocation(enabled);

    if (_currentUserLocation != null) {
      _currentUserLocation = _currentUserLocation!.copyWith(isSharing: enabled);
      _userLocationController.add(_currentUserLocation);
    }

    if (supabaseService.isConfigured && supabaseService.client != null) {
      try {
        await supabaseService.client!
            .from('locations')
            .update({
              'isSharing': enabled,
              'updatedAt': DateTime.now().toIso8601String(),
            })
            .eq('uid', uid);
      } catch (e) {
        debugPrint('[LocationRepository] setSharingStatus error: $e');
      }
    }
  }

  /// Listen to partner's location updates and sharing status
  void listenToPartnerLocation(String? partnerUid) {
    _partnerLocSubscription?.cancel();
    _partnerPollTimer?.cancel();

    if (partnerUid == null || partnerUid.isEmpty) {
      _partnerLocation = null;
      _isPartnerSharing = false;
      _partnerLocationController.add(null);
      _partnerSharingController.add(false);
      return;
    }

    if (supabaseService.isConfigured && supabaseService.client != null) {
      // 1. Initial immediate fetch
      _fetchInitialPartnerLocation(partnerUid);

      // 2. High-reliability fallback polling timer (3s) ensures updates arrive even when mobile websockets drop
      _partnerPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _fetchInitialPartnerLocation(partnerUid);
      });

      // 3. Stream partner updates via Supabase Realtime
      try {
        _partnerLocSubscription = supabaseService.client!
            .from('locations')
            .stream(primaryKey: ['uid'])
            .eq('uid', partnerUid)
            .listen(
              (List<Map<String, dynamic>> records) {
                if (records.isNotEmpty) {
                  final loc = LocationDataModel.fromJson(records.first);
                  _applyPartnerLocationUpdate(loc);
                }
              },
              onError: (err) {
                debugPrint('[LocationRepository] Partner stream error: $err');
                _fetchInitialPartnerLocation(partnerUid);
              },
            );
      } catch (e) {
        debugPrint('[LocationRepository] Stream listener setup error: $e');
        _fetchInitialPartnerLocation(partnerUid);
      }
    } else {
      _partnerLocation = null;
      _partnerLocationController.add(null);
      _isPartnerSharing = false;
      _partnerSharingController.add(false);
    }
  }

  Future<void> _fetchInitialPartnerLocation(String partnerUid) async {
    try {
      if (supabaseService.client == null) return;
      final res = await supabaseService.client!
          .from('locations')
          .select()
          .eq('uid', partnerUid)
          .maybeSingle();

      if (res != null) {
        final loc = LocationDataModel.fromJson(Map<String, dynamic>.from(res));
        _applyPartnerLocationUpdate(loc);
      }
    } catch (e) {
      debugPrint('[LocationRepository] fetchPartnerLocation error: $e');
    }
  }

  void _applyPartnerLocationUpdate(LocationDataModel newLoc) {
    // 1. Reject out-of-order older packets
    if (_partnerLocation != null &&
        newLoc.updatedAt.isBefore(_partnerLocation!.updatedAt)) {
      return;
    }

    // 2. Accept update if newer or sharing status changed
    if (_partnerLocation == null ||
        newLoc.updatedAt.isAfter(_partnerLocation!.updatedAt) ||
        newLoc.latitude != _partnerLocation!.latitude ||
        newLoc.longitude != _partnerLocation!.longitude ||
        newLoc.isSharing != _isPartnerSharing) {
      _partnerLocation = newLoc;
      _isPartnerSharing = newLoc.isSharing;
      _partnerLocationController.add(newLoc);
      _partnerSharingController.add(newLoc.isSharing);
    }
  }

  void stopListeningPartner() {
    _partnerLocSubscription?.cancel();
    _partnerPollTimer?.cancel();
  }

  void dispose() {
    stopListeningPartner();
    _userLocationController.close();
    _partnerLocationController.close();
    _partnerSharingController.close();
  }
}
