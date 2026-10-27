import 'package:flutter_test/flutter_test.dart';
import 'package:pairly/data/models/invite_model.dart';
import 'package:pairly/data/models/location_data_model.dart';
import 'package:pairly/data/models/partner_connection_model.dart';
import 'package:pairly/data/models/user_model.dart';

void main() {
  group('Data Models Tests', () {
    test('UserModel serializes and deserializes properly', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'user_123',
        email: 'user@example.com',
        displayName: 'Sam Taylor',
        photoUrl: 'https://example.com/photo.jpg',
        statusMessage: 'At home',
        createdAt: now,
      );

      final json = user.toJson();
      final fromJson = UserModel.fromJson(json);

      expect(fromJson.id, user.id);
      expect(fromJson.email, user.email);
      expect(fromJson.displayName, user.displayName);
      expect(fromJson.statusMessage, user.statusMessage);
    });

    test(
      'PartnerConnectionModel correctly identifies partner UID and status',
      () {
        final now = DateTime.now();
        final conn = PartnerConnectionModel(
          id: 'conn_1',
          memberUids: ['user_A', 'user_B'],
          status: ConnectionStatus.active,
          createdAt: now,
        );

        expect(conn.isActive, true);
        expect(conn.getPartnerUid('user_A'), 'user_B');
        expect(conn.getPartnerUid('user_B'), 'user_A');
        expect(conn.getPartnerUid('user_C'), isNull);
      },
    );

    test('LocationDataModel detects staleness according to thresholds', () {
      final now = DateTime.now();
      final fresh = LocationDataModel(
        uid: 'u1',
        latitude: 37.77,
        longitude: -122.41,
        accuracy: 10.0,
        updatedAt: now,
        isSharing: true,
      );
      expect(fresh.isStale, false);

      final stale = LocationDataModel(
        uid: 'u1',
        latitude: 37.77,
        longitude: -122.41,
        accuracy: 10.0,
        updatedAt: now.subtract(const Duration(minutes: 20)),
        isSharing: true,
      );
      expect(stale.isStale, true);
    });

    test('InviteModel checks expiration correctly', () {
      final now = DateTime.now();
      final validInvite = InviteModel(
        id: 'inv_1',
        code: 'ABC123',
        creatorUid: 'user_1',
        creatorName: 'User',
        expiresAt: now.add(const Duration(hours: 12)),
        createdAt: now,
      );
      expect(validInvite.isValid, true);

      final expiredInvite = InviteModel(
        id: 'inv_2',
        code: 'XYZ789',
        creatorUid: 'user_1',
        creatorName: 'User',
        expiresAt: now.subtract(const Duration(minutes: 5)),
        createdAt: now.subtract(const Duration(hours: 24)),
      );
      expect(expiredInvite.isValid, false);
      expect(expiredInvite.isExpired, true);
    });
  });
}
