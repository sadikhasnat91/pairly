import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/safe_arrival_model.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class SafeArrivalRepository {
  final SupabaseService supabaseService;
  final StorageService storageService;

  SafeArrivalRepository({
    required this.supabaseService,
    required this.storageService,
  });

  SupabaseClient? get _client => supabaseService.client;

  /// Fetch user's safe arrival settings
  Future<SafeArrivalSettingsModel?> getSettings(String userId) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response = await client
          .from('user_safe_arrival_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return SafeArrivalSettingsModel.fromJson(response);
    } catch (e) {
      debugPrint('[SafeArrivalRepository] getSettings error: $e');
      return null;
    }
  }

  /// Save or update safe arrival settings (Upsert)
  Future<SafeArrivalSettingsModel?> saveSettings(
      SafeArrivalSettingsModel settings) async {
    final client = _client;
    if (client == null) return null;

    try {
      final payload = settings.toJson();
      final response = await client
          .from('user_safe_arrival_settings')
          .upsert(payload, onConflict: 'user_id')
          .select()
          .single();

      return SafeArrivalSettingsModel.fromJson(response);
    } catch (e) {
      debugPrint('[SafeArrivalRepository] saveSettings error: $e');
      return null;
    }
  }

  /// Delete safe arrival settings
  Future<bool> deleteSettings(String userId) async {
    final client = _client;
    if (client == null) return false;

    try {
      await client
          .from('user_safe_arrival_settings')
          .delete()
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('[SafeArrivalRepository] deleteSettings error: $e');
      return false;
    }
  }

  /// Record an arrival event in Supabase
  Future<SafeArrivalEventModel?> createArrivalEvent(
      SafeArrivalEventModel event) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response = await client
          .from('safe_arrival_events')
          .insert(event.toJson())
          .select()
          .single();

      return SafeArrivalEventModel.fromJson(response);
    } catch (e) {
      debugPrint('[SafeArrivalRepository] createArrivalEvent error: $e');
      return null;
    }
  }

  /// Invoke Edge Function notify-safe-arrival to push FCM notification to partner
  Future<bool> invokeNotifyFunction({
    required String eventId,
    required String idempotencyKey,
  }) async {
    final client = _client;
    if (client == null) return false;

    try {
      final FunctionResponse response = await client.functions.invoke(
        'notify-safe-arrival',
        body: {
          'eventId': eventId,
          'idempotencyKey': idempotencyKey,
        },
      );

      debugPrint(
          '[SafeArrivalRepository] Edge function status: ${response.status}');
      return response.status == 200;
    } catch (e) {
      debugPrint('[SafeArrivalRepository] invokeNotifyFunction error: $e');
      return false;
    }
  }

  /// Realtime stream for partner safe arrival events
  Stream<List<Map<String, dynamic>>> listenForPartnerArrivalEvents(
      String partnerId) {
    final client = _client;
    if (client == null) return const Stream.empty();

    return client
        .from('safe_arrival_events')
        .stream(primaryKey: ['id'])
        .eq('user_id', partnerId)
        .order('event_timestamp', ascending: false)
        .limit(1);
  }
}
