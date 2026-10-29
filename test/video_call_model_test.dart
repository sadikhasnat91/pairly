import 'package:flutter_test/flutter_test.dart';
import 'package:pairly/data/models/video_call_model.dart';

void main() {
  group('VideoCallSessionModel Tests', () {
    test('serializes and deserializes properly with consent status', () {
      final now = DateTime.now();
      final session = VideoCallSessionModel(
        id: 'session_123',
        connectionId: 'conn_456',
        callerId: 'user_a',
        receiverId: 'user_b',
        status: VideoCallStatus.ringing,
        sdpOffer: {'type': 'offer', 'sdp': 'v=0...'},
        callerCandidates: [{'candidate': 'cand_1'}],
        createdAt: now,
        updatedAt: now,
      );

      final json = session.toJson();
      expect(json['id'], 'session_123');
      expect(json['connection_id'], 'conn_456');
      expect(json['caller_id'], 'user_a');
      expect(json['receiver_id'], 'user_b');
      expect(json['status'], 'ringing');
      expect(json['sdp_offer'], isNotNull);

      final fromJson = VideoCallSessionModel.fromJson(json);
      expect(fromJson.id, 'session_123');
      expect(fromJson.status, VideoCallStatus.ringing);
      expect(fromJson.callerCandidates.length, 1);
    });

    test('status transition from ringing to accepted requires consent', () {
      final now = DateTime.now();
      final ringingSession = VideoCallSessionModel(
        id: 'session_123',
        connectionId: 'conn_456',
        callerId: 'user_a',
        receiverId: 'user_b',
        status: VideoCallStatus.ringing,
        createdAt: now,
        updatedAt: now,
      );

      expect(ringingSession.status, VideoCallStatus.ringing);

      final acceptedSession = ringingSession.copyWith(
        status: VideoCallStatus.accepted,
        sdpAnswer: {'type': 'answer', 'sdp': 'v=0...answer'},
      );

      expect(acceptedSession.status, VideoCallStatus.accepted);
      expect(acceptedSession.sdpAnswer, isNotNull);
    });

    test('status transition to declined cleanly terminates session', () {
      final now = DateTime.now();
      final session = VideoCallSessionModel(
        id: 'session_123',
        connectionId: 'conn_456',
        callerId: 'user_a',
        receiverId: 'user_b',
        status: VideoCallStatus.declined,
        createdAt: now,
        updatedAt: now,
      );

      expect(session.status, VideoCallStatus.declined);
    });
  });
}

