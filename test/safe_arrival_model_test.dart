import 'package:flutter_test/flutter_test.dart';
import 'package:pairly/data/models/safe_arrival_model.dart';

void main() {
  group('Safe Arrival Models Test', () {
    test('SafeArrivalSettingsModel serializes and deserializes properly', () {
      final now = DateTime.now();
      final model = SafeArrivalSettingsModel(
        id: 'settings_uuid_1',
        userId: 'user_123',
        homeLatitude: 22.8123,
        homeLongitude: 89.5432,
        homeAddress: 'Our Romantic Home',
        geofenceRadiusMeters: 180.0,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = model.toJson();
      expect(json['user_id'], 'user_123');
      expect(json['home_latitude'], 22.8123);
      expect(json['home_longitude'], 89.5432);
      expect(json['home_address'], 'Our Romantic Home');
      expect(json['geofence_radius_meters'], 180.0);
      expect(json['enabled'], true);

      final fromJson = SafeArrivalSettingsModel.fromJson(json);
      expect(fromJson.userId, 'user_123');
      expect(fromJson.homeLatitude, 22.8123);
      expect(fromJson.homeLongitude, 89.5432);
      expect(fromJson.homeAddress, 'Our Romantic Home');
      expect(fromJson.geofenceRadiusMeters, 180.0);
      expect(fromJson.isEnabled, true);
    });

    test('SafeArrivalEventModel serializes and deserializes properly', () {
      final now = DateTime.now();
      final event = SafeArrivalEventModel(
        id: 'event_uuid_1',
        userId: 'user_123',
        connectionId: 'conn_456',
        eventType: 'arrival',
        eventTimestamp: now,
        idempotencyKey: 'idemp_key_1',
        processingStatus: 'sent',
      );

      final json = event.toJson();
      expect(json['user_id'], 'user_123');
      expect(json['connection_id'], 'conn_456');
      expect(json['event_type'], 'arrival');
      expect(json['idempotency_key'], 'idemp_key_1');
      expect(json['processing_status'], 'sent');

      final fromJson = SafeArrivalEventModel.fromJson(json);
      expect(fromJson.userId, 'user_123');
      expect(fromJson.connectionId, 'conn_456');
      expect(fromJson.eventType, 'arrival');
      expect(fromJson.idempotencyKey, 'idemp_key_1');
      expect(fromJson.processingStatus, 'sent');
    });
  });
}

