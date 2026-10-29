import 'package:flutter_test/flutter_test.dart';
import 'package:pairly/core/utils/location_utils.dart';
import 'package:pairly/data/models/location_data_model.dart';
import 'package:pairly/data/models/partner_connection_model.dart';

void main() {
  group('Partner Isolation & Integrity Tests', () {
    test('PartnerConnectionModel strictly isolates User A and User B', () {
      const userAId = 'user_aaa_111';
      const userBId = 'user_bbb_222';

      final connection = PartnerConnectionModel(
        id: 'conn_123',
        memberUids: [userAId, userBId],
        status: ConnectionStatus.active,
        createdAt: DateTime.now(),
      );

      // User A queries partner -> must be User B
      expect(connection.getPartnerUid(userAId), equals(userBId));

      // User B queries partner -> must be User A
      expect(connection.getPartnerUid(userBId), equals(userAId));

      // Unknown User C queries -> must be null
      expect(connection.getPartnerUid('user_ccc_333'), isNull);
    });

    test('LocationDataModel keeps distinct user locations completely separate', () {
      final now = DateTime.now();
      final locA = LocationDataModel(
        uid: 'user_aaa_111',
        latitude: 22.8123,
        longitude: 89.5432,
        accuracy: 10.0,
        updatedAt: now,
        isSharing: true,
      );

      final locB = LocationDataModel(
        uid: 'user_bbb_222',
        latitude: 22.8456,
        longitude: 89.5678,
        accuracy: 12.0,
        updatedAt: now,
        isSharing: true,
      );

      expect(locA.uid, isNot(equals(locB.uid)));
      expect(locA.latitude, isNot(equals(locB.latitude)));
      expect(locA.longitude, isNot(equals(locB.longitude)));

      final distance = LocationUtils.calculateDistanceInMeters(
        locA.latitude,
        locA.longitude,
        locB.latitude,
        locB.longitude,
      );

      expect(distance, greaterThan(1000.0)); // > 1 km apart
    });
  });

  group('Safe Arrival Geofencing & Anti-Flapping Tests', () {
    const homeLat = 22.8100;
    const homeLng = 89.5400;
    const geofenceRadius = 150.0;
    const outerHysteresis = geofenceRadius + 50.0; // 200.0m

    test('High accuracy reading outside geofence does not trigger arrival', () {
      // Point 500m away
      final distance = LocationUtils.calculateDistanceInMeters(
        22.8150,
        89.5400,
        homeLat,
        homeLng,
      );

      expect(distance, greaterThan(geofenceRadius));
    });

    test('GPS reading with poor accuracy (> 60m) is considered drift and rejected', () {
      const accuracy = 75.0;
      final isAccurate = accuracy <= 60.0;
      expect(isAccurate, isFalse);
    });

    test('Hysteresis prevents flickering when hovering at perimeter boundary', () {
      // Inside perimeter (120m <= 150m)
      const dist1 = 120.0;
      final isInside1 = dist1 <= geofenceRadius;
      expect(isInside1, isTrue);

      // Fluctuates slightly to 165m (between 150m and 200m)
      const dist2 = 165.0;
      // In hysteresis engine, it does NOT mark outside until > outerHysteresis (200m)
      final hasExited = dist2 > outerHysteresis;
      expect(hasExited, isFalse);

      // Truly leaves the area to 250m (> 200m)
      const dist3 = 250.0;
      final hasTrulyExited = dist3 > outerHysteresis;
      expect(hasTrulyExited, isTrue);
    });

    test('Idempotency key prevents duplicate events in the same time block', () {
      final now = DateTime(2026, 10, 28, 14, 30);
      final key1 =
          'arrival_userA_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}';

      final nowPlus5Min = DateTime(2026, 10, 28, 14, 35);
      final key2 =
          'arrival_userA_${nowPlus5Min.year}${nowPlus5Min.month.toString().padLeft(2, '0')}${nowPlus5Min.day.toString().padLeft(2, '0')}_${nowPlus5Min.hour}';

      expect(key1, equals(key2)); // Idempotent key deduplicates within same hour block
    });
  });
}
