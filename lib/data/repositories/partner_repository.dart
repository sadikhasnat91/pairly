import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/connection_request_model.dart';
import '../models/invite_model.dart';
import '../models/partner_connection_model.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../../core/constants/app_constants.dart';

class PartnerRepository {
  final SupabaseService supabaseService;
  final StorageService storageService;

  final _connectionController =
      StreamController<PartnerConnectionModel?>.broadcast();
  Stream<PartnerConnectionModel?> get connectionStream =>
      _connectionController.stream;

  final _pendingRequestsController =
      StreamController<List<ConnectionRequestModel>>.broadcast();
  Stream<List<ConnectionRequestModel>> get pendingRequestsStream =>
      _pendingRequestsController.stream;

  PartnerConnectionModel? _currentConnection;
  PartnerConnectionModel? get currentConnection => _currentConnection;

  UserModel? _partnerUser;
  UserModel? get partnerUser => _partnerUser;

  StreamSubscription? _connectionSubscription;

  PartnerRepository({
    required this.supabaseService,
    required this.storageService,
  });

  void listenToPartnerConnection(String currentUid) {
    _connectionSubscription?.cancel();

    if (supabaseService.isConfigured && supabaseService.client != null) {
      // 1. Initial fetch of active connection
      _fetchActiveConnection(currentUid);

      // 2. Stream partner connection changes
      try {
        _connectionSubscription = supabaseService.client!
            .from('partner_connections')
            .stream(primaryKey: ['id'])
            .listen((List<Map<String, dynamic>> records) async {
              PartnerConnectionModel? foundConn;
              for (final row in records) {
                final conn = PartnerConnectionModel.fromJson(row);
                if (conn.memberUids.contains(currentUid) && conn.isActive) {
                  foundConn = conn;
                  break;
                }
              }

              if (foundConn != null) {
                _currentConnection = foundConn;
                _connectionController.add(foundConn);
                final partnerUid = foundConn.getPartnerUid(currentUid);
                if (partnerUid != null) {
                  _partnerUser = await _fetchUser(partnerUid);
                }
              } else {
                _currentConnection = null;
                _partnerUser = null;
                _connectionController.add(null);
              }
            });
      } catch (_) {
        _fetchActiveConnection(currentUid);
      }
    } else {
      // Local fallback mode
      _loadLocalConnection(currentUid);
    }
  }

  Future<void> _fetchActiveConnection(String currentUid) async {
    try {
      if (supabaseService.client == null) return;
      final res = await supabaseService.client!
          .from('partner_connections')
          .select()
          .eq('status', 'active');

      PartnerConnectionModel? activeConn;
      for (final row in res) {
        final conn =
            PartnerConnectionModel.fromJson(Map<String, dynamic>.from(row));
        if (conn.memberUids.contains(currentUid)) {
          activeConn = conn;
          break;
        }
      }

      if (activeConn != null) {
        _currentConnection = activeConn;
        _connectionController.add(activeConn);
        final partnerUid = activeConn.getPartnerUid(currentUid);
        if (partnerUid != null) {
          _partnerUser = await _fetchUser(partnerUid);
        }
      } else {
        _currentConnection = null;
        _partnerUser = null;
        _connectionController.add(null);
      }
    } catch (_) {}
  }

  void _loadLocalConnection(String currentUid) {
    _connectionController.add(_currentConnection);
  }

  Future<UserModel?> _fetchUser(String uid) async {
    try {
      if (supabaseService.isConfigured && supabaseService.client != null) {
        final res = await supabaseService.client!
            .from('users')
            .select()
            .eq('id', uid)
            .maybeSingle();

        if (res != null) {
          return UserModel.fromJson(Map<String, dynamic>.from(res));
        }

        // Check if partner created an invite with their display name
        final inviteRes = await supabaseService.client!
            .from('connection_invites')
            .select('creatorName')
            .eq('creatorUid', uid)
            .maybeSingle();
        final name = inviteRes?['creatorName'] as String? ?? 'Partner';
        return UserModel(
          id: uid,
          email: '',
          displayName: name,
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {}
    return UserModel(
      id: uid,
      email: '',
      displayName: 'Partner',
      createdAt: DateTime.now(),
    );
  }

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

    if (supabaseService.isConfigured && supabaseService.client != null) {
      await supabaseService.client!
          .from('connection_invites')
          .insert(invite.toJson());
    }

    return invite;
  }

  /// Look up an invite code and redeem it by creating a mutual connection
  Future<PartnerConnectionModel> redeemInviteCode({
    required String code,
    required UserModel currentUser,
  }) async {
    final cleanCode = code.trim().toUpperCase();

    if (supabaseService.isConfigured && supabaseService.client != null) {
      final res = await supabaseService.client!
          .from('connection_invites')
          .select()
          .eq('code', cleanCode)
          .eq('status', 'pending')
          .maybeSingle();

      if (res == null) {
        throw Exception(
          'Invalid or expired invitation code. Please ask your partner for a new code.',
        );
      }

      final invite = InviteModel.fromJson(Map<String, dynamic>.from(res));

      if (invite.isExpired) {
        await supabaseService.client!
            .from('connection_invites')
            .update({'status': 'expired'}).eq('id', invite.id);
        throw Exception(
          'This invitation code has expired. Please ask your partner to generate a new code.',
        );
      }

      if (invite.creatorUid == currentUser.id) {
        throw Exception(
          'You cannot pair with yourself. Please share this code with your partner.',
        );
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

      await supabaseService.client!
          .from('partner_connections')
          .insert(connection.toJson());

      await supabaseService.client!
          .from('connection_invites')
          .update({'status': 'accepted'}).eq('id', invite.id);

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
      // Local demo mode
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
    if (supabaseService.isConfigured && supabaseService.client != null) {
      try {
        await supabaseService.client!
            .from('partner_connections')
            .update({
              'status': 'disconnected',
              'updatedAt': DateTime.now().toIso8601String(),
            })
            .eq('id', connectionId);
      } catch (_) {}
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
    if (supabaseService.isConfigured && supabaseService.client != null) {
      try {
        await supabaseService.client!
            .from('partner_connections')
            .update({
              'status': 'blocked',
              'blockedByUid': currentUid,
              'updatedAt': DateTime.now().toIso8601String(),
            })
            .eq('id', connectionId);
      } catch (_) {}
    }

    _currentConnection = null;
    _partnerUser = null;
    _connectionController.add(null);
  }

  void stopListening() {
    _connectionSubscription?.cancel();
    _currentConnection = null;
    _partnerUser = null;
    _connectionController.add(null);
  }

  void dispose() {
    _connectionSubscription?.cancel();
    _connectionController.close();
    _pendingRequestsController.close();
  }
}
