import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_call_model.dart';
import '../services/supabase_service.dart';

class VideoSignalingRepository {
  final SupabaseService supabaseService;

  VideoSignalingRepository({required this.supabaseService});

  SupabaseClient? get _client => supabaseService.client;

  /// Initiate a new video call session request with an initial SDP Offer and gathered candidates
  Future<VideoCallSessionModel?> createCallSession({
    required String connectionId,
    required String callerId,
    required String receiverId,
    required Map<String, dynamic> sdpOffer,
    List<Map<String, dynamic>>? initialCallerCandidates,
  }) async {
    final client = _client;
    if (client == null) return null;

    try {
      final res = await client
          .from('video_call_sessions')
          .insert({
            'connection_id': connectionId,
            'caller_id': callerId,
            'receiver_id': receiverId,
            'status': 'ringing',
            'sdp_offer': sdpOffer,
            'caller_candidates': initialCallerCandidates ?? [],
            'receiver_candidates': [],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return VideoCallSessionModel.fromJson(res);
    } catch (e) {
      debugPrint('[VideoSignalingRepository] createCallSession error: $e');
      return null;
    }
  }

  /// Update call status (accepted, declined, ended, missed)
  Future<bool> updateCallStatus({
    required String sessionId,
    required VideoCallStatus status,
  }) async {
    final client = _client;
    if (client == null) return false;

    try {
      await client.from('video_call_sessions').update({
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);
      return true;
    } catch (e) {
      debugPrint('[VideoSignalingRepository] updateCallStatus error: $e');
      return false;
    }
  }

  /// Receiver sends SDP Answer and initial candidates upon explicit user acceptance
  Future<bool> sendAnswer({
    required String sessionId,
    required Map<String, dynamic> sdpAnswer,
    List<Map<String, dynamic>>? initialReceiverCandidates,
  }) async {
    final client = _client;
    if (client == null) return false;

    try {
      final updateData = <String, dynamic>{
        'status': 'accepted',
        'sdp_answer': sdpAnswer,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (initialReceiverCandidates != null && initialReceiverCandidates.isNotEmpty) {
        updateData['receiver_candidates'] = initialReceiverCandidates;
      }

      await client
          .from('video_call_sessions')
          .update(updateData)
          .eq('id', sessionId);
      return true;
    } catch (e) {
      debugPrint('[VideoSignalingRepository] sendAnswer error: $e');
      return false;
    }
  }

  /// Exchange a batch of ICE Candidates to prevent race conditions and DB write collisions
  Future<bool> addIceCandidatesBatch({
    required String sessionId,
    required List<Map<String, dynamic>> newCandidates,
    required bool isCaller,
  }) async {
    final client = _client;
    if (client == null || newCandidates.isEmpty) return false;

    try {
      final sessionRes = await client
          .from('video_call_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (sessionRes == null) return false;

      final column = isCaller ? 'caller_candidates' : 'receiver_candidates';
      final currentList = List<dynamic>.from(sessionRes[column] ?? []);

      final existingCandidateStrs = currentList
          .map((c) => (c is Map) ? c['candidate']?.toString() : null)
          .whereType<String>()
          .toSet();

      var hasNew = false;
      for (final c in newCandidates) {
        final cStr = c['candidate']?.toString();
        if (cStr != null && !existingCandidateStrs.contains(cStr)) {
          currentList.add(c);
          existingCandidateStrs.add(cStr);
          hasNew = true;
        }
      }

      if (hasNew) {
        await client.from('video_call_sessions').update({
          column: currentList,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', sessionId);
      }

      return true;
    } catch (e) {
      debugPrint('[VideoSignalingRepository] addIceCandidatesBatch error: $e');
      return false;
    }
  }

  /// Exchange single ICE Candidate
  Future<bool> addIceCandidate({
    required String sessionId,
    required Map<String, dynamic> candidate,
    required bool isCaller,
  }) async {
    return addIceCandidatesBatch(
      sessionId: sessionId,
      newCandidates: [candidate],
      isCaller: isCaller,
    );
  }

  /// Direct fetch fallback for any active incoming call for receiver
  Future<List<Map<String, dynamic>>> fetchActiveIncomingCalls(String receiverId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from('video_call_sessions')
          .select()
          .eq('receiver_id', receiverId)
          .eq('status', 'ringing');
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  /// Realtime stream for incoming call requests for the current user
  Stream<List<Map<String, dynamic>>> listenToIncomingCalls(String receiverId) {
    final client = _client;
    if (client == null) return const Stream.empty();

    return client
        .from('video_call_sessions')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', receiverId);
  }

  /// Realtime stream for session updates (SDP answer, ICE candidates, hang up)
  Stream<List<Map<String, dynamic>>> listenToSession(String sessionId) {
    final client = _client;
    if (client == null) return const Stream.empty();

    return client
        .from('video_call_sessions')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId);
  }

  /// Directly fetch session state (reliable polling fallback for mobile connections)
  Future<Map<String, dynamic>?> fetchSession(String sessionId) async {
    final client = _client;
    if (client == null) return null;

    try {
      final res = await client
          .from('video_call_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('[VideoSignalingRepository] fetchSession error: $e');
      return null;
    }
  }
}

