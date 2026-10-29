import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_constants.dart';

enum LocationServiceState {
  ready,
  disabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _positionStreamController = StreamController<Position>.broadcast();
  Stream<Position> get onPositionChanged => _positionStreamController.stream;

  final Set<Function(Position position)> _callbacks = {};
  Timer? _heartbeatTimer;

  Position? _lastKnownPosition;
  Position? get lastKnownPosition => _lastKnownPosition;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Verifies location service and Android/Web permissions
  Future<LocationServiceState> checkServiceAndPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationServiceState.disabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationServiceState.permissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationServiceState.permissionDeniedForever;
      }

      return LocationServiceState.ready;
    } catch (e) {
      debugPrint('[LocationService] Permission check error: $e');
      return LocationServiceState.ready;
    }
  }

  /// Request Background Location Permission (Allow all the time) for Android 10+
  Future<bool> requestBackgroundPermission() async {
    if (kIsWeb) return true;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always) return true;

      // In Android 10+ requesting permission when whileInUse is already granted requests background
      final newPerm = await Geolocator.requestPermission();
      return newPerm == LocationPermission.always;
    } catch (e) {
      debugPrint('[LocationService] requestBackgroundPermission error: $e');
      return false;
    }
  }

  /// Check whether Background Location Permission (Allow all the time) is granted
  Future<bool> isBackgroundPermissionGranted() async {
    if (kIsWeb) return true;
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// Requests current one-shot device position
  Future<Position?> getCurrentPosition() async {
    final state = await checkServiceAndPermission();
    if (state == LocationServiceState.disabled ||
        state == LocationServiceState.permissionDeniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      _lastKnownPosition = position;
      return position;
    } catch (e) {
      debugPrint('[LocationService] High accuracy position error: $e');
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          _lastKnownPosition = last;
          return last;
        }
      } catch (_) {}
      return null;
    }
  }

  /// Starts or subscribes to the persistent background position stream
  Future<bool> startTracking({
    required Function(Position position) onUpdate,
    Function(dynamic error)? onError,
  }) async {
    _callbacks.add(onUpdate);

    // If we have a cached position, emit immediately to the caller
    if (_lastKnownPosition != null) {
      try {
        onUpdate(_lastKnownPosition!);
      } catch (_) {}
    }

    // If already tracking, return true without re-creating the native stream
    if (_isTracking && _positionSubscription != null) {
      return true;
    }

    final state = await checkServiceAndPermission();
    if (state == LocationServiceState.disabled ||
        state == LocationServiceState.permissionDeniedForever) {
      return false;
    }

    // Platform-aware settings
    LocationSettings locationSettings;
    if (kIsWeb) {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    } else {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // 5 meters filter for prompt movement detection
        intervalDuration: AppConstants.locationThrottleInterval, // 5 seconds
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Pairly Live Location Active',
          notificationText: 'Sharing your real-time location with your partner',
          notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          _positionStreamController.add(position);
          _dispatchPosition(position);
        },
        onError: (err) {
          debugPrint('[LocationService] Stream error: $err');
          if (onError != null) onError(err);
        },
      );

      // Start periodic heartbeat: refreshes timestamp even if stationary
      _startHeartbeat();

      _isTracking = true;
      return true;
    } catch (e) {
      debugPrint('[LocationService] Failed to start position stream: $e');
      return false;
    }
  }

  void _dispatchPosition(Position position) {
    for (final cb in List.of(_callbacks)) {
      try {
        cb(position);
      } catch (e) {
        debugPrint('[LocationService] Callback dispatch error: $e');
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    // Every 60s, dispatch last known position to prevent false "stale" status while stationary
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_lastKnownPosition != null && _isTracking) {
        _dispatchPosition(_lastKnownPosition!);
      }
    });
  }

  /// Stops position stream
  Future<void> stopTracking({Function(Position position)? onUpdate}) async {
    if (onUpdate != null) {
      _callbacks.remove(onUpdate);
      if (_callbacks.isNotEmpty) {
        return; // Keep underlying stream alive for other active subscribers
      }
    } else {
      _callbacks.clear();
    }

    _heartbeatTimer?.cancel();
    if (_positionSubscription != null) {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
    }
    _isTracking = false;
  }

  /// Opens system app settings for permission management
  Future<bool> openAppSettings() async {
    if (kIsWeb) return false;
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Opens system location settings
  Future<bool> openLocationSettings() async {
    if (kIsWeb) return false;
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    stopTracking();
    _positionStreamController.close();
  }
}
