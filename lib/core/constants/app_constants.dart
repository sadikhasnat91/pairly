class AppConstants {
  AppConstants._();

  static const String appName = 'Pairly';
  static const String appTagline = 'Closer, Wherever You Are.';
  static const String appVersion = '1.0.0';

  // Supabase Configuration
  static const String supabaseUrl = 'https://muqjxewkuymkzyjvipzc.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_2MuePQ0WxN1O3MXx07QEeQ_KKZyFiMq';

  // Partner Pairing
  static const int inviteCodeLength = 6;
  static const Duration inviteCodeValidity = Duration(hours: 24);

  // Location Tracking
  static const Duration staleLocationThreshold = Duration(minutes: 5);
  static const Duration offlineThreshold = Duration(minutes: 30);
  static const int locationDistanceFilterMeters = 10;
  static const Duration locationThrottleInterval = Duration(seconds: 5);

  // Maps
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  static const double defaultZoom = 14.5;
  static const double partnerOverviewZoom = 13.0;

  // Storage Keys
  static const String keyAuthUser = 'pairly_auth_user';
  static const String keyIsSharingLocation = 'pairly_is_sharing_location';
  static const String keyHasCompletedOnboarding = 'pairly_completed_onboarding';
  static const String keySafeArrivalDestination = 'pairly_safe_arrival_dest';
}

