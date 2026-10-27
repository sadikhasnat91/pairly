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

  Position? _lastKnownPosition;
  Position? get lastKnownPosition => _lastKnownPosition;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Verifies location service and Android permissions
  Future<LocationServiceState> checkServiceAndPermission() async {
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
  }

  /// Requests current one-shot device position
  Future<Position?> getCurrentPosition() async {
    final state = await checkServiceAndPermission();
    if (state != LocationServiceState.ready) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lastKnownPosition = position;
      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Starts throttled foreground position stream
  Future<bool> startTracking({
    required Function(Position position) onUpdate,
    Function(dynamic error)? onError,
  }) async {
    final state = await checkServiceAndPermission();
    if (state != LocationServiceState.ready) {
      return false;
    }

    await stopTracking();

    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: AppConstants.locationDistanceFilterMeters,
      intervalDuration: AppConstants.locationThrottleInterval,
      foregroundNotificationConfig:
          null, // Keep foreground-only unless background configured
    );

    try {
      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(
                (Position position) {
                  _lastKnownPosition = position;
                  _positionStreamController.add(position);
                  onUpdate(position);
                },
                onError: (err) {
                  debugPrint('Geolocator stream error: $err');
                  if (onError != null) onError(err);
                },
              );
      _isTracking = true;
      return true;
    } catch (e) {
      debugPrint('Failed to start position stream: $e');
      return false;
    }
  }

  /// Stops position stream
  Future<void> stopTracking() async {
    if (_positionSubscription != null) {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
    }
    _isTracking = false;
  }

  /// Opens system app settings for permission management
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Opens system location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  void dispose() {
    stopTracking();
    _positionStreamController.close();
  }
}
