import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final SupabaseService supabaseService;
  final StorageService storageService;
  final _authStateController = StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  StreamSubscription? _authSubscription;

  AuthRepository({
    required this.supabaseService,
    required this.storageService,
  }) {
    _init();
  }

  void _init() {
    _currentUser = storageService.getCachedUser();
    if (supabaseService.isConfigured && supabaseService.client != null) {
      _authSubscription =
          supabaseService.client!.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        final user = session?.user;
        if (user != null) {
          final profile = await _fetchUserProfile(user.id);
          _currentUser = profile ??
              UserModel(
                id: user.id,
                email: user.email ?? '',
                displayName: (user.userMetadata?['displayName'] as String?) ??
                    (user.userMetadata?['display_name'] as String?) ??
                    user.email?.split('@').first ??
                    'User',
                createdAt: DateTime.now(),
              );
          await storageService.setCachedUser(_currentUser);
          _authStateController.add(_currentUser);
        } else {
          _currentUser = null;
          await storageService.setCachedUser(null);
          _authStateController.add(null);
        }
      });
    } else {
      _authStateController.add(_currentUser);
    }
  }

  Future<UserModel?> _fetchUserProfile(String uid) async {
    try {
      if (!supabaseService.isConfigured || supabaseService.client == null) {
        return _currentUser;
      }
      final response = await supabaseService.client!
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (supabaseService.isConfigured && supabaseService.client != null) {
      final res = await supabaseService.client!.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'displayName': displayName.trim()},
      );

      final user = res.user;
      final uid = user?.id ?? const Uuid().v4();

      final newUser = UserModel(
        id: uid,
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      );

      try {
        await supabaseService.client!.from('users').upsert(newUser.toJson());
      } catch (_) {}

      _currentUser = newUser;
      await storageService.setCachedUser(newUser);
      _authStateController.add(newUser);
      return newUser;
    } else {
      // Offline / Local fallback mode
      final uid = const Uuid().v4();
      final newUser = UserModel(
        id: uid,
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      );
      _currentUser = newUser;
      await storageService.setCachedUser(newUser);
      _authStateController.add(newUser);
      return newUser;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (supabaseService.isConfigured && supabaseService.client != null) {
      final res = await supabaseService.client!.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = res.user;
      final uid = user?.id ?? '';
      final profile = await _fetchUserProfile(uid);

      final resolvedUser = profile ??
          UserModel(
            id: uid,
            email: user?.email ?? email.trim(),
            displayName: (user?.userMetadata?['displayName'] as String?) ??
                email.split('@').first,
            createdAt: DateTime.now(),
          );

      _currentUser = resolvedUser;
      await storageService.setCachedUser(resolvedUser);
      _authStateController.add(resolvedUser);
      return resolvedUser;
    } else {
      // Local fallback sign in
      final cached = storageService.getCachedUser();
      if (cached != null &&
          cached.email.toLowerCase() == email.trim().toLowerCase()) {
        _currentUser = cached;
      } else {
        _currentUser = UserModel(
          id: const Uuid().v4(),
          email: email.trim(),
          displayName: email.split('@').first,
          createdAt: DateTime.now(),
        );
      }
      await storageService.setCachedUser(_currentUser);
      _authStateController.add(_currentUser);
      return _currentUser!;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (supabaseService.isConfigured && supabaseService.client != null) {
      await supabaseService.client!.auth.resetPasswordForEmail(email.trim());
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? statusMessage,
  }) async {
    if (_currentUser == null) return;

    final updated = _currentUser!.copyWith(
      displayName: displayName ?? _currentUser!.displayName,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
      statusMessage: statusMessage ?? _currentUser!.statusMessage,
    );

    _currentUser = updated;
    await storageService.setCachedUser(updated);

    if (supabaseService.isConfigured && supabaseService.client != null) {
      try {
        await supabaseService.client!.from('users').upsert(updated.toJson());
        if (displayName != null) {
          await supabaseService.client!.auth.updateUser(
            UserAttributes(data: {'displayName': displayName}),
          );
        }
      } catch (_) {}
    }

    _authStateController.add(_currentUser);
  }

  Future<void> signOut() async {
    if (supabaseService.isConfigured && supabaseService.client != null) {
      try {
        await supabaseService.client!.auth.signOut();
      } catch (_) {}
    }
    _currentUser = null;
    await storageService.setCachedUser(null);
    await storageService.setSharingLocation(false);
    _authStateController.add(null);
  }

  Future<void> deleteAccount() async {
    final uid = _currentUser?.id;
    if (uid != null && supabaseService.isConfigured) {
      try {
        await supabaseService.client!.from('users').delete().eq('id', uid);
        await supabaseService.client!.from('locations').delete().eq('uid', uid);
      } catch (_) {}
    }
    await signOut();
  }

  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }
}
