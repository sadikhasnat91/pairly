enum ConnectionStatus { active, pending, disconnected, blocked }

class PartnerConnectionModel {
  final String id;
  final List<String> memberUids;
  final ConnectionStatus status;
  final String? blockedByUid;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? updatedAt;

  const PartnerConnectionModel({
    required this.id,
    required this.memberUids,
    required this.status,
    this.blockedByUid,
    required this.createdAt,
    this.acceptedAt,
    this.updatedAt,
  });

  bool get isActive => status == ConnectionStatus.active;
  bool get isBlocked => status == ConnectionStatus.blocked;
  bool get isDisconnected => status == ConnectionStatus.disconnected;

  String? getPartnerUid(String currentUid) {
    if (!memberUids.contains(currentUid)) return null;
    for (final uid in memberUids) {
      if (uid != currentUid) return uid;
    }
    return null;
  }

  PartnerConnectionModel copyWith({
    String? id,
    List<String>? memberUids,
    ConnectionStatus? status,
    String? blockedByUid,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) {
    return PartnerConnectionModel(
      id: id ?? this.id,
      memberUids: memberUids ?? this.memberUids,
      status: status ?? this.status,
      blockedByUid: blockedByUid ?? this.blockedByUid,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberUids': memberUids,
      'status': status.name,
      'blockedByUid': blockedByUid,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory PartnerConnectionModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    ConnectionStatus status;
    switch (statusStr) {
      case 'active':
        status = ConnectionStatus.active;
        break;
      case 'blocked':
        status = ConnectionStatus.blocked;
        break;
      case 'disconnected':
        status = ConnectionStatus.disconnected;
        break;
      default:
        status = ConnectionStatus.pending;
    }

    final membersRaw = json['memberUids'];
    List<String> members = [];
    if (membersRaw is List) {
      members = membersRaw.map((e) => e.toString()).toList();
    }

    return PartnerConnectionModel(
      id: json['id'] as String? ?? '',
      memberUids: members,
      status: status,
      blockedByUid: json['blockedByUid'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.tryParse(json['acceptedAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
