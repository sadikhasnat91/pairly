import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';

class SupabaseService {
  bool _isConfigured = false;
  bool get isConfigured => _isConfigured;

  SupabaseClient? get client => _isConfigured ? Supabase.instance.client : null;
  GoTrueClient? get auth => client?.auth;

  Future<SupabaseService> init() async {
    try {
      if (AppConstants.supabaseUrl.isNotEmpty &&
          AppConstants.supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: AppConstants.supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: AppConstants.supabaseAnonKey,
        );
        _isConfigured = true;
        developer.log(
          'Supabase initialized successfully',
          name: 'SupabaseService',
        );
      }
    } catch (e, stack) {
      _isConfigured = false;
      developer.log(
        'Supabase initialization error: $e',
        name: 'SupabaseService',
        error: e,
        stackTrace: stack,
      );
    }
    return this;
  }
}
