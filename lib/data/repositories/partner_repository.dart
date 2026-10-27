import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/connection_request_model.dart';
import '../models/invite_model.dart';
import '../models/partner_connection_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class PartnerRepository {
  final FirebaseService firebaseService;
  final StorageService storageService;

  final _connectionController = StreamController<PartnerConnectionModel?>.broadcast();
  Stream<PartnerConnectionModel?> get connectionStream => _connectionController.stream;

  final _pendingRequestsController = StreamController<List<ConnectionRequestModel>>.broadcast();
  Stream<List<ConnectionRequestModel>> get pendingRequestsStream => _pendingRequestsController.stream;

  PartnerConnectionModel? _currentConnection;
  PartnerConnectionModel? get currentConnection => _currentConnection;

  UserModel? _partnerUser;
  UserModel? get partnerUser => _partnerUser;

  StreamSubscription? _connectionSubscription;
  StreamSubscription? _requestsSubscription;

  PartnerRepository({
    required this.firebaseService,
    required this.storageService,
  });

  void listenToPartnerConnection(String currentUid) {
    _connectionSubscription?.cancel();
    _requestsSubscription?.cancel();

    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      // Query active connection containing currentUid
      _connectionSubscription = firebaseService.firestore!
          .collection('partnerConnections')
          .where('memberUids', arrayContains: currentUid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final connection = PartnerConnectionModel.fromJson(doc.data());
          _currentConnection = connection;
          _connectionController.add(connection);

          final partnerUid = connection.getPartnerUid(currentUid);
          if (partnerUid != null) {
            _partnerUser = await _fetchUser(partnerUid);
          }
        } else {
          _currentConnection = null;
          _partnerUser = null;
          _connectionController.add(null);
        }
      });

      // Query pending connection requests for currentUid
      _requestsSubscription = firebaseService.firestore!
          .collection('connectionRequests')
          .where('recipientUid', isEqualTo: currentUid)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
        final list = snapshot.docs
            .map((doc) => ConnectionRequestModel.fromJson(doc.data()))
            .toList();
        _pendingRequestsController.add(list);
      });
    } else {
      // Local fallback mode: check storage or mock state
      _loadLocalConnection(currentUid);
    }
  }

  void _loadLocalConnection(String currentUid) {
    final raw = storageService.getString('local_connection_$currentUid');
    if (raw != null) {
      // Can be populated if local pairing simulation was executed
    }
    _connectionController.add(_currentConnection);
  }

  Future<UserModel?> _fetchUser(String uid) async {
    try {
      if (firebaseService.isConfigured && firebaseService.firestore != null) {
        final doc = await firebaseService.firestore!.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data()!);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Generates a unique 6-character uppercase alphanumeric code
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(
      AppConstants.inviteCodeLength,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Create and upload an expiring invite code
  Future<InviteModel> createInviteCode({
    required String currentUid,
    required String creatorName,
  }) async {
    final inviteId = const Uuid().v4();
    final code = _generateCode();
    final now = DateTime.now();
    final expiresAt = now.add(AppConstants.inviteCodeValidity);

    final invite = InviteModel(
      id: inviteId,
      code: code,
      creatorUid: currentUid,
      creatorName: creatorName,
      expiresAt: expiresAt,
      createdAt: now,
    );

    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      await firebaseService.firestore!
          .collection('connectionInvites')
          .doc(inviteId)
          .set(invite.toJson());
    }

    return invite;
  }

  /// Look up an invite code and redeem it by creating a mutual connection
  Future<PartnerConnectionModel> redeemInviteCode({
    required String code,
    required UserModel currentUser,
  }) async {
    final cleanCode = code.trim().toUpperCase();

    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      final query = await firebaseService.firestore!
          .collection('connectionInvites')
          .where('code', isEqualTo: cleanCode)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Invalid or expired invitation code. Please ask your partner for a new code.');
      }

      final inviteDoc = query.docs.first;
      final invite = InviteModel.fromJson(inviteDoc.data());

      if (invite.isExpired) {
        await inviteDoc.reference.update({'status': 'expired'});
        throw Exception('This invitation code has expired. Please ask your partner to generate a new code.');
      }

      if (invite.creatorUid == currentUser.id) {
        throw Exception('You cannot pair with yourself. Please share this code with your partner.');
      }

      // Check if either user is already connected
      final existingCheck = await firebaseService.firestore!
          .collection('partnerConnections')
          .where('memberUids', arrayContains: currentUser.id)
          .where('status', isEqualTo: 'active')
          .get();

      if (existingCheck.docs.isNotEmpty) {
        throw Exception('You are already connected to a partner. Disconnect first to pair with another.');
      }

      // Create mutual connection
      final connectionId = const Uuid().v4();
      final now = DateTime.now();
      final connection = PartnerConnectionModel(
        id: connectionId,
        memberUids: [invite.creatorUid, currentUser.id],
        status: ConnectionStatus.active,
        createdAt: now,
        acceptedAt: now,
        updatedAt: now,
      );

      final batch = firebaseService.firestore!.batch();
      batch.set(
        firebaseService.firestore!.collection('partnerConnections').doc(connectionId),
        connection.toJson(),
      );
      batch.update(inviteDoc.reference, {'status': 'accepted'});
      await batch.commit();

      _currentConnection = connection;
      _partnerUser = await _fetchUser(invite.creatorUid) ??
          UserModel(
            id: invite.creatorUid,
            email: '',
            displayName: invite.creatorName,
            createdAt: DateTime.now(),
          );
      _connectionController.add(connection);

      return connection;
    } else {
      // Local demo mode: simulate successful connection
      final connectionId = const Uuid().v4();
      final partnerUid = const Uuid().v4();
      final now = DateTime.now();

      final connection = PartnerConnectionModel(
        id: connectionId,
        memberUids: [currentUser.id, partnerUid],
        status: ConnectionStatus.active,
        createdAt: now,
        acceptedAt: now,
        updatedAt: now,
      );

      _partnerUser = UserModel(
        id: partnerUid,
        email: 'partner@pairly.app',
        displayName: 'Alex Rivers',
        createdAt: now,
      );

      _currentConnection = connection;
      _connectionController.add(connection);
      return connection;
    }
  }

  /// Disconnect the active partner relationship
  Future<void> disconnectPartner({
    required String connectionId,
    required String currentUid,
  }) async {
    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      await firebaseService.firestore!
          .collection('partnerConnections')
          .doc(connectionId)
          .update({
        'status': 'disconnected',
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await firebaseService.firestore!
          .collection('locationSharing')
          .doc(currentUid)
          .set({'enabled': false, 'updatedAt': DateTime.now().toIso8601String()}, SetOptions(merge: true));
    }

    _currentConnection = null;
    _partnerUser = null;
    _connectionController.add(null);
  }

  /// Block a partner and immediately revoke location sharing
  Future<void> blockPartner({
    required String connectionId,
    required String currentUid,
  }) async {
    if (firebaseService.isConfigured && firebaseService.firestore != null) {
      await firebaseService.firestore!
          .collection('partnerConnections')
          .doc(connectionId)
          .update({
        'status': 'blocked',
        'blockedByUid': currentUid,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await firebaseService.firestore!
          .collection('locationSharing')
          .doc(currentUid)
          .set({'enabled': false, 'updatedAt': DateTime.now().toIso8601String()}, SetOptions(merge: true));
    }

    _currentConnection = null;
    _partnerUser = null;
    _connectionController.add(null);
  }

  void dispose() {
    _connectionSubscription?.cancel();
    _requestsSubscription?.cancel();
    _connectionController.close();
    _pendingRequestsController.close();
  }
}
