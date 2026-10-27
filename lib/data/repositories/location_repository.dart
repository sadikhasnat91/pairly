import 'dart:async';
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

    if (supabaseService.isConfigured && supabaseService.client != null) {
      try {
        await supabaseService.client!.from('locations').upsert(model.toJson());
      } catch (_) {}
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
      } catch (_) {}
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

      // 2. Continuous fallback polling every 4 seconds for reliable delivery over mobile networks
      _partnerPollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        _fetchInitialPartnerLocation(partnerUid);
      });

      // 3. Stream partner updates via Supabase Realtime
      try {
        _partnerLocSubscription = supabaseService.client!
            .from('locations')
            .stream(primaryKey: ['uid'])
            .eq('uid', partnerUid)
            .listen((List<Map<String, dynamic>> records) {
              if (records.isNotEmpty) {
                final loc = LocationDataModel.fromJson(records.first);
                _partnerLocation = loc;
                _isPartnerSharing = loc.isSharing;
                _partnerLocationController.add(loc);
                _partnerSharingController.add(loc.isSharing);
              }
            });
      } catch (_) {
        _fetchInitialPartnerLocation(partnerUid);
      }
    } else {
      // Local fallback mode: simulated partner location nearby
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
        _partnerLocation = loc;
        _isPartnerSharing = loc.isSharing;
        _partnerLocationController.add(loc);
        _partnerSharingController.add(loc.isSharing);
      }
    } catch (_) {}
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
