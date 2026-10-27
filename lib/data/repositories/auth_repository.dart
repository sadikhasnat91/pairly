import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final FirebaseService firebaseService;
  final StorageService storageService;
  final _authStateController = StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  AuthRepository({
    required this.firebaseService,
    required this.storageService,
  }) {
    _init();
  }

  void _init() {
    _currentUser = storageService.getCachedUser();
    if (firebaseService.isConfigured && firebaseService.auth != null) {
      firebaseService.auth!.authStateChanges().listen((User? user) async {
        if (user != null) {
          final profile = await _fetchUserProfile(user.uid);
          _currentUser = profile ??
              UserModel(
                id: user.uid,
                email: user.email ?? '',
                displayName: user.displayName ?? 'User',
                photoUrl: user.photoURL,
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
      if (!firebaseService.isConfigured || firebaseService.firestore == null) {
        return _currentUser;
      }
      final doc = await firebaseService.firestore!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (firebaseService.isConfigured && firebaseService.auth != null) {
      final credential = await firebaseService.auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(displayName.trim());

      final newUser = UserModel(
        id: uid,
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      );

      await firebaseService.firestore!.collection('users').doc(uid).set(newUser.toJson());
      _currentUser = newUser;
      await storageService.setCachedUser(newUser);
      _authStateController.add(newUser);
      return newUser;
    } else {
      // Offline / Demo mode
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
    if (firebaseService.isConfigured && firebaseService.auth != null) {
      final credential = await firebaseService.auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final profile = await _fetchUserProfile(uid);
      final user = profile ??
          UserModel(
            id: uid,
            email: credential.user!.email ?? email,
            displayName: credential.user!.displayName ?? 'User',
            createdAt: DateTime.now(),
          );
      _currentUser = user;
      await storageService.setCachedUser(user);
      _authStateController.add(user);
      return user;
    } else {
      // Local fallback sign in
      final cached = storageService.getCachedUser();
      if (cached != null && cached.email.toLowerCase() == email.trim().toLowerCase()) {
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
    if (firebaseService.isConfigured && firebaseService.auth != null) {
      await firebaseService.auth!.sendPasswordResetEmail(email: email.trim());
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

    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      await firebaseService.firestore!
          .collection('users')
          .doc(updated.id)
          .set(updated.toJson(), SetOptions(merge: true));

      if (displayName != null) {
        await firebaseService.auth?.currentUser?.updateDisplayName(displayName);
      }
    }

    _authStateController.add(_currentUser);
  }

  Future<void> signOut() async {
    if (firebaseService.isConfigured && firebaseService.auth != null) {
      await firebaseService.auth!.signOut();
    }
    _currentUser = null;
    await storageService.setCachedUser(null);
    await storageService.setSharingLocation(false);
    _authStateController.add(null);
  }

  Future<void> deleteAccount() async {
    final uid = _currentUser?.id;
    if (uid != null && firebaseService.isConfigured) {
      try {
        await firebaseService.firestore?.collection('users').doc(uid).delete();
        await firebaseService.firestore?.collection('locations').doc(uid).delete();
        await firebaseService.firestore?.collection('locationSharing').doc(uid).delete();
        await firebaseService.auth?.currentUser?.delete();
      } catch (_) {}
    }
    await signOut();
  }

  void dispose() {
    _authStateController.close();
  }
}
