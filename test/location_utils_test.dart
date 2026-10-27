import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pairly/core/utils/location_utils.dart';

void main() {
  group('LocationUtils Tests', () {
    test('formatDistance produces correct human-readable formats', () {
      expect(LocationUtils.formatDistance(15), 'Right beside you');
      expect(LocationUtils.formatDistance(250), '250 m away');
      expect(LocationUtils.formatDistance(2400), '2.4 km away');
      expect(LocationUtils.formatDistance(18500), '19 km away');
    });

    test('estimateTravelTime calculates approximate drive durations', () {
      expect(LocationUtils.estimateTravelTime(20), '< 1 min');
      expect(LocationUtils.estimateTravelTime(3000), contains('min drive'));
    });

    test('getFreshness correctly classifies freshness by timestamp', () {
      final now = DateTime.now();
      expect(
        LocationUtils.getFreshness(now.subtract(const Duration(minutes: 2))),
        LocationFreshness.live,
      );
      expect(
        LocationUtils.getFreshness(now.subtract(const Duration(minutes: 20))),
        LocationFreshness.stale,
      );
      expect(
        LocationUtils.getFreshness(now.subtract(const Duration(hours: 2))),
        LocationFreshness.offline,
      );
      expect(LocationUtils.getFreshness(null), LocationFreshness.unknown);
    });

    test('createBounds constructs valid bounding coordinates', () {
      const pos1 = LatLng(37.7749, -122.4194);
      const pos2 = LatLng(37.7833, -122.4167);

      final bounds = LocationUtils.createBounds(pos1, pos2);
      expect(bounds.southwest.latitude, 37.7749);
      expect(bounds.northeast.latitude, 37.7833);
    });
  });
}
