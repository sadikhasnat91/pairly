enum VideoCallStatus { ringing, accepted, declined, ended, missed }

class VideoCallSessionModel {
  final String id;
  final String connectionId;
  final String callerId;
  final String receiverId;
  final VideoCallStatus status;
  final Map<String, dynamic>? sdpOffer;
  final Map<String, dynamic>? sdpAnswer;
  final List<dynamic> callerCandidates;
  final List<dynamic> receiverCandidates;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VideoCallSessionModel({
    required this.id,
    required this.connectionId,
    required this.callerId,
    required this.receiverId,
    required this.status,
    this.sdpOffer,
    this.sdpAnswer,
    this.callerCandidates = const [],
    this.receiverCandidates = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connection_id': connectionId,
      'caller_id': callerId,
      'receiver_id': receiverId,
      'status': status.name,
      if (sdpOffer != null) 'sdp_offer': sdpOffer,
      if (sdpAnswer != null) 'sdp_answer': sdpAnswer,
      'caller_candidates': callerCandidates,
      'receiver_candidates': receiverCandidates,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VideoCallSessionModel.fromJson(Map<String, dynamic> json) {
    VideoCallStatus parsedStatus = VideoCallStatus.ringing;
    final statusStr = json['status'] as String? ?? 'ringing';
    for (final s in VideoCallStatus.values) {
      if (s.name == statusStr) {
        parsedStatus = s;
        break;
      }
    }

    return VideoCallSessionModel(
      id: json['id'] as String? ?? '',
      connectionId: json['connection_id'] as String? ?? '',
      callerId: json['caller_id'] as String? ?? '',
      receiverId: json['receiver_id'] as String? ?? '',
      status: parsedStatus,
      sdpOffer: json['sdp_offer'] as Map<String, dynamic>?,
      sdpAnswer: json['sdp_answer'] as Map<String, dynamic>?,
      callerCandidates: json['caller_candidates'] as List<dynamic>? ?? const [],
      receiverCandidates: json['receiver_candidates'] as List<dynamic>? ?? const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  VideoCallSessionModel copyWith({
    String? id,
    String? connectionId,
    String? callerId,
    String? receiverId,
    VideoCallStatus? status,
    Map<String, dynamic>? sdpOffer,
    Map<String, dynamic>? sdpAnswer,
    List<dynamic>? callerCandidates,
    List<dynamic>? receiverCandidates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoCallSessionModel(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      sdpOffer: sdpOffer ?? this.sdpOffer,
      sdpAnswer: sdpAnswer ?? this.sdpAnswer,
      callerCandidates: callerCandidates ?? this.callerCandidates,
      receiverCandidates: receiverCandidates ?? this.receiverCandidates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

