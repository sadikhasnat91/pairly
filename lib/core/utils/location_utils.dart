import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/app_constants.dart';

enum LocationFreshness { live, stale, offline, unknown }

class LocationUtils {
  LocationUtils._();

  /// Calculates distance in meters between two lat/lng coordinates using Geolocator
  static double calculateDistanceInMeters(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Formats human-readable distance (e.g., '150 m', '2.4 km', 'Nearby')
  static String formatDistance(double meters) {
    if (meters < 30) {
      return 'Right beside you';
    } else if (meters < 1000) {
      return '${meters.round()} m away';
    } else {
      final km = meters / 1000;
      if (km < 10) {
        return '${km.toStringAsFixed(1)} km away';
      } else {
        return '${km.round()} km away';
      }
    }
  }

  /// Determines freshness level based on last update timestamp
  static LocationFreshness getFreshness(DateTime? updatedAt) {
    if (updatedAt == null) return LocationFreshness.unknown;

    final diff = DateTime.now().difference(updatedAt);
    if (diff < AppConstants.staleLocationThreshold) {
      return LocationFreshness.live;
    } else if (diff < AppConstants.offlineThreshold) {
      return LocationFreshness.stale;
    } else {
      return LocationFreshness.offline;
    }
  }

  /// Calculates LatLngBounds containing both positions with safe padding
  static LatLngBounds createBounds(LatLng pos1, LatLng pos2) {
    final southWestLat = math.min(pos1.latitude, pos2.latitude);
    final southWestLng = math.min(pos1.longitude, pos2.longitude);
    final northEastLat = math.max(pos1.latitude, pos2.latitude);
    final northEastLng = math.max(pos1.longitude, pos2.longitude);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  /// Estimates approximate driving or travel time based on distance
  static String estimateTravelTime(double distanceMeters) {
    if (distanceMeters < 50) return '< 1 min';
    // Assume average urban speed ~35 km/h = 9.72 m/s
    final seconds = distanceMeters / 9.72;
    final minutes = (seconds / 60).round();

    if (minutes < 60) {
      return '~$minutes min drive';
    } else {
      final hrs = minutes ~/ 60;
      final remMins = minutes % 60;
      return '~$hrs hr ${remMins > 0 ? "$remMins min" : ""} drive';
    }
  }
}
