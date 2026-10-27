import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  bool _isConfigured = false;
  bool get isConfigured => _isConfigured;

  FirebaseAuth? get auth => _isConfigured ? FirebaseAuth.instance : null;
  FirebaseFirestore? get firestore =>
      _isConfigured ? FirebaseFirestore.instance : null;

  Future<FirebaseService> init() async {
    try {
      await Firebase.initializeApp();
      _isConfigured = true;
      developer.log(
        'Firebase initialized successfully',
        name: 'FirebaseService',
      );
    } catch (e, stack) {
      _isConfigured = false;
      developer.log(
        'Firebase initialization skipped or failed: $e. Falling back to local offline repository.',
        name: 'FirebaseService',
        error: e,
        stackTrace: stack,
      );
    }
    return this;
  }
}
