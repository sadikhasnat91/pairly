class InviteModel {
  final String id;
  final String code;
  final String creatorUid;
  final String creatorName;
  final DateTime expiresAt;
  final String status; // 'pending', 'accepted', 'expired'
  final DateTime createdAt;

  const InviteModel({
    required this.id,
    required this.code,
    required this.creatorUid,
    required this.creatorName,
    required this.expiresAt,
    this.status = 'pending',
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && status == 'pending';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'expiresAt': expiresAt.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InviteModel.fromJson(Map<String, dynamic> json) {
    return InviteModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      creatorUid: json['creatorUid'] as String? ?? '',
      creatorName: json['creatorName'] as String? ?? 'Partner',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
