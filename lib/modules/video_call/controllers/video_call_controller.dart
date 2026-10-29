import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/video_call_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/video_signaling_repository.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/video_call_service.dart';

class VideoCallController extends GetxController {
  final VideoCallService videoService = Get.find<VideoCallService>();
  final VideoSignalingRepository _signalingRepo =
      Get.find<VideoSignalingRepository>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final callStatus = Rx<VideoCallStatus>(VideoCallStatus.ringing);
  final isCaller = true.obs;
  final isConnected = false.obs;
  final isLocalReady = false.obs;
  final isRemoteReady = false.obs;
  final isMuted = false.obs;
  final isCameraOff = false.obs;
  final partnerName = 'Partner'.obs;

  final activeSession = Rxn<VideoCallSessionModel>();

  StreamSubscription? _sessionSub;
  Timer? _durationTimer;
  Timer? _sessionPollTimer;
  final Set<String> _processedCandidates = {};
  int _secondsElapsed = 0;
  final callDurationText = '00:00'.obs;

  RTCVideoRenderer get localRenderer => videoService.localRenderer;
  RTCVideoRenderer get remoteRenderer => videoService.remoteRenderer;

  @override
  void onInit() {
    super.onInit();
    videoService.initRenderers();
  }

  /// Caller starts a consent-based live video request
  Future<void> initiateCall({
    required String partnerId,
    required String connectionId,
    required String partnerDisplayName,
  }) async {
    isCaller.value = true;
    partnerName.value = partnerDisplayName;
    callStatus.value = VideoCallStatus.ringing;
    isConnected.value = false;

    // 1. Initialize local media preview
    final stream = await videoService.startLocalMedia();
    if (stream == null) {
      Get.snackbar(
        'Permissions Needed',
        'Camera and Microphone permissions are required to start video sharing.',
        backgroundColor: AppColors.errorAccent,
        colorText: Colors.white,
      );
      Get.back();
      return;
    }
    isLocalReady.value = true;

    // 2. Create WebRTC PeerConnection
    await videoService.createConnection(
      onIceCandidate: (candidate) {
        if (activeSession.value?.id != null) {
          _signalingRepo.addIceCandidate(
            sessionId: activeSession.value!.id,
            candidate: {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
            isCaller: true,
          );
        }
      },
      onRemoteStream: (stream) {
        isRemoteReady.value = true;
        isConnected.value = true;
      },
    );

    // 3. Create SDP Offer
    final offerDesc = await videoService.createOffer();
    if (offerDesc == null) return;

    final currentUser = _authRepo.currentUser;
    if (currentUser == null) return;

    // 4. Save call session in Supabase to ring partner's device
    final session = await _signalingRepo.createCallSession(
      connectionId: connectionId,
      callerId: currentUser.id,
      receiverId: partnerId,
      sdpOffer: {'sdp': offerDesc.sdp, 'type': offerDesc.type},
    );

    if (session == null) {
      Get.snackbar('Connection Error', 'Failed to connect to video server.');
      await endCall();
      return;
    }

    activeSession.value = session;
    _listenToSessionUpdates(session.id);
  }

  /// Receiver explicitly accepts the incoming live video request (Consent Given)
  Future<void> acceptCall(VideoCallSessionModel session) async {
    _notificationService.cancelIncomingCallNotification();
    isCaller.value = false;
    activeSession.value = session;
    callStatus.value = VideoCallStatus.accepted;

    // 1. Start local camera & microphone with user consent
    final stream = await videoService.startLocalMedia();
    if (stream == null) {
      Get.snackbar(
        'Permissions Needed',
        'Camera and Microphone permissions are required to share video.',
        backgroundColor: AppColors.errorAccent,
        colorText: Colors.white,
      );
      await declineCall(session.id);
      return;
    }
    isLocalReady.value = true;

    // 2. Create PeerConnection
    await videoService.createConnection(
      onIceCandidate: (candidate) {
        _signalingRepo.addIceCandidate(
          sessionId: session.id,
          candidate: {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
          isCaller: false,
        );
      },
      onRemoteStream: (stream) {
        isRemoteReady.value = true;
        isConnected.value = true;
      },
    );

    // 3. Set remote offer & send SDP Answer
    if (session.sdpOffer != null) {
      final answerDesc = await videoService.createAnswer(session.sdpOffer!);
      if (answerDesc != null) {
        await _signalingRepo.sendAnswer(
          sessionId: session.id,
          sdpAnswer: {'sdp': answerDesc.sdp, 'type': answerDesc.type},
        );
      }
    }

    // 4. Add existing caller candidates
    for (final c in session.callerCandidates) {
      if (c is Map<String, dynamic>) {
        await videoService.addRemoteIceCandidate(c);
      }
    }

    _listenToSessionUpdates(session.id);
    _startDurationTimer();
  }

  /// Receiver declines incoming request (Consent Denied)
  Future<void> declineCall(String sessionId) async {
    _notificationService.cancelIncomingCallNotification();
    await _signalingRepo.updateCallStatus(
      sessionId: sessionId,
      status: VideoCallStatus.declined,
    );
    await videoService.stopAndCleanUp();
    Get.back();
  }

  /// Listen for signaling updates during session
  void _listenToSessionUpdates(String sessionId) {
    _sessionSub?.cancel();
    _sessionPollTimer?.cancel();
    _processedCandidates.clear();

    _sessionSub = _signalingRepo.listenToSession(sessionId).listen(
      (records) async {
        if (records.isEmpty) return;
        final updated = VideoCallSessionModel.fromJson(records.first);
        await _handleSessionUpdate(updated);
      },
    );

    // Active 1-second polling fallback: ensures caller immediately connects when partner taps Accept,
    // even if mobile network or carrier NAT drops Supabase WebSocket update frames.
    _sessionPollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final sessionMap = await _signalingRepo.fetchSession(sessionId);
      if (sessionMap != null) {
        final updated = VideoCallSessionModel.fromJson(sessionMap);
        await _handleSessionUpdate(updated);
      }
    });
  }

  Future<void> _handleSessionUpdate(VideoCallSessionModel updated) async {
    activeSession.value = updated;
    callStatus.value = updated.status;

    if (updated.status == VideoCallStatus.ended ||
        updated.status == VideoCallStatus.declined) {
      Get.snackbar(
        'Session Ended',
        updated.status == VideoCallStatus.declined
            ? 'Partner declined the video session.'
            : 'Live video session disconnected.',
        backgroundColor: AppColors.deepRomanticPlum,
        colorText: Colors.white,
      );
      await _cleanupSession();
      Get.back();
      return;
    }

    // Caller receives SDP Answer from receiver
    if (isCaller.value &&
        updated.status == VideoCallStatus.accepted &&
        updated.sdpAnswer != null &&
        !isConnected.value) {
      debugPrint('[VideoCallController] Received SDP Answer! Connecting WebRTC...');
      await videoService.setRemoteAnswer(updated.sdpAnswer!);
      isConnected.value = true;
      _startDurationTimer();
    }

    // Process remote ICE candidates (only after remote description is in place)
    if (isCaller.value ? isConnected.value : true) {
      final remoteCandidates =
          isCaller.value ? updated.receiverCandidates : updated.callerCandidates;
      for (final cand in remoteCandidates) {
        if (cand is Map<String, dynamic>) {
          final candKey = '${cand['candidate']}_${cand['sdpMid']}_${cand['sdpMLineIndex']}';
          if (!_processedCandidates.contains(candKey)) {
            _processedCandidates.add(candKey);
            await videoService.addRemoteIceCandidate(cand);
          }
        }
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _secondsElapsed = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsElapsed++;
      final mins = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
      final secs = (_secondsElapsed % 60).toString().padLeft(2, '0');
      callDurationText.value = '$mins:$secs';
    });
  }

  /// Toggle Audio Mute
  void toggleMute() {
    videoService.toggleMute();
    isMuted.value = videoService.isMuted;
  }

  /// Toggle Camera Video
  void toggleCamera() {
    videoService.toggleCamera();
    isCameraOff.value = videoService.isCameraOff;
  }

  /// Switch Front/Back camera
  Future<void> switchCamera() async {
    await videoService.switchCamera();
  }

  /// End Call and safely release hardware immediately
  Future<void> endCall() async {
    final session = activeSession.value;
    if (session != null) {
      await _signalingRepo.updateCallStatus(
        sessionId: session.id,
        status: VideoCallStatus.ended,
      );
    }
    await _cleanupSession();
    Get.back();
  }

  Future<void> _cleanupSession() async {
    _notificationService.cancelIncomingCallNotification();
    _durationTimer?.cancel();
    _sessionPollTimer?.cancel();
    _sessionSub?.cancel();
    _processedCandidates.clear();
    await videoService.stopAndCleanUp();
    isLocalReady.value = false;
    isRemoteReady.value = false;
    isConnected.value = false;
    activeSession.value = null;
  }

  @override
  void onClose() {
    _cleanupSession();
    super.onClose();
  }
}

