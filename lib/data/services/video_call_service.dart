import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool isMuted = false;
  bool isCameraOff = false;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
      {'urls': 'stun:stun.relay.metered.ca:80'},
      {'urls': 'stun:stun.cloudflare.com:3478'},
      {
        'urls': 'turn:standard.relay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:standard.relay.metered.ca:443',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:standard.relay.metered.ca:443?transport=tcp',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  /// Initialize video renderers
  Future<void> initRenderers() async {
    if (!_isInitialized) {
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      _isInitialized = true;
    }
  }

  /// Request runtime permissions for Camera and Microphone
  Future<bool> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  /// Check current permissions
  Future<bool> hasPermissions() async {
    final cameraGranted = await Permission.camera.isGranted;
    final micGranted = await Permission.microphone.isGranted;
    return cameraGranted && micGranted;
  }

  /// Open camera & mic media stream only upon explicit consent
  Future<MediaStream?> startLocalMedia({bool isFrontCamera = true}) async {
    final granted = await requestPermissions();
    if (!granted) {
      debugPrint('[VideoCallService] Permissions denied');
      return null;
    }

    try {
      await initRenderers();

      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': isFrontCamera ? 'user' : 'environment',
          'optional': [
            {'minWidth': '640'},
            {'minHeight': '480'},
            {'minFrameRate': '30'},
          ],
        }
      };

      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localRenderer.srcObject = localStream;
      return localStream;
    } catch (e) {
      debugPrint('[VideoCallService] getUserMedia error: $e');
      return null;
    }
  }

  /// Create WebRTC PeerConnection
  Future<RTCPeerConnection?> createConnection({
    required Function(RTCIceCandidate candidate) onIceCandidate,
    required Function(MediaStream stream) onRemoteStream,
    Function(RTCPeerConnectionState state)? onConnectionStateChange,
  }) async {
    try {
      await initRenderers();
      peerConnection = await createPeerConnection(_iceServers, _config);

      // Add local tracks to peer connection
      if (localStream != null) {
        for (final track in localStream!.getTracks()) {
          await peerConnection!.addTrack(track, localStream!);
        }
      }

      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        onIceCandidate(candidate);
      };

      peerConnection!.onTrack = (RTCTrackEvent event) {
        debugPrint('[VideoCallService] onTrack received: ${event.streams.length} streams, track=${event.track.kind}');
        if (event.streams.isNotEmpty) {
          remoteStream = event.streams[0];
          remoteRenderer.srcObject = remoteStream;
          onRemoteStream(remoteStream!);
        }
      };

      peerConnection!.onAddStream = (MediaStream stream) {
        debugPrint('[VideoCallService] onAddStream received');
        remoteStream = stream;
        remoteRenderer.srcObject = remoteStream;
        onRemoteStream(stream);
      };

      peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        debugPrint('[VideoCallService] PeerConnectionState: $state');
        onConnectionStateChange?.call(state);
      };

      peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        debugPrint('[VideoCallService] IceConnectionState: $state');
      };

      return peerConnection;
    } catch (e) {
      debugPrint('[VideoCallService] createConnection error: $e');
      return null;
    }
  }

  /// Create SDP Offer (Caller)
  Future<RTCSessionDescription?> createOffer() async {
    if (peerConnection == null) return null;
    try {
      final desc = await peerConnection!.createOffer({
        'offerToReceiveVideo': 1,
        'offerToReceiveAudio': 1,
      });
      await peerConnection!.setLocalDescription(desc);
      return desc;
    } catch (e) {
      debugPrint('[VideoCallService] createOffer error: $e');
      return null;
    }
  }

  /// Create SDP Answer (Receiver)
  Future<RTCSessionDescription?> createAnswer(Map<String, dynamic> offer) async {
    if (peerConnection == null) return null;
    try {
      final remoteDesc = RTCSessionDescription(
        offer['sdp'] as String?,
        offer['type'] as String?,
      );
      await peerConnection!.setRemoteDescription(remoteDesc);

      final answer = await peerConnection!.createAnswer({
        'offerToReceiveVideo': 1,
        'offerToReceiveAudio': 1,
      });
      await peerConnection!.setLocalDescription(answer);
      return answer;
    } catch (e) {
      debugPrint('[VideoCallService] createAnswer error: $e');
      return null;
    }
  }

  /// Set remote answer on caller side
  Future<bool> setRemoteAnswer(Map<String, dynamic> answer) async {
    if (peerConnection == null) return false;
    try {
      final desc = RTCSessionDescription(
        answer['sdp'] as String?,
        answer['type'] as String?,
      );
      await peerConnection!.setRemoteDescription(desc);
      return true;
    } catch (e) {
      debugPrint('[VideoCallService] setRemoteAnswer error: $e');
      return false;
    }
  }

  /// Add remote ICE candidate
  Future<void> addRemoteIceCandidate(Map<String, dynamic> candidateData) async {
    if (peerConnection == null) return;
    try {
      final candidate = RTCIceCandidate(
        candidateData['candidate'] as String?,
        candidateData['sdpMid'] as String?,
        candidateData['sdpMLineIndex'] as int?,
      );
      await peerConnection!.addCandidate(candidate);
    } catch (e) {
      debugPrint('[VideoCallService] addRemoteIceCandidate error: $e');
    }
  }

  /// Toggle Microphone
  void toggleMute() {
    if (localStream != null) {
      final audioTracks = localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final current = audioTracks[0].enabled;
        audioTracks[0].enabled = !current;
        isMuted = !current;
      }
    }
  }

  /// Toggle Camera Video
  void toggleCamera() {
    if (localStream != null) {
      final videoTracks = localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final current = videoTracks[0].enabled;
        videoTracks[0].enabled = !current;
        isCameraOff = !current;
      }
    }
  }

  /// Flip front/back camera
  Future<void> switchCamera() async {
    if (localStream != null) {
      final videoTracks = localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks[0]);
      }
    }
  }

  /// Stop and release all camera, microphone and peer connections immediately
  Future<void> stopAndCleanUp() async {
    try {
      // 1. Release hardware media tracks
      if (localStream != null) {
        for (final track in localStream!.getTracks()) {
          track.stop();
        }
        await localStream?.dispose();
        localStream = null;
      }

      if (remoteStream != null) {
        for (final track in remoteStream!.getTracks()) {
          track.stop();
        }
        await remoteStream?.dispose();
        remoteStream = null;
      }

      // 2. Clear renderers
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;

      // 3. Close peer connection
      await peerConnection?.close();
      await peerConnection?.dispose();
      peerConnection = null;

      isMuted = false;
      isCameraOff = false;
      debugPrint('[VideoCallService] Hardware & WebRTC safely released');
    } catch (e) {
      debugPrint('[VideoCallService] CleanUp error: $e');
    }
  }

  void dispose() {
    stopAndCleanUp();
    localRenderer.dispose();
    remoteRenderer.dispose();
    _isInitialized = false;
  }
}

