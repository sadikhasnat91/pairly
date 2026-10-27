import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Onboarding
  bool get hasCompletedOnboarding =>
      _prefs.getBool(AppConstants.keyHasCompletedOnboarding) ?? false;

  Future<void> setCompletedOnboarding(bool value) async {
    await _prefs.setBool(AppConstants.keyHasCompletedOnboarding, value);
  }

  // Location sharing preference
  bool get isSharingLocation =>
      _prefs.getBool(AppConstants.keyIsSharingLocation) ?? false;

  Future<void> setSharingLocation(bool value) async {
    await _prefs.setBool(AppConstants.keyIsSharingLocation, value);
  }

  // Cached User
  UserModel? getCachedUser() {
    final raw = _prefs.getString(AppConstants.keyAuthUser);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> setCachedUser(UserModel? user) async {
    if (user == null) {
      await _prefs.remove(AppConstants.keyAuthUser);
    } else {
      await _prefs.setString(
        AppConstants.keyAuthUser,
        jsonEncode(user.toJson()),
      );
    }
  }

  // Generic key-value helpers
  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  Future<void> remove(String key) => _prefs.remove(key);

  // Secure storage for sensitive tokens
  Future<void> writeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}
