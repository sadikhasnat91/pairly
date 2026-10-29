import 'dart:async';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/video_call_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/partner_repository.dart';
import '../../../data/repositories/video_signaling_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/storage_service.dart';
import '../../video_call/views/incoming_call_view.dart';

class MainLayoutController extends GetxController {
  final currentIndex = 0.obs;

  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final PartnerRepository _partnerRepository = Get.find<PartnerRepository>();
  final LocationRepository _locationRepository = Get.find<LocationRepository>();
  final LocationService _locationService = Get.find<LocationService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  final VideoSignalingRepository _signalingRepository =
      Get.find<VideoSignalingRepository>();

  StreamSubscription? _authSub;
  StreamSubscription? _connSub;
  StreamSubscription? _incomingCallSub;
  Timer? _incomingCallPollTimer;

  @override
  void onInit() {
    super.onInit();
    _startListeners();
  }

  void _startListeners() {
    // 1. Reactively track auth changes to bind partner streams, tracking and incoming calls
    _authSub = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _partnerRepository.listenToPartnerConnection(user.id);
        _startGlobalTracking(user.id);
        _listenToIncomingCalls(user.id);
      } else {
        _partnerRepository.stopListening();
        _locationRepository.listenToPartnerLocation(null);
        _locationService.stopTracking();
        _incomingCallSub?.cancel();
        _incomingCallPollTimer?.cancel();
      }
    });

    // 2. Also check if user is already signed in on initial mount
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      _partnerRepository.listenToPartnerConnection(currentUser.id);
      _startGlobalTracking(currentUser.id);
      _listenToIncomingCalls(currentUser.id);
    }

    // 3. Listen to connection stream to update partner live location stream
    _connSub = _partnerRepository.connectionStream.listen((connection) {
      final user = _authRepository.currentUser;
      if (user != null && connection != null && connection.isActive) {
        final partnerUid = connection.getPartnerUid(user.id);
        _locationRepository.listenToPartnerLocation(partnerUid);
      } else {
        _locationRepository.listenToPartnerLocation(null);
      }
    });
  }

  void _listenToIncomingCalls(String uid) {
    _incomingCallSub?.cancel();
    _incomingCallPollTimer?.cancel();

    _incomingCallSub =
        _signalingRepository.listenToIncomingCalls(uid).listen((records) {
      _handleIncomingCallSessions(records);
    });

    // 3-second fallback polling to guarantee incoming calls are received
    _incomingCallPollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) async {
      final records = await _signalingRepository.fetchActiveIncomingCalls(uid);
      if (records.isNotEmpty) {
        _handleIncomingCallSessions(records);
      }
    });
  }

  void _handleIncomingCallSessions(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return;

    final ringingRecords =
        records.where((r) => r['status'] == 'ringing').toList();
    if (ringingRecords.isEmpty) return;

    // Pick latest ringing call
    ringingRecords.sort((a, b) {
      final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
          DateTime(2000);
      final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
          DateTime(2000);
      return bTime.compareTo(aTime);
    });

    final session = VideoCallSessionModel.fromJson(ringingRecords.first);
    // Only trigger if call is fresh (< 60 seconds old)
    if (session.status == VideoCallStatus.ringing &&
        DateTime.now().difference(session.createdAt).inSeconds < 60) {
      final partner = _partnerRepository.partnerUser;
      final callerName = partner?.displayName.isNotEmpty == true
          ? partner!.displayName
          : 'Your Partner';

      // 1. Wake the screen and ring with a high-priority full-screen incoming call heads-up notification
      _notificationService.showIncomingCallNotification(
        callerName: callerName,
        payload: '/incoming-call',
      );

      // 2. Present full-screen Incoming Call View
      if (Get.currentRoute != '/incoming-call' &&
          Get.currentRoute != AppRoutes.videoCall) {
        Get.to(
          () => IncomingCallView(
            session: session,
            callerName: callerName,
            callerPhotoUrl: partner?.photoUrl,
          ),
          routeName: '/incoming-call',
          fullscreenDialog: true,
        );
      }
    }
  }

  void _startGlobalTracking(String uid) {
    if (_storageService.isSharingLocation) {
      _locationService.startTracking(
        onUpdate: (position) {
          _locationRepository.updateCurrentLocation(
            uid: uid,
            position: position,
            isSharing: true,
          );
        },
      );
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _connSub?.cancel();
    _incomingCallSub?.cancel();
    _incomingCallPollTimer?.cancel();
    super.onClose();
  }
}
